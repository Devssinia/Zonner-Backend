alter table "public"."orders"
  add constraint "orders_delivery_address_id_fkey"
  foreign key ("delivery_address_id")
  references "public"."addresses"
  ("adress_id") on update set null on delete set null;
