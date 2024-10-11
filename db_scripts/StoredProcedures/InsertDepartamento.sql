DROP PROCEDURE IF EXISTS insertdepartamento;
CREATE PROCEDURE insertdepartamento(
    IN p_depnombre TEXT,
    OUT p_id INT  -- This will hold the returned ID
)
LANGUAGE plpgsql
AS $$
DECLARE
    dept_exists BOOLEAN;
BEGIN
    -- Check if the department exists
    SELECT EXISTS (
        SELECT 1
        FROM departamentos
        WHERE depnombre = p_depnombre
    ) INTO dept_exists;

    -- Raise an exception if the department does not exist
    IF NOT dept_exists THEN
        RAISE EXCEPTION 'Department with ID % does not exist', p_departamentoid;
    END IF;

    -- Insert the record and return the id of the inserted record
    INSERT INTO departamentos (depnombre)
    VALUES (p_depnombre)
    RETURNING departamentoid INTO p_id;
END;
$$;
