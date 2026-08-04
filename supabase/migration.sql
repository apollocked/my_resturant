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
  role TEXT
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profile rows are read-only via the Data API. All writes (PINs, role,
-- activation) go through SECURITY DEFINER RPCs below so clients can never
-- self-assign role='admin' or activated=TRUE directly.
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
-- Function to get current user's role
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE SQL STABLE SECURITY INVOKER SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- ============================================================
-- Profile mutation RPCs
-- PINs are hashed server-side with bcrypt (pgcrypto) and PIN
-- verification is rate-limited to prevent brute force.
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

CREATE POLICY "Everyone can read recipes"
  ON recipes FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can insert recipes"
  ON recipes FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can update recipes"
  ON recipes FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id)
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can delete recipes"
  ON recipes FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE INDEX IF NOT EXISTS idx_recipes_restaurant_id ON recipes(restaurant_id);

-- ============================================================
-- Categories table
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  key TEXT NOT NULL,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  restaurant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (key, restaurant_id)
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read categories"
  ON categories FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can insert categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can update categories"
  ON categories FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id)
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can delete categories"
  ON categories FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE INDEX IF NOT EXISTS idx_categories_restaurant_id ON categories(restaurant_id);

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

CREATE POLICY "Everyone can read orders"
  ON orders FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can insert orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can update orders"
  ON orders FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id)
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can delete orders"
  ON orders FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE INDEX IF NOT EXISTS idx_orders_restaurant_id ON orders(restaurant_id);

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

CREATE POLICY "Everyone can read settings"
  ON app_settings FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can insert settings"
  ON app_settings FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can update settings"
  ON app_settings FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id)
  WITH CHECK ((select auth.uid()) = restaurant_id);

CREATE POLICY "Authenticated users can delete settings"
  ON app_settings FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE INDEX IF NOT EXISTS idx_app_settings_restaurant_id ON app_settings(restaurant_id);

-- ============================================================
-- Enable Realtime
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE recipes;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE app_settings;

-- ============================================================
-- Storage policies (path-based isolation per restaurant)
-- ============================================================
CREATE POLICY "Authenticated users can upload recipe images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

CREATE POLICY "Authenticated users can read own restaurant images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

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
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_user() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM anon, authenticated;

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
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM public.recipes WHERE restaurant_id = NEW.restaurant_id) >= 50 THEN
    RAISE EXCEPTION 'Maximum number of recipes (50) reached.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

DROP TRIGGER IF EXISTS check_recipe_limit ON recipes;
CREATE TRIGGER check_recipe_limit
  BEFORE INSERT ON recipes
  FOR EACH ROW
  EXECUTE FUNCTION public.check_recipe_limit();

-- Max 15 categories per restaurant
CREATE OR REPLACE FUNCTION public.check_category_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM public.categories WHERE restaurant_id = NEW.restaurant_id) >= 15 THEN
    RAISE EXCEPTION 'Maximum number of categories (15) reached.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

DROP TRIGGER IF EXISTS check_category_limit ON categories;
CREATE TRIGGER check_category_limit
  BEFORE INSERT ON categories
  FOR EACH ROW
  EXECUTE FUNCTION public.check_category_limit();

-- Max 10000 orders per restaurant
CREATE OR REPLACE FUNCTION public.check_order_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM public.orders WHERE restaurant_id = NEW.restaurant_id) >= 10000 THEN
    RAISE EXCEPTION 'Maximum number of orders (10000) reached.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

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
ALTER TABLE orders ADD CONSTRAINT orders_status_check CHECK (status IN ('pending', 'preparing', 'served'));

-- Length caps (server-side enforcement)
ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_name_len;
ALTER TABLE recipes ADD CONSTRAINT recipes_name_len CHECK (length(name) <= 80);
ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_desc_len;
ALTER TABLE recipes ADD CONSTRAINT recipes_desc_len CHECK (length(description) <= 1000);
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_notes_len;
ALTER TABLE orders ADD CONSTRAINT orders_notes_len CHECK (length(notes) <= 1000);

-- ============================================================
-- Promo Codes
-- Codes are only ever minted/read/deleted by the platform admin.
-- Claiming is a single atomic UPDATE so two users can never claim
-- the same code (no TOCTOU race), expired codes are rejected, and
-- an account can only be activated once.
-- ============================================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS activated BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS promo_codes (
  code TEXT PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  used_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  used_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL
);

ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Server-side admin check (email is unique in auth.users, so a user
-- cannot adopt the admin's email).
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

CREATE POLICY "Only admin can read promo codes"
  ON promo_codes FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Only admin can create promo codes"
  ON promo_codes FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

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
