DROP PROCEDURE IF EXISTS insertdepartamento;
-- Procedure para insertar un nuevo departamento.
-- Recibe el nombre del departamento a insertar.
CREATE OR REPLACE PROCEDURE public.insertdepartamento(IN p_depnombre text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    BEGIN
        -- Insertar el nuevo departamento, dependiendo de la restricción de unique para evitar
		-- departamentos duplicados.
        INSERT INTO departamentos (depnombre)
        VALUES (p_depnombre);

    EXCEPTION
        --  Si hay una violación de unicidad, retornar excepción.
        WHEN unique_violation THEN
            RAISE EXCEPTION 'Department already exists' USING ERRCODE = '45000';
        -- Registrar y levantar la excepción otra vez cuando ocurren otro tipo de excepciones.
        WHEN others THEN
            RAISE EXCEPTION 'Unexpected error occurred: %', SQLERRM USING ERRCODE = '45001';
    END;
END;
$procedure$
