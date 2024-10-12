CREATE OR REPLACE FUNCTION getimpuestosrenta()
RETURNS TABLE (
    impuestominimo INTEGER,
    impuestomaximo INTEGER,
    impuestoporcentaje NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
           ir.impuestominimo, 
           ir.impuestomaximo, 
           ir.impuestoporcentaje
    FROM public.impuestorenta ir
	WHERE ir.enabled = True
	ORDER BY ir.impuestominimo;
END;
$$;

SELECT * FROM getimpuestosrenta()