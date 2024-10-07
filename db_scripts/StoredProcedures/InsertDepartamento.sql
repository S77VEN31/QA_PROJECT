CREATE PROCEDURE insertdepartamento(
    IN p_depnombre TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO departamentos (depnombre)
    VALUES (p_depnombre);
END;
$$;
