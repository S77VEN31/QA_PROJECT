-- Función para obtener los datos del salario de un colaborador, como
-- el salario, la cantidad de hijos, si tiene esposo y el porcentaje de contribución
-- Recibe una cédula y el id del departamento al que pertenece el empleado.
-- retorna la cédula, el id del departamento, el salario bruto, la cantidad de hijos, si tiene cónyuge y el porcentaje de contribución
CREATE OR REPLACE FUNCTION public.obtenerdatosalarialcolaborador(p_cedula integer, p_departamentoid smallint)
 RETURNS TABLE(cardid integer, departmentid smallint, salary integer, childrenquantity smallint, hasspouse boolean, contributionpercentage numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Verificar si la cédula está asociada al departamento
    IF NOT EXISTS (
        SELECT 1
        FROM empleadosdepartamentos
        WHERE cedula = p_cedula
        AND departamentoid = p_departamentoid
    ) THEN
        RAISE EXCEPTION 'El colaborador con cédula % no está asignado al departamento %', p_cedula, p_departamentoid;
    END IF;

    -- Obtener los datos más recientes del salario del colaborador en el departamento
    RETURN QUERY
    SELECT 
        s.cedula,
        ed.departamentoid,
        s.salariobruto,
        s.hijos,
        s.conyuge,
        s.obrsolidarista
    FROM salarios s
    INNER JOIN empleadosdepartamentos ed ON s.cedula = ed.cedula
    WHERE s.cedula = p_cedula
    AND ed.departamentoid = p_departamentoid
    AND s.enabled = true
    ORDER BY s.validfrom DESC
    LIMIT 1;

END;
$function$
