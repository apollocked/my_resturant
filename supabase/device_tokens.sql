-- ============================================================
-- Device tokens for FCM manager notifications
-- Applied live as migration: device_tokens
-- - Restaurants register their FCM tokens here (RLS: owner only)
-- - Edge function notify-manager sends pushes to these tokens
--   when 3 consecutive wrong role-change PINs occur.
-- ============================================================
CREATE TABLE IF NOT EXISTS public.device_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  token text NOT NULL UNIQUE,
  platform text NOT NULL DEFAULT 'android',
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

-- Users can read/insert/update/delete only their own tokens.
CREATE POLICY "device_tokens_owner_all" ON public.device_tokens
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.device_tokens TO authenticated;
