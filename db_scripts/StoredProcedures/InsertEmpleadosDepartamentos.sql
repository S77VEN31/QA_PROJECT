CREATE PROCEDURE insertEmpleadosDepartamentos(
    IN p_departamentoid SMALLINT,
    IN p_cedulas INT[]
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert all cedulas in the array in one operation
    INSERT INTO empleadosdepartamentos (cedula, departamentoid, validfrom, validto, enabled)
    SELECT cedula, p_departamentoid, CURRENT_DATE, NULL, TRUE
    FROM unnest(p_cedulas) AS cedula;
END;
$$;