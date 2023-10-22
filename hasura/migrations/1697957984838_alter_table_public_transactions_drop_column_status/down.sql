alter table "public"."transactions" alter column "status" drop not null;
alter table "public"."transactions" add column "status" text;
