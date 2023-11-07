alter table "public"."orders" alter column "order_status" set default ''inprogress'::text';
alter table "public"."orders" alter column "order_status" drop not null;
alter table "public"."orders" add column "order_status" text;
