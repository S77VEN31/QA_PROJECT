CREATE OR REPLACE PROCEDURE public.asignarsalarioporcedula(IN p_cedula integer, IN p_departamentoid smallint, IN p_salario integer, IN p_hijos smallint, IN p_conyuge boolean, IN p_solidarista numeric)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    actual_time TIMESTAMP;
    emp_dept_exists BOOLEAN;
BEGIN
    -- Verificar si la cédula y el departamento existen en la tabla empleadosdepartamentos
    SELECT EXISTS (
        SELECT 1
        FROM empleadosdepartamentos
        WHERE cedula = p_cedula
        AND departamentoid = p_departamentoid
    ) INTO emp_dept_exists;

    -- Levantar una excepción si la cédula no está asignada al departamento
    IF NOT emp_dept_exists THEN
        RAISE EXCEPTION 'Employee with cedula % is not assigned to department %', p_cedula, p_departamentoid;
    END IF;

    -- Obtener el tiempo actual
    actual_time := CURRENT_TIMESTAMP;

    -- Desactivar el salario actual del empleado en ese departamento
    UPDATE salarios
    SET enabled = false, validto = actual_time
    FROM empleadosdepartamentos
    WHERE salarios.cedula = empleadosdepartamentos.cedula
    AND salarios.enabled = true
    AND empleadosdepartamentos.departamentoid = p_departamentoid
    AND empleadosdepartamentos.cedula = p_cedula;

    -- Insertar el nuevo salario para el empleado en el departamento
    INSERT INTO salarios (
        cedula, salariobruto, hijos, conyuge, obrsolidarista, validfrom, validto, enabled
    )
    SELECT
        ed.cedula,
        COALESCE(p_salario, s.salariobruto),
        COALESCE(p_hijos, s.hijos),
        COALESCE(p_conyuge, s.conyuge),
        COALESCE(p_solidarista, s.obrsolidarista),
        CURRENT_TIMESTAMP, NULL, true
    FROM empleadosdepartamentos ed
    INNER JOIN salarios s ON s.cedula = ed.cedula
    WHERE ed.cedula = p_cedula
    AND ed.departamentoid = p_departamentoid
    AND s.validto = actual_time;
END;
$procedure$
