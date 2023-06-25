alter table "public"."authentications"
  add constraint "authentications_role_id_fkey"
  foreign key ("role_id")
  references "public"."roles"
  ("role_id") on update restrict on delete restrict;
