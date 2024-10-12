CREATE OR REPLACE FUNCTION getempleadonombre(p_cedula INTEGER)
RETURNS TEXT AS $$
DECLARE
	emp_exists BOOLEAN;
BEGIN
	SELECT EXISTS (
        SELECT 1
        FROM empleados
        WHERE cedula = p_cedula
    ) INTO emp_exists;

    -- Raise an exception if the department does not exist
    IF NOT emp_exists THEN
        RAISE EXCEPTION 'Employee with ID % does not exist', p_cedula;
    END IF;
	
    RETURN (
        SELECT (n.nombre || ' ' || a1.apellido || ' ' || a2.apellido) AS nombre
        FROM empleados e
        INNER JOIN nombres n ON n.nombreId = e.nombreId
        INNER JOIN apellidos a1 ON a1.apellidoId = e.apellido1Id
        INNER JOIN apellidos a2 ON a2.apellidoId = e.apellido2Id
        WHERE e.cedula = p_cedula
    );
END;
$$ LANGUAGE plpgsql;



SELECT * FROM getempleadonombre(106500405)
	