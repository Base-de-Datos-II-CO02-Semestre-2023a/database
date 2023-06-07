create or replace function insert_tiempo(diaP date)
    returns void
    language plpgsql
as
$$

    declare almacenamiento_restanteNuevo int;

    declare ingresosNuevos bigint;
    declare egresosNuevos bigint;

    declare dimEmpleado dim_empleado%ROWTYPE;
    declare lugarDim dim_lugar%ROWTYPE;
    declare last date;

    begin
            last := (select id from dim_tiempo where id < diaP order by id desc limit 1);
            case when last is null then last = '1800-01-01'; end case;
            insert into dim_tiempo(id, dia, mes, año) VALUES (
                                                              diaP,
                                                              to_char(diaP, 'DD'),
                                                              to_char(diaP,'MM'),
                                                              to_char(diaP, 'YYYY')
                                                              );

        for lugarDim in select * from dim_lugar loop
            select sum(monto) into egresosNuevos from gastos_lugar
                                           where id_lugar = lugarDim.id
                                             and fecha > last
                                            and fecha <= diaP;
            --TODO: con una variable declarada, guarda los datos de los selects en ella, haz los case que cuando sea null, esta se vuelva 0
            egresosNuevos = egresosNuevos + (select sum(total_perdida) from perdida where id_lugar = lugarDim.id
                                                                        and fecha > last
                                                                        and fecha <= diaP);
            egresosNuevos = egresosNuevos + (select sum(total_compra) from reabastecimiento where id_lugar = lugarDim.id
                                                                                  and fecha > last
                                                                                  and fecha <= diaP);
            egresosNuevos = egresosNuevos + (select  sum(iva) from venta where id_lugar = lugarDim.id
                                                               and fecha > last
                                                               and fecha <= diaP);
            ingresosNuevos = (select sum(total) from venta where id_lugar = lugarDim.id
                                           and fecha > last
                                           and fecha <= diaP);

            insert into fact_finanzas(id_lugar, id_tiempo, ingresos, egresos, ganancias)
                values (lugarDim.id, diaP, ingresosNuevos, egresosNuevos, ingresosNuevos-egresosNuevos);

            almacenamiento_restanteNuevo = (select sum(a.volumen*i.cantidad) from inventario i inner join articulo a on i.id_articulo = a.id
                                             where i.cantidad > 0
                                             and i.id_lugar = lugarDim.id) - (select cap_almacenamiento_max from lugar where id = lugarDim.id);
            insert into fact_almacenamiento(id_lugar, id_tiempo, almacenamiento_restante)
                values (lugarDim.id, diaP, almacenamiento_restanteNuevo);



            end loop;

            for dimEmpleado in select * from dim_empleado loop
                    update fact_finanzas set egresos = egresos + (select sum(total) from prestacion
                                                                  where id_empleado = dimEmpleado.id
                                                                    and fecha > last
                                                                    and fecha <= diaP)
                    where id_lugar = dimEmpleado.id_lugar
                      and id_tiempo = diaP;

                    insert into fact_productividad(id_empleado, id_lugar, id_tiempo, productividad)
                        values (dimEmpleado.id, dimEmpleado.id_lugar, diaP, (select indice_productividad from empleado where id = dimEmpleado.id));
                end loop;
    end;
$$;


create or replace function insert_dim_lugar()
    returns trigger
    language plpgsql
as
    $$
    begin
        insert into dim_lugar(id, nombre, ciudad, tipo, codigo_postal) values (new.id, new.nombre, new.id_ciudad, new.tipo,new.codigo_postal);
        return new;
    end;
    $$;

create or replace trigger poblar_lugar
    before insert
    on lugar
    for each row
    execute function insert_dim_lugar();

create or replace function insertar_dim_empleado()
    returns trigger
    language plpgsql
as
    $$
    begin
        insert into dim_empleado(id, nombre) values (new.id, new.nombre);
        return new;
    end;
    $$;

create or replace trigger poblar_empleado
    before insert
    on empleado
    for each row
    execute function insertar_dim_empleado();

create or replace function update_dim_empleado()
    returns trigger
    language plpgsql
as
    $$
        begin
            update dim_empleado set id_lugar = new.id_lugar,
                                    puesto = new.puesto,
                                    contrato = new.id
            where dim_empleado.id = new.id_empleado;
            return new;
        end;
    $$;

create or replace trigger update_dim_empleado
    after insert or update
    on registro_contratos
    for each row
    execute function update_dim_empleado();


