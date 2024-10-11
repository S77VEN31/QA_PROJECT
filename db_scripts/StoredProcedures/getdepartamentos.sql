CREATE OR REPLACE FUNCTION getdepartamentos()
RETURNS TABLE (
    departamentoid SMALLINT,
    depnombre TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT d.departamentoid, d.depnombre
    FROM public.departamentos d;
END;
$$;

DROP FUNCTION getdepartamentos(int)
SELECT * FROM getdepartamentos();