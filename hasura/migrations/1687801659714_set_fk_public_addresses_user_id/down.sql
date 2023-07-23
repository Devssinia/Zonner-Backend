alter table "public"."addresses" drop constraint "addresses_user_id_fkey",
  add constraint "addresses_user_id_fkey"
  foreign key ("user_id")
  references "public"."authentications"
  ("user_id") on update cascade on delete restrict;
