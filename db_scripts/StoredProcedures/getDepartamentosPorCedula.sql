CREATE OR REPLACE FUNCTION public.getdepartamentosporcedula(p_cedula integer DEFAULT NULL::integer)
 RETURNS TABLE(departamentoid smallint, depnombre text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF p_cedula IS NOT NULL THEN
        -- Si se proporciona la cédula, devolver solo los departamentos donde esa cédula está registrada
        RETURN QUERY
        SELECT d.departamentoid, d.depnombre
        FROM public.departamentos d
        JOIN public.empleadosdepartamentos ed ON d.departamentoid = ed.departamentoid
        WHERE ed.cedula = p_cedula;
    ELSE
        -- Si no se proporciona la cédula, devolver todos los departamentos
        RETURN QUERY
        SELECT d.departamentoid, d.depnombre
        FROM public.departamentos d;
    END IF;
END;
$function$