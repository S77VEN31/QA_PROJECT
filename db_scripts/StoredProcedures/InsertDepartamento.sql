DROP PROCEDURE IF EXISTS insertdepartamento;
CREATE OR REPLACE PROCEDURE public.insertdepartamento(IN p_depnombre text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    BEGIN
        -- Insert the new department, rely on unique constraint for duplicates
        INSERT INTO departamentos (depnombre)
        VALUES (p_depnombre);

    EXCEPTION
        -- Capture unique constraint violation and raise custom exception
        WHEN unique_violation THEN
            RAISE EXCEPTION 'Department already exists' USING ERRCODE = '45000';
        -- Log and re-raise any other errors for debugging purposes
        WHEN others THEN
            RAISE EXCEPTION 'Unexpected error occurred: %', SQLERRM USING ERRCODE = '45001';
    END;
END;
$procedure$
