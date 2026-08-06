-- ============================================================
-- Admin app support (my_rest_admin)
-- RPCs for the platform admin (hamabarznji1990@gmail.com)
-- ============================================================

-- Promo code generator (same alphabet as the restaurant app UI)
CREATE OR REPLACE FUNCTION public.generate_promo_code()
RETURNS TEXT
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..8 LOOP
    code := code || substr(chars, 1 + floor(random() * length(chars))::int, 1);
  END LOOP;
  RETURN code;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.generate_promo_code() FROM PUBLIC, anon, authenticated;

-- List every restaurant (profile) with activation/staff info.
CREATE OR REPLACE FUNCTION public.admin_list_restaurants()
RETURNS TABLE(
  id uuid,
  email text,
  role text,
  activated boolean,
  created_at timestamptz,
  pin_admin_set boolean,
  pin_waiter_set boolean,
  pin_kitchen_set boolean,
  promo_code text,
  promo_used_at timestamptz,
  promo_expires_at timestamptz,
  recipes_count bigint,
  orders_count bigint
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Forbidden';
  END IF;
  RETURN QUERY
    SELECT p.id, p.email, p.role, p.activated, p.created_at,
           (p.pin_admin <> ''), (p.pin_waiter <> ''), (p.pin_kitchen <> ''),
           pc.code, pc.used_at, pc.expires_at,
           (SELECT count(*) FROM public.recipes r WHERE r.restaurant_id = p.id),
           (SELECT count(*) FROM public.orders o WHERE o.restaurant_id = p.id)
    FROM public.profiles p
    LEFT JOIN public.promo_codes pc ON pc.used_by = p.id
    ORDER BY p.created_at;
END;
$$;

-- List all promo codes with the claiming restaurant email.
CREATE OR REPLACE FUNCTION public.admin_list_promo_codes()
RETURNS TABLE(
  code text,
  created_at timestamptz,
  used_at timestamptz,
  expires_at timestamptz,
  used_by uuid,
  used_by_email text
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Forbidden';
  END IF;
  RETURN QUERY
    SELECT pc.code, pc.created_at, pc.used_at, pc.expires_at, pc.used_by, p.email
    FROM public.promo_codes pc
    LEFT JOIN public.profiles p ON p.id = pc.used_by
    ORDER BY pc.created_at DESC;
END;
$$;

-- Create a restaurant account directly (email + password) and optionally
-- activate it for a number of months, minting + claiming a promo code.
-- Returns the generated promo code (NULL when no activation duration given).
CREATE OR REPLACE FUNCTION public.admin_create_restaurant(p_email TEXT, p_password TEXT, p_duration_months INT DEFAULT 0)
RETURNS TEXT
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  admin_uid uuid := auth.uid();
  new_uid uuid := gen_random_uuid();
  new_code TEXT;
BEGIN
  IF admin_uid IS NULL OR NOT public.is_admin() THEN
    RAISE EXCEPTION 'Forbidden';
  END IF;
  IF p_email IS NULL OR p_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' THEN
    RAISE EXCEPTION 'Invalid email';
  END IF;
  IF p_password IS NULL OR length(p_password) < 6 THEN
    RAISE EXCEPTION 'Password too short (min 6 characters)';
  END IF;
  IF p_duration_months < 0 OR p_duration_months > 120 THEN
    RAISE EXCEPTION 'Duration must be between 0 and 120 months';
  END IF;
  IF EXISTS (SELECT 1 FROM auth.users WHERE lower(email) = lower(p_email)) THEN
    RAISE EXCEPTION 'Email already registered';
  END IF;

  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, is_sso_user
  ) VALUES (
    '00000000-0000-0000-0000-000000000000', new_uid, 'authenticated', 'authenticated', p_email,
    crypt(p_password, gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    NOW(), NOW(), FALSE
  );

  INSERT INTO auth.identities (
    id, user_id, provider_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(), new_uid, new_uid::text,
    jsonb_build_object('sub', new_uid::text, 'email', p_email, 'email_verified', TRUE, 'phone_verified', FALSE),
    'email', NOW(), NOW(), NOW()
  );

  IF p_duration_months > 0 THEN
    new_code := public.generate_promo_code();
    INSERT INTO public.promo_codes (code, used_by, used_at, expires_at, created_by)
    VALUES (new_code, new_uid, NOW(), NOW() + make_interval(months => p_duration_months), admin_uid);
    UPDATE public.profiles SET activated = TRUE WHERE id = new_uid;
  END IF;

  RETURN new_code;
END;
$$;

-- Grants: admin RPCs are callable by any authenticated user but internally
-- reject everyone except the platform admin.
REVOKE EXECUTE ON FUNCTION public.admin_create_restaurant(TEXT, TEXT, INT) FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.admin_create_restaurant(TEXT, TEXT, INT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_list_restaurants() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.admin_list_restaurants() TO authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_list_promo_codes() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.admin_list_promo_codes() TO authenticated;
