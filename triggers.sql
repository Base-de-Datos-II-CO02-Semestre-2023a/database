CREATE OR REPLACE FUNCTION movement_verification()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
    DECLARE
        registro inventario%ROWTYPE;
        lugarmovimiento int;
        destinolugar int;
        cantidadTmp int;
        iepsPorcentaje numeric(10,2);
        ivaPorcentaje numeric(10,2);
BEGIN
        cantidadTmp = new.cantidad;

        select precio_base, porcentaje_ieps into new.precio_base, iepsPorcentaje from articulo
        where new.id_articulo = id;
    CASE
        WHEN NEW.tipo = 'venta' THEN
            select id_lugar into strict lugarmovimiento   FROM venta
            WHERE id = NEW.id_movimiento;
            select porcentaje_iva into strict ivaPorcentaje from articulo
            where new.id_articulo = id;
            new.precio_unitario = new.precio_base + (new.precio_base * iepsPorcentaje );
            raise notice 'precio unitario %', new.precio_unitario;
            new.monto = new.precio_unitario * new.cantidad;
            raise notice 'monto %', new.monto;
            raise notice 'iva %', ivaPorcentaje;


            update venta set cantidad_conceptos = cantidad_conceptos+1,
                             subtotal = subtotal + new.monto,
                             iva = iva+ (new.precio_unitario * ivaPorcentaje),
                                total = total + new.monto + (new.precio_unitario * ivaPorcentaje)
                         where id = new.id_movimiento;

        WHEN NEW.tipo = 'perdida' THEN
            select id_lugar into strict lugarmovimiento FROM perdida
            WHERE id = NEW.id_movimiento;
            new.precio_unitario = new.precio_base;
            new.monto = new.precio_unitario * new.cantidad;
            update perdida set cantidad_conceptos = cantidad_conceptos+1,
                               total_perdida = total_perdida + new.monto
                            where id = new.id_movimiento;

        WHEN  NEW.tipo = 'reabastecimiento' then
            select id_lugar into strict lugarmovimiento FROM reabastecimiento
            where id = new.id_movimiento;
            new.precio_unitario = new.precio_base;
            new.monto = new.precio_unitario * new.cantidad;
            update reabastecimiento
            set cantidad_conceptos = cantidad_conceptos+1,
                total_compra = total_compra + new.monto
            where id = new.id_movimiento;
        WHEN new.tipo = 'traslado' then
            select id_lugar into strict lugarmovimiento  from traslado
            where  id = new.id_movimiento;
            select destino into strict  destinolugar from traslado
            where  id = new.id_movimiento;
            update traslado set cantidad_conceptos = cantidad_conceptos+1
                            where id = new.id_movimiento;
    end case;

    CASE
        WHEN NEW.tipo = 'venta' or new.tipo = 'perdida' THEN

            FOR registro IN
                SELECT * FROM inventario WHERE
                    id_articulo = NEW.id_articulo AND
                    id_lugar = lugarmovimiento and
                    cantidad > 0 and
                    caducidad >= current_date
                ORDER BY caducidad asc
            loop
                if registro.cantidad >= cantidadTmp then
                    update inventario
                    set cantidad = cantidad - cantidadTmp
                    where id_lugar = lugarmovimiento and
                            id_articulo = new.id_articulo and
                            caducidad = registro.caducidad;
                    cantidadTmp=0;
                    exit;
                else
                    cantidadTmp = cantidadTmp - registro.cantidad;
                    update inventario
                    set cantidad = 0
                    where id_lugar = lugarmovimiento and
                          id_articulo = new.id_articulo and
                          caducidad = registro.caducidad;
                end if;
            end loop;
            if cantidadTmp > 0 then
                raise exception 'no hay suficiente inventario';

            end if;
        WHEN NEW.tipo = 'reabastecimiento' then

            if exists(
                select * from inventario
                where id_lugar = lugarmovimiento and
                        id_articulo = new.id_articulo and
                        caducidad = new.caducidad
            ) THEN

                UPDATE inventario
                SET cantidad =  cantidad + NEW.cantidad
                where id_articulo = new.id_articulo and
                      id_lugar = lugarmovimiento and
                      caducidad =  new.caducidad;
            ELSE
                INSERT INTO inventario(cantidad, id_articulo, id_lugar, caducidad)
                VALUES (NEW.cantidad, NEW.id_articulo,lugarmovimiento,NEW.caducidad);
            END IF;
        when new.tipo = 'traslado' then
            new.precio_unitario = 0;
            new.monto = 0;
            if exists(
                select * from inventario
                where id_lugar = destinolugar and
                      id_articulo = new.id_articulo and
                      caducidad = new.caducidad
            ) then
                update inventario
                set cantidad = cantidad + new.cantidad
                where
                    id_articulo = new.id_articulo and
                    id_lugar = destinolugar and
                    caducidad = new.caducidad;
            else
                insert into inventario(cantidad, id_lugar, id_articulo, caducidad)
                values (new.cantidad, destinolugar, new.id_articulo, new.caducidad);
            end if;
            update inventario
            set cantidad = cantidad - new.cantidad
            where id_articulo = new.id_articulo and
                  id_lugar =  lugarmovimiento and
                  caducidad = new.caducidad;

    END CASE;
    RETURN NEW;
END
$$;

CREATE TRIGGER concepto_inventario
    BEFORE INSERT
    ON concepto
    FOR EACH ROW
EXECUTE PROCEDURE movement_verification();



create or replace function update_preciobase_inventario()
returns TRIGGER
language plpgsql
as
$$
    DECLARE
        precioBase numeric(10,2);
    begin
        select precio_base into precioBase from articulo
        where new.id_articulo = id;

        new.precio_base := precioBase;
        return new;
    end;
$$;

create trigger inventario_insert
    before  insert
    on inventario
    for each row
    execute  procedure  update_preciobase_inventario();



CREATE OR REPLACE FUNCTION insertar_movimiento()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN
	INSERT INTO movimiento(id,tipomov, cantidad_conceptos, id_lugar, fecha, hora)
	VALUES (NEW.id ,NEW.tipomov, NEW.cantidad_conceptos , NEW.id_lugar, NEW.fecha, NEW.hora);
RETURN NEW;
END
$$;


CREATE OR REPLACE FUNCTION update_movimiento()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN
    update only movimiento
        set cantidad_conceptos = new.cantidad_conceptos,
            id_lugar = new.id_lugar,
            fecha = new.fecha,
            hora = new.hora
        where id = new.id
        and tipomov = new.tipomov;

RETURN new;
END
$$;


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
EXECUTE PROCEDURE insertar_movimiento('reabastecimiento');

CREATE TRIGGER insertar_perdida
BEFORE INSERT
ON perdida
FOR EACH ROW
EXECUTE PROCEDURE insertar_movimiento('perdida');

create trigger update_venta
    before update
    on venta
    for each row
    execute procedure update_movimiento();

create trigger update_traslado
    before update
    on traslado
    for each row
    execute procedure update_movimiento();

create trigger update_reabastecimiento
    before update
    on reabastecimiento
    for each row
    execute procedure update_movimiento();

create trigger update_perdida
    before update
    on perdida
    for each row
    execute procedure update_movimiento();


create or replace function update_contrato_empleado()
returns trigger
language plpgsql
as
$$
    declare
        cont int;
begin
    select contrato into cont from empleado
        where id = new.id_empleado;

    update registro_contratos set fecha_fin = current_date
    where id = cont;

    update empleado set contrato = new.id
    where id = new.id_empleado;
    return new;
end
$$;

create or replace trigger update_contrato_into_empleado
    after insert
    on registro_contratos
    for each row
    execute procedure update_contrato_empleado();
create  or replace  function delete_contrato_empleado()
returns trigger
language plpgsql
as
    $$
    begin
        update empleado set contrato=null where contrato=old.id;
        return old;
    end
$$;

create or replace trigger remove_contrato_into_empleado
    before delete
          on registro_contratos
          for each row
    execute procedure delete_contrato_empleado();