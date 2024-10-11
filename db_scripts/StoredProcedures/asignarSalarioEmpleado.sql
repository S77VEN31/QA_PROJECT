DROP PROCEDURE IF EXISTS AsignarSalarioEmpleado;
CREATE OR REPLACE PROCEDURE AsignarSalarioEmpleado(
    IN p_cedula INT,
    IN p_salario INT,
	IN p_hijos SMALLINT,
	IN p_conyuge BOOLEAN,
	IN p_solidarista NUMERIC(4,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
	actual_time TIMESTAMP;
    emp_exists BOOLEAN;
BEGIN
    -- Check if the department exists
    SELECT EXISTS (
        SELECT 1
        FROM empleados
        WHERE cedula = p_cedula
    ) INTO emp_exists;

    -- Raise an exception if the department does not exist
    IF NOT emp_exists THEN
        RAISE EXCEPTION 'Employee with ID % does not exist', p_cedula;
    END IF;

	actual_time := CURRENT_TIMESTAMP;
	
	UPDATE salarios
	SET enabled = false, validto = actual_time
	WHERE salarios.cedula = p_cedula
	AND salarios.enabled = true;

	INSERT INTO salarios(
	cedula, salariobruto, hijos, conyuge, obrsolidarista, validfrom, validto, enabled)
	SELECT
		p_cedula,
		COALESCE(p_salario, s.salariobruto),
		COALESCE(p_hijos, s.hijos),
		COALESCE(p_conyuge, s.conyuge),
		COALESCE(p_solidarista, s.obrsolidarista),
		CURRENT_TIMESTAMP, NULL, true
	FROM salarios s
	WHERE s.cedula = p_cedula
	AND s.validto = actual_time;
END;
$$;

INSERT INTO departamentos (depnombre)
    VALUES ('Departamento Pruebas');

SELECT * FROM DEPARTAMENTOS

INSERT INTO public.empleadosdepartamentos(
	cedula, departamentoid, validfrom, enabled)
	VALUES (105750751, 25, CURRENT_TIMESTAMP, TRUE),
	(106500405, 25, CURRENT_TIMESTAMP, TRUE);

CALL AsignarSalarioEmpleado(106500405::INT, 1000000::int, 2::smallint, True, 1::numeric(4,2));
CALL AsignarSalarioEmpleado(106500405::INT, 1000000::int, 3::smallint, NULL, NULL::numeric(4,2));
CALL AsignarSalarioEmpleado(106500405::INT, NULL::int, 3::smallint, FALSE, NULL::numeric(4,2));
CALL AsignarSalarioEmpleado(106500405::INT, 2000000::int, NULL::smallint, NULL, 5::numeric(4,2));

SELECT * FROM salarios WHERE cedula = 106500405 ORDER BY salarioid;
