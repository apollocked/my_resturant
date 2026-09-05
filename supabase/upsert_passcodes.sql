-- ============================================================
-- Per-account passcode auto-save (UPSERT)
-- Previously save_passcodes ran `UPDATE profiles WHERE id = uid`.
-- If the logged-in account had no profiles row, 0 rows were
-- updated silently and passcodes_configured() stayed FALSE, so the
-- setup page reappeared on every login. Now it creates the row if
-- missing and always persists the passcodes for the account.
-- Idempotent; safe to re-run.
-- ============================================================

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
  INSERT INTO public.profiles (id, email, pin_waiter, pin_kitchen, pin_admin)
  VALUES (uid,
          (SELECT email FROM auth.users WHERE id = uid),
          crypt(p_waiter, gen_salt('bf')),
          crypt(p_kitchen, gen_salt('bf')),
          crypt(p_admin, gen_salt('bf')))
  ON CONFLICT (id) DO UPDATE SET
    pin_waiter  = EXCLUDED.pin_waiter,
    pin_kitchen = EXCLUDED.pin_kitchen,
    pin_admin   = EXCLUDED.pin_admin;
END;
$$;