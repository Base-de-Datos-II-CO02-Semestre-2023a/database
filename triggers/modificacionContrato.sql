create or replace function modificacion_registro_contratos()
    returns trigger
    language plpgsql
as
$$
declare modificacion varchar;
    declare modificacionjson json;
BEGIN
    modificacion = '{';
    CASE
        WHEN NEW.fecha_inicio != old.fecha_inicio THEN
            modificacion = modificacion ||'"oldFechaInicio": "' || old.fecha_inicio ||'",';
            modificacion = modificacion || '"fechaInicio": "' || new.fecha_inicio ||'",';
        WHEN new.fecha_fin != OLD.fecha_fin THEN
            modificacion = modificacion ||'"oldFechaFin": "' || old.fecha_fin ||'",';
            modificacion = modificacion || '"fechaFin": "' || new.fecha_fin ||'",';

        WHEN new.puesto != OLD.puesto THEN
            modificacion = modificacion||'"oldPuesto": ' || old.puesto ||',';
            modificacion = modificacion||'"puesto": ' || new.puesto ||',';


        WHEN new.salario != OLD.salario THEN
            modificacion = modificacion||'"oldSalario": ' || old.salario ||',';
            modificacion = modificacion||'"salario": ' || new.salario ||',';

        WHEN new.dias_vacaciones != OLD.dias_vacaciones THEN
            modificacion = modificacion||'"oldDiasVacaciones": ' || old.dias_vacaciones ||',';
            modificacion = modificacion||'"diasVacaciones": ' || new.dias_vacaciones ||',';

        when new.horas_diarias != old.horas_diarias then
            modificacion = modificacion||'"oldHorasDiarias": ' || old.horas_diarias ||',';
            modificacion = modificacion||'"horasDiarias": ' || new.horas_diarias ||',';

        when new.id_lugar != old.id_lugar then
            modificacion = modificacion||'"oldIdLugar": ' || old.id_lugar ||',';
            modificacion = modificacion||'"idLugar": ' || new.id_lugar ||',';
        else return new;
        END CASE;

    modificacion = substr(modificacion, 1, length(modificacion)-1);
    modificacion= modificacion ||'}';

    modificacionjson = modificacion::json;

    insert into modificacion_contrato (id_contrato, changed_on, modificaciones)
    VALUES (new.id, now(), modificacionjson);
    return new;
END;
$$;

create trigger modificar_contrato
    before update
    on registro_contratos
    for each row
execute procedure Modificacion_Registro_Contratos();