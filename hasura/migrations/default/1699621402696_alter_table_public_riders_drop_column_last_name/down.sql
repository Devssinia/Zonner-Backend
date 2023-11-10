alter table "public"."riders" alter column "last_name" drop not null;
alter table "public"."riders" add column "last_name" text;
