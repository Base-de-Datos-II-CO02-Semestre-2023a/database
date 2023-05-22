## Concepto-Inventario
```sql
CREATE OR REPLACE FUNCTION movement_verification()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN
CASE
	WHEN NEW.tipo = 'Venta' OR NEW.tipo  = 'Perdida' THEN 
		UPDATE inventario 
		SET cantidad = cantidad - NEW.cantidad
		FROM movimiento
		WHERE 
		NEW.id_movimiento = movimiento.id
		AND movimiento.id_lugar = inventario.id_lugar
		AND inventario.caducidad = (SELECT MAX(caducidad)
   					 FROM inventario
					WHERE NEW.id_articulo = id_articulo );
	WHEN NEW.tipo = 'Reabastecimiento' THEN 	
		IF EXISTS(SELECT inventario.id_articulo FROM inventario,movimiento
		WHERE NEW.id_movimiento = movimiento.id
			AND movimiento.id_lugar = inventario.id_lugar
			AND inventario.id_articulo = NEW.id_articulo
			AND NEW.caducidad = inventario.caducidad
			) THEN 
			UPDATE inventario 
			SET cantidad =  cantidad + NEW.cantidad
			FROM movimiento
			WHERE 
			NEW.id_movimiento = movimiento.id
			AND movimiento.id_lugar = inventario.id_lugar
			AND inventario.id_articulo = NEW.id_articulo
			AND NEW.caducidad = inventario.caducidad;
		ELSE
			INSERT INTO inventario(cantidad, id_articulo, id_lugar, caducidad)
			VALUES (NEW.cantidad, NEW.id_articulo,(SELECT id_lugar FROM movimiento WHERE NEW.id_movimiento = movimiento.id),NEW.caducidad);
		END IF;
	WHEN NEW.tipo = 'Translado' THEN
		IF EXISTS(SELECT inventario.id_articulo FROM inventario,movimiento
		WHERE NEW.id_movimiento = movimiento.id
			AND movimiento.id_lugar = inventario.id_lugar
			AND inventario.id_articulo = NEW.id_articulo
			AND NEW.caducidad = inventario.caducidad
			) THEN 
			UPDATE inventario 
			SET cantidad =  cantidad + NEW.cantidad
			FROM translado
			WHERE 
			NEW.id_movimiento = translado.id
			AND translado.destino = inventario.id_lugar
			AND inventario.id_articulo = NEW.id_articulo
			AND NEW.caducidad = inventario.caducidad;
		ELSE
			INSERT INTO inventario(cantidad, id_articulo, id_lugar, caducidad) 
			VALUES (NEW.cantidad, NEW.id_articulo, (SELECT destino FROM translado WHERE NEW.id_movimiento = translado.id), NEW.caducidad);
		END IF;
		UPDATE inventario 
		SET cantidad = cantidad - NEW.cantidad
		FROM translado
			WHERE 
			NEW.id_movimiento = translado.id
			AND translado.id_lugar = inventario.id_lugar
			AND inventario.id_articulo = NEW.id_articulo
			AND NEW.caducidad = inventario.caducidad;
END CASE;
RETURN NEW;
END
$$
;

CREATE TRIGGER concepto_movimiento
BEFORE INSERT
ON concepto
FOR EACH ROW
EXECUTE PROCEDURE movement_verification();
```

## Tipo de moviento-Movimiento
```sql
CREATE OR REPLACE FUNCTION insertar_movimiento()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN
	INSERT INTO movimiento(id, cantidad_conceptos, id_lugar, fecha, hora) 
	VALUES (NEW.id , NEW.cantidad_conceptos , NEW.id_lugar, NEW.fecha, NEW.hora);
RETURN NEW;
END
$$
;

CREATE TRIGGER insertar_venta
BEFORE INSERT
ON venta
FOR EACH ROW
EXECUTE PROCEDURE insertar_movimiento();

CREATE TRIGGER insertar_traslado
BEFORE INSERT
ON traslado
FOR EACH ROW
EXECUTE PROCEDURE insertar_movimiento();

CREATE TRIGGER insertar_reabastecimiento
BEFORE INSERT
ON reabastecimiento
FOR EACH ROW
EXECUTE PROCEDURE insertar_movimiento();

CREATE TRIGGER insertar_perdida
BEFORE INSERT
ON perdida
FOR EACH ROW
EXECUTE PROCEDURE insertar_movimiento();
```
## Registro_Contratos - Empleado

## Falta-Empleado

## Objetivo-Empleado
