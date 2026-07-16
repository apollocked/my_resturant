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

CREATE POLICY "Users can manage own profile"
  ON profiles FOR ALL
  TO authenticated
  USING ((select auth.uid()) = id)
  WITH CHECK ((select auth.uid()) = id);

-- ============================================================
-- Function to auto-create profile on signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- Function to get current user's role
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE SQL STABLE SECURITY INVOKER;

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

CREATE POLICY "Admin can insert recipes"
  ON recipes FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE POLICY "Admin can update recipes"
  ON recipes FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin')
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE POLICY "Admin can delete recipes"
  ON recipes FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

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

CREATE POLICY "Admin can insert categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE POLICY "Admin can update categories"
  ON categories FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin')
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE POLICY "Admin can delete categories"
  ON categories FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

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
  restaurant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read orders"
  ON orders FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = restaurant_id);

CREATE POLICY "Waiter and admin can insert orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = ANY (ARRAY['waiter', 'admin']));

CREATE POLICY "Kitchen and admin can update orders"
  ON orders FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = ANY (ARRAY['kitchen', 'admin']))
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = ANY (ARRAY['kitchen', 'admin']));

CREATE POLICY "Admin can delete orders"
  ON orders FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

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

CREATE POLICY "Admin can insert settings"
  ON app_settings FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE POLICY "Admin can update settings"
  ON app_settings FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin')
  WITH CHECK ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE POLICY "Admin can delete settings"
  ON app_settings FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = restaurant_id AND (select get_my_role()) = 'admin');

CREATE INDEX IF NOT EXISTS idx_app_settings_restaurant_id ON app_settings(restaurant_id);

-- ============================================================
-- Enable Realtime
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE recipes;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE app_settings;

-- ============================================================
-- Storage policies (path-based isolation per restaurant)
-- ============================================================
CREATE POLICY "Admin can upload recipe images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'recipe_images'
    AND (select get_my_role()) = 'admin'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

CREATE POLICY "Users can read own restaurant images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

CREATE POLICY "Admin can update recipe images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (select get_my_role()) = 'admin'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'recipe_images'
    AND (select get_my_role()) = 'admin'
    AND (storage.foldername(name))[1] = (select auth.uid())::text
  );

CREATE POLICY "Admin can delete recipe images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'recipe_images'
    AND (select get_my_role()) = 'admin'
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
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM public.profiles) >= 20 THEN
    RAISE EXCEPTION 'Maximum number of restaurants (20) reached.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
