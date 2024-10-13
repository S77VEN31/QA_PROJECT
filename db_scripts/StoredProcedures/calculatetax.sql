-- Calcular el impuesto sobre la renta
-- Recibe el salario bruto del empleado,
-- el monto a deducir por la cantidad de hijos,
-- y el monto a deducir por el conyuge.
-- Estos montos se reciben ya calculados.
-- Retorna el monto correspondiente al impuesto de la renta.
CREATE OR REPLACE FUNCTION calculate_tax(salariobruto NUMERIC, deduccionhijos INTEGER, deduccionconyuge INTEGER)
RETURNS NUMERIC
LANGUAGE sql
AS $$
-- Se calcula una suma de los montos correspondientes a cada tramo
SELECT SUM(
  CASE
  	-- Si el salario bruto es mayor que el límite inferior del tramo
    WHEN salariobruto > ir.impuestominimo THEN
		-- Se obtiene el menor entre el salariobruto y el límite máximo
		-- y a eso se le resta el límite inferior.
		-- Después, se le saca el porcentaje correspondiente al tramo.
      (LEAST(salariobruto, ir.impuestomaximo) - ir.impuestominimo) * ir.impuestoporcentaje / 100
    ELSE
      0
  END
) - (deduccionhijos + deduccionconyuge) -- Se le restan los créditos fiscales al resultado de la suma
FROM impuestorenta ir
WHERE ir.enabled = true;
$$;

SELECT * FROM calculate_tax(5000000)