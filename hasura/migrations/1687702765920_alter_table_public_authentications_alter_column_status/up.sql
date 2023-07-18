alter table "public"."authentications" alter column "status" set default 'true';
alter table "public"."authentications" alter column "status" drop not null;
