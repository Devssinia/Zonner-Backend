ALTER TABLE "public"."products" ALTER COLUMN "quantity_in_stock" TYPE numeric;
alter table "public"."products" alter column "quantity_in_stock" drop not null;
