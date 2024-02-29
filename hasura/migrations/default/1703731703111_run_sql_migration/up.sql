CREATE OR REPLACE FUNCTION public.number_of_likes(info_row infos)
 RETURNS bigint
 LANGUAGE sql
 STABLE
AS $function$ 
select count(*) FILTER (WHERE is_like = true) AS likes_count FROM likes WHERE info_id = info_row.id;
$function$;
