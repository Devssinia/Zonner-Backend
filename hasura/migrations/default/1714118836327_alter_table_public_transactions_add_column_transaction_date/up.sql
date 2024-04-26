alter table "public"."transactions" add column "transaction_date" timestamptz
 null default now();
