alter table "public"."transactions" alter column "tx_ref" set not null;
alter table "public"."transactions" add constraint "transactions_tx_ref_key" unique ("tx_ref");
