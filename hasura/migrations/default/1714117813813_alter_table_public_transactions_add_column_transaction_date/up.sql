alter table "public"."transactions" add column "transaction_date" time
 not null default now();
