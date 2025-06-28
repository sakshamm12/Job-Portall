/*
  # Create applications table

  1. New Tables
    - `applications`
      - `id` (bigint, primary key, auto-increment)
      - `job_id` (bigint, foreign key to jobs)
      - `candidate_id` (text, not null - references Clerk user ID)
      - `name` (text, not null)
      - `experience` (integer, not null)
      - `skills` (text, not null)
      - `education` (text, not null)
      - `resume` (text, not null - URL to resume file)
      - `status` (text, default 'applied')
      - `created_at` (timestamp with timezone, default now())

  2. Security
    - Enable RLS on `applications` table
    - Add policy for candidates to read their own applications
    - Add policy for recruiters to read applications for their jobs
    - Add policy for candidates to insert their own applications
    - Add policy for recruiters to update application status for their jobs
*/

CREATE TABLE IF NOT EXISTS applications (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  job_id bigint REFERENCES jobs(id) ON DELETE CASCADE,
  candidate_id text NOT NULL,
  name text NOT NULL,
  experience integer NOT NULL,
  skills text NOT NULL,
  education text NOT NULL,
  resume text NOT NULL,
  status text DEFAULT 'applied',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Candidates can read their own applications"
  ON applications
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'sub' = candidate_id);

CREATE POLICY "Recruiters can read applications for their jobs"
  ON applications
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM jobs 
      WHERE jobs.id = applications.job_id 
      AND jobs.recruiter_id = auth.jwt() ->> 'sub'
    )
  );

CREATE POLICY "Candidates can insert their own applications"
  ON applications
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'sub' = candidate_id);

CREATE POLICY "Recruiters can update application status for their jobs"
  ON applications
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM jobs 
      WHERE jobs.id = applications.job_id 
      AND jobs.recruiter_id = auth.jwt() ->> 'sub'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM jobs 
      WHERE jobs.id = applications.job_id 
      AND jobs.recruiter_id = auth.jwt() ->> 'sub'
    )
  );