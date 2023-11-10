ALTER TABLE "public"."likes" ALTER COLUMN "is_like" drop default;
alter table "public"."likes" alter column "is_like" drop not null;
