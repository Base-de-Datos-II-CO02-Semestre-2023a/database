CREATE OR REPLACE FUNCTION productividad_falta()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN

    IF ( (SELECT indice_productividad FROM empleado WHERE id = NEW.id_empleado)-(NEW.impacto_productividad/10) < 1 ) THEN
        UPDATE empleado
        SET indice_productividad = indice_productividad - (NEW.impacto_productividad / 10)
        WHERE id = NEW.id_empleado;
    END IF;
    RETURN NEW;
END
$$
;


CREATE or replace TRIGGER falta_empleado
    BEFORE UPDATE on falta
    FOR EACH ROW
EXECUTE FUNCTION  productividad_falta();
