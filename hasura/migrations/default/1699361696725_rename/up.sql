alter table "public"."vendors" alter column "status" set default 'False';
alter table "public"."customers" alter column "status" set default 'True';
alter table "public"."customers" drop column "first_name" cascade;
alter table "public"."customers" rename column "last_name" to "full_name";
alter table "public"."vendors" drop column "first_name" cascade;
alter table "public"."vendors" rename column "last_name" to "full_name";
alter table "public"."customers" alter column "phone_no" drop not null;
alter table "public"."customers" add column "profile_image" Text
 null default 'https://img.freepik.com/free-icon/user_318-563642.jpg';
alter table "public"."orders" alter column "order_id" set default gen_random_uuid();
alter table "public"."orders" add column "order_status" text
 null;
alter table "public"."orders" alter column "order_status" set default 'inprogress';
alter table "public"."orders" alter column "order_status" set default 'inprogress';
alter table "public"."orders" alter column "order_status" set default 'inprogress';
