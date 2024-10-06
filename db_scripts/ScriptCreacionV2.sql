-- This script was generated by the ERD tool in pgAdmin 4.
-- Please log an issue at https://github.com/pgadmin-org/pgadmin4/issues/new/choose if you find any bugs, including reproduction steps.
BEGIN;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.apellidos CASCADE;
DROP TABLE IF EXISTS public.deduccionesobrero CASCADE;
DROP TABLE IF EXISTS public.deduccionespatronales CASCADE;
DROP TABLE IF EXISTS public.departamentos CASCADE;
DROP TABLE IF EXISTS public.empleados CASCADE;
DROP TABLE IF EXISTS public.impuestorenta CASCADE;
DROP TABLE IF EXISTS public.nombres CASCADE;
DROP TABLE IF EXISTS public.organizaciones CASCADE;
DROP TABLE IF EXISTS public.pagos CASCADE;
DROP TABLE IF EXISTS public.reservaspatronales CASCADE;
DROP TABLE IF EXISTS public.usuarios CASCADE;
DROP TABLE IF EXISTS public.salarios CASCADE;
DROP TABLE IF EXISTS public.empleadosdepartamentos CASCADE;
DROP TABLE IF EXISTS public.porcentajesvoluntarios CASCADE;

CREATE TABLE IF NOT EXISTS public.apellidos
(
    apellidoid serial NOT NULL,
    apellido text COLLATE pg_catalog."default",
    CONSTRAINT apellidos_pkey PRIMARY KEY (apellidoid)
);

CREATE TABLE IF NOT EXISTS public.deduccionesobrero
(
    dedobrid serial NOT NULL,
    obrivm numeric(4, 2) NOT NULL,
    obreym numeric(4, 2) NOT NULL,
    obrbanco numeric(4, 2) NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp with time zone,
    enabled boolean NOT NULL,
    CONSTRAINT deduccionobrero_pkey PRIMARY KEY (dedobrid)
);

CREATE TABLE IF NOT EXISTS public.deduccionespatronales
(
    dedpatid serial NOT NULL,
    pativm numeric(4, 2) NOT NULL,
    pateym numeric(4, 2) NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp without time zone,
    enabled boolean NOT NULL,
    CONSTRAINT deduccionpatronal_pkey PRIMARY KEY (dedpatid)
);

CREATE TABLE IF NOT EXISTS public.departamentos
(
    departamentoid SMALLSERIAL NOT NULL,
    depnombre text COLLATE pg_catalog."default",
    CONSTRAINT departamentos_pkey PRIMARY KEY (departamentoid)
);

CREATE TABLE IF NOT EXISTS public.empleados
(
    cedula integer NOT NULL,
    nombreid integer NOT NULL,
    apellido1id integer NOT NULL,
    apellido2id integer NOT NULL,
    fechanacimiento date NOT NULL,
    organizacionid smallint NOT NULL,
    CONSTRAINT empleadooptimo_pkey PRIMARY KEY (cedula)
);

CREATE TABLE IF NOT EXISTS public.impuestorenta
(
    impuestoid serial NOT NULL,
    impuestominimo integer NOT NULL,
    impuestomaximo integer NOT NULL,
    impuestoporcentaje numeric(4, 2) NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp without time zone,
    enabled boolean NOT NULL,
    CONSTRAINT impuestorenta_pkey PRIMARY KEY (impuestoid)
);

CREATE TABLE IF NOT EXISTS public.nombres
(
    nombreid serial NOT NULL,
    nombre text COLLATE pg_catalog."default",
    CONSTRAINT nombres_pkey PRIMARY KEY (nombreid)
);

CREATE TABLE IF NOT EXISTS public.organizaciones
(
    organizacionid SMALLSERIAL NOT NULL,
    orgnombre text COLLATE pg_catalog."default",
    CONSTRAINT organizaciones_pkey PRIMARY KEY (organizacionid)
);

CREATE TABLE IF NOT EXISTS public.pagos
(
    pagoid serial NOT NULL,
    salarioid integer,
    cedula integer NOT NULL,
    fechapago timestamp without time zone NOT NULL,
    pateym numeric(13, 4) NOT NULL,
    pativm numeric(13, 4) NOT NULL,
    obreym numeric(13, 4) NOT NULL,
    obrivm numeric(13, 4) NOT NULL,
    obrbanco numeric(13, 4) NOT NULL,
    obrsolidarista numeric(13, 4) NOT NULL DEFAULT 0,
    resaguinaldo numeric(13, 4) NOT NULL,
    rescesantia numeric(13, 4) NOT NULL,
    resvacaciones numeric(13, 4) NOT NULL,
    impuestorenta numeric(13, 4) NOT NULL,
    enabled boolean NOT NULL DEFAULT true,
    CONSTRAINT pagos_pkey PRIMARY KEY (pagoid)
);

CREATE TABLE IF NOT EXISTS public.reservaspatronales
(
    reservaid serial,
    resaguinaldo numeric(4, 2) NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp without time zone,
    enabled boolean NOT NULL,
    rescesantia numeric(4, 2) NOT NULL,
    resvacaciones numeric(4, 2) NOT NULL,
    PRIMARY KEY (reservaid)
);

CREATE TABLE IF NOT EXISTS public.usuarios
(
    usuario_id serial NOT NULL,
    password text NOT NULL,
    PRIMARY KEY (usuario_id)
);

CREATE TABLE IF NOT EXISTS public.salarios
(
    salarioid serial NOT NULL,
    cedula integer NOT NULL,
    salariobruto integer NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp without time zone,
    enabled boolean,
    PRIMARY KEY (salarioid)
);

CREATE TABLE IF NOT EXISTS public.empleadosdepartamentos
(
    cedula integer NOT NULL,
    departamentoid smallint NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp without time zone,
    enabled boolean
);

CREATE TABLE IF NOT EXISTS public.porcentajesvoluntarios
(
    "voluntarioId" serial NOT NULL,
    cedula integer NOT NULL,
    porcentaje numeric(3, 2) NOT NULL,
    validfrom timestamp without time zone,
    validto timestamp without time zone,
    enabled boolean NOT NULL,
    PRIMARY KEY ("voluntarioId")
);

ALTER TABLE IF EXISTS public.empleados
    ADD CONSTRAINT apellido1_relationship FOREIGN KEY (apellido1id)
    REFERENCES public.apellidos (apellidoid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS idx_apellido1_empleadooptimo
    ON public.empleados(apellido1id);


ALTER TABLE IF EXISTS public.empleados
    ADD CONSTRAINT apellido2_relationship FOREIGN KEY (apellido2id)
    REFERENCES public.apellidos (apellidoid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS idx_apellido2_empleadooptimo
    ON public.empleados(apellido2id);


ALTER TABLE IF EXISTS public.empleados
    ADD CONSTRAINT nombres_relationship FOREIGN KEY (nombreid)
    REFERENCES public.nombres (nombreid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS idx_nombre_empleadooptimo
    ON public.empleados(nombreid);


ALTER TABLE IF EXISTS public.empleados
    ADD CONSTRAINT organizacion_relationship FOREIGN KEY (organizacionid)
    REFERENCES public.organizaciones (organizacionid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
CREATE INDEX IF NOT EXISTS idx_organizacionid_empleadooptimo
    ON public.empleados(organizacionid);


ALTER TABLE IF EXISTS public.pagos
    ADD FOREIGN KEY (cedula)
    REFERENCES public.empleados (cedula) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.pagos
    ADD FOREIGN KEY (salarioid)
    REFERENCES public.salarios (salarioid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.salarios
    ADD FOREIGN KEY (cedula)
    REFERENCES public.empleados (cedula) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.empleadosdepartamentos
    ADD FOREIGN KEY (cedula)
    REFERENCES public.empleados (cedula) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.empleadosdepartamentos
    ADD FOREIGN KEY (departamentoid)
    REFERENCES public.departamentos (departamentoid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.porcentajesvoluntarios
    ADD FOREIGN KEY (cedula)
    REFERENCES public.empleados (cedula) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;