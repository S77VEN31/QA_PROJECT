/* Función para obtener la información detallada de las quincenas.
Recibe:
la fecha del pago, la cual puede servir para filtrar directamente por esa fecha
o como el inicio de un rango de fechas.
la fecha del fin del rango de fechas por filtrar. Si solo viene la fecha del fin, sin
fecha de inicio, se escogen todas las quincenas hasta la fecha del fin.
la cédula del empleado: filtra las pagos realizados al empleado.
el id del departamento: Filtra los pagos realizados a los empleados del departamento.
el punto a partir del cual se van a empezar a retornar registros,
el límite de resultados que retorna la función.
Cualquiera o todos de estos valores podrían venir NULL, lo que significa que no se aplican filtros ni límites.
Así, se pueden combinar los filtros deseados.
Retorna los registros con los datos del empleado como la cédula, el nombre, el salario bruto
y las deducciones aplicadas a cada empleado, ya sean las obrero, patronales y las reservas patronales.
También devuelve el impuesto de renta y un booleano llamado créditos fiscales para 
señalar si al impuesto de renta se le hicieron deducciones por el tema de beneficios
fiscales.
*/
CREATE OR REPLACE FUNCTION getquincenas(
    p_fechapago DATE,
	p_fechafin DATE,
    p_cedula INT,
    p_departamentoId SMALLINT,
	p_start INT,
	p_limit INT
)
RETURNS TABLE (
    pagoid INT,
    salarioid INT,
    cedula INT,
	nombre TEXT,
    departamentoId SMALLINT,
    depnombre TEXT,
	salariobruto INT,
    fechapago TIMESTAMP,
    pateym NUMERIC(13, 4),
    pativm NUMERIC(13, 4),
    obreym NUMERIC(13, 4),
    obrivm NUMERIC(13, 4),
    obrbanco NUMERIC(13, 4),
    obrsolidarista NUMERIC(13, 4),
    resaguinaldo NUMERIC(13, 4),
    rescesantia NUMERIC(13, 4),
    resvacaciones NUMERIC(13, 4),
    impuestorenta NUMERIC(13, 4),
    enabled BOOLEAN,
	creditosfiscales BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
	l_fechafin DATE;
	l_start INT;
	queryStr TEXT;
BEGIN
	-- query: se hacen todos los joins con las tablas escogidas.
	-- Se relaciona el departamento a devolver de acuerdo con la fecha del pago de la quincena
	-- y el intervalo a partir del cual el empleado fue miembro del departamento. Esto se realiza por medio la primera cláusula del where.
	queryStr := '
	SELECT p.pagoid, p.salarioid, p.cedula, (n.nombre || '' '' || a1.apellido || '' '' || a2.apellido) AS nombre,
           ed.departamentoId, d.depnombre, s.salariobruto,
           p.fechapago, p.pateym, p.pativm, p.obreym, p.obrivm, p.obrbanco, 
           p.obrsolidarista, p.resaguinaldo, p.rescesantia, p.resvacaciones, 
           p.impuestorenta, p.enabled,
		   CASE
		   		WHEN s.hijos > 0 OR s.conyuge = TRUE THEN TRUE
				ELSE FALSE
			END AS creditosfiscales
    FROM public.pagos p
    INNER JOIN empleadosdepartamentos ed ON ed.cedula = p.cedula
	INNER JOIN empleados e ON e.cedula = p.cedula
	INNER JOIN salarios s ON s.salarioid = p.salarioid
	INNER JOIN nombres n ON n.nombreId = e.nombreId
	INNER JOIN apellidos a1 ON a1.apellidoId = e.apellido1Id
	INNER JOIN apellidos a2 ON a2.apellidoId = e.apellido2Id
    INNER JOIN departamentos d ON d.departamentoId = ed.departamentoId
	WHERE p.fechapago BETWEEN ed.validfrom AND COALESCE(ed.validto, (CURRENT_DATE + INTERVAL ''5 years''))
	';

	-- Si hay punto de inicio, lo establece	
	IF p_start IS NULL THEN
		l_start := 0;
	ELSE
		l_start := p_start;
	END IF;

	-- Si hay filtro por fecha de inicio
	IF p_fechapago IS NOT NULL THEN
		-- Si no hay filtro por fecha fin, se filtra solo por la fecha de inicio
		IF p_fechafin IS NULL THEN
			l_fechafin := p_fechapago;
		ELSE
			-- Si hay fecha fin, se filtra por rango de fechas.
			l_fechafin := p_fechafin;
		END IF;
		-- Se agrega el filtro al query
		queryStr := queryStr || ' AND (p.fechapago::DATE BETWEEN $1 AND $2)';
	ELSE
		-- Si hay fecha de fin y no hay fecha de inicio, se agarran todos los anteriores a la fecha fin.
		IF p_fechafin IS NOT NULL THEN
			l_fechafin := p_fechafin;
			queryStr := queryStr || ' AND p.fechapago::DATE <= $2';
		END IF;
	END IF;

	-- Se agrega el filtro por cédula
	IF p_cedula IS NOT NULL THEN
		queryStr := queryStr || ' AND p.cedula = $3';
	END IF;

	-- Se agrega el filtro por departamento
	IF p_departamentoId IS NOT NULL THEN
		queryStr := queryStr || ' AND d.departamentoId = $4';
	END IF;

	-- Se ordena por pagoid
	queryStr := queryStr || ' ORDER BY p.pagoid';

	-- Se establece el límite máximo de registros a retornar.
	IF p_limit IS NOT NULL THEN
		queryStr := queryStr || ' LIMIT ' || p_limit::TEXT;
	END IF;

	-- El offset ignora los primeros l_start registros
	queryStr := queryStr || ' OFFSET ' || l_start::TEXT;
	
    RETURN QUERY EXECUTE queryStr
	USING p_fechapago, l_fechafin, p_cedula, p_departamentoId, l_start;
END;
$$;

DROP FUNCTION getquincenas(date, date, integer, smallint, integer, integer);

SELECT * FROM getquincenas(NULL::DATE, NULL::DATE, NULL::INT, NULL::SMALLINT, NULL::INT, NULL::INT) ORDER BY pagoid DESC LIMIT 1;

SELECT * FROM getquincenas('2024-10-28'::DATE, NULL::DATE, 106500405::INT, NULL::SMALLINT, NULL::INT, null::INT)
SELECT * FROM getquincenas('2024-12-28'::DATE, NULL::DATE, NULL::INT, NULL::SMALLINT, NULL::INT, 100::INT)
SELECT * FROM getquincenas(NULL::DATE, NULL::DATE, NULL::INT, 3::SMALLINT, 9::INT, 9::INT)


SELECT COUNT(*) FROM empleadosdepartamentos GROUP BY departamentoId;

SELECT * FROM pagos WHERE cedula = 106500405
SELECT * FROM pagos p INNER JOIN salarios s ON s.salarioid = p.salarioid where p.cedula = 106500405 

SELECT COUNT(*) FROM pagos
SELECT DISTINCT fechapago FROM pagos


