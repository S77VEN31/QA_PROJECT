CREATE OR REPLACE FUNCTION public.register_user(p_username character varying, p_email character varying, p_password_hash character varying)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_user_id integer;
BEGIN
    INSERT INTO users (username, email, password)
    VALUES (p_username, p_email, p_password_hash)
    RETURNING id INTO p_user_id;
    
    RETURN p_user_id;
END;
$function$

CREATE TABLE users(
    id SERIAL NOT NULL,
    username varchar(100) NOT NULL,
    email varchar(100) NOT NULL,
    password varchar(255) NOT NULL,
    PRIMARY KEY(id)
);
CREATE UNIQUE INDEX users_username_key ON users USING btree ("username");
CREATE UNIQUE INDEX users_email_key ON users USING btree ("email");

