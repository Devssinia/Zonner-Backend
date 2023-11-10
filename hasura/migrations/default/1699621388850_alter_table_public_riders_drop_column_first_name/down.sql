alter table "public"."riders" alter column "first_name" drop not null;
alter table "public"."riders" add column "first_name" text;
