alter table "public"."customers" alter column "first_name" drop not null;
alter table "public"."customers" add column "first_name" text;
