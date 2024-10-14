/*
Procedimiento para insertar 1 quincena.
Recibe un timestamp con la fecha que se registrará en los pagos.
*/
CREATE OR REPLACE PROCEDURE insertquincena(IN payment_date TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Revisar si ya esa quincena fue pagada.
    IF EXISTS (SELECT 1 FROM public.pagos WHERE fechapago::date = payment_date::date) THEN
        RAISE EXCEPTION 'Ya hay pagos para la quincena %', payment_date::date;
    END IF;

    -- 2. Insertar los registros en la tabla de pagos para cada uno de los empleados.
    INSERT INTO public.pagos (
        salarioid, cedula, fechapago, pateym, pativm, obreym, obrivm, obrbanco, obrsolidarista,
        resaguinaldo, rescesantia, resvacaciones, impuestorenta, enabled
    )
    SELECT
        s.salarioid, 
        s.cedula, 
        payment_date, 
        pat.pateym * (s.salariobruto / 2) / 100 AS pateym,
        pat.pativm * (s.salariobruto / 2) / 100 AS pativm,
        obr.obreym * (s.salariobruto / 2) / 100 AS obreym,
        obr.obrivm * (s.salariobruto / 2) / 100 AS obrivm,
        obr.obrbanco * (s.salariobruto / 2) / 100 AS obrbanco,
		s.obrsolidarista * (s.salariobruto / 2) / 100 AS obrsolidarista,
        res.resaguinaldo * (s.salariobruto / 2) / 100 AS resaguinaldo,
        res.rescesantia * (s.salariobruto / 2) / 100 AS rescesantia,
        res.resvacaciones * (s.salariobruto / 2) / 100 AS resvacaciones,
        calculate_tax(s.salariobruto, (s.hijos * cred.credhijos),
			(CASE WHEN s.conyuge = TRUE THEN cred.credconyuge ELSE 0 END)
		) / 2 AS impuestorenta,-- Calcular el impuesto de renta para el salario. Se envían los montos a deducir por créditos fiscales ya calculados.
        true AS enabled
    FROM salarios s
    CROSS JOIN deduccionesobrero obr -- Se filtra por el registro con las deducciones de cada categoría activas. Solo debería haber 1 enabled.
    CROSS JOIN deduccionespatronales pat
    CROSS JOIN reservaspatronales res
	CROSS JOIN creditosfiscales cred	
    WHERE obr.enabled = true
    AND pat.enabled = true
    AND res.enabled = true
	AND cred.enabled = true
	AND payment_date BETWEEN s.validfrom AND COALESCE(s.validto, (CURRENT_DATE + INTERVAL '5 year'));
	-- Se pagan solo los salarios que estén activos para la fecha que se insertó en la quincena.

EXCEPTION
    -- Manejar errores.
    WHEN OTHERS THEN
        RAISE;
END;
$$;


DROP PROCEDURE insertquincena(DATE)
SELECT COUNT(*) FROM pagos

CALL insertquincena('2025-01-14 00:00:00'::timestamp)

SELECT DISTINCT fechapago FROM pagos

SELECT
        s.salarioid, 
        s.cedula,
        pat.pateym * (s.salariobruto / 2) / 100 AS pateym,
        pat.pativm * (s.salariobruto / 2) / 100 AS pativm,
        obr.obreym * (s.salariobruto / 2) / 100 AS obreym,
        obr.obrivm * (s.salariobruto / 2) / 100 AS obrivm,
        obr.obrbanco * (s.salariobruto / 2) / 100 AS obrbanco,
        res.resaguinaldo * (s.salariobruto / 2) / 100 AS resaguinaldo,
        res.rescesantia * (s.salariobruto / 2) / 100 AS rescesantia,
        res.resvacaciones * (s.salariobruto / 2) / 100 AS resvacaciones,
        calculate_tax(s.salariobruto) / 2 AS impuestorenta,  -- Calcular el impuesto de renta para el salario
        true AS enabled
    FROM salarios s
    CROSS JOIN deduccionesobrero obr
    CROSS JOIN deduccionespatronales pat
    CROSS JOIN reservaspatronales res
    WHERE obr.enabled = true
    AND pat.enabled = true
    AND res.enabled = true
	AND payment_date BETWEEN s.validfrom AND COALESCE(s.validto, (CURRENT_DATE + INTERVAL '5 year'));

SELECT
        s.salarioid, 
        s.cedula, 
        pat.pateym * (s.salariobruto / 2) / 100 AS pateym,
        pat.pativm * (s.salariobruto / 2) / 100 AS pativm,
        obr.obreym * (s.salariobruto / 2) / 100 AS obreym,
        obr.obrivm * (s.salariobruto / 2) / 100 AS obrivm,
        obr.obrbanco * (s.salariobruto / 2) / 100 AS obrbanco,
		s.obrsolidarista * (s.salariobruto / 2) / 100 AS obrsolidarista,
        res.resaguinaldo * (s.salariobruto / 2) / 100 AS resaguinaldo,
        res.rescesantia * (s.salariobruto / 2) / 100 AS rescesantia,
        res.resvacaciones * (s.salariobruto / 2) / 100 AS resvacaciones,
        calculate_tax(s.salariobruto, s.hijos * cred.credhijos,
			(CASE WHEN s.conyuge = TRUE THEN cred.credconyuge ELSE 0 END)
		) / 2 AS impuestorenta,-- Calcular el impuesto de renta para el salario
        true AS enabled
    FROM salarios s
    CROSS JOIN deduccionesobrero obr
    CROSS JOIN deduccionespatronales pat
    CROSS JOIN reservaspatronales res
	CROSS JOIN creditosfiscales cred	
    WHERE obr.enabled = true
    AND pat.enabled = true
    AND res.enabled = true
	AND cred.enabled = true
