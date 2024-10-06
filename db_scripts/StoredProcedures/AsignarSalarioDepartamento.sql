DROP PROCEDURE IF EXISTS AsignarSalarioDepartamento;
CREATE PROCEDURE AsignarSalarioDepartamento(
    IN p_departamentoid SMALLINT,
    IN p_salario INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE salarios
	SET enabled = false, validto = CURRENT_TIMESTAMP
	FROM empleadosdepartamentos
	WHERE salarios.cedula = empleadosdepartamentos.cedula
	AND salarios.enabled = true
	AND empleadosdepartamentos.departamentoid = p_departamentoid;




	INSERT INTO salarios (cedula, salariobruto, validfrom, validto, enabled)
	SELECT empleadosdepartamentos.cedula, p_salario, CURRENT_TIMESTAMP, NULL, true
	FROM empleadosdepartamentos
	WHERE empleadosdepartamentos.departamentoId = p_departamentoid;
END;
$$;