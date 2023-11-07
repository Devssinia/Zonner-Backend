alter table "public"."transactions"
  add constraint "transactions_order_id_fkey"
  foreign key ("order_id")
  references "public"."orders"
  ("order_id") on update restrict on delete restrict;
