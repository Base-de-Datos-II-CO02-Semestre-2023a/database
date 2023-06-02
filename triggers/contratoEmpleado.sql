create or replace function update_contrato_empleado()
    returns trigger
    language plpgsql
as
$$
declare
    cont int;
begin

    --Finaliza el contrato anterior
    select contrato into cont from empleado
    where id = new.id_empleado;

    update registro_contratos set fecha_fin = current_date
    where id = cont;

    -- Relaciona el nuevo contrato con el empleado
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