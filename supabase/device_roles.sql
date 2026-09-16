-- ============================================================
-- Multi-device roles
-- ============================================================
-- Problem: roles lived on `profiles.role` (one value per account), so the
-- second device to login overwrote the first device's role and RLS switched
-- everyone to the same role.
--
-- Fix: each install sends a stable random `x-device-id` header on every
-- request. Roles are stored per (user_id, device_id) in `device_sessions`.
--   * current_role()  returns THIS device's role (fallback: legacy headerless
--     clients keep reading profiles.role so the transition is seamless).
--   * set_role()      upserts THIS device's role.
--   * profiles.role   is still written as a mirror for legacy reads, but is no
--     longer the source of truth for RLS.
-- `device_sessions` has no grants to anon/client roles (RLS on, no policies) –
-- only SECURITY DEFINER functions touch it.
-- Idempotent; safe to re-run.
-- ============================================================

-- Device role table -------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.device_sessions (
  user_id    UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  device_id  TEXT        NOT NULL,
  role       TEXT        NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, device_id)
);

ALTER TABLE public.device_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.device_sessions FROM anon, authenticated;

-- Which device is making this request -------------------------------------
CREATE OR REPLACE FUNCTION public.current_device_id()
RETURNS TEXT
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT NULLIF(
    (SELECT value FROM jsonb_each_text(current_setting('request.headers', true)::jsonb)
     WHERE lower(key) = 'x-device-id' LIMIT 1),
    '');
$$;

-- Device-aware role lookup ------------------------------------------------
CREATE OR REPLACE FUNCTION public.current_role()
RETURNS TEXT
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT CASE
    WHEN public.current_device_id() IS NULL OR public.current_device_id() = '' THEN
      -- Legacy client (no device header): keep old single-role behaviour.
      coalesce((SELECT role FROM public.profiles WHERE id = auth.uid()), '')
    ELSE
      coalesce(
        (SELECT ds.role FROM public.device_sessions ds
         WHERE ds.user_id = auth.uid() AND ds.device_id = public.current_device_id()),
        '')
  END;
$$;

-- Device-aware role switch ------------------------------------------------
DROP FUNCTION IF EXISTS public.set_role(text, text);

CREATE OR REPLACE FUNCTION public.set_role(p_role TEXT, p_pin TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  dev text := public.current_device_id();
  cur text;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF p_role IS NOT NULL AND p_role NOT IN ('waiter', 'kitchen', 'admin') THEN
    RAISE EXCEPTION 'Invalid role';
  END IF;

  -- Legacy client without a device header: keep old single-role behaviour.
  IF dev IS NULL OR dev = '' THEN
    SELECT role INTO cur FROM public.profiles WHERE id = uid;
    IF p_role IS NULL OR cur = 'admin' THEN
      UPDATE public.profiles SET role = p_role WHERE id = uid;
      RETURN;
    END IF;
    IF p_pin IS NULL OR NOT public.verify_pin(p_role, p_pin) THEN
      RAISE EXCEPTION 'Forbidden';
    END IF;
    UPDATE public.profiles SET role = p_role WHERE id = uid;
    RETURN;
  END IF;

  SELECT coalesce((SELECT role FROM public.device_sessions
                   WHERE user_id = uid AND device_id = dev), '')
  INTO cur;

  -- Logout / exit role on this device only.
  IF p_role IS NULL THEN
    DELETE FROM public.device_sessions WHERE user_id = uid AND device_id = dev;
    RETURN;
  END IF;

  -- Admin devices switch roles freely; every other switch needs the PIN of
  -- the target role (verified server-side).
  IF cur <> 'admin' THEN
    IF p_pin IS NULL OR NOT public.verify_pin(p_role, p_pin) THEN
      RAISE EXCEPTION 'Forbidden';
    END IF;
  END IF;

  INSERT INTO public.device_sessions (user_id, device_id, role)
  VALUES (uid, dev, p_role)
  ON CONFLICT (user_id, device_id) DO UPDATE SET role = EXCLUDED.role, updated_at = now();

  -- Mirror to profiles.role for legacy reads / admin dashboards. Not used by
  -- RLS anymore (current_role() is device-aware above).
  UPDATE public.profiles SET role = p_role WHERE id = uid;
END;
$$;

-- Grants ------------------------------------------------------------------
-- current_role() is now a client RPC (per-device role read).
REVOKE EXECUTE ON FUNCTION public.current_device_id() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.current_role() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.current_role() TO authenticated;
REVOKE EXECUTE ON FUNCTION public.set_role(TEXT, TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.set_role(TEXT, TEXT) TO authenticated;