DROP PROCEDURE IF EXISTS insertEmpleadosDepartamentos;
-- Procedimiento para asignar empleados a un departamento.
-- Recibe el id del departamento al cual se le asignan empleados.
-- Recibe una lista de cédulas 
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
   -- Revisar si existe el departamento
    SELECT EXISTS (
        SELECT 1
        FROM departamentos
        WHERE departamentoid = p_departamentoid
    ) INTO dept_exists;

    -- Levantar una excepción si no existe el departamento
    IF NOT dept_exists THEN
        RAISE EXCEPTION 'Department with ID % does not exist', p_departamentoid  USING ERRCODE = 'P0001';
    END IF;

    -- Revisar si alguna cédula en p_cedulas no existe en la tabla de empleados.
    SELECT EXISTS (
        SELECT 1
        FROM unnest(p_cedulas) AS cedula
        WHERE cedula NOT IN (SELECT cedula FROM empleados)
    ) INTO missing_cedula;

    -- Si hay una cédula faltante, se levanta la excepción.
    IF missing_cedula THEN
        RAISE EXCEPTION 'There is a cedula that does not exist in empleados table' USING ERRCODE = 'P0002';
    END IF;

	-- Revisar si hay alguna cédula ya registrada en el departamento.
    SELECT EXISTS (
        SELECT 1
        FROM unnest(p_cedulas) AS cedula
        WHERE cedula IN (SELECT cedula FROM empleadosdepartamentos WHERE departamentoId = p_departamentoId AND enabled=true)
    ) INTO empleado_in_department;

    -- Si ya hay un empleado en el departamento, se levanta la excepción.
    IF empleado_in_department THEN
        RAISE EXCEPTION 'There is a cedula that is already in the department.'  USING ERRCODE = 'P0003';
    END IF;

	-- Tiempo para realización del cambio de departamento
    newValidTo := CURRENT_TIMESTAMP;

	-- Se desinscriben los empleados de los departamentos viejos.
    UPDATE empleadosdepartamentos
    SET validto = newValidTo,
        enabled = false
    WHERE cedula = ANY (p_cedulas) AND enabled=true; 
    
    -- Se insertan los empleados en el departamento en una sola operación.
    INSERT INTO empleadosdepartamentos (cedula, departamentoid, validfrom, validto, enabled)
    SELECT cedula, p_departamentoid, newValidTo, NULL, TRUE
    FROM unnest(p_cedulas) AS cedula;
END;
$$;