CREATE OR REPLACE FUNCTION productividad_avance()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN

IF (NEW.porcentaje_avance = 1 AND (SELECT indice_productividad FROM empleado WHERE id = NEW.id_empleado)+(NEW.impacto_productividad/10) < 1 ) THEN
	UPDATE empleado
	SET indice_productividad = indice_productividad + (NEW.impacto_productividad / 10)
	WHERE id = NEW.id_empleado; 
END IF;
RETURN NEW;
END
$$
;


CREATE or replace TRIGGER objetivo_empleado
BEFORE UPDATE on OBJETIVO
FOR EACH ROW
EXECUTE FUNCTION  productividad_avance();
