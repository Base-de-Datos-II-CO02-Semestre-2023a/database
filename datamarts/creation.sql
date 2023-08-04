CREATE TABLE dim_tiempo(
    id date primary key,
    dia char(2),
    mes char(2),
    año char(4)
);

CREATE TABLE dim_lugar(
    id int primary key,
    nombre varchar(100),
    ciudad varchar,
    tipo tipo_lugar,
    codigo_postal int
);

CREATE TABLE dim_empleado(
    id int primary key,
    id_lugar int references lugar(id),
    nombre varchar(100),
    puesto tipo_puesto,
    contrato int references registro_contratos
);

CREATE TABLE fact_finanzas(
    id_lugar int references dim_lugar(id),
    id_tiempo date references dim_tiempo(id),
    ingresos bigint,
    egresos bigint,
    ganancias numeric(10,2),
    primary key (id_lugar, id_tiempo)
);

create table fact_almacenamiento(
    id_lugar int references dim_lugar(id),
    id_tiempo date references dim_tiempo(id),
    almacenamiento_restante numeric(10,2),
    primary key (id_tiempo, id_lugar)
);

create table fact_productividad(
    id_empleado int references dim_empleado(id),
    id_lugar int references dim_lugar(id),
    id_tiempo date references dim_tiempo(id),
    productividad numeric(10,2),
    primary key (id_lugar,id_tiempo,id_empleado)
);


set search_path to public;

grant select on all tables in schema capibarav2 to agentep;

set search_path to capibarav2

copy articulo from ~ar;