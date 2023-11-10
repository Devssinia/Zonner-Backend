alter table "public"."likes" alter column "is_like" set not null;
alter table "public"."likes" alter column "is_like" set default 'true';
