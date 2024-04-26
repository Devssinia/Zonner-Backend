alter table "public"."transactions" drop constraint "transactions_tx_ref_key";
alter table "public"."transactions" alter column "tx_ref" drop not null;
