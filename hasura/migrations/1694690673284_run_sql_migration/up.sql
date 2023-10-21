DROP TYPE IF EXISTS order_status2;

CREATE TYPE order_status2 AS ENUM ('new', 'inprogress','ready','dispatched','cancelled','delivered');
