CREATE OR REPLACE PROCEDURE insertnquincenas(IN num_payments INT, IN start_date TIMESTAMP)
LANGUAGE plpgsql
AS $$
DECLARE
    conflict_date TIMESTAMP;
BEGIN
    -- Verificar que las quincenas son 5 o 10 (5 meses)
    IF num_payments NOT IN (5, 10) THEN
        RAISE EXCEPTION 'Invalid number of payments. Must be either 5 or 10.';
    END IF;

	 -- Paso 1: Revisar si alguna de las fechas ya tiene pagos.
    SELECT payment_date
    INTO conflict_date
    FROM (
        SELECT start_date + (n * INTERVAL '14 days') AS payment_date
        FROM generate_series(0, num_payments - 1) n
    ) AS payment_dates
    WHERE EXISTS (
        SELECT 1 FROM public.pagos p WHERE p.fechapago::date = payment_dates.payment_date::date
    )
    LIMIT 1;

    -- Si hay un conflicto en las fechas, levantar una excepción y abortar.
    IF conflict_date IS NOT NULL THEN
        RAISE EXCEPTION 'Payment already exists for the date %', conflict_date::date;
    END IF;

    -- Step 2: Perform a bulk insert for the valid payment dates
    INSERT INTO public.pagos (
        salarioid, cedula, fechapago, pateym, pativm, obreym, obrivm, obrbanco, 
        resaguinaldo, rescesantia, resvacaciones, impuestorenta, enabled
    )
    SELECT
        s.salarioid, 
        s.cedula, 
        payment_dates.payment_date, 
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
    CROSS JOIN (
        -- Generate a series of payment dates
        SELECT start_date + (n * INTERVAL '14 days') AS payment_date
        FROM generate_series(0, num_payments - 1) n
    ) AS payment_dates
    WHERE obr.enabled = TRUE
      AND pat.enabled = TRUE
      AND res.enabled = TRUE
      AND payment_dates.payment_date BETWEEN s.validfrom AND COALESCE(s.validto, (CURRENT_DATE + INTERVAL '5 years'));

EXCEPTION
    -- Handle any errors
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error occurred during multiple payments insertion: %', SQLERRM;
END;
$$;

CALL  insertnquincenas(5, '2024-10-11'::TIMESTAMP);
SET max_parallel_workers_per_gather = 16;
SET max_parallel_workers = 17;
SHOW max_parallel_workers;
EXPLAIN ANALYZE SELECT
        s.salarioid, 
        s.cedula, 
        payment_dates.payment_date, 
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
    CROSS JOIN (
        -- Generate a series of payment dates
        SELECT '2024-10-11'::TIMESTAMP + (n * INTERVAL '14 days') AS payment_date
        FROM generate_series(0, 5 - 1) n
    ) AS payment_dates
    WHERE obr.enabled = TRUE
      AND pat.enabled = TRUE
      AND res.enabled = TRUE
      AND payment_dates.payment_date BETWEEN s.validfrom AND COALESCE(s.validto, (CURRENT_DATE + INTERVAL '5 years'));
