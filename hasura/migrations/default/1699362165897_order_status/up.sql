-- DROP TYPE IF EXISTS order_status;
CREATE TYPE order_status AS ENUM ('new', 'inprogress','ready','dispatched','cancelled','delivered');
