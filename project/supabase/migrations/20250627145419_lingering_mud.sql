/*
  # Create companies table

  1. New Tables
    - `companies`
      - `id` (bigint, primary key, auto-increment)
      - `name` (text, unique, not null)
      - `logo_url` (text)
      - `created_at` (timestamp with timezone, default now())

  2. Security
    - Enable RLS on `companies` table
    - Add policy for authenticated users to read companies
    - Add policy for authenticated users to insert companies
*/

CREATE TABLE IF NOT EXISTS companies (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text UNIQUE NOT NULL,
  logo_url text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read companies"
  ON companies
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert companies"
  ON companies
  FOR INSERT
  TO authenticated
  WITH CHECK (true);