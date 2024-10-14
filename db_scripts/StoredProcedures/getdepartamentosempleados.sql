-- Función para obtener los empleados en un departamento específico.
-- Se recibe el id del departamento, una cédula que es opcional,
-- el punto a partir del cual se van a empezar a retornar registros,
-- el límite de resultados que retorna la función.
-- La función retorna registros con el nombre del departamento,
-- la cédula del empleado y su nombre, el salario bruto, la cantidad de hijos,
-- si tiene cónyuge, el porcentaje de la asociación solidarista,
-- y desde cuándo está el empleado en el departamento.
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
    -- Revisar si existe el departamento
    SELECT EXISTS (
        SELECT 1
        FROM departamentos
        WHERE departamentoid = p_departamentoid
    ) INTO dept_exists;

    -- Levantar una excepción si no existe el departamento
    IF NOT dept_exists THEN
        RAISE EXCEPTION 'Department with ID % does not exist', p_departamentoid;
    END IF;

	-- Consulta:
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

	-- Si viene la cédula, se hace el filtro
	IF p_cedula IS NOT NULL THEN
		queryStr = queryStr || ' AND e.cedula = $2';
	END IF;

	-- Si no hay inicio, empieza desde el primer registro
	IF p_start IS NULL THEN
		l_start := 0;
	ELSE
		l_start := p_start;
	END IF;

	queryStr := queryStr || ' ORDER BY e.cedula';

	-- Si hay límite, lo establece. Si no, retorna todos los registros.
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
	