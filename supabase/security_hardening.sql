-- ============================================================
-- Security hardening — apply to the live Supabase project
-- Run this once in the SQL editor. Idempotent (safe to re-run).
-- Fixes:
--   1. profiles: clients can no longer UPDATE role/activated/pins directly
--   2. PINs: hashed server-side with bcrypt + brute-force rate limit
--   3. promo_codes: admin-only read/mint/delete; atomic claim with expiry
--   4. profiles removed from realtime publication
--   5. misc: search_path on SECURITY DEFINER fns, length caps
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ------------------------------------------------------------
-- 1. Profiles — read-only for clients, writes via RPCs only
-- ------------------------------------------------------------
DROP POLICY IF EXISTS "Users can manage own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;

CREATE POLICY "Users can read own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = id);

REVOKE SELECT (pin_waiter, pin_kitchen, pin_admin) ON public.profiles FROM anon, authenticated;

-- ------------------------------------------------------------
-- 2. PIN attempts table (rate limiting)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.pin_attempts (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  success BOOLEAN NOT NULL,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.pin_attempts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.pin_attempts FROM anon, authenticated;

-- ------------------------------------------------------------
-- 3. Profile RPCs
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.save_passcodes(p_waiter TEXT, p_kitchen TEXT, p_admin TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF p_waiter !~ '^\d{4,6}$' OR p_kitchen !~ '^\d{4,6}$' OR p_admin !~ '^\d{4,6}$' THEN
    RAISE EXCEPTION 'PIN must be 4 to 6 digits';
  END IF;
  UPDATE public.profiles
  SET pin_waiter = crypt(p_waiter, gen_salt('bf')),
      pin_kitchen = crypt(p_kitchen, gen_salt('bf')),
      pin_admin = crypt(p_admin, gen_salt('bf'))
  WHERE id = uid;
END;
$$;

CREATE OR REPLACE FUNCTION public.change_passcode(p_role TEXT, p_pin TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF p_role NOT IN ('waiter', 'kitchen', 'admin') THEN RAISE EXCEPTION 'Invalid role'; END IF;
  IF p_pin !~ '^\d{4,6}$' THEN RAISE EXCEPTION 'PIN must be 4 to 6 digits'; END IF;
  CASE p_role
    WHEN 'waiter'  THEN UPDATE public.profiles SET pin_waiter  = crypt(p_pin, gen_salt('bf')) WHERE id = uid;
    WHEN 'kitchen' THEN UPDATE public.profiles SET pin_kitchen = crypt(p_pin, gen_salt('bf')) WHERE id = uid;
    WHEN 'admin'   THEN UPDATE public.profiles SET pin_admin   = crypt(p_pin, gen_salt('bf')) WHERE id = uid;
  END CASE;
END;
$$;

CREATE OR REPLACE FUNCTION public.verify_pin(p_role TEXT, p_pin TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  uid uuid := auth.uid();
  stored TEXT;
  recent_failures INT;
BEGIN
  IF uid IS NULL THEN RETURN FALSE; END IF;
  IF p_role NOT IN ('waiter', 'kitchen', 'admin') THEN RETURN FALSE; END IF;
  IF p_pin IS NULL OR length(p_pin) > 6 OR p_pin !~ '^\d+$' THEN RETURN FALSE; END IF;

  SELECT COUNT(*) INTO recent_failures
  FROM public.pin_attempts
  WHERE user_id = uid AND success = FALSE AND attempted_at > NOW() - INTERVAL '5 minutes';
  IF recent_failures >= 5 THEN
    RETURN FALSE;
  END IF;

  SELECT CASE p_role
    WHEN 'waiter'  THEN pin_waiter
    WHEN 'kitchen' THEN pin_kitchen
    WHEN 'admin'   THEN pin_admin
  END INTO stored
  FROM public.profiles
  WHERE id = uid;

  IF stored IS NULL OR stored = '' THEN
    RETURN FALSE;
  END IF;

  IF crypt(p_pin, stored) = stored THEN
    RETURN TRUE;
  END IF;

  INSERT INTO public.pin_attempts (user_id, success) VALUES (uid, FALSE);
  RETURN FALSE;
END;
$$;

CREATE OR REPLACE FUNCTION public.passcodes_configured()
RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT pin_waiter <> '' AND pin_kitchen <> '' AND pin_admin <> ''
     FROM public.profiles WHERE id = auth.uid()),
    FALSE
  );
$$;

CREATE OR REPLACE FUNCTION public.set_role(p_role TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF p_role IS NOT NULL AND p_role NOT IN ('waiter', 'kitchen', 'admin') THEN
    RAISE EXCEPTION 'Invalid role';
  END IF;
  UPDATE public.profiles SET role = p_role WHERE id = uid;
END;
$$;

-- ------------------------------------------------------------
-- IMPORTANT: existing PINs were stored as unsalted SHA-256 hashes,
-- which bcrypt's crypt() cannot verify. Clear them so every owner
-- re-sets their passcodes from the setup page (app will show setup
-- because passcodes_configured() now returns false).
-- ------------------------------------------------------------
UPDATE public.profiles SET pin_waiter = '', pin_kitchen = '', pin_admin = '';

-- ------------------------------------------------------------
-- 4. Promo codes — admin only, atomic claim with expiry
-- ------------------------------------------------------------
ALTER TABLE public.promo_codes ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;
ALTER TABLE public.promo_codes ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid()
      AND u.email = 'hamabarznji1990@gmail.com'
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

DROP POLICY IF EXISTS "Authenticated users can read all promo codes" ON public.promo_codes;
DROP POLICY IF EXISTS "Authenticated users can insert promo codes" ON public.promo_codes;
DROP POLICY IF EXISTS "Authenticated users can delete unused promo codes" ON public.promo_codes;

CREATE POLICY "Only admin can read promo codes"
  ON public.promo_codes FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Only admin can create promo codes"
  ON public.promo_codes FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Only admin can delete unused promo codes"
  ON public.promo_codes FOR DELETE
  TO authenticated
  USING (public.is_admin() AND used_by IS NULL);

CREATE OR REPLACE FUNCTION public.claim_promo_code(promo_code TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  updated INT;
  already_activated BOOLEAN;
BEGIN
  IF uid IS NULL OR promo_code IS NULL OR length(promo_code) < 4 THEN
    RETURN FALSE;
  END IF;

  SELECT activated INTO already_activated FROM public.profiles WHERE id = uid;
  IF already_activated THEN
    RETURN FALSE;
  END IF;

  UPDATE public.promo_codes
  SET used_by = uid, used_at = NOW()
  WHERE code = upper(promo_code)
    AND used_by IS NULL
    AND (expires_at IS NULL OR expires_at > NOW());
  GET DIAGNOSTICS updated = ROW_COUNT;

  IF updated = 0 THEN
    RETURN FALSE;
  END IF;

  UPDATE public.profiles SET activated = TRUE WHERE id = uid;
  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_activated()
RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT COALESCE((SELECT activated FROM public.profiles WHERE id = auth.uid()), FALSE);
$$;

CREATE OR REPLACE FUNCTION public.check_restaurant_limit()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  IF (SELECT count(*) FROM public.profiles) >= 20 THEN
    RAISE EXCEPTION 'Maximum number of restaurants (20) reached.';
  END IF;
  RETURN NEW;
END;
$$;

-- ------------------------------------------------------------
-- 5. Realtime — stop streaming profiles (contains hashes/email)
-- ------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'profiles'
  ) THEN
    ALTER PUBLICATION supabase_realtime DROP TABLE public.profiles;
  END IF;
END $$;

-- ------------------------------------------------------------
-- 6. Length caps (server-side)
-- ------------------------------------------------------------
ALTER TABLE public.recipes DROP CONSTRAINT IF EXISTS recipes_name_len;
ALTER TABLE public.recipes ADD CONSTRAINT recipes_name_len CHECK (length(name) <= 80) NOT VALID;
ALTER TABLE public.recipes DROP CONSTRAINT IF EXISTS recipes_desc_len;
ALTER TABLE public.recipes ADD CONSTRAINT recipes_desc_len CHECK (length(description) <= 1000) NOT VALID;
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_notes_len;
ALTER TABLE public.orders ADD CONSTRAINT orders_notes_len CHECK (length(notes) <= 1000) NOT VALID;

-- ------------------------------------------------------------
-- 7. Client can no longer execute any SECURITY DEFINER functions
--    except the auth RPCs, which are restricted to authenticated
-- ------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.save_passcodes(TEXT, TEXT, TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.save_passcodes(TEXT, TEXT, TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.change_passcode(TEXT, TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.change_passcode(TEXT, TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.verify_pin(TEXT, TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.verify_pin(TEXT, TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.passcodes_configured() FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.passcodes_configured() TO anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.set_role(TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.set_role(TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.claim_promo_code(TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.claim_promo_code(TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.is_activated() FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.is_activated() TO anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- infra-only functions: no client role may call them via RPC
REVOKE EXECUTE ON FUNCTION public.auto_confirm_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.cleanup_old_orders() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_restaurant_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_recipe_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_category_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_order_limit() FROM PUBLIC, anon, authenticated;

-- pin search_path on remaining trigger functions
CREATE OR REPLACE FUNCTION public.check_recipe_limit()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public
AS $function$
BEGIN
  IF (SELECT count(*) FROM public.recipes WHERE restaurant_id = NEW.restaurant_id) >= 50 THEN
    RAISE EXCEPTION 'Maximum number of recipes (50) reached for this restaurant.';
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.check_category_limit()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public
AS $function$
BEGIN
  IF (SELECT count(*) FROM public.categories WHERE restaurant_id = NEW.restaurant_id) >= 15 THEN
    RAISE EXCEPTION 'Maximum number of categories (15) reached for this restaurant.';
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.check_order_limit()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public
AS $function$
BEGIN
  IF (SELECT count(*) FROM public.orders WHERE restaurant_id = NEW.restaurant_id) >= 10000 THEN
    RAISE EXCEPTION 'Maximum number of active orders (10000) reached. Please archive old orders.';
  END IF;
  RETURN NEW;
END;
$function$;
