alter table "public"."orders" rename column "delivery_address_name" to "delivery_address_id";
alter table "public"."orders" alter column "delivery_address_id" set not null;
ALTER TABLE "public"."orders" ALTER COLUMN "delivery_address_id" TYPE uuid;
