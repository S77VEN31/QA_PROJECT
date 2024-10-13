DROP PROCEDURE IF EXISTS AsignarSalarioEmpleado;

-- Asigna el salario a un empleado de acuerdo con su cédula
-- También se puede asignar la cantidad de hijos, si tiene cónyuge,
-- y el porcentaje de contribución a la asociación solidarista.
-- Los campos a actualizar pueden venir nulos, en cuyo caso mantiene el dato anterior
CREATE OR REPLACE PROCEDURE public.asignarsalarioempleado(IN p_cedula integer, IN p_salario integer, IN p_hijos smallint, IN p_conyuge boolean, IN p_solidarista numeric)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	actual_time TIMESTAMP;
    emp_exists BOOLEAN;
BEGIN
    -- Revisar si existe el empleado
    SELECT EXISTS (
        SELECT 1
        FROM empleados
        WHERE cedula = p_cedula
    ) INTO emp_exists;

    -- Levantar una excepción si no existe el empleado con esa cédula
    IF NOT emp_exists THEN
        RAISE EXCEPTION 'Employee with ID % does not exist', p_cedula;
    END IF;

	actual_time := CURRENT_TIMESTAMP;

	-- Desactivar el salario viejo del empleado
	UPDATE salarios
	SET enabled = false, validto = actual_time
	WHERE salarios.cedula = p_cedula
	AND salarios.enabled = true;

	-- Insertar el salario nuevo.
	INSERT INTO salarios(
	cedula, salariobruto, hijos, conyuge, obrsolidarista, validfrom, validto, enabled)
	SELECT
		p_cedula,
		COALESCE(p_salario, s.salariobruto),
		COALESCE(p_hijos, s.hijos),
		COALESCE(p_conyuge, s.conyuge),
		COALESCE(p_solidarista, s.obrsolidarista),
		CURRENT_TIMESTAMP, NULL, true
	FROM salarios s
	WHERE s.cedula = p_cedula
	AND s.validto = actual_time;
END;
$procedure$

INSERT INTO departamentos (depnombre)
    VALUES ('Departamento Pruebas');

SELECT * FROM DEPARTAMENTOS

INSERT INTO public.empleadosdepartamentos(
	cedula, departamentoid, validfrom, enabled)
	VALUES (105750751, 25, CURRENT_TIMESTAMP, TRUE),
	(106500405, 25, CURRENT_TIMESTAMP, TRUE);

CALL AsignarSalarioEmpleado(106500405::INT, 1000000::int, 2::smallint, True, 1::numeric(4,2));
CALL AsignarSalarioEmpleado(106500405::INT, 1000000::int, 3::smallint, NULL, NULL::numeric(4,2));
CALL AsignarSalarioEmpleado(106500405::INT, NULL::int, 3::smallint, FALSE, NULL::numeric(4,2));
CALL AsignarSalarioEmpleado(106500405::INT, 2000000::int, NULL::smallint, NULL, 5::numeric(4,2));

SELECT * FROM salarios WHERE cedula = 106500405 ORDER BY salarioid;
