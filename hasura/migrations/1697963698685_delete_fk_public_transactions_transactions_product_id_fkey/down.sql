alter table "public"."transactions"
  add constraint "transactions_product_id_fkey"
  foreign key ("order_id")
  references "public"."products"
  ("product_id") on update no action on delete no action;
