CREATE OR REPLACE FUNCTION public.authenticate_user(p_email character varying)
 RETURNS TABLE(p_user_id integer, p_password_hash character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY 
    SELECT id, password
    FROM users
    WHERE email = p_email;
END;
$function$