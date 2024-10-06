CREATE OR REPLACE FUNCTION getquincenastotal(
    p_fechapago DATE,
    p_cedula INT,
    p_departamentoId SMALLINT
)
RETURNS TABLE (
	salarioBruto BIGINT,
    pateym NUMERIC,
    pativm NUMERIC,
    obreym NUMERIC,
    obrivm NUMERIC,
    obrbanco NUMERIC,
    obrsolidarista NUMERIC,
    resaguinaldo NUMERIC,
    rescesantia NUMERIC,
    resvacaciones NUMERIC,
    impuestorenta NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
	queryStr TEXT;
	has_grouping BOOLEAN := FALSE;
	group_by_fechapago BOOLEAN := FALSE;
	group_by_cedula BOOLEAN := FALSE;
	group_by_departamentoId BOOLEAN := FALSE;
BEGIN

	IF p_fechapago IS NOT NULL THEN
		group_by_fechapago := TRUE;
	END IF;

	IF p_cedula IS NOT NULL THEN
		group_by_cedula := TRUE;
	END IF;

	IF p_departamentoId IS NOT NULL THEN
		group_by_departamentoId := TRUE;
	END IF;

	queryStr := '
    SELECT SUM(s.salariobruto),
           SUM(p.pateym), SUM(p.pativm), SUM(p.obreym), SUM(p.obrivm), SUM(p.obrbanco), 
           SUM(p.obrsolidarista), SUM(p.resaguinaldo), SUM(p.rescesantia), SUM(p.resvacaciones), 
           SUM(p.impuestorenta)
    FROM public.pagos p
    INNER JOIN empleadosdepartamentos ed ON ed.cedula = p.cedula
    INNER JOIN empleados e ON e.cedula = p.cedula
    INNER JOIN salarios s ON s.salarioid = p.salarioid
    INNER JOIN nombres n ON n.nombreId = e.nombreId
    INNER JOIN apellidos a1 ON a1.apellidoId = e.apellido1Id
    INNER JOIN apellidos a2 ON a2.apellidoId = e.apellido2Id
    INNER JOIN departamentos d ON d.departamentoId = ed.departamentoId
    WHERE ($1 IS NULL OR p.fechapago = $1)
      AND ($2 IS NULL OR p.cedula = $2)
      AND ($3 IS NULL OR d.departamentoId = $3)
    ';
	
    IF group_by_cedula THEN
        queryStr := queryStr || ' GROUP BY p.cedula';
        has_grouping := TRUE;
    END IF;
    
    IF group_by_departamentoId THEN
        IF has_grouping THEN
            queryStr := queryStr || ', ed.departamentoId';
        ELSE
            queryStr := queryStr || ' GROUP BY ed.departamentoId';
            has_grouping := TRUE;
        END IF;
    END IF;

    IF group_by_fechapago THEN
        IF has_grouping THEN
            queryStr := queryStr || ', p.fechapago';
        ELSE
            queryStr := queryStr || ' GROUP BY p.fechapago';
            has_grouping := TRUE;
        END IF;
    END IF;

    -- Execute the dynamic query
    RETURN QUERY EXECUTE queryStr USING p_fechapago, p_cedula, p_departamentoId;
END;
$$;

DROP FUNCTION getquincenastotal(date, integer, smallint)

SELECT * FROM getquincenastotal(NULL::DATE, NULL::INT, 3::SMALLINT)

SELECT * FROM salarios ORDER BY salariobruto DESC LIMIT 3