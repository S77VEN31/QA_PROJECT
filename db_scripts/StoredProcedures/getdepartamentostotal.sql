-- Función que retorna los montos totales para el salariobruto y las deducciones
-- para cada departamento.
-- Recibe fecha de inicio y fin de filtro,
-- el punto a partir del cual se van a empezar a retornar registros,
-- el límite de resultados que retorna la función.
-- La función retorna registros con el nombre del departamento,
-- la cédula del empleado y su nombre, el salario bruto, la cantidad de hijos,
-- si tiene cónyugue, el porcentaje de la asociacón solidarista,
-- y desde cuando está el empleado en el departamento
CREATE OR REPLACE FUNCTION getdepartamentostotal(
    p_fechapago DATE,
	p_fechafin DATE,
	p_start INT,
	p_limit INT
)
RETURNS TABLE (
	depnombre TEXT,
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
	l_fechafin DATE;
	l_start INT;
	queryStr TEXT;
BEGIN
	queryStr := '
    SELECT d.depnombre, SUM(s.salariobruto) salariobruto,
           SUM(p.pateym), SUM(p.pativm), SUM(p.obreym), SUM(p.obrivm), SUM(p.obrbanco), 
           SUM(p.obrsolidarista), SUM(p.resaguinaldo), SUM(p.rescesantia), SUM(p.resvacaciones), 
           SUM(p.impuestorenta)
    FROM public.pagos p
    INNER JOIN empleadosdepartamentos ed ON ed.cedula = p.cedula
    INNER JOIN salarios s ON s.salarioid = p.salarioid
    INNER JOIN departamentos d ON d.departamentoId = ed.departamentoId
    ';

	-- Filtro del pago 
	IF p_fechapago IS NOT NULL THEN
		IF p_fechafin IS NULL THEN
			l_fechafin := p_fechapago;
		ELSE
			l_fechafin := p_fechafin;
		END IF;
		queryStr := queryStr || ' WHERE p.fechapago BETWEEN $1 AND $2';
	ELSE
		IF p_fechafin IS NOT NULL THEN
			l_fechafin := p_fechafin;
			queryStr := queryStr || ' WHERE p.fechapago <= $2';
		END IF;
	END IF;

	queryStr := queryStr || ' GROUP BY d.departamentoId HAVING SUM(s.salariobruto) IS NOT NULL';

	-- Establecer punto de inicio
	IF p_start IS NULL THEN
		l_start := 0;
	ELSE
		l_start := p_start;
	END IF;

	-- Establecer límite
	IF p_limit IS NOT NULL THEN
		queryStr := queryStr || ' LIMIT ' || p_limit::TEXT;
	END IF;

	queryStr := queryStr || ' OFFSET ' || l_start::TEXT;
    -- Execute the dynamic query
    RETURN QUERY EXECUTE queryStr USING p_fechapago, l_fechafin;
END;
$$;

DROP FUNCTION getdepartamentostotal(date, date, integer, integer)

SELECT * FROM getdepartamentostotal('2024-10-14'::DATE, NULL::DATE, NULL::INT, NULL::INT)
SELECT * FROM getdepartamentostotal(NULL::DATE, NULL::DATE, NULL::INT, NULL::INT)
SELECT * FROM getdepartamentostotal('2024-10-14'::DATE, '2024-10-28'::DATE, NULL::INT, NULL::INT)
SELECT * FROM getdepartamentostotal(NULL::DATE, NULL::DATE, NULL::INT, 9::INT)
SELECT * FROM getdepartamentostotal(NULL::DATE, NULL::DATE, 9::INT, 9::INT)
SELECT * FROM getdepartamentostotal(NULL::DATE, NULL::DATE, 18::INT, 9::INT)
SELECT * FROM getdepartamentostotal(NULL::DATE, NULL::DATE, 25::INT, 9::INT)

SELECT d.depnombre, SUM(s.salariobruto) salariobruto,
           SUM(p.pateym), SUM(p.pativm), SUM(p.obreym), SUM(p.obrivm), SUM(p.obrbanco), 
           SUM(p.obrsolidarista), SUM(p.resaguinaldo), SUM(p.rescesantia), SUM(p.resvacaciones), 
           SUM(p.impuestorenta)
    FROM public.pagos p
    INNER JOIN empleadosdepartamentos ed ON ed.cedula = p.cedula
    INNER JOIN salarios s ON s.salarioid = p.salarioid
    INNER JOIN departamentos d ON d.departamentoId = ed.departamentoId
	 GROUP BY d.departamentoId HAVING SUM(s.salariobruto) IS NOT NULL