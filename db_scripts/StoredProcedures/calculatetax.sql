CREATE OR REPLACE FUNCTION calculate_tax(salariobruto NUMERIC)
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
)
FROM impuestorenta ir
WHERE ir.enabled = true;
$$;

SELECT * FROM calculate_tax(5000000)