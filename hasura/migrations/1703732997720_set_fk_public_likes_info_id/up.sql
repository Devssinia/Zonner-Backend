alter table "public"."likes" drop constraint "likes_info_id_fkey",
  add constraint "likes_info_id_fkey"
  foreign key ("info_id")
  references "public"."infos"
  ("id") on update cascade on delete cascade;
