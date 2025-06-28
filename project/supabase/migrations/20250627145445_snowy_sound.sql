/*
  # Create storage buckets for file uploads

  1. Storage Buckets
    - `resumes` - for storing candidate resume files
    - `company-logo` - for storing company logo files

  2. Security
    - Enable RLS on storage buckets
    - Add policies for authenticated users to upload and read files
*/

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('resumes', 'resumes', true),
  ('company-logo', 'company-logo', true)
ON CONFLICT (id) DO NOTHING;

-- Policies for resumes bucket
CREATE POLICY "Authenticated users can upload resumes"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'resumes');

CREATE POLICY "Anyone can read resumes"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'resumes');

-- Policies for company-logo bucket
CREATE POLICY "Authenticated users can upload company logos"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'company-logo');

CREATE POLICY "Anyone can read company logos"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'company-logo');