alter table "public"."authentications" alter column "status" set not null;
ALTER TABLE "public"."authentications" ALTER COLUMN "status" drop default;
