-- DROP TYPE IF EXISTS order_status;
-- CREATE TYPE order_status AS ENUM ('new', 'inprogress','ready','dispatched','cancelled','delivered');

ALTER TABLE orders
ALTER COLUMN order_status TYPE order_status2
USING order_status::text::order_status2;
DROP TYPE IF EXISTS order_status;
