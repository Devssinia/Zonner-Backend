CREATE VIEW public.online_users AS
 SELECT 
    authentications.user_id,
    authentications.role_id,
    authentications.last_seen,
    authentications.phone_no
   FROM public.authentications
  WHERE (authentications.last_seen > (now() - '00:30:00'::interval));