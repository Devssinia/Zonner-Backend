-- DROP TYPE IF EXISTS order_status;
-- CREATE TYPE order_status AS ENUM ('new', 'inprogress','ready','dispatched','cancelled','delivered');
CREATE TYPE transaction_status AS ENUM ('paid','unpaid','failed','cancelled','delivered');

-- ALTER TABLE orders
-- ALTER COLUMN order_status TYPE order_status
-- USING order_status::text::order_status;
-- DROP TYPE IF EXISTS order_status2;
