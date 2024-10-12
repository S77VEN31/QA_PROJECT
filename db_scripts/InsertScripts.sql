
-- Tabla temporal
DROP TABLE IF EXISTS Empleado;
CREATE TABLE Empleado (
    cedula TEXT,
    nombre TEXT,
    apellido1 TEXT,
    apellido2 TEXT,
    salario TEXT,
    fecha_nacimiento TEXT,
    Organizacion TEXT,
    Departamento TEXT
);

SELECT COUNT(*) FROM Empleado;
SELECT * FROM Empleado;

-- Tabla EmpleadoOpt
DROP TABLE IF EXISTS EmpleadoOptimizado;
CREATE TABLE IF NOT EXISTS EmpleadoOptimizado (
    cedula INTEGER PRIMARY KEY,
    nombre TEXT,
    apellido1 TEXT,
    apellido2 TEXT,
    salario INTEGER,
    fecha_nacimiento TIMESTAMP,
    Organizacion SMALLINT,
    Departamento SMALLINT
);

INSERT INTO EmpleadoOptimizado (cedula, nombre, apellido1, apellido2, salario, fecha_nacimiento, organizacion, departamento)
SELECT CAST(cedula AS INTEGER) AS cedula,
	nombre,
	apellido1,
	apellido2,
	CAST(salario AS FLOAT) AS salario,
	CAST(fecha_nacimiento AS TIMESTAMP) AS fecha_nacimiento,
	CAST(CAST(organizacion AS FLOAT) AS INTEGER) AS organizacion,
	CAST(CAST(departamento AS FLOAT) AS INTEGER) AS departamento
FROM Empleado;

SELECT * FROM EmpleadoOptimizado;
SELECT COUNT(*) FROM EmpleadoOptimizado;

-- NOMBRES
SELECT DISTINCT nombre, count(nombre) as apariciones FROM empleadooptimizado GROUP BY nombre ORDER BY apariciones DESC;
SELECT DISTINCT nombre FROM empleadooptimizado;

DROP TABLE IF EXISTS nombres;
CREATE TABLE IF NOT EXISTS public.nombres
(
	nombreId SERIAL PRIMARY KEY,
	nombre TEXT
);

INSERT INTO nombres (nombre)
SELECT DISTINCT nombre FROM empleadooptimizado;

SELECT* FROM nombres;
CREATE INDEX idx_nombre ON public.nombres (nombre);

SELECT empleadooptimizado.cedula, nombres.nombre, nombres.nombreId FROM public.empleadooptimizado INNER JOIN nombres ON empleadooptimizado.nombre = nombres.nombre;

-- APELLIDOS
DROP TABLE apellidos;
CREATE TABLE IF NOT EXISTS public.apellidos
(
	apellidoId SERIAL PRIMARY KEY,
	apellido TEXT
);

INSERT INTO apellidos (apellido)
SELECT DISTINCT apellido1 FROM empleadooptimizado
UNION
SELECT DISTINCT apellido2 FROM empleadooptimizado;

CREATE INDEX idx_apellido ON public.apellidos (apellido);
SELECT * FROM apellidos;

-- ORGANIZACIONES
DROP TABLE IF EXISTS organizaciones;
CREATE TABLE IF NOT EXISTS public.organizaciones
(
	organizacionId SMALLSERIAL PRIMARY KEY,
	orgNombre TEXT
);

INSERT INTO organizaciones (organizacionId, orgNombre)
SELECT organizacionId, ('Organizacion ' || organizacionId) AS orgNombre FROM
(SELECT DISTINCT CAST(CAST(organizacion AS FLOAT) AS INTEGER) as organizacionId
FROM empleadooptimizado) AS organizacionesTemp;

SELECT * FROM organizaciones;

CREATE INDEX idx_organizaciones ON organizaciones (orgNombre);

-- DEPARTAMENTOS
DROP TABLE IF EXISTS departamentos;
CREATE TABLE IF NOT EXISTS public.departamentos
(
	departamentoId SMALLSERIAL PRIMARY KEY,
	depNombre TEXT
);

INSERT INTO departamentos (departamentoId, depNombre)
SELECT departamentoId, ('Departamento ' || departamentoId) AS depNombre FROM
(SELECT DISTINCT CAST(CAST(departamento AS FLOAT) AS INTEGER) as departamentoId
FROM empleadooptimizado) AS departamentosTemp;

SELECT * FROM departamentos;

CREATE INDEX idx_departamentos ON departamentos (depNombre);

-- Tabla de empleados
INSERT INTO empleados (cedula, nombreid, apellido1id, apellido2id, fechanacimiento, organizacionid)
SELECT CAST(cedula AS INTEGER) AS cedula,
	nombres.nombreId,
	apellidos1.apellidoId,
	apellidos2.apellidoId,
	CAST(empleadooptimizado.fecha_nacimiento AS TIMESTAMP) AS fecha_nacimiento,
	CAST(CAST(organizacion AS FLOAT) AS INTEGER) AS organizacion
FROM EmpleadoOptimizado INNER JOIN nombres ON nombres.nombre = empleadooptimizado.nombre
INNER JOIN apellidos as apellidos1 ON apellidos1.apellido = empleadooptimizado.apellido1
INNER JOIN apellidos as apellidos2 ON apellidos2.apellido = empleadooptimizado.apellido2;

SELECT * FROM empleados
INNER JOIN nombres ON nombres.nombreid = empleados.nombreid
INNER JOIN apellidos as apellidos1 ON apellidos1.apellidoid = empleados.apellido1id
INNER JOIN apellidos as apellidos2 ON apellidos2.apellidoid = empleados.apellido2id LIMIT 100;

-- INSERTAR EN EMPLEADOSDEPARTAMENTOS
INSERT INTO public.empleadosdepartamentos(
	cedula, departamentoid, validfrom, validto, enabled)
SELECT empleadooptimizado.cedula, empleadoOptimizado.departamento, CURRENT_DATE, NULL, true FROM empleadooptimizado;

CREATE INDEX idx_departamentoId_empleadosdepartamentos ON empleadosdepartamentos (departamentoId);
CREATE INDEX idx_cedula_empleadosdepartamentos ON empleadosdepartamentos (cedula);

-- INSERTAR SALARIOS
INSERT INTO public.salarios(
	cedula, salariobruto, validfrom, validto, enabled)
SELECT empleadooptimizado.cedula, empleadooptimizado.salario, CURRENT_DATE, NULL, true FROM empleadooptimizado;

CREATE INDEX idx_cedula_salarios ON salarios (cedula);

SELECT * from salarios limit 1

-- INSERTAR DEDUCCIONES PERSONALES
INSERT INTO public.deduccionespersonales(
	cedula, porcentaje, hijos, conyuge, validfrom, enabled)
	SELECT e.cedula, 0, 0, false, '2024-09-29 00:00:00', TRUE FROM empleados e;

CREATE INDEX idx_cedula_deduccionespersonales ON deduccionespersonales (cedula);
CREATE INDEX idx_validfrom_deduccionespersonales ON deduccionespersonales (validfrom);

-- Crear indices en tabla empleado
CREATE INDEX idx_nombre_empleados ON empleados (nombreId);
CREATE INDEX idx_apellido1_empleados ON empleados (apellido1Id);
CREATE INDEX idx_apellido2_empleados ON empleados (apellido2Id);

CREATE INDEX idx_organizacionId_empleados on empleados (organizacionId);


-- DEDUCCIONES PATRONALES
INSERT INTO public.deduccionespatronales(
	pativm, pateym, validfrom, validto, enabled)
	VALUES (5.42, 9.25, CURRENT_DATE, NULL, true);
	

SELECT * FROM deduccionespatronales

-- DEDUCCIONES OBRERO
INSERT INTO public.deduccionesobrero(
	obrivm, obreym, obrbanco, validfrom, validto, enabled)
	VALUES (4.17, 5.5, 1.0, CURRENT_DATE, null, true);

select * from deduccionesobrero;

-- RESERVAS PATRONALES
INSERT INTO public.reservaspatronales(
	resaguinaldo, validfrom, validto, enabled, rescesantia, resvacaciones)
	VALUES
	(8.33, CURRENT_DATE, NULL, true, 6.33, 4.16);

SELECT * FROM reservaspatronales;
-- IMPUESTO DE RENTA AL SALRIO
INSERT INTO public.impuestorenta(
	impuestominimo, impuestomaximo, impuestoporcentaje, validfrom, validto, enabled)
	VALUES
(0.00, 929000.00, 0.0, CURRENT_DATE, NULL, true),
(929000.00, 1363000.00, 10, CURRENT_DATE, NULL, true),
(1363000.00, 2392000.00, 15, CURRENT_DATE, NULL, true),
(2392000.00, 4783000.00, 20, CURRENT_DATE, NULL, true),
(4783000.00, 999999999.00, 25, CURRENT_DATE, NULL, true);

SELECT * FROM impuestoRenta;

-- CREDITOS FISCALES
INSERT INTO public.creditosfiscales(
	credhijos, credconyuge, validfrom, enabled)
	VALUES (1730, 2620, '2024-09-29 00:00:00', TRUE);

SELECT * FROM salarios CROSS JOIN impuestoRenta LIMIT 100;
SELECT
	s.cedula,
	s.salarioid,
    s.salariobruto,
    -- Calculate the tax by multiplying taxable amount by impuestoporcentaje
	SUM(
		(CASE
	        WHEN s.salariobruto > ir.impuestominimo THEN
	            LEAST(s.salariobruto, ir.impuestomaximo) - ir.impuestominimo
	        ELSE
	            0
	    END * ir.impuestoporcentaje / 100)
	) AS tax
FROM
    salarios s
CROSS JOIN
    impuestorenta ir
WHERE
    ir.enabled = true
GROUP BY s.cedula, s.salarioid, s.salariobruto
LIMIT 100;


SELECT
	s.cedula,
	s.salarioid,
	s.salariobruto,
	obr.obrivm * s.salariobruto / 100 as obrivm,
	obr.obreym * s.salariobruto / 100 as obreym,
	obr.obrbanco * s.salariobruto / 100 as obrbanco,
	pat.pativm * s.salariobruto / 100 as pativm,
	pat.pateym * s.salariobruto / 100 as pateym,
	res.resaguinaldo * s.salariobruto / 100 as resaguinaldo,
	res.rescesantia * s.salariobruto / 100 as rescesantia,
	res.resvacaciones * s.salariobruto / 100 as resvacaciones,
	-- Calcular impuesto de renta sumando el porcentaje correspondiente a cada tramo
	SUM(
		(CASE
	        WHEN s.salariobruto > ir.impuestominimo THEN
	            LEAST(s.salariobruto, ir.impuestomaximo) - ir.impuestominimo
	        ELSE
	            0
	    END * ir.impuestoporcentaje / 100)
	) AS tax
FROM salarios s
CROSS JOIN
    impuestorenta ir
CROSS JOIN
	deduccionesobrero obr
CROSS JOIN 
	deduccionespatronales pat
CROSS JOIN 
	reservaspatronales res
WHERE ir.enabled = true
AND obr.enabled = true
AND pat.enabled = true
AND res.enabled = true
GROUP BY s.cedula, s.salarioid, s.salariobruto, obr.obrivm, obr.obreym, obr.obrbanco,
pat.pativm, pat.pateym, res.resaguinaldo, res.rescesantia, res.resvacaciones;


SELECT * FROM deduccionesobrero;
SELECT * FROM deduccionespatronales;
SELECT * FROM reservaspatronales;

SELECT
	s.cedula,
	s.salarioid,
    s.salariobruto,
	CASE
	    WHEN s.salariobruto > ir.impuestominimo THEN
	        LEAST(s.salariobruto, ir.impuestomaximo) - ir.impuestominimo
		ELSE
			0
	END AS taxableamount,
    -- Calculate the tax by multiplying taxable amount by impuestoporcentaje
		(CASE
	        WHEN s.salariobruto > ir.impuestominimo THEN
	            LEAST(s.salariobruto, ir.impuestomaximo) - ir.impuestominimo
	        ELSE
	            0
	    END * ir.impuestoporcentaje / 100)
	AS tax
FROM
    salarios s
CROSS JOIN
    impuestorenta ir
WHERE
    ir.enabled = true
LIMIT 100;




SELECT impuestoPorcentaje, impuestoMinimo, impuestoMaximo, e.cedula, e.salario FROM impuestoRenta
CROSS JOIN empleadoOptimo e WHERE e.salario >= CAST(impuestoMinimo AS int) AND
	e.salario < CAST(impuestoMaximo AS int);

SELECT e.cedula, COUNT(e.cedula) times FROM impuestoRenta
CROSS JOIN empleadoOptimo e WHERE e.salario >= impuestoMinimo AND
	e.salario < impuestoMaximo GROUP BY (e.cedula) HAVING COUNT(e.cedula) > 1;

SELECT pg_size_pretty(pg_indexes_size('impuestoRenta')) AS impuestoRenta;

-- PAGOS
CREATE INDEX idx_cedula_pagos ON pagos (cedula);
CREATE INDEX idx_salarioid_pagos ON pagos (salarioid);
CREATE INDEX idx_fechapago_pagos ON pagos (fechaPago);

-- De aquí para abjao no es muy importante

-- DEDUCCIONES PATRONALES POR PAGO
DROP TABLE IF EXISTS public.deduccionPatPago;
CREATE TABLE IF NOT EXISTS public.deduccionPatPago
(
	pagoId INTEGER,
	dedPatId INTEGER,
	deduccionCalculada FLOAT,
	CONSTRAINT pago_relationship
    FOREIGN KEY (pagoId)
    REFERENCES pagos (pagoId),
	CONSTRAINT deduccion_relationship
    FOREIGN KEY (dedPatId)
    REFERENCES deduccionPatronal (dedPatId)
);

CREATE INDEX idx_pagoId_deduccionPatPago ON deduccionPatPago (pagoId);

SELECT pg_size_pretty(pg_indexes_size('deduccionPatPago')) AS deduccionPatPago;

-- DEDUCCIONES DEL OBRERO POR PAGO
DROP TABLE IF EXISTS public.deduccionObrPago;
CREATE TABLE IF NOT EXISTS public.deduccionObrPago
(
	pagoId INTEGER,
	dedObrId INTEGER,
	deduccionCalculada FLOAT,
	CONSTRAINT pago_relationship
    FOREIGN KEY (pagoId)
    REFERENCES pagos (pagoId),
	CONSTRAINT deduccion_relationship
    FOREIGN KEY (dedObrId)
    REFERENCES deduccionObrero (dedObrId)
);

CREATE INDEX idx_pagoId_deduccionObrPago ON deduccionObrPago (pagoId);

SELECT pg_size_pretty(pg_indexes_size('deduccionObrPago')) AS deduccionObrPago;

-- IMPUESTO DE RENTA POR PAGO
DROP TABLE IF EXISTS public.impuestoPago;
CREATE TABLE IF NOT EXISTS public.impuestoPago
(
	pagoId INTEGER,
	impuestoId INTEGER,
	deduccionCalculada FLOAT,
	CONSTRAINT pago_relationship
    FOREIGN KEY (pagoId)
    REFERENCES pagos (pagoId),
	CONSTRAINT deduccion_relationship
    FOREIGN KEY (impuestoId)
    REFERENCES impuestoRenta (impuestoId)
);

select * from pagos where fechaPago BETWEEN '2024-04-17 12:00:00'AND  '2024-05-01 12:00:00'
SELECT COUNT(*) FROM pagos;

CREATE INDEX idx_pagoId_impuestoPago ON impuestoPago (pagoId);

SELECT pg_size_pretty(pg_indexes_size('impuestoPago')) AS impuestoPago;

-- INSERT IN PAGOS
DO $$
DECLARE
	counter SMALLINT := 0;
    fortnight_date1 TIMESTAMP := '2024-01-15 12:00:00';
    fortnight_date2 TIMESTAMP := '2024-01-30 12:00:00';
BEGIN
    WHILE counter < 2 LOOP
        INSERT INTO pagos (salarioBruto, cedula, fechaPago)
        SELECT salario, cedula, fortnight_date1
        FROM EmpleadoOptimo;
		
		INSERT INTO pagos (salarioBruto, cedula, fechaPago)
        SELECT salario, cedula, fortnight_date2
        FROM EmpleadoOptimo;
		
        fortnight_date1 := fortnight_date1 + INTERVAL '1 month';
		fortnight_date2 := fortnight_date2 + INTERVAL '1 month';
		counter := counter + 1;
    END LOOP;
END $$;

-- Insert en deducciones patronales por pago
INSERT INTO deduccionPatPago (pagoId, dedPatId, deduccionCalculada)
SELECT pagos.pagoId, deduccionPatronal.dedPatId, (pagos.salarioBruto * deduccionPatronal.dedPatPorcentaje)
FROM pagos
CROSS JOIN deduccionPatronal;

SELECT * FROM deduccionPatPago LIMIT 1000;

-- insert en deducciones obrero por pago
INSERT INTO deduccionObrPago (pagoId, dedObrId, deduccionCalculada)
SELECT pagos.pagoId, deduccionObrero.dedObrId, (pagos.salarioBruto * deduccionObrero.dedObrPorcentaje)
FROM pagos
CROSS JOIN deduccionObrero;

-- insert en deducciones por impuesto de renta por pago.
INSERT INTO impuestoPago (pagoId, impuestoId, deduccionCalculada)
SELECT pa.pagoId, impuestoRenta.impuestoId, (pa.salariobruto - impuestoMinimo) * impuestoPorcentaje FROM impuestoRenta
CROSS JOIN pagos pa WHERE pa.salariobruto >= impuestoMinimo AND pa.salariobruto < impuestoMaximo;

SELECT pa.pagoId, impuestoRenta.impuestoId, pa.salariobruto, (pa.salariobruto - impuestoMinimo) * impuestoPorcentaje FROM impuestoRenta
CROSS JOIN pagos pa WHERE pa.salariobruto >= impuestoMinimo AND pa.salariobruto < impuestoMaximo ORDER BY pagoId ASC LIMIT 100;

SELECT * FROM impuestoPago;

SELECT pagos.pagoId, impuestoPago.impuestoId FROM impuestoPago
	INNER JOIN pagos on pagos.pagoId = impuestoPago.pagoId
	WHERE salarioBruto < 4783000 AND impuestoPago.impuestoId = 5;

DELETE FROM impuestoPago
WHERE EXISTS (
    SELECT 1
    FROM pagos
    WHERE pagos.pagoId = impuestoPago.pagoId
      AND pagos.salarioBruto < 4783000
) AND impuestoId = 5;
-- Aguinaldo
INSERT INTO pagos (salarioBruto, cedula, fechaPago)
SELECT EmpleadoOptimo.salario, EmpleadoOptimo.cedula, '2024-12-24 12:00:00'
FROM EmpleadoOptimo

-- 2a
-- Indique el salario y las deducciones en una quincena específica.
WITH deduccionesPorPago AS (
SELECT empleadooptimo.cedula, empleadoOptimo.salario, 'PATRONAL' AS tipo, deduccionPatronal.dedpatnombre AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
UNION
SELECT empleadooptimo.cedula, empleadoOptimo.salario, 'OBRERO' AS tipo, deduccionObrero.dedobrnombre AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
UNION
SELECT empleadooptimo.cedula, empleadoOptimo.salario,
	'RENTA' AS tipo, CONCAT(impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
) SELECT * FROM deduccionesPorPago WHERE cedula = 100010370 AND fechaPago = '2024-1-15 12:00:00'
ORDER BY tipo;

SELECT DISTINCT pagos.fechaPago FROM pagos;
	

-- Indique el salario y las deducciones en un rango de fechas.
WITH deduccionesPorPago AS (
SELECT empleadooptimo.cedula, empleadoOptimo.salario, 'PATRONAL' AS tipo, deduccionPatronal.dedpatnombre AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
UNION
SELECT empleadooptimo.cedula, empleadoOptimo.salario, 'OBRERO' AS tipo, deduccionObrero.dedobrnombre AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
UNION
SELECT empleadooptimo.cedula, empleadoOptimo.salario,
	'RENTA' AS tipo, CONCAT(impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
) SELECT * FROM deduccionesPorPago WHERE cedula = 100010370 AND fechaPago BETWEEN '2024-01-15 12:00:00' AND '2024-03-01 12:00:00'
ORDER BY fechaPago, tipo;

--2b 
-- Indique el total de salarios y las deducciones en un rango de fechas.
SELECT departamentos.depNombre, SUM(EmpleadoOptimo.salario) salariosTotales,
	SUM(deduccionPatPago.deduccionCalculada) deduccionesPatronalesTotales,
	SUM(deduccionObrPago.deduccionCalculada) deduccionesObrerosTotales, SUM(impuestoPago.deduccionCalculada) deduccionesImpuestoRentaTotales
FROM departamentos
INNER JOIN EmpleadoOptimo on departamentos.departamentoId = empleadooptimo.departamentoid
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago on pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionObrPago on pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN impuestoPago on pagos.pagoId = impuestoPago.pagoId
WHERE departamentos.depNombre = 'Departamento 1' AND pagos.fechaPago BETWEEN '2024-01-14 12:00:00' AND '2024-02-01 12:00:00'
GROUP BY departamentos.depNombre, empleadoOptimo.departamentoId;



-- Indique el detalle de los salarios y deducciones para una quincena específica.
WITH deduccionesPorPago AS (
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'PATRONAL' AS tipo, deduccionPatronal.dedpatnombre AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'OBRERO' AS tipo, deduccionObrero.dedobrnombre AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario,
	'RENTA' AS tipo, CONCAT(impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
) SELECT * FROM deduccionesPorPago WHERE depNombre = 'Departamento 1' AND fechaPago = '2024-01-15 12:00:00'
ORDER BY cedula, tipo;

-- Indique la persona que más gana por departamento, además despliegue el detalle de las deducciones que se le hacen.
WITH deduccionesPorPago AS (
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'PATRONAL' AS tipo, deduccionPatronal.dedpatnombre AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'OBRERO', deduccionObrero.dedobrnombre AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario,
	'RENTA' AS tipo, CONCAT(impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
) SELECT deduccionesPorPago.* FROM deduccionesPorPago INNER JOIN
(WITH RankedSalaries AS (SELECT e.cedula, ROW_NUMBER() OVER (PARTITION BY e.departamentoId ORDER BY e.salario DESC) AS rank
    FROM EmpleadoOptimo e
    JOIN departamentos d ON e.departamentoId = d.departamentoId
)
SELECT cedula
FROM RankedSalaries WHERE rank = 1) AS mejoresSalarios ON mejoresSalarios.cedula = deduccionesPorPago.cedula
	WHERE depNombre = 'Departamento 1'
ORDER BY deduccionNombre;

-- Indique el monto promedio de salario y de deducciones por cada rubro, ordenado por departamento
SELECT departamentos.depNombre, AVG(EmpleadoOptimo.salario) salarioPromedio,
	AVG(deduccionPatPago.deduccionCalculada) deduccionesPatronalesPromedio,
	AVG(deduccionObrPago.deduccionCalculada) deduccionesObrerosPromedio,
	AVG(impuestoPago.deduccionCalculada) deduccionesImpuestoRentaPromedio
FROM departamentos
INNER JOIN EmpleadoOptimo on departamentos.departamentoId = empleadooptimo.departamentoid
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago on pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionObrPago on pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN impuestoPago on pagos.pagoId = impuestoPago.pagoId
WHERE departamentos.depNombre = 'Departamento 1'
GROUP BY departamentos.depNombre, empleadoOptimo.departamentoId
ORDER BY empleadoOptimo.departamentoId;

--2c
-- Indique el total de salarios y las deducciones en un rango de fechas.
SELECT departamentos.depNombre, SUM(EmpleadoOptimo.salario) salariosTotales,
	SUM(deduccionPatPago.deduccionCalculada) deduccionesPatronalesTotales,
	SUM(deduccionObrPago.deduccionCalculada) deduccionesObrerosTotales,
	SUM(impuestoPago.deduccionCalculada) deduccionesImpuestoRentaTotales
FROM departamentos
INNER JOIN EmpleadoOptimo on departamentos.departamentoId = empleadooptimo.departamentoid
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago on pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionObrPago on pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN impuestoPago on pagos.pagoId = impuestoPago.pagoId
WHERE pagos.fechaPago BETWEEN '2024-01-14 12:00:00' AND '2024-02-01 12:00:00'
GROUP BY departamentos.depNombre, empleadoOptimo.departamentoId;


-- Indique el detalle de los salarios y deducciones para una quincena específica.
WITH deduccionesPorPago AS (
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'PATRONAL' AS tipo, deduccionPatronal.dedpatnombre AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'OBRERO' AS tipo, deduccionObrero.dedobrnombre AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario,
	'RENTA' AS tipo, CONCAT(impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
) SELECT * FROM deduccionesPorPago WHERE fechaPago = '2024-01-15 12:00:00'
ORDER BY cedula, tipo;

-- Indique la persona que más gana por departamento, además despliegue el detalle de las deducciones que se le hacen.
WITH deduccionesPorPago AS (
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'PATRONAL' AS tipo, deduccionPatronal.dedpatnombre AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario, 'OBRERO', deduccionObrero.dedobrnombre AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
UNION
SELECT departamentos.depNombre, empleadoOptimo.cedula, empleadoOptimo.salario,
	'RENTA' AS tipo, CONCAT(impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
INNER JOIN departamentos ON departamentos.departamentoId = empleadoOptimo.departamentoId
) SELECT deduccionesPorPago.* FROM deduccionesPorPago INNER JOIN
(WITH RankedSalaries AS (SELECT e.cedula, ROW_NUMBER() OVER (PARTITION BY e.departamentoId ORDER BY e.salario DESC) AS rank
    FROM EmpleadoOptimo e
    JOIN departamentos d ON e.departamentoId = d.departamentoId
)
SELECT cedula
FROM RankedSalaries WHERE rank = 1) AS mejoresSalarios ON mejoresSalarios.cedula = deduccionesPorPago.cedula
ORDER BY deduccionNombre;

-- Indique el monto promedio de salario y de deducciones por cada rubro, ordenado por departamento
SELECT departamentos.depNombre, AVG(EmpleadoOptimo.salario) salarioPromedio,
	AVG(deduccionPatPago.deduccionCalculada) deduccionesPatronalesPromedio,
	AVG(deduccionObrPago.deduccionCalculada) deduccionesObrerosPromedio,
	AVG(impuestoPago.deduccionCalculada) deduccionesImpuestoRentaPromedio
FROM departamentos
INNER JOIN EmpleadoOptimo on departamentos.departamentoId = empleadooptimo.departamentoid
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago on pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionObrPago on pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN impuestoPago on pagos.pagoId = impuestoPago.pagoId
WHERE departamentos.depNombre = 'Departamento 1'
GROUP BY departamentos.depNombre, empleadoOptimo.departamentoId
ORDER BY empleadoOptimo.departamentoId;





-- CON ORGANIZACIONES


-- Indique el total de salarios y las deducciones en un rango de fechas.
SELECT organizaciones.orgNombre, SUM(EmpleadoOptimo.salario) salariosTotales,
	SUM(deduccionPatPago.deduccionCalculada) deduccionesPatronalesTotales,
	SUM(deduccionObrPago.deduccionCalculada) deduccionesObrerosTotales, SUM(impuestoPago.deduccionCalculada) deduccionesImpuestoRentaTotales
FROM organizaciones
INNER JOIN EmpleadoOptimo on organizaciones.organizacionId = empleadooptimo.organizacionId
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago on pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionObrPago on pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN impuestoPago on pagos.pagoId = impuestoPago.pagoId
WHERE organizaciones.orgNombre = 'Organizacion 1' AND pagos.fechaPago BETWEEN '2024-01-14 12:00:00' AND '2024-02-01 12:00:00'
GROUP BY organizaciones.orgNombre, empleadoOptimo.organizacionId;



-- Indique el detalle de los salarios y deducciones para una quincena específica.
WITH deduccionesPorPago AS (
SELECT organizaciones.orgNombre, empleadoOptimo.cedula, empleadoOptimo.salario, CONCAT('PATRONAL: ', deduccionPatronal.dedpatnombre) AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
INNER JOIN organizaciones ON organizaciones.organizacionId = empleadoOptimo.organizacionId
UNION
SELECT organizaciones.orgNombre, empleadoOptimo.cedula, empleadoOptimo.salario, CONCAT('OBRERO: ', deduccionObrero.dedobrnombre) AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
INNER JOIN organizaciones ON organizaciones.organizacionId = empleadoOptimo.organizacionId
UNION
SELECT organizaciones.orgNombre, empleadoOptimo.cedula, empleadoOptimo.salario,
	CONCAT('RENTA: ', impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
INNER JOIN organizaciones ON organizaciones.organizacionId = empleadoOptimo.organizacionId
) SELECT * FROM deduccionesPorPago WHERE orgNombre = 'Organizacion 1' AND fechaPago = '2024-01-15 12:00:00'
ORDER BY cedula, deduccionNombre;

-- Indique la persona que más gana por departamento, además despliegue el detalle de las deducciones que se le hacen.
WITH deduccionesPorPago AS (
SELECT organizaciones.orgNombre, empleadoOptimo.cedula, empleadoOptimo.salario, CONCAT('PATRONAL: ', deduccionPatronal.dedpatnombre) AS deduccionNombre,
	dedpatporcentaje * 100 AS deduccionPorcentaje, deduccionPatPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago ON pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionPatronal ON deduccionPatPago.dedPatId = deduccionPatronal.dedPatId
INNER JOIN organizaciones ON organizaciones.organizacionId = empleadoOptimo.organizacionId
UNION
SELECT organizaciones.orgNombre, empleadoOptimo.cedula, empleadoOptimo.salario, CONCAT('OBRERO: ', deduccionObrero.dedobrnombre) AS deduccionNombre,
	dedobrporcentaje * 100 AS deduccionPorcentaje, deduccionObrPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionObrPago ON pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN deduccionObrero ON deduccionObrPago.dedObrId = deduccionObrero.dedObrId
INNER JOIN organizaciones ON organizaciones.organizacionId = empleadoOptimo.organizacionId
UNION
SELECT organizaciones.orgNombre, empleadoOptimo.cedula, empleadoOptimo.salario,
	CONCAT('RENTA: ', impuestoRenta.impuestoMinimo, 'C - ', impuestoRenta.impuestoMaximo,'C') AS deduccionNombre,
	impuestoPorcentaje * 100 AS deduccionPorcentaje, impuestoPago.deduccionCalculada AS deduccionCalculada, pagos.fechaPago
FROM empleadoOptimo
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN impuestoPago ON pagos.pagoId = impuestoPago.pagoId
INNER JOIN impuestoRenta ON impuestoRenta.impuestoId = impuestoPago.impuestoId
INNER JOIN organizaciones ON organizaciones.organizacionId = empleadoOptimo.organizacionId
) SELECT deduccionesPorPago.* FROM deduccionesPorPago INNER JOIN
(WITH RankedSalaries AS (SELECT e.cedula, ROW_NUMBER() OVER (PARTITION BY e.organizacionId ORDER BY e.salario DESC) AS rank
    FROM EmpleadoOptimo e
    JOIN organizaciones o ON e.organizacionId = o.organizacionId
)
SELECT cedula
FROM RankedSalaries WHERE rank = 1) AS mejoresSalarios ON mejoresSalarios.cedula = deduccionesPorPago.cedula
	WHERE orgNombre = 'Organizacion 1'
ORDER BY deduccionNombre;

-- Indique el monto promedio de salario y de deducciones por cada rubro, ordenado por departamento
SELECT departamentos.depNombre, AVG(EmpleadoOptimo.salario) salarioPromedio,
	AVG(deduccionPatPago.deduccionCalculada) deduccionesPatronalesPromedio,
	AVG(deduccionObrPago.deduccionCalculada) deduccionesObrerosPromedio,
	AVG(impuestoPago.deduccionCalculada) deduccionesImpuestoRentaPromedio
FROM departamentos
INNER JOIN EmpleadoOptimo on departamentos.departamentoId = empleadooptimo.departamentoid
INNER JOIN pagos ON empleadoOptimo.cedula = pagos.cedula
INNER JOIN deduccionPatPago on pagos.pagoId = deduccionPatPago.pagoId
INNER JOIN deduccionObrPago on pagos.pagoId = deduccionObrPago.pagoId
INNER JOIN impuestoPago on pagos.pagoId = impuestoPago.pagoId
GROUP BY departamentos.depNombre, empleadoOptimo.departamentoId
ORDER BY empleadoOptimo.departamentoId;
