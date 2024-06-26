CREATE TABLE "public"."wards" ("ward_id" uuid NOT NULL DEFAULT gen_random_uuid(), "county_id" uuid NOT NULL, "ward_name" text NOT NULL, PRIMARY KEY ("ward_id") , FOREIGN KEY ("county_id") REFERENCES "public"."counties"("county_id") ON UPDATE cascade ON DELETE cascade);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
