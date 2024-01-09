CREATE OR REPLACE FUNCTION public.calculate_likes_dislikes(info_row infos)
 RETURNS TABLE(likes_count bigint, dislikes_count bigint)
 LANGUAGE sql
 STABLE
AS $function$
    SELECT
        COUNT(*) FILTER (WHERE is_like = true) AS likes_count,
        COUNT(*) FILTER (WHERE is_like = false) AS dislikes_count
    FROM likes
    WHERE info_id = info_row.id;
$function$;
