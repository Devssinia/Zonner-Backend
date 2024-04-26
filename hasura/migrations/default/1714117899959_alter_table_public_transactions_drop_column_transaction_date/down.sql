alter table "public"."transactions" alter column "transaction_date" set default now();
alter table "public"."transactions" alter column "transaction_date" drop not null;
alter table "public"."transactions" add column "transaction_date" time;
