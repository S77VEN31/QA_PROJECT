/* Función que retorna la información resumida o total de las quincenas.
Recibe:
la fecha del pago, la cual puede servir para filtrar directamente por esa fecha
o como el inicio de un rango de fechas.
la fecha del fin del rango de fechas por filtrar. Si solo viene la fecha del fin, sin
fecha de inicio, se escogen todas las quincenas hasta la fecha del fin.
la cédula del empleado: filtra los pagos realizados al empleado.
el id del departamento: Filtra los pagos realizados a los empleados del departamento.
Cualquiera o todos de estos valores podrían venir NULL, lo que significa que no se aplican filtros ni límites.
Así, se pueden combinar los filtros deseados.
Retorna el registro con la suma de los salarios brutos y todas las deducciones obrero y patronales, las reservas patronales
y los impuestos sobre la renta.
*/
CREATE OR REPLACE FUNCTION getquincenastotal(
    p_fechapago DATE,
	p_fechafin DATE,
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
	has_where BOOLEAN := FALSE;
	has_grouping BOOLEAN := FALSE;
	l_fechafin DATE;
BEGIN
	queryStr := '
    SELECT SUM(s.salariobruto) salariobruto,
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
    ';

	-- Filtro por fecha
	IF p_fechapago IS NOT NULL THEN
		-- Si la fechafin es null, se filtra solo por la fecha de inicio
		IF p_fechafin IS NULL THEN
			l_fechafin := p_fechapago;
		ELSE
			-- Se filtra por rango de fechas
			l_fechafin := p_fechafin;
		END IF;
		queryStr := queryStr || ' WHERE p.fechapago BETWEEN $1 AND $2';
		has_where := TRUE;
	ELSE
		-- Si hay fecha fin, se filtra hasta la fecha fin
		IF p_fechafin IS NOT NULL THEN
			l_fechafin := p_fechafin;
			queryStr := queryStr || ' WHERE p.fechapago <= $2';
			has_where := TRUE;
		END IF;
	END IF;

	-- Se filtra por cédula
	IF p_cedula IS NOT NULL THEN
		IF has_where = TRUE THEN
			queryStr := queryStr || ' AND p.cedula = $3';
		ELSE
			queryStr := queryStr || ' WHERE p.cedula = $3';
			has_where := TRUE;
		END if;
	END IF;

	-- Se filtra por departamento
	IF p_departamentoId IS NOT NULL THEN
		IF has_where = TRUE THEN
			queryStr := queryStr || ' AND d.departamentoId = $4';
		ELSE 
			queryStr := queryStr || ' WHERE d.departamentoId = $4';
			has_where := TRUE;
		END IF;
	END IF;

	-- El having hace que se retorna una lista vacía si el resultado de la suma es nulo.
	queryStr := queryStr || ' HAVING SUM(s.salariobruto) IS NOT NULL';
    -- Execute the dynamic query
    RETURN QUERY EXECUTE queryStr USING p_fechapago, l_fechafin, p_cedula, p_departamentoId;
END;
$$;

DROP FUNCTION getquincenastotal(date, integer, smallint)

SELECT * FROM getquincenastotal('2024-11-14'::DATE, NULL::DATE, NULL::INT, NULL::SMALLINT)
SELECT * FROM getquincenastotal(NULL::DATE, NULL::DATE, NULL::INT, NULL::SMALLINT)
SELECT * FROM getquincenastotal(NULL::DATE, '2024-10-05'::DATE, NULL::INT, NULL::SMALLINT)
SELECT * FROM getquincenastotal(NULL::DATE, NULL::DATE, 105750751::INT, NULL::SMALLINT)
SELECT * FROM getquincenastotal(NULL::DATE, NULL::DATE, NULL::INT, 10::SMALLINT)
SELECT * FROM getquincenas(NULL::DATE, NULL::DATE, 100022263::INT, 3::SMALLINT, NULL::INT, NULL::INT);

SELECT * FROM salarios ORDER BY salariobruto DESC LIMIT 3

SELECT SUM(s.salariobruto) salariobruto,
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
	WHERE p.fechapago::DATE = '2024-11-05'
	HAVING SUM(s.salariobruto) IS NOT NULL