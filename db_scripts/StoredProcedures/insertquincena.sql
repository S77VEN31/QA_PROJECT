CREATE OR REPLACE PROCEDURE insertquincena(IN payment_date TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Revisar si ya hay esa quincena fue pagada.
    IF EXISTS (SELECT 1 FROM public.pagos WHERE fechapago::date = payment_date::date) THEN
        RAISE EXCEPTION 'Ya hay pagos para la quincena %', payment_date::date;
    END IF;

    -- 2. Insert data into the pagos table from the calculated select
    INSERT INTO public.pagos (
        salarioid, cedula, fechapago, pateym, pativm, obreym, obrivm, obrbanco, 
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

EXCEPTION
    -- Handle any errors without explicit rollback or commit
    WHEN OTHERS THEN
        -- Optionally raise the error after logging or handling it
        RAISE;
END;
$$;


DROP PROCEDURE insertquincena(DATE)
SELECT COUNT(*) FROM pagos

CALL insertquincena('2024-12-28 00:00:00'::timestamp)

SELECT * FROM pagos

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
