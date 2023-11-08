CREATE FUNCTION public.info_dislike_counter(info_row public.infos) RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  SELECT COUNT(1) FROM likes WHERE info_id = info_row.id AND is_like = false;
$$;
CREATE FUNCTION public.info_like_counter(info_row public.infos) RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  SELECT COUNT(1) FROM likes WHERE info_id = info_row.id AND is_like = true;
$$;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
