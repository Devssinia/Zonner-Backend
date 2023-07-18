alter table "public"."vendors" alter column "first_name" drop not null;
alter table "public"."vendors" add column "first_name" text;
