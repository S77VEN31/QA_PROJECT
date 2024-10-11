DROP PROCEDURE IF EXISTS AsignarSalarioDepartamento;
CREATE OR REPLACE PROCEDURE public.asignarsalariodepartamento(IN p_departamentoid smallint, IN p_salario integer, IN p_hijos smallint, IN p_conyuge boolean, IN p_solidarista numeric)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	actual_time TIMESTAMP;
    dept_exists BOOLEAN;
BEGIN
    -- Check if the department exists
    SELECT EXISTS (
        SELECT 1
        FROM departamentos
        WHERE departamentoid = p_departamentoid
    ) INTO dept_exists;

    -- Raise an exception if the department does not exist
    IF NOT dept_exists THEN
        RAISE EXCEPTION 'Department with ID % does not exist', p_departamentoid;
    END IF;

	actual_time := CURRENT_TIMESTAMP;
	
	UPDATE salarios
	SET enabled = false, validto = actual_time
	FROM empleadosdepartamentos
	WHERE salarios.cedula = empleadosdepartamentos.cedula
	AND salarios.enabled = true
	AND empleadosdepartamentos.departamentoid = p_departamentoid;

	INSERT INTO salarios(
	cedula, salariobruto, hijos, conyuge, obrsolidarista, validfrom, validto, enabled)
	SELECT
		ed.cedula,
		COALESCE(p_salario, s.salariobruto),
		COALESCE(p_hijos, s.hijos),
		COALESCE(p_conyuge, s.conyuge),
		COALESCE(p_solidarista, s.obrsolidarista),
		CURRENT_TIMESTAMP, NULL, true
	FROM empleadosdepartamentos ed
	INNER JOIN salarios s ON s.cedula = ed.cedula
	WHERE ed.departamentoId = p_departamentoid
	AND s.validto = actual_time;
END;
$procedure$