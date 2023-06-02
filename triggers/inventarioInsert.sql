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