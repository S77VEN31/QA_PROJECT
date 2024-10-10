CREATE OR REPLACE FUNCTION calculate_tax(salariobruto NUMERIC, deduccionhijos INTEGER, deduccionconyuge INTEGER)
RETURNS NUMERIC
LANGUAGE sql
AS $$
SELECT SUM(
  CASE
    WHEN salariobruto > ir.impuestominimo THEN
      (LEAST(salariobruto, ir.impuestomaximo) - ir.impuestominimo) * ir.impuestoporcentaje / 100
    ELSE
      0
  END
) - (deduccionhijos + deduccionconyuge)
FROM impuestorenta ir
WHERE ir.enabled = true;
$$;
