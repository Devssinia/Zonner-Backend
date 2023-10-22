alter table "public"."transactions"
  add constraint "transactions_order_id_fkey"
  foreign key ("order_id")
  references "public"."orders"
  ("order_id") on update no action on delete no action;
