alter table "public"."transactions" alter column "transaction_id" set default gen_random_uuid();
