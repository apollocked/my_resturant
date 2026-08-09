-- ============================================================
-- Storage bucket for recipe/food images
-- Run this once in the Supabase SQL editor (idempotent).
-- Fix: "Cannot add new food" — the recipe_images bucket was
-- missing in the live project, so image uploads failed.
-- ============================================================

-- Create the bucket (public so getPublicUrl() images load without auth)
INSERT INTO storage.buckets (id, name, public)
VALUES ('recipe_images', 'recipe_images', true)
ON CONFLICT (id) DO NOTHING;

-- Path-isolation policies: each restaurant only touches its own folder
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
