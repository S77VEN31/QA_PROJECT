CREATE OR REPLACE FUNCTION getDepartamentosEmpleados(
	p_departamentoid SMALLINT,
	p_cedula INT,
 	p_start INT,
	p_limit INT
)
RETURNS TABLE (
	depnombre TEXT,
	cedula INT,
	nombre TEXT,
	salariobruto INT,
	hijos SMALLINT,
	conyuge BOOLEAN,
	obrsolidarista NUMERIC,
	validfrom DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
	queryStr TEXT;
    dept_exists BOOLEAN;
	l_start INT;
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

	queryStr := '
		SELECT d.depnombre AS depnombre,
			e.cedula AS cedula,
			(n.nombre || '' '' || a1.apellido || '' '' || a2.apellido) AS nombre,
			s.salariobruto AS salariobruto,
			s.hijos AS hijos,
			s.conyuge AS conyuge,
			s.obrsolidarista AS obrsolidarista,
			ed.validfrom::DATE AS validfrom
        FROM empleados e
        INNER JOIN nombres n ON n.nombreId = e.nombreId
        INNER JOIN apellidos a1 ON a1.apellidoId = e.apellido1Id
        INNER JOIN apellidos a2 ON a2.apellidoId = e.apellido2Id
		INNER JOIN empleadosdepartamentos ed ON e.cedula = ed.cedula
		INNER JOIN departamentos d ON d.departamentoId = ed.departamentoId
		INNER JOIN salarios s ON s.cedula = e.cedula
        WHERE s.enabled = TRUE AND ed.enabled = TRUE
		AND ed.departamentoId = $1
	';

	IF p_cedula IS NOT NULL THEN
		queryStr = queryStr || ' AND e.cedula = $2';
	END IF;
	
	IF p_start IS NULL THEN
		l_start := 0;
	ELSE
		l_start := p_start;
	END IF;

	queryStr := queryStr || ' ORDER BY e.cedula';
	
	IF p_limit IS NOT NULL THEN
		queryStr := queryStr || ' LIMIT ' || p_limit::TEXT;
	END IF;

	queryStr := queryStr || ' OFFSET ' || l_start::TEXT;
    -- Execute the dynamic query
    RETURN QUERY EXECUTE queryStr USING p_departamentoId, p_cedula;
END;
$$;

DROP FUNCTION getdepartamentosempleados(smallint)


SELECT * FROM getdepartamentosempleados(1::SMALLINT, NULL::INT, 18::INT, 9::INT)
	