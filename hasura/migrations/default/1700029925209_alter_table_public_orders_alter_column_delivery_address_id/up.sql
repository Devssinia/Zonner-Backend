ALTER TABLE "public"."orders" ALTER COLUMN "delivery_address_id" TYPE text;
alter table "public"."orders" alter column "delivery_address_id" drop not null;
alter table "public"."orders" rename column "delivery_address_id" to "delivery_address_name";
