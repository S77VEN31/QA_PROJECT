CREATE OR REPLACE PROCEDURE insertnquincenas(IN num_payments INT, IN start_date TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de que fecha de inicio sea el 14 o 28 del mes.
    IF EXTRACT(DAY FROM start_date) NOT IN (14, 28) THEN
        RAISE EXCEPTION 'Invalid start date. The start date must be either the 14th or the 28th of the month.';
    END IF;

    -- Inserción de todos los pagos, calculando que las fechas de los pagos sean el 14 y el 28 de cada mes.
    INSERT INTO public.pagos (
        salarioid, cedula, fechapago, pateym, pativm, obreym, obrivm, obrbanco, obrsolidarista,
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
		s.obrsolidarista * (s.salariobruto / 2) / 100 AS obrsolidarista,
        res.resaguinaldo * (s.salariobruto / 2) / 100 AS resaguinaldo,
        res.rescesantia * (s.salariobruto / 2) / 100 AS rescesantia,
        res.resvacaciones * (s.salariobruto / 2) / 100 AS resvacaciones,
        calculate_tax(s.salariobruto, (s.hijos * cred.credhijos),
			(CASE WHEN s.conyuge = TRUE THEN cred.credconyuge ELSE 0 END)
		) / 2 AS impuestorenta,-- Calcular el impuesto de renta para el salario
        true AS enabled
    FROM salarios s
    CROSS JOIN deduccionesobrero obr
    CROSS JOIN deduccionespatronales pat
    CROSS JOIN reservaspatronales res
	CROSS JOIN creditosfiscales cred
    CROSS JOIN (
        SELECT 
		    CASE
		        -- Si la fecha es el 14, se alterna entre el 14 y el 28 para cada mes.
		        WHEN EXTRACT(DAY FROM start_date) = 14 THEN
		            -- Si n es par, se añade el 14, y si es impar, el 28.
		            CASE 
		                WHEN MOD(n, 2) = 0 THEN date_trunc('month', start_date + (n/2) * INTERVAL '1 month') + INTERVAL '13 days'
		                ELSE date_trunc('month', start_date + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
		            END
		        -- Si la fecha es el 28, se alterna entre el 28 del mes y el 14 del siguiente mes cada mes.
		        WHEN EXTRACT(DAY FROM start_date) = 28 THEN
		            -- If n is even, add the 28th of the month, if n is odd, add the 14th of the next month
		            CASE 
		                WHEN MOD(n, 2) = 0 THEN date_trunc('month', start_date + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
		                ELSE date_trunc('month', start_date + (n/2 + 1) * INTERVAL '1 month') + INTERVAL '13 days'
		            END
		    END AS payment_date
		FROM generate_series(0, num_payments - 1) n
    ) AS payment_dates
    WHERE obr.enabled = TRUE
      AND pat.enabled = TRUE
      AND res.enabled = TRUE
	  AND cred.enabled = TRUE
      AND payment_dates.payment_date BETWEEN s.validfrom AND COALESCE(s.validto, (CURRENT_DATE + INTERVAL '5 years'))
      AND NOT EXISTS (
          SELECT 1 FROM public.pagos p WHERE p.fechapago::date = payment_dates.payment_date::date
      );  -- Ensure there are no payments for the same date

EXCEPTION
    -- Handle any errors
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error occurred during multiple payments insertion: %', SQLERRM;
END;
$$;


CALL  insertnquincenas(5, '2025-01-14'::TIMESTAMP);

SELECT * FROM getquincenas('2025-01-15'::DATE, '2025-12-12'::DATE, NULL::INT, NULL::SMALLINT, NULL::INT, NULL::INT)

SELECT 
    CASE
        -- If the start_date is the 14th, we add alternating 14th and 28th dates for each month
        WHEN EXTRACT(DAY FROM '2024-10-14'::DATE) = 14 THEN
            -- If n is even, add the 14th of the month, if n is odd, add the 28th
            CASE 
                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-10-14'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '13 days'
                ELSE date_trunc('month', '2024-10-14'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
            END
        -- If the start_date is the 28th, we add alternating 28th and 14th dates for each month
        WHEN EXTRACT(DAY FROM '2024-10-14'::DATE) = 28 THEN
            -- If n is even, add the 28th of the month, if n is odd, add the 14th of the next month
            CASE 
                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-10-14'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
                ELSE date_trunc('month', '2024-10-14'::DATE + (n/2 + 1) * INTERVAL '1 month') + INTERVAL '13 days'
            END
    END AS payment_date
FROM generate_series(0, 5 - 1) n;

SELECT 
    CASE
        -- If the start_date is the 14th, we add alternating 14th and 28th dates for each month
        WHEN EXTRACT(DAY FROM '2024-10-28'::DATE) = 14 THEN
            -- If n is even, add the 14th of the month, if n is odd, add the 28th
            CASE 
                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-10-28'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '13 days'
                ELSE date_trunc('month', '2024-10-28'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
            END
        -- If the start_date is the 28th, we add alternating 28th and 14th dates for each month
        WHEN EXTRACT(DAY FROM '2024-10-28'::DATE) = 28 THEN
            -- If n is even, add the 28th of the month, if n is odd, add the 14th of the next month
            CASE 
                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-10-28'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
                ELSE date_trunc('month', '2024-10-28'::DATE + (n/2 + 1) * INTERVAL '1 month') + INTERVAL '13 days'
            END
    END AS payment_date
FROM generate_series(0, 10 - 1) n;

SELECT 
    CASE
        -- If the start_date is the 14th, we add alternating 14th and 28th dates for each month
        WHEN EXTRACT(DAY FROM '2024-10-28 12:00:00'::TIMESTAMP) = 14 THEN
            -- If n is even, add the 14th of the month, if n is odd, add the 28th
            CASE 
                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-10-28 12:00:00'::TIMESTAMP + (n/2) * INTERVAL '1 month') + INTERVAL '13 days'
                ELSE date_trunc('month', '2024-10-28 12:00:00'::TIMESTAMP + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
            END
        -- If the start_date is the 28th, we add alternating 28th and 14th dates for each month
        WHEN EXTRACT(DAY FROM '2024-10-28 12:00:00'::TIMESTAMP) = 28 THEN
            -- If n is even, add the 28th of the month, if n is odd, add the 14th of the next month
            CASE 
                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-10-28 12:00:00'::TIMESTAMP + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
                ELSE date_trunc('month', '2024-10-28 12:00:00'::TIMESTAMP + (n/2 + 1) * INTERVAL '1 month') + INTERVAL '13 days'
            END
    END AS payment_date
FROM generate_series(0, 10 - 1) n;

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
        SELECT 
		    CASE
		        -- If the start_date is the 14th, we add alternating 14th and 28th dates for each month
		        WHEN EXTRACT(DAY FROM '2024-09-14'::DATE) = 14 THEN
		            -- If n is even, add the 14th of the month, if n is odd, add the 28th
		            CASE 
		                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-09-14'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '13 days'
		                ELSE date_trunc('month', '2024-09-14'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
		            END
		        -- If the start_date is the 28th, we add alternating 28th and 14th dates for each month
		        WHEN EXTRACT(DAY FROM '2024-09-14'::DATE) = 28 THEN
		            -- If n is even, add the 28th of the month, if n is odd, add the 14th of the next month
		            CASE 
		                WHEN MOD(n, 2) = 0 THEN date_trunc('month', '2024-09-14'::DATE + (n/2) * INTERVAL '1 month') + INTERVAL '27 days'
		                ELSE date_trunc('month', '2024-09-14'::DATE + (n/2 + 1) * INTERVAL '1 month') + INTERVAL '13 days'
		            END
		    END AS payment_date
		FROM generate_series(0, 5 - 1) n
    ) AS payment_dates
    WHERE obr.enabled = TRUE
      AND pat.enabled = TRUE
      AND res.enabled = TRUE
      AND payment_dates.payment_date BETWEEN s.validfrom AND COALESCE(s.validto, (CURRENT_DATE + INTERVAL '5 years'))
      AND NOT EXISTS (
          SELECT 1 FROM public.pagos p WHERE p.fechapago::date = payment_dates.payment_date::date
      );  -- Ensure there are no payments for the same date


		
