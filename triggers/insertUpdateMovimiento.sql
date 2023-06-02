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

