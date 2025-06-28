/*
  # Fix storage bucket policies

  1. Storage Policy Updates
    - Simplify company logo policies to allow all authenticated users to upload
    - Fix resume policies to work with current file naming convention
    - Remove folder-based restrictions that don't match current implementation

  2. Security
    - Company logos: Public read, authenticated upload
    - Resumes: Authenticated users can upload and read (for job applications)
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Company logos are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload company logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own company logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own company logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can read their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own resumes" ON storage.objects;

-- Company logos policies - simplified
CREATE POLICY "Anyone can view company logos"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'company-logos');

CREATE POLICY "Authenticated users can upload company logos"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'company-logos');

CREATE POLICY "Authenticated users can update company logos"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (bucket_id = 'company-logos');

CREATE POLICY "Authenticated users can delete company logos"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'company-logos');

-- Resume policies - simplified for job applications
CREATE POLICY "Authenticated users can view resumes"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'resumes');

CREATE POLICY "Authenticated users can upload resumes"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'resumes');

CREATE POLICY "Authenticated users can update resumes"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (bucket_id = 'resumes');

CREATE POLICY "Authenticated users can delete resumes"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'resumes');