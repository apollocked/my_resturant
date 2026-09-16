-- ============================================================
-- Security hardening v2 — apply to the live Supabase project
-- Run once in the SQL editor. Idempotent (safe to re-run).
-- Fixes found in the audit of the living database:
--   1. branches / items / stock_movements had RLS policies with
--      USING(true) / WITH CHECK(true) -> ANY authenticated user
--      (i.e. every restaurant tenant) could read, insert, update
--      and delete ALL rows. These tables belong to the platform
--      admin side, so all direct access is now gated on is_admin().
--   2. record_stock_movement / branch_stock_report are SECURITY
--      DEFINER with no auth check -> now require is_admin(); anon
--      EXECUTE revoked.
--   3. is_admin() keyed only on a hardcoded email. If the platform
--      admin ever changes their email via the app, every admin RPC
--      would lock out. Now the admin user is flagged in
--      raw_app_meta_data (platform_admin) so is_admin() survives
--      email changes while the email remains as a fallback.
--   4. profiles.email goes stale when auth.users.email is changed
--      by the account page. New trigger syncs it on email update.
--   5. anon granted EXECUTE on is_activated()/passcodes_configured()
--      SECURITY DEFINER functions; tightened to authenticated.
--   6. search_path pinned on the remaining SECURITY DEFINER fns.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Lock the shared admin stock tables behind is_admin()
-- These tables live on the same Supabase instance as the admin
-- side; guard them so no restaurant tenant can touch them.
-- Wrapped in a DO block so the file is safe on projects where the
-- admin tables do not (yet) exist.
-- ------------------------------------------------------------
DO $$
BEGIN
  IF to_regclass('public.branches') IS NOT NULL THEN
    DROP POLICY IF EXISTS "branches_rw_authenticated" ON public.branches;
    DROP POLICY IF EXISTS "admin manages branches" ON public.branches;
    CREATE POLICY "admin manages branches" ON public.branches
      FOR ALL TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
    REVOKE ALL ON TABLE public.branches FROM anon;
  END IF;

  IF to_regclass('public.items') IS NOT NULL THEN
    DROP POLICY IF EXISTS "items_rw_authenticated" ON public.items;
    DROP POLICY IF EXISTS "admin manages items" ON public.items;
    CREATE POLICY "admin manages items" ON public.items
      FOR ALL TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
    REVOKE ALL ON TABLE public.items FROM anon;
  END IF;

  IF to_regclass('public.stock_movements') IS NOT NULL THEN
    DROP POLICY IF EXISTS "authenticated insert movements" ON public.stock_movements;
    DROP POLICY IF EXISTS "authenticated select movements" ON public.stock_movements;
    DROP POLICY IF EXISTS "admin manages stock movements" ON public.stock_movements;
    CREATE POLICY "admin manages stock movements" ON public.stock_movements
      FOR ALL TO authenticated
      USING (public.is_admin())
      WITH CHECK (public.is_admin());
    REVOKE ALL ON TABLE public.stock_movements FROM anon;
  END IF;
END $$;

-- ------------------------------------------------------------
-- 2. Gate the stock RPCs on is_admin()
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.record_stock_movement(p_item_id integer, p_movement_type text, p_quantity integer, p_note text DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_branch_id integer;
  v_user text;
  v_new_qty integer;
  v_item_qty integer;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Forbidden';
  END IF;
  SELECT branch_id, quantity INTO v_branch_id, v_item_qty
  FROM items WHERE id = p_item_id;
  IF v_branch_id IS NULL THEN
    RAISE EXCEPTION 'Item not found';
  END IF;

  IF p_movement_type NOT IN ('IN', 'OUT', 'DAMAGE') THEN
    RAISE EXCEPTION 'Invalid movement type';
  END IF;

  IF p_movement_type = 'IN' THEN
    v_new_qty := v_item_qty + p_quantity;
  ELSE
    v_new_qty := v_item_qty - p_quantity;
  END IF;

  UPDATE items SET quantity = v_new_qty WHERE id = p_item_id;

  v_user := nullif(auth.jwt() ->> 'email', '');

  INSERT INTO stock_movements (item_id, branch_id, movement_type, quantity, note, user_email)
  VALUES (p_item_id, v_branch_id, p_movement_type, p_quantity, p_note, v_user);

  RETURN v_new_qty;
END;
$$;

CREATE OR REPLACE FUNCTION public.branch_stock_report(p_branch_id integer)
RETURNS json
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT json_build_object(
    'total_items',    count(*),
    'total_units',    coalesce(sum(quantity), 0),
    'stock_value',    coalesce(sum(coalesce(quantity, 0) * coalesce(price, 0)), 0)::numeric::text,
    'in_stock',       count(*) FILTER (WHERE quantity > 0),
    'zero_stock',     count(*) FILTER (WHERE quantity = 0),
    'minus_stock',    count(*) FILTER (WHERE quantity < 0),
    'low_stock',      count(*) FILTER (WHERE quantity > 0 AND quantity <= 5),
    'total_in',       coalesce((SELECT sum(quantity) FROM stock_movements WHERE branch_id = p_branch_id AND movement_type = 'IN'), 0),
    'total_out',      coalesce((SELECT sum(quantity) FROM stock_movements WHERE branch_id = p_branch_id AND movement_type = 'OUT'), 0),
    'total_damage',   coalesce((SELECT sum(quantity) FROM stock_movements WHERE branch_id = p_branch_id AND movement_type = 'DAMAGE'), 0)
  )
  FROM items
  WHERE branch_id = p_branch_id;
$$;

REVOKE EXECUTE ON FUNCTION public.record_stock_movement(integer, text, integer, text) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.record_stock_movement(integer, text, integer, text) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.branch_stock_report(integer) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.branch_stock_report(integer) TO authenticated;

-- ------------------------------------------------------------
-- 3. is_admin() keyed on app metadata, email as fallback
-- ------------------------------------------------------------
UPDATE auth.users
SET raw_app_meta_data = COALESCE(raw_app_meta_data::text, '{}')::jsonb || '{"platform_admin": true}'::jsonb
WHERE email = 'hamabarznji1990@gmail.com'
  AND NOT COALESCE(raw_app_meta_data->>'platform_admin', '') = 'true';

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid()
      AND (
        COALESCE(u.raw_app_meta_data->>'platform_admin', '') = 'true'
        OR u.email = 'hamabarznji1990@gmail.com'
      )
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- ------------------------------------------------------------
-- 4. Sync profiles.email whenever auth.users.email changes
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_profile_email()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  UPDATE public.profiles SET email = NEW.email WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_email_update ON auth.users;
CREATE TRIGGER on_auth_user_email_update
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_profile_email();

REVOKE EXECUTE ON FUNCTION public.sync_profile_email() FROM PUBLIC, anon, authenticated;

-- ------------------------------------------------------------
-- 5. Tighten anon EXECUTE on read-only SECURITY DEFINER RPCs
--    (they only ever return booleans about the caller, so anon
--    has no business calling them).
-- ------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.is_activated() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.is_activated() TO authenticated;
REVOKE EXECUTE ON FUNCTION public.passcodes_configured() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.passcodes_configured() TO authenticated;