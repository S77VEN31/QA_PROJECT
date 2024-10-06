CREATE OR REPLACE FUNCTION getquincenas(
    p_fechapago DATE,
    p_cedula INT,
    p_departamentoId SMALLINT
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
    enabled BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT p.pagoid, p.salarioid, p.cedula, (n.nombre || ' ' || a1.apellido || ' ' || a2.apellido) AS nombre,
		   ed.departamentoId, d.depnombre, s.salariobruto,
           p.fechapago, p.pateym, p.pativm, p.obreym, p.obrivm, p.obrbanco, 
           p.obrsolidarista, p.resaguinaldo, p.rescesantia, p.resvacaciones, 
           p.impuestorenta, p.enabled
    FROM public.pagos p
    INNER JOIN empleadosdepartamentos ed ON ed.cedula = p.cedula
	INNER JOIN empleados e ON e.cedula = p.cedula
	INNER JOIN salarios s ON s.salarioid = p.salarioid
	INNER JOIN nombres n ON n.nombreId = e.nombreId
	INNER JOIN apellidos a1 ON a1.apellidoId = e.apellido1Id
	INNER JOIN apellidos a2 ON a2.apellidoId = e.apellido2Id
    INNER JOIN departamentos d ON d.departamentoId = ed.departamentoId
    WHERE (p_fechapago IS NULL OR p.fechapago = p_fechapago)
      AND (p_cedula IS NULL OR p.cedula = p_cedula)
      AND (p_departamentoId IS NULL OR d.departamentoId = p_departamentoId);
END;
$$;

DROP FUNCTION getquincenas(date, integer, smallint)

SELECT * FROM getquincenas('2024-10-5'::DATE, NULL::INT, NULL::SMALLINT)
