DROP PROCEDURE IF EXISTS insertEmpleadosDepartamentos;
CREATE PROCEDURE insertEmpleadosDepartamentos(
    IN p_departamentoid SMALLINT,
    IN p_cedulas INT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    dept_exists BOOLEAN;
    missing_cedula BOOLEAN;
    empleado_in_department BOOLEAN;
    newValidTo TIMESTAMP;
BEGIN
    -- Check if the department exists
    SELECT EXISTS (
        SELECT 1
        FROM departamentos
        WHERE departamentoid = p_departamentoid
    ) INTO dept_exists;

    -- Raise an exception if the department does not exist
    IF NOT dept_exists THEN
        RAISE EXCEPTION 'Department with ID % does not exist', p_departamentoid  USING ERRCODE = 'P0001';
    END IF;

    -- Check if any cedula in p_cedulas does not exist in empleados table
    SELECT EXISTS (
        SELECT 1
        FROM unnest(p_cedulas) AS cedula
        WHERE cedula NOT IN (SELECT cedula FROM empleados)
    ) INTO missing_cedula;

    -- If a missing cedula is found, raise an exception
    IF missing_cedula THEN
        RAISE EXCEPTION 'There is a cedula that does not exist in empleados table' USING ERRCODE = 'P0002';
    END IF;

	-- Check if any cedula in p_cedulas exists in empleadosdepartamentos table
    SELECT EXISTS (
        SELECT 1
        FROM unnest(p_cedulas) AS cedula
        WHERE cedula IN (SELECT cedula FROM empleadosdepartamentos WHERE departamentoId = p_departamentoId AND enabled=true)
    ) INTO empleado_in_department;

    -- If a missing cedula is found, raise an exception
    IF empleado_in_department THEN
        RAISE EXCEPTION 'There is a cedula that is already in the department.'  USING ERRCODE = 'P0003';
    END IF;

    newValidTo := CURRENT_TIMESTAMP;
    
    UPDATE empleadosdepartamentos
    SET validto = newValidTo,
        enabled = false
    WHERE cedula = ANY (p_cedulas) AND enabled=true; 
    
    -- Insert all cedulas in the array in one operation
    INSERT INTO empleadosdepartamentos (cedula, departamentoid, validfrom, validto, enabled)
    SELECT cedula, p_departamentoid, newValidTo, NULL, TRUE
    FROM unnest(p_cedulas) AS cedula;
END;
$$;