/*
  # Create saved jobs table

  1. New Tables
    - `saved_jobs`
      - `id` (bigint, primary key, auto-increment)
      - `user_id` (text, not null - references Clerk user ID)
      - `job_id` (bigint, foreign key to jobs)
      - `created_at` (timestamp with timezone, default now())
      - Unique constraint on (user_id, job_id)

  2. Security
    - Enable RLS on `saved_jobs` table
    - Add policy for users to read their own saved jobs
    - Add policy for users to insert their own saved jobs
    - Add policy for users to delete their own saved jobs
*/

CREATE TABLE IF NOT EXISTS saved_jobs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id text NOT NULL,
  job_id bigint REFERENCES jobs(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, job_id)
);

ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own saved jobs"
  ON saved_jobs
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'sub' = user_id);

CREATE POLICY "Users can insert their own saved jobs"
  ON saved_jobs
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'sub' = user_id);

CREATE POLICY "Users can delete their own saved jobs"
  ON saved_jobs
  FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'sub' = user_id);