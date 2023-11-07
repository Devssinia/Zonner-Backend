alter table "public"."buisness_address" rename to "business_address";
alter table "public"."business_address" alter column "ward_id" drop not null;
alter table "public"."business_address" alter column "county_id" drop not null;
alter table "public"."business_address" alter column "city" drop not null;
alter table "public"."business_address" alter column "longtude" drop not null;
alter table "public"."business_address" alter column "latitude" drop not null;
