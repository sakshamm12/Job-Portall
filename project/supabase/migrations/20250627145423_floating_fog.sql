/*
  # Create jobs table

  1. New Tables
    - `jobs`
      - `id` (bigint, primary key, auto-increment)
      - `title` (text, not null)
      - `description` (text, not null)
      - `location` (text, not null)
      - `company_id` (bigint, foreign key to companies)
      - `recruiter_id` (text, not null - references Clerk user ID)
      - `requirements` (text, not null)
      - `isOpen` (boolean, default true)
      - `created_at` (timestamp with timezone, default now())

  2. Security
    - Enable RLS on `jobs` table
    - Add policy for authenticated users to read jobs
    - Add policy for recruiters to insert their own jobs
    - Add policy for recruiters to update their own jobs
    - Add policy for recruiters to delete their own jobs
*/

CREATE TABLE IF NOT EXISTS jobs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title text NOT NULL,
  description text NOT NULL,
  location text NOT NULL,
  company_id bigint REFERENCES companies(id) ON DELETE CASCADE,
  recruiter_id text NOT NULL,
  requirements text NOT NULL,
  "isOpen" boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read jobs"
  ON jobs
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Recruiters can insert their own jobs"
  ON jobs
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'sub' = recruiter_id);

CREATE POLICY "Recruiters can update their own jobs"
  ON jobs
  FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'sub' = recruiter_id)
  WITH CHECK (auth.jwt() ->> 'sub' = recruiter_id);

CREATE POLICY "Recruiters can delete their own jobs"
  ON jobs
  FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'sub' = recruiter_id);