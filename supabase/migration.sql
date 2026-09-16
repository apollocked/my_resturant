-- ============================================================
-- my_resturant schema — canonical, idempotent baseline
--
-- Mirrors the hardened live schema (see security_hardening.sql +
-- security_hardening_v2.sql for the applied deltas). Safe to
-- re-run: everything is IF NOT EXISTS / CREATE OR REPLACE.
--
-- Security model:
--   * profiles rows are owner-read-only via RLS; all mutations go
--     through SECURITY DEFINER RPCs (PINs hashed with bcrypt,
--     role switches require PIN verification, rate-limited).
--   * recipes / orders / app_settings are tenant scoped by
--     restaurant_id = auth.uid(), with role-based write gates.
--   * categories are per-tenant (key + restaurant_id).
--   * promo codes / pin_attempts are admin-or-server only.
-- ============================================================

-- ============================================================
-- Profiles table (extends auth.users with role passcodes)
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  pin_waiter TEXT NOT NULL DEFAULT '',
  pin_kitchen TEXT NOT NULL DEFAULT '',
  pin_admin TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  role TEXT,
  activated BOOLEAN NOT NULL DEFAULT FALSE,
  passcodes_set BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profile rows are read-only via the Data API. All writes (PINs, role,
-- activation) go through SECURITY DEFINER RPCs below so clients can never
-- self-assign role='admin' or activated=TRUE directly.
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = id);

-- Hide the PIN hashes from the Data API entirely.
REVOKE SELECT (pin_waiter, pin_kitchen, pin_admin) ON profiles FROM anon, authenticated;

-- ============================================================
-- Function to auto-create profile on signup
-- ============================================================
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- Role helpers (per-device)
-- Each install sends a stable random `x-device-id` header on every request;
-- roles are stored per (user_id, device_id) in `device_sessions`, so several
-- devices on the same account can hold different roles at the same time.
-- current_role() returns THIS device's role. Headerless (legacy) clients keep
-- reading profiles.role, so the transition is seamless.
-- get_my_role() = the profiles.role mirror, INVOKER (records only own row).
-- ============================================================
CREATE TABLE IF NOT EXISTS public.device_sessions (
  user_id    UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  device_id  TEXT        NOT NULL,
  role       TEXT        NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, device_id)
);

ALTER TABLE public.device_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.device_sessions FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.current_device_id()
RETURNS TEXT
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT NULLIF(
    (SELECT value FROM jsonb_each_text(current_setting('request.headers', true)::jsonb)
     WHERE lower(key) = 'x-device-id' LIMIT 1),
    '');
$$;

CREATE OR REPLACE FUNCTION public.current_role()
RETURNS TEXT
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT CASE
    WHEN public.current_device_id() IS NULL OR public.current_device_id() = '' THEN
      coalesce((SELECT role FROM public.profiles WHERE id = auth.uid()), '')
    ELSE
      coalesce(
        (SELECT ds.role FROM public.device_sessions ds
         WHERE ds.user_id = auth.uid() AND ds.device_id = public.current_device_id()),
        '')
  END;
$$;

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE SQL STABLE SECURITY INVOKER SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- ============================================================
-- Profile mutation RPCs
-- PINs are hashed server-side with bcrypt (pgcrypto), role
-- switches require the PIN for the target role, and verification
-- is rate-limited to prevent brute force.
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.pin_attempts (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  success BOOLEAN NOT NULL,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.pin_attempts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.pin_attempts FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.save_passcodes(p_waiter TEXT, p_kitchen TEXT, p_admin TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF p_waiter !~ '^[0-9]{4,6}$' OR p_kitchen !~ '^[0-9]{4,6}$' OR p_admin !~ '^[0-9]{4,6}$' THEN
    RAISE EXCEPTION 'PIN must be 4 to 6 digits';
  END IF;
  -- First-time setup is allowed for any authenticated user; afterwards
  -- only an admin may overwrite the account's passcodes.
  IF public.passcodes_configured() AND public.current_role() <> 'admin' THEN
    RAISE EXCEPTION 'Forbidden';
  END IF;
  INSERT INTO public.profiles (id, email, pin_waiter, pin_kitchen, pin_admin, passcodes_set)
  VALUES (uid,
          (SELECT email FROM auth.users WHERE id = uid),
          crypt(p_waiter, gen_salt('bf')),
          crypt(p_kitchen, gen_salt('bf')),
          crypt(p_admin, gen_salt('bf')),
          TRUE)
  ON CONFLICT (id) DO UPDATE SET
    pin_waiter    = EXCLUDED.pin_waiter,
    pin_kitchen   = EXCLUDED.pin_kitchen,
    pin_admin     = EXCLUDED.pin_admin,
    passcodes_set = TRUE;
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
  IF public.current_role() <> 'admin' THEN RAISE EXCEPTION 'Forbidden'; END IF;
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
    (SELECT passcodes_set FROM public.profiles WHERE id = auth.uid()),
    FALSE
  );
$$;

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

  -- Legacy client without a device header: keep the old single-role behaviour.
  IF dev IS NULL OR dev = '' THEN
    SELECT role INTO cur FROM public.profiles WHERE id = uid;
    -- Admin may switch freely; every other switch must present the
    -- PIN of the target role (verified server-side).
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

  -- Admin devices switch roles freely; every other switch must present the
  -- PIN of the target role (verified server-side).
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

-- ============================================================
-- Recipes table
-- ============================================================
CREATE TABLE IF NOT EXISTS recipes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  image_url TEXT NOT NULL,
  price DOUBLE PRECISION NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  available BOOLEAN NOT NULL DEFAULT TRUE,
  restaurant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE
);

ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read recipes" ON recipes;
CREATE POLICY "Everyone can read recipes"
  ON recipes FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

DROP POLICY IF EXISTS "Admin can insert recipes" ON recipes;
CREATE POLICY "Admin can insert recipes"
  ON recipes FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id AND public.current_role() = 'admin');

DROP POLICY IF EXISTS "Admin can update recipes" ON recipes;
CREATE POLICY "Admin can update recipes"
  ON recipes FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND public.current_role() = 'admin')
  WITH CHECK ((select auth.uid()) = restaurant_id AND public.current_role() = 'admin');

DROP POLICY IF EXISTS "Admin can delete recipes" ON recipes;
CREATE POLICY "Admin can delete recipes"
  ON recipes FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND public.current_role() = 'admin');

CREATE INDEX IF NOT EXISTS idx_recipes_restaurant_id ON recipes(restaurant_id);

-- ============================================================
-- Categories table (per tenant: key + restaurant_id)
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  key TEXT NOT NULL,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  restaurant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (key, restaurant_id)
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read categories" ON categories;
DROP POLICY IF EXISTS "Tenant can read own categories" ON categories;
CREATE POLICY "Tenant can read own categories"
  ON categories FOR SELECT
  TO authenticated
  USING (restaurant_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admin can insert own categories" ON categories;
CREATE POLICY "Admin can insert own categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (restaurant_id = (select auth.uid()) AND public.current_role() = 'admin');

DROP POLICY IF EXISTS "Admin can update own categories" ON categories;
CREATE POLICY "Admin can update own categories"
  ON categories FOR UPDATE
  TO authenticated
  USING (restaurant_id = (select auth.uid()) AND public.current_role() = 'admin')
  WITH CHECK (restaurant_id = (select auth.uid()) AND public.current_role() = 'admin');

DROP POLICY IF EXISTS "Admin can delete own categories" ON categories;
CREATE POLICY "Admin can delete own categories"
  ON categories FOR DELETE
  TO authenticated
  USING (restaurant_id = (select auth.uid()) AND public.current_role() = 'admin');

-- ============================================================
-- Orders table
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  table_number INTEGER NOT NULL,
  table_label TEXT,
  status TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  items_json TEXT NOT NULL DEFAULT '[]',
  tracking_code TEXT NOT NULL DEFAULT '',
  restaurant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read orders" ON orders;
CREATE POLICY "Everyone can read orders"
  ON orders FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

DROP POLICY IF EXISTS "Waiters and admins can insert orders" ON orders;
CREATE POLICY "Waiters and admins can insert orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['waiter', 'admin']));

DROP POLICY IF EXISTS "Kitchen and admins can update orders" ON orders;
CREATE POLICY "Kitchen and admins can update orders"
  ON orders FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['kitchen', 'admin']))
  WITH CHECK ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['kitchen', 'admin']));

DROP POLICY IF EXISTS "Admins can delete orders" ON orders;
CREATE POLICY "Admins can delete orders"
  ON orders FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND public.current_role() = 'admin');

CREATE INDEX IF NOT EXISTS idx_orders_restaurant_id ON orders(restaurant_id);

-- Append items to an existing order atomically (merges by recipe_id).
CREATE OR REPLACE FUNCTION public.append_order_items(p_order_id TEXT, p_items JSONB)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_merged jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
  IF public.current_role() NOT IN ('waiter', 'admin') THEN RAISE EXCEPTION 'Forbidden'; END IF;

  WITH combined AS (
    SELECT value FROM jsonb_array_elements(
      COALESCE(
        (SELECT items_json::jsonb FROM public.orders
         WHERE id = p_order_id AND restaurant_id = auth.uid()),
        '[]'::jsonb
      )
    )
    UNION ALL
    SELECT value FROM jsonb_array_elements(p_items)
  ),
  grouped AS (
    SELECT
      value->>'recipe_id' AS recipe_id,
      COALESCE(value->>'notes', '') AS notes,
      sum((value->>'quantity')::int) AS quantity,
      (array_agg(value))[1] AS sample
    FROM combined
    GROUP BY 1, 2
  )
  SELECT jsonb_agg(
    jsonb_set(jsonb_set(sample, '{quantity}', to_jsonb(quantity)), '{notes}', to_jsonb(notes))
  ) INTO v_merged
  FROM grouped;

  UPDATE public.orders
  SET items_json = COALESCE(v_merged, '[]'::jsonb)::text
  WHERE id = p_order_id AND restaurant_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order not found';
  END IF;
END;
$$;

-- ============================================================
-- App Settings table
-- ============================================================
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  restaurant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (key, restaurant_id)
);

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- One permissive policy per command (SELECT/INSERT/UPDATE/DELETE) so the
-- advisor's "multiple permissive policies" lint stays clear.
DROP POLICY IF EXISTS "Everyone can read settings" ON app_settings;
DROP POLICY IF EXISTS "Members can read own settings" ON app_settings;
CREATE POLICY "Members can read own settings"
  ON app_settings FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

DROP POLICY IF EXISTS "Admin can update app settings" ON app_settings;
DROP POLICY IF EXISTS "Authorized staff can insert settings" ON app_settings;
CREATE POLICY "Authorized staff can insert settings"
  ON app_settings FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['waiter', 'kitchen', 'admin'])
    AND (key LIKE 'cleared\_%' OR public.current_role() = 'admin'));

DROP POLICY IF EXISTS "Staff can update table clearing settings" ON app_settings;
DROP POLICY IF EXISTS "Authorized staff can update settings" ON app_settings;
CREATE POLICY "Authorized staff can update settings"
  ON app_settings FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['waiter', 'kitchen', 'admin'])
    AND (key LIKE 'cleared\_%' OR public.current_role() = 'admin'))
  WITH CHECK ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['waiter', 'kitchen', 'admin'])
    AND (key LIKE 'cleared\_%' OR public.current_role() = 'admin'));

DROP POLICY IF EXISTS "Authorized staff can delete settings" ON app_settings;
CREATE POLICY "Authorized staff can delete settings"
  ON app_settings FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id
    AND public.current_role() = ANY (ARRAY['waiter', 'kitchen', 'admin'])
    AND (key LIKE 'cleared\_%' OR public.current_role() = 'admin'));

CREATE INDEX IF NOT EXISTS idx_app_settings_restaurant_id ON app_settings(restaurant_id);

-- Covering indexes for FK lookups (addressed by security advisor lints)
CREATE INDEX IF NOT EXISTS categories_restaurant_id_idx ON categories(restaurant_id);
CREATE INDEX IF NOT EXISTS pin_attempts_user_id_idx ON pin_attempts(user_id);
CREATE INDEX IF NOT EXISTS promo_codes_used_by_idx ON promo_codes(used_by);
CREATE INDEX IF NOT EXISTS promo_codes_created_by_idx ON promo_codes(created_by);

-- ============================================================
-- Enable Realtime (profiles intentionally excluded)
-- ============================================================
DROP TRIGGER IF EXISTS supabase_realtime_add_recipes ON recipes;
ALTER PUBLICATION supabase_realtime ADD TABLE recipes;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE app_settings;

-- ============================================================
-- Storage policies (path-based isolation per restaurant)
-- ============================================================
DROP POLICY IF EXISTS "Authenticated users can upload recipe images" ON storage.objects;
CREATE POLICY "Authenticated users can upload recipe images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

DROP POLICY IF EXISTS "Authenticated users can read own restaurant images" ON storage.objects;
CREATE POLICY "Authenticated users can read own restaurant images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

DROP POLICY IF EXISTS "Authenticated users can update recipe images" ON storage.objects;
CREATE POLICY "Authenticated users can update recipe images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

DROP POLICY IF EXISTS "Authenticated users can delete recipe images" ON storage.objects;
CREATE POLICY "Authenticated users can delete recipe images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ============================================================
-- Security: Revoke EXECUTE on SECURITY DEFINER functions
-- ============================================================
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.current_device_id() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.current_role() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.verify_pin(TEXT, TEXT) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.set_role(TEXT, TEXT) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.save_passcodes(TEXT, TEXT, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.change_passcode(TEXT, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.passcodes_configured() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.is_activated() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.append_order_items(TEXT, JSONB) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;

GRANT  EXECUTE ON FUNCTION public.verify_pin(TEXT, TEXT) TO authenticated;
GRANT  EXECUTE ON FUNCTION public.set_role(TEXT, TEXT) TO authenticated;
GRANT  EXECUTE ON FUNCTION public.current_role() TO authenticated;
GRANT  EXECUTE ON FUNCTION public.save_passcodes(TEXT, TEXT, TEXT) TO authenticated;
GRANT  EXECUTE ON FUNCTION public.change_passcode(TEXT, TEXT) TO authenticated;
GRANT  EXECUTE ON FUNCTION public.passcodes_configured() TO authenticated;
GRANT  EXECUTE ON FUNCTION public.is_activated() TO authenticated;
GRANT  EXECUTE ON FUNCTION public.append_order_items(TEXT, JSONB) TO authenticated;

-- ============================================================
-- SaaS Limits (free tier)
-- ============================================================

-- Max 20 restaurants total
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

DROP TRIGGER IF EXISTS check_restaurant_limit ON auth.users;
CREATE TRIGGER check_restaurant_limit
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.check_restaurant_limit();

-- Max 50 recipes per restaurant
CREATE OR REPLACE FUNCTION public.check_recipe_limit()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public
AS $$
BEGIN
  IF (SELECT count(*) FROM public.recipes WHERE restaurant_id = NEW.restaurant_id) >= 50 THEN
    RAISE EXCEPTION 'Maximum number of recipes (50) reached for this restaurant.';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS check_recipe_limit ON recipes;
CREATE TRIGGER check_recipe_limit
  BEFORE INSERT ON recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.check_recipe_limit();

-- Max 15 categories (per restaurant)
CREATE OR REPLACE FUNCTION public.check_category_limit()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public
AS $$
BEGIN
  IF (SELECT count(*) FROM public.categories WHERE restaurant_id = NEW.restaurant_id) >= 15 THEN
    RAISE EXCEPTION 'Maximum number of categories (15) reached for this restaurant.';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS check_category_limit ON categories;
CREATE TRIGGER check_category_limit
  BEFORE INSERT ON categories
  FOR EACH ROW
  EXECUTE FUNCTION public.check_category_limit();

-- Max 10000 orders per restaurant
CREATE OR REPLACE FUNCTION public.check_order_limit()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public
AS $$
BEGIN
  IF (SELECT count(*) FROM public.orders WHERE restaurant_id = NEW.restaurant_id) >= 10000 THEN
    RAISE EXCEPTION 'Maximum number of active orders (10000) reached. Please archive old orders.';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS check_order_limit ON orders;
CREATE TRIGGER check_order_limit
  BEFORE INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION public.check_order_limit();

-- Validate recipe price
ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_price_check;
ALTER TABLE recipes ADD CONSTRAINT recipes_price_check CHECK (price > 0);

-- Validate order status
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending', 'preparing', 'served', 'cancelled'));

-- Length caps (server-side enforcement)
ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_name_len;
ALTER TABLE recipes ADD CONSTRAINT recipes_name_len CHECK (length(name) <= 80);
ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_desc_len;
ALTER TABLE recipes ADD CONSTRAINT recipes_desc_len CHECK (length(description) <= 1000);
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_notes_len;
ALTER TABLE orders ADD CONSTRAINT orders_notes_len CHECK (length(notes) <= 1000);

REVOKE EXECUTE ON FUNCTION public.check_restaurant_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_recipe_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_category_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_order_limit() FROM PUBLIC, anon, authenticated;

-- ============================================================
-- Promo Codes
-- Codes are only ever minted/read/deleted by the platform admin.
-- Claiming is a single atomic UPDATE so two users can never claim
-- the same code (no TOCTOU race), expired codes are rejected, and
-- an account can only be activated once.
-- ============================================================
CREATE TABLE IF NOT EXISTS promo_codes (
  code TEXT PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '1 year',
  used_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  used_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL
);

ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Server-side admin check. The platform admin is flagged in
-- auth.users.raw_app_meta_data (platform_admin) so the admin keeps
-- their powers even after changing their email; the original email
-- remains as a fallback.
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
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

DROP POLICY IF EXISTS "Only admin can read promo codes" ON promo_codes;
CREATE POLICY "Only admin can read promo codes"
  ON promo_codes FOR SELECT
  TO authenticated
  USING (public.is_admin());

DROP POLICY IF EXISTS "Only admin can create promo codes" ON promo_codes;
CREATE POLICY "Only admin can create promo codes"
  ON promo_codes FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Only admin can delete unused promo codes" ON promo_codes;
CREATE POLICY "Only admin can delete unused promo codes"
  ON promo_codes FOR DELETE
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

REVOKE EXECUTE ON FUNCTION public.claim_promo_code(TEXT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.claim_promo_code(TEXT) TO authenticated;

-- Sync profiles.email whenever auth.users.email changes.
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