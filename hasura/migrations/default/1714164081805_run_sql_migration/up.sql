-- Drop the existing transaction_status enum type
DROP TYPE IF EXISTS transaction_status;

-- Create a new transaction_status enum type
CREATE TYPE transaction_status AS ENUM ('paid','unpaid','failed','cancelled','delivered','pending','success');
