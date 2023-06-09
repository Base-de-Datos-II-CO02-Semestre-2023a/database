
CREATE SCHEMA capibarav2;
set search_path to capibarav2;

CREATE TYPE tipo_regimen AS ENUM ('601', '602', '603', '604', '605', '606', '607', '608', '609', '610', '611', '612', '613', '614', '615', '616', '617', '618', '619', '620', '621', '622', '623', '624', '625', '626');

CREATE TYPE tipo_externo AS ENUM ('Cliente','Provedor');

CREATE TYPE tipo_lugar AS ENUM('sucursal','almacen','oficina');

CREATE TYPE tipo_puesto AS ENUM('Ventas','Recursos_Humanos','Finanzas','Inventario','Admin');

CREATE TYPE tipo_prestacion AS ENUM('Nomina','Seguro','Afore','Prima_Vacacional');

CREATE TYPE tipo_gasto_lugar AS ENUM('fijo','variable');

CREATE TYPE tipo_falta AS ENUM('inasistencia','retardo', 'indisciplina');

CREATE TYPE impuesto AS ENUM('00','01','02','03','04');

CREATE TYPE tipo_unidad AS ENUM('kg','k','l','ml','m','cm','pza');

CREATE TYPE tipo_asistencia AS ENUM('entrada','salida');

CREATE TYPE tipo_movimiento AS ENUM('venta','traslado','reabastecimiento','perdida');

CREATE TYPE tipo_perdida AS ENUM('robo','caducado');

CREATE TYPE tipo_pago AS ENUM('efectivo','tarjeta','transferencia');



CREATE CAST (character varying AS tipo_regimen) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_externo) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_lugar) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_puesto) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_prestacion) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_gasto_lugar) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_falta) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS impuesto) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_unidad) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_asistencia) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_movimiento) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_perdida) WITH INOUT AS IMPLICIT;

CREATE CAST (character varying AS tipo_pago) WITH INOUT AS IMPLICIT;



CREATE TABLE ciudad(
    id VARCHAR(5) PRIMARY KEY,
    entidad VARCHAR(1000) NOT NULL,
    pais VARCHAR(1000) NOT NULL,
    nombre VARCHAR(1000) NOT NULL
);

CREATE TABLE sujeto(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono BIGINT NOT NULL UNIQUE,
    correo VARCHAR(256) check (correo LIKE '%_@%.%')NOT NULL UNIQUE,
    codigo_postal INT NOT NULL,
    id_ciudad VARCHAR CONSTRAINT sujeto_id_ciudad_fk REFERENCES ciudad(id) NOT NULL,
    calle VARCHAR(100) NOT NULL,
    numero_interno INT,
    numero_externo INT
);



CREATE TABLE externo(
    id SERIAL PRIMARY KEY,
    rfc VARCHAR(13) UNIQUE,
    regimen_fiscal tipo_regimen NOT NULL,
    tipo tipo_externo NOT NULL,

    telefono BIGINT NOT NULL UNIQUE,
    correo VARCHAR(256) check (correo LIKE '%_@%.%')NOT NULL UNIQUE,
    id_ciudad VARCHAR CONSTRAINT externo_id_ciudad_fk REFERENCES ciudad(id) NOT NULL

) inherits (sujeto);





CREATE TABLE lugar(
    id SERIAL PRIMARY KEY,
    tipo tipo_lugar NOT NULL,

    id_responsable INTEGER NOT NULL,
    cap_almacenamiento_max NUMERIC(10,2) NOT NULL,

    telefono BIGINT NOT NULL UNIQUE,
    correo VARCHAR(256) check (correo LIKE '%_@%.%')NOT NULL UNIQUE,
    id_ciudad VARCHAR CONSTRAINT externo_id_ciudad_fk REFERENCES ciudad(id) NOT NULL

) INHERITS (sujeto);


CREATE TABLE registro_contratos(
    id SERIAL PRIMARY KEY,

    id_empleado INTEGER NOT NULL,
    id_lugar INTEGER NOT NULL REFERENCES lugar(id),

    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    
    puesto tipo_puesto NOT NULL,

    salario NUMERIC (10,2) check ( salario >= 0) NOT NULL,

    horas_diarias INT check (horas_diarias >= 0) NOT NULL,

    dias_vacaciones INT check (dias_vacaciones >= 0) NOT NULL

);

CREATE TABLE modificacion_contrato(
    id_contrato INT CONSTRAINT id_contrato_fk REFERENCES registro_contratos(id) NOT NULL,
    changed_on TIMESTAMP(6) NOT NULL,
    modificaciones VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_contrato, changed_on)
);

CREATE TABLE empleado(
    id SERIAL PRIMARY KEY,

    nss NUMERIC(11) NOT NULL UNIQUE,
    rfc VARCHAR(13) NOT NULL UNIQUE,
    password VARCHAR(256) NOT NULL UNIQUE,

    fecha_de_nacimiento DATE NOT NULL,
    fecha_de_ingreso DATE NOT NULL,
    
    contrato INTEGER CONSTRAINT contrato_fk REFERENCES registro_contratos(id),
    
    indice_productividad NUMERIC(10,2) check (indice_productividad BETWEEN 0 AND 1) default 1 not null ,

    telefono BIGINT NOT NULL UNIQUE,
    correo VARCHAR(256) check (correo LIKE '%_@%.%')NOT NULL UNIQUE,
    id_ciudad VARCHAR CONSTRAINT empleado_id_ciudad_fk REFERENCES ciudad(id) NOT NULL
 ) INHERITS (sujeto);

alter table lugar add constraint lugar_responsable_fk foreign key (id_responsable) REFERENCES empleado(id);
alter table registro_contratos add constraint registro_contrato_id_empleado_fk foreign key (id_empleado) REFERENCES empleado(id);



CREATE TABLE prestacion(
    id_empleado INTEGER CONSTRAINT lugar_ REFERENCES empleado(id) NOT NULL,

    concepto tipo_prestacion NOT NULL,
    
    descripcion VARCHAR(1000),
    
    total NUMERIC (10,2) CHECK (total >= 0 )NOT NULL,
    
    fecha DATE NOT NULL,
    
    PRIMARY KEY(id_empleado, fecha)
);

CREATE TABLE registro_vacaciones(
    id_empleado INTEGER CONSTRAINT registro_vacaciones_id_empleado_fk REFERENCES empleado(id) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    PRIMARY KEY(id_empleado, fecha_inicio)
);


CREATE TABLE gastos_lugar(
    id_lugar INTEGER CONSTRAINT gastos_lugar_id_fk REFERENCES lugar(id) NOT NULL,

    descripcion VARCHAR(1000) NOT NULL,
    
    monto NUMERIC(10,2) check(monto >= 0)NOT NULL,
    
    tipo tipo_gasto_lugar NOT NULL,
    
    fecha DATE NOT NULL,
    
    PRIMARY KEY (id_lugar,tipo, fecha)
);


CREATE TABLE falta(
    id_empleado INTEGER CONSTRAINT falta_id_empleado_fk REFERENCES empleado(id) NOT NULL,

    tipo tipo_falta NOT NULL,
    
    fecha DATE NOT NULL,
    
    descripcion VARCHAR(1000) NOT NULL,
    
    impacto_productividad NUMERIC(10,2) check(0 <= impacto_productividad and impacto_productividad <=1 ) NOT NULL,
    
    PRIMARY KEY (id_empleado, tipo, fecha)
);


CREATE TABLE objetivo(
    id SERIAL PRIMARY KEY,

    id_empleado INTEGER CONSTRAINT objetivo_id_empleado_fk REFERENCES empleado(id) NOT NULL,
    
    descripcion VARCHAR(1000) NOT NULL,
    
    porcentaje_avance NUMERIC(10,2) CHECK (0 <= porcentaje_avance and porcentaje_avance<= 1 ) NOT NULL,
    
    impacto_productividad NUMERIC(10,2) CHECK (0<=impacto_productividad and impacto_productividad<=1) NOT NULL
);


CREATE TABLE control_asistencia(
    id_empleado INTEGER CONSTRAINT objetivo_id_empleado_fk REFERENCES empleado(id) NOT NULL,

    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    
    tipo TIPO_ASISTENCIA NOT NULL
);

CREATE TABLE cat_prod_ser(
    clave INT PRIMARY KEY,
    descripcion VARCHAR(1000) NOT NULL
);


CREATE TABLE articulo(
    id NUMERIC(14),
    nombre VARCHAR(50) NOT NULL,

    descripcion INT CONSTRAINT articulo_descripcion_prod_ser_fk REFERENCES cat_prod_ser(clave) NOT NULL,

    unidad TIPO_UNIDAD NOT NULL,

    volumen NUMERIC(10,2),

    obj_imp impuesto NOT NULL,

    caracteristicas JSON NOT NULL,

    precio_base NUMERIC(10,2) NOT NULL,

    porcentaje_iva NUMERIC(10,2) check(0<= porcentaje_iva and porcentaje_iva <=1 ) NOT NULL,
    porcentaje_ieps NUMERIC(10,2) check(0<=porcentaje_ieps and porcentaje_ieps<=1) NOT NULL,
    porcentaje_ganancia NUMERIC(10,2) check(0<=porcentaje_ganancia and porcentaje_ganancia<=1) NOT NULL,
    PRIMARY KEY (id, precio_base)
) PARTITION BY RANGE (precio_base);

CREATE TABLE articulo_cheaper partition of articulo FOR VALUES FROM (0) TO (1000);
CREATE TABLE articulo_expensive partition of articulo FOR VALUES FROM (1000) TO (1000000);

CREATE TABLE inventario(
    cantidad INT NOT NULL,
    descuento NUMERIC(10,2) check(descuento BETWEEN 0 AND 1) NOT NULL default 0,
    id_lugar INTEGER NOT NULL,
    id_articulo INTEGER NOT NULL,
    precio_base NUMERIC(10,2),
    caducidad DATE,
    constraint inventario_articulo_fk FOREIGN KEY (id_articulo, precio_base) REFERENCES articulo(id, precio_base),

    PRIMARY KEY(id_lugar, id_articulo, caducidad)
);

CREATE TABLE movimiento(
    id SERIAL,

    tipomov tipo_movimiento NOT NULL,

    cantidad_conceptos INT CHECK (cantidad_conceptos >= 0) NOT NULL DEFAULT 0,

    id_lugar INTEGER CONSTRAINT movimiento_id_lugar_fk REFERENCES lugar(id) NOT NULL,

    fecha DATE NOT NULL,

    hora TIME NOT NULL,
    primary key (id, tipomov)
);

CREATE TABLE traslado(
    id INTEGER PRIMARY KEY,
    id_empleado INTEGER CONSTRAINT traslado_id_empleado_fk REFERENCES empleado(id) NOT NULL,
    destino INTEGER CONSTRAINT destino_destino_fk REFERENCES lugar(id) NOT NULL
) INHERITS (movimiento);



CREATE TABLE perdida(
    id INTEGER PRIMARY KEY,
    tipo tipo_perdida NOT NULL,
    total_perdida NUMERIC(10,2) CHECK (total_perdida >= 0) NOT NULL default 0
) INHERITS (movimiento);


CREATE TABLE reabastecimiento(
    id INTEGER PRIMARY KEY,
    id_provedor INTEGER CONSTRAINT reabastecimiento_id_provedor_fk REFERENCES externo(id) NOT NULL,
    total_compra NUMERIC(10,2) CHECK (total_compra >= 0) NOT NULL default 0,
) INHERITS (movimiento);



CREATE TABLE venta(
    id INTEGER PRIMARY KEY,
    id_empleado INTEGER CONSTRAINT venta_id_empleador_fk REFERENCES empleado(id) NOT NULL,
    id_cliente INTEGER CONSTRAINT venta_id_cliente_fk REFERENCES externo(id),
    subtotal NUMERIC(10,2) CHECK (subtotal >= 0) NOT NULL default 0,
    iva NUMERIC(10,2) CHECK (iva >= 0) NOT NULL default 0,
    total NUMERIC(10,2) CHECK (total >= 0) NOT NULL default 0,
    metodo_pago tipo_pago
) INHERITS (movimiento);




CREATE TABLE concepto(
    cantidad INT NOT NULL,
    id_articulo INT,
    id_movimiento INT NOT NULL,
    caducidad DATE,
    precio_unitario NUMERIC(8,2) NOT NULL,
    precio_base NUMERIC(10,2),
    tipo tipo_movimiento NOT NULL,
    monto NUMERIC(10,2) NOT NULL,
    CONSTRAINT concepto_articulo_fk FOREIGN KEY (id_articulo, precio_base) REFERENCES articulo(id, precio_base),
    PRIMARY KEY (id_articulo, id_movimiento, tipo),
    constraint concepto_movimiento foreign key (id_movimiento, tipo) references movimiento(id, tipomov)
);

set search_path to public;

grant select, insert, update, delete on all tables in schema capibarav2 to agentep;
grant usage on all sequences in schema capibarav2 to agentep;
grant usage on schema capibarav2 to agentep;


