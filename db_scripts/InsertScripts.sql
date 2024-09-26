
-- Tabla temporal
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

SELECT
pg_size_pretty(pg_table_size('empleado')) AS table_size,
pg_size_pretty(pg_indexes_size('empleado')) AS indexes_size;

SELECT
    pg_size_pretty(AVG(pg_column_size(cedula) + pg_column_size(nombre) + pg_column_size(apellido1) + pg_column_size(apellido2)
	 + pg_column_size(salario) + pg_column_size(fecha_nacimiento) + pg_column_size(Organizacion) + pg_column_size(Departamento)))
	AS size_registro
FROM
    empleado;

-- Tabla EmpleadoOpt
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

SELECT
pg_size_pretty(pg_table_size('EmpleadoOptimizado')) AS table_size,
pg_size_pretty(pg_indexes_size('EmpleadoOptimizado')) AS indexes_size;

SELECT
    pg_size_pretty(AVG(pg_column_size(cedula) + pg_column_size(nombre) + pg_column_size(apellido1) + pg_column_size(apellido2)
	 + pg_column_size(salario) + pg_column_size(fecha_nacimiento) + pg_column_size(organizacion) + pg_column_size(departamento)))
	AS size_registro
FROM
    EmpleadoOptimizado;

-- NOMBRES
SELECT DISTINCT nombre, count(nombre) as apariciones FROM empleadooptimizado GROUP BY nombre ORDER BY apariciones DESC;
SELECT DISTINCT nombre FROM empleadooptimizado;

DROP TABLE nombres;
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

SELECT
pg_size_pretty(pg_table_size('nombres')) AS table_size,
pg_size_pretty(pg_indexes_size('nombres')) AS indexes_size;

SELECT
    pg_size_pretty(AVG(pg_column_size(nombreId) + pg_column_size(nombre)))
	AS size_registro
FROM
    nombres;

SELECT
pg_size_pretty(pg_indexes_size('nombres')) AS nombres;

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

SELECT
pg_size_pretty(pg_table_size('apellidos')) AS table_size,
pg_size_pretty(pg_indexes_size('apellidos')) AS indexes_size;

SELECT
pg_size_pretty(pg_indexes_size('apellidos')) AS apellidos;

SELECT
    pg_size_pretty(AVG(pg_column_size(apellidoId) + pg_column_size(apellido)))
	AS size_registro
FROM
    apellidos;

-- ORGANIZACIONES
DROP TABLE IF EXISTS organizaciones;
CREATE TABLE IF NOT EXISTS public.organizaciones
(
	organizacionId SMALLINT PRIMARY KEY,
	orgNombre TEXT
);

INSERT INTO organizaciones (organizacionId, orgNombre)
SELECT organizacionId, ('Organizacion ' || organizacionId) AS orgNombre FROM
(SELECT DISTINCT CAST(CAST(organizacion AS FLOAT) AS INTEGER) as organizacionId
FROM empleadooptimizado) AS organizacionesTemp;

SELECT * FROM organizaciones;

SELECT
pg_size_pretty(pg_table_size('organizaciones')) AS table_size,
pg_size_pretty(pg_indexes_size('organizaciones')) AS indexes_size;

CREATE INDEX idx_organizaciones ON organizaciones (orgNombre);
SELECT pg_size_pretty(pg_indexes_size('organizaciones')) AS organizaciones;

-- DEPARTAMENTOS
DROP TABLE IF EXISTS departamentos;
CREATE TABLE IF NOT EXISTS public.departamentos
(
	departamentoId SMALLINT PRIMARY KEY,
	depNombre TEXT
);

INSERT INTO departamentos (departamentoId, depNombre)
SELECT departamentoId, ('Departamento ' || departamentoId) AS depNombre FROM
(SELECT DISTINCT CAST(CAST(departamento AS FLOAT) AS INTEGER) as departamentoId
FROM empleadooptimizado) AS departamentosTemp;

SELECT * FROM departamentos;

SELECT
pg_size_pretty(pg_table_size('departamentos')) AS table_size,
pg_size_pretty(pg_indexes_size('departamentos')) AS indexes_size;

CREATE INDEX idx_departamentos ON departamentos (depNombre);

SELECT
pg_size_pretty(pg_indexes_size('departamentos')) AS departamentos;

-- Tabla de EmpleadoÓptimo
DROP TABLE IF EXISTS EmpleadoOptimo;
CREATE TABLE IF NOT EXISTS public.EmpleadoOptimo
(
    cedula integer PRIMARY KEY,
    nombreId integer,
    apellido1Id int,
    apellido2Id int,
    salario int,
    fecha_nacimiento TIMESTAMP,
    organizacionId int,
    departamentoId int,
	CONSTRAINT nombres_relationship
    FOREIGN KEY (nombreId)
    REFERENCES nombres (nombreId),
	CONSTRAINT apellido1_relationship
    FOREIGN KEY (apellido1Id)
    REFERENCES apellidos (apellidoId),
	CONSTRAINT apellido2_relationship
    FOREIGN KEY (apellido2Id)
    REFERENCES apellidos (apellidoId),
	CONSTRAINT organizacion_relationship
    FOREIGN KEY (organizacionId)
    REFERENCES organizaciones (organizacionId),
	CONSTRAINT departamento_relationship
    FOREIGN KEY (departamentoId)
    REFERENCES departamentos (departamentoId)
);

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

SELECT * FROM empleados LIMIT 100;
SELECT
pg_size_pretty(pg_table_size('EmpleadoOptimo')) AS table_size,
pg_size_pretty(pg_indexes_size('EmpleadoOptimo')) AS indexes_size;

-- CAST(CAST(departamento AS FLOAT) AS INTEGER) AS departamento
SELECT
    pg_size_pretty(AVG(pg_column_size(cedula) + pg_column_size(nombreid) + pg_column_size(apellido1id) + pg_column_size(apellido2id)
	 + pg_column_size(salario) + pg_column_size(fecha_nacimiento) + pg_column_size(organizacionid) + pg_column_size(departamentoid)))
	AS size_registro
FROM
    EmpleadoOptimo;

CREATE INDEX idx_nombre_empleadooptimo ON empleadooptimo (nombreId);
CREATE INDEX idx_apellido1_empleadooptimo ON empleadooptimo (apellido1Id);
CREATE INDEX idx_apellido2_empleadooptimo ON empleadooptimo (apellido2Id);

DROP INDEX idx_departamentoId_empleadooptimo;
CREATE INDEX idx_organizacionId_empleadooptimo on empleadooptimo (organizacionId);
CREATE INDEX idx_departamentoId_empleadooptimo ON empleadooptimo (departamentoId);

SELECT pg_size_pretty(pg_indexes_size('EmpleadoOptimo')) AS EmpleadoOptimo;

-- DEDUCCIONES PATRONALES
CREATE TABLE IF NOT EXISTS public.deduccionPatronal
(
	dedPatId SERIAL PRIMARY KEY,
	dedPatNombre TEXT,
	dedPatPorcentaje FLOAT
);

INSERT INTO deduccionPatronal (dedPatNombre, dedPatPorcentaje) VALUES 
('SEM', 0.0925),
('IVM', 0.0542), 
('Cuota Patronal Banco Popular', 0.0025), 
('Asignaciones Familiares', 0.0500),
('IMAS', 0.0050),
('INA', 0.0150),
('Aporte Patrono Banco Popular', 0.0025),
('Fondo de Capitalización Laboral', 0.0150),
('Fondo de Pensiones Complementarias', 0.0200),
('INS', 0.0100);

SELECT pg_size_pretty(pg_indexes_size('deduccionPatronal')) AS deduccionPatronal;

-- DEDUCCIONES OBRERO
CREATE TABLE IF NOT EXISTS public.deduccionObrero
(
	dedObrId SERIAL PRIMARY KEY,
	dedObrNombre TEXT,
	dedObrPorcentaje FLOAT
);

INSERT INTO deduccionObrero (dedObrNombre, dedObrPorcentaje) VALUES 
('SEM',0.0925),
('IVM', 0.0542),
('Aporte Trabajador Banco Popular', 0.0100);

SELECT pg_size_pretty(pg_indexes_size('deduccionObrero')) AS deduccionObrero;

-- IMPUESTO DE RENTA AL SALRIO
DROP TABLE impuestoRenta;
CREATE TABLE IF NOT EXISTS public.impuestoRenta
(
	impuestoId SERIAL PRIMARY KEY,
	impuestoMinimo FLOAT,
	impuestoMaximo FLOAT, 
	impuestoPorcentaje FLOAT
);

INSERT INTO impuestoRenta (impuestoMinimo, impuestoMaximo, impuestoPorcentaje) VALUES 
(0.00, 929000.00, 0.0),
(929000.00, 1363000.00, 0.10),
(1363000.00, 2392000.00, 0.15),
(2392000.00, 4783000.00, 0.20),
(4783000.00, 999999999.00, 0.25);

SELECT * FROM impuestoRenta;

UPDATE impuestoRenta
SET impuestoMinimo = 4783000
WHERE impuestoId = 5;

SELECT impuestoPorcentaje, impuestoMinimo, impuestoMaximo, e.cedula, e.salario FROM impuestoRenta
CROSS JOIN empleadoOptimo e WHERE e.salario >= CAST(impuestoMinimo AS int) AND
	e.salario < CAST(impuestoMaximo AS int);

SELECT e.cedula, COUNT(e.cedula) times FROM impuestoRenta
CROSS JOIN empleadoOptimo e WHERE e.salario >= impuestoMinimo AND
	e.salario < impuestoMaximo GROUP BY (e.cedula) HAVING COUNT(e.cedula) > 1;

SELECT pg_size_pretty(pg_indexes_size('impuestoRenta')) AS impuestoRenta;

-- PAGOS
DROP TABLE IF EXISTS public.pagos
CREATE TABLE IF NOT EXISTS public.pagos
(
	pagoId SERIAL PRIMARY KEY,
	salarioBruto FLOAT,
	cedula INTEGER,
	fechaPago TIMESTAMP,
	CONSTRAINT cedula_relationship
    FOREIGN KEY (cedula)
    REFERENCES EmpleadoOptimo (cedula)
);

CREATE INDEX idx_cedula_pagos ON pagos (cedula);
CREATE INDEX idx_salariobruto_pagos ON pagos (salarioBruto);
CREATE INDEX idx_fechaPago_pagos ON pagos (fechaPago);

SELECT pg_size_pretty(pg_indexes_size('pagos')) AS pagos;

-- DEDUCCIONES PATRONALES POR PAGO
DROP TABLE IF EXISTS public.deduccionPatPago
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
DROP TABLE IF EXISTS public.deduccionObrPago
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
DROP TABLE IF EXISTS public.impuestoPago
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
