/*
  # Fix Storage Buckets and Policies

  1. Storage Bucket Fixes
    - Ensure company-logos bucket exists and is properly configured
    - Ensure resumes bucket exists and is properly configured
    - Fix bucket naming consistency (company-logos vs company-logo)

  2. Security Policy Updates
    - Fix RLS policies for storage objects
    - Ensure proper access controls for file uploads
    - Add missing policies for bucket operations

  3. Table Fixes
    - Fix saved_jobs table name (should be saved_job to match API)
    - Ensure all foreign key constraints are properly set
*/

-- Drop existing buckets if they exist with wrong names
DELETE FROM storage.buckets WHERE id IN ('company-logo', 'company-logos', 'resumes');

-- Create storage buckets with correct configuration
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES 
  ('company-logos', 'company-logos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']),
  ('resumes', 'resumes', false, 10485760, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Drop all existing storage policies
DROP POLICY IF EXISTS "Anyone can view company logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload company logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update company logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete company logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view resumes" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload resumes" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update resumes" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete resumes" ON storage.objects;
DROP POLICY IF EXISTS "Company logos are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can read their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own resumes" ON storage.objects;

-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Company logos policies (public bucket)
CREATE POLICY "Public read access for company logos"
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

-- Resume policies (private bucket)
CREATE POLICY "Authenticated users can read resumes"
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

-- Fix table name consistency - rename saved_jobs to saved_job if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'saved_jobs') THEN
    ALTER TABLE saved_jobs RENAME TO saved_job;
  END IF;
EXCEPTION
  WHEN duplicate_table THEN
    -- Table already exists with correct name, drop the old one
    DROP TABLE IF EXISTS saved_jobs;
END $$;

-- Ensure saved_job table exists with correct structure
CREATE TABLE IF NOT EXISTS saved_job (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id text NOT NULL,
  job_id bigint REFERENCES jobs(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, job_id)
);

-- Enable RLS and create policies for saved_job table
ALTER TABLE saved_job ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for saved_job
DROP POLICY IF EXISTS "Users can read their own saved jobs" ON saved_job;
DROP POLICY IF EXISTS "Users can insert their own saved jobs" ON saved_job;
DROP POLICY IF EXISTS "Users can delete their own saved jobs" ON saved_job;

-- Create policies for saved_job table
CREATE POLICY "Users can read their own saved jobs"
  ON saved_job
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'sub' = user_id);

CREATE POLICY "Users can insert their own saved jobs"
  ON saved_job
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'sub' = user_id);

CREATE POLICY "Users can delete their own saved jobs"
  ON saved_job
  FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'sub' = user_id);

-- Ensure all tables have proper indexes for performance
CREATE INDEX IF NOT EXISTS idx_jobs_recruiter_id ON jobs(recruiter_id);
CREATE INDEX IF NOT EXISTS idx_jobs_company_id ON jobs(company_id);
CREATE INDEX IF NOT EXISTS idx_jobs_location ON jobs(location);
CREATE INDEX IF NOT EXISTS idx_jobs_isopen ON jobs("isOpen");
CREATE INDEX IF NOT EXISTS idx_saved_job_user_id ON saved_job(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_job_job_id ON saved_job(job_id);
CREATE INDEX IF NOT EXISTS idx_applications_candidate_id ON applications(candidate_id);
CREATE INDEX IF NOT EXISTS idx_applications_job_id ON applications(job_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);