/*
  # Insert sample companies

  1. Sample Data
    - Insert popular tech companies for demo purposes
*/

INSERT INTO companies (name, logo_url) VALUES
  ('Google', '/companies/google.webp'),
  ('Microsoft', '/companies/microsoft.webp'),
  ('Amazon', '/companies/amazon.svg'),
  ('Meta', '/companies/meta.svg'),
  ('Netflix', '/companies/netflix.png'),
  ('Uber', '/companies/uber.svg'),
  ('IBM', '/companies/ibm.svg'),
  ('Atlassian', '/companies/atlassian.svg')
ON CONFLICT (name) DO NOTHING;