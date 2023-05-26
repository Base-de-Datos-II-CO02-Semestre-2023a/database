insert into cat_prod_ser (clave, descripcion) values ('1', 'Categoria 1');
insert into articulo (id, nombre, descripcion, unidad, volumen, obj_imp, caracteristicas, precio_base, porcentaje_iva, porcentaje_ieps, porcentaje_ganancia)
values (1, 'Ejemplo', 1,'k',24.5, '00', '{"ejemplo":2}', 24, 0.14,0.03,0.3);

select * from articulo;



insert into ciudad (id, entidad, pais, nombre) VALUES (1, 'Ejemplo', 'Ejemplo', 'Ejemplo');

insert into externo (id, nombre, telefono, correo, codigo_postal, id_ciudad, calle, numero_interno, numero_externo, rfc, regimen_fiscal, tipo)
VALUES ( 1, 'Ejemplo', '1234567890', 'ejemplo@gmail.com', '12345', 1, 'Ejemplo', '1', '2', 'Ejemplo', '601', 'Cliente');

insert into externo (id, nombre, telefono, correo, codigo_postal, id_ciudad, calle, numero_interno, numero_externo, rfc, regimen_fiscal, tipo)
VALUES ( 2, 'Ejemplo', '2234567890', 'dejemplo@gmail.com', '12345', 1, 'Ejemplo', '1', '2', 'Ejemplod', '601', 'Provedor');

select * from externo;

insert into empleado (id, nombre, telefono, correo, codigo_postal, id_ciudad, calle, numero_interno, numero_externo, nss, rfc, password, fecha_de_nacimiento, fecha_de_ingreso, indice_productividad)
values (1, 'Ejemplo', '1234567890', 'empleado@gmail.com', '12345', 1, 'Ejemplo', '1', '2', '1234567890', 'Ejemplo', '1234567890', '2000-01-01', '2020-01-01', 1);

insert into lugar(id, nombre, telefono, correo, codigo_postal, id_ciudad, calle, numero_interno, numero_externo, tipo, id_responsable, cap_almacenamiento_max)
VALUES (1, 'Ejemplo', '1234567890', 'ejemlo@empresa.com', '12345', 1, 'Ejemplo', '1', '2', 'sucursal', 1, 100);

select * from lugar;

insert into reabastecimiento ( id, id_lugar, fecha, hora, id_provedor, total_compra)
values (1, 1, current_date, current_time, 1, 0);

insert into perdida(id, id_lugar, fecha, hora, tipo, total_perdida)
values ( 1, 1, current_date, current_time, 'robo', 24);

select * from reabastecimiento;
select * from perdida;
select * from only movimiento;
select * from inventario;

select id_lugar from "perdida" where id = 1;

insert into concepto (cantidad, id_articulo, id_movimiento, caducidad, precio_unitario, tipo, monto)
values (1, 1, 1, '2023-04-24', 24, 'reabastecimiento', 24);


insert into reabastecimiento ( id, id_lugar, fecha, hora, id_provedor, total_compra)
values (2, 1, current_date, current_time, 1, 0);

insert into concepto (cantidad, id_articulo, id_movimiento, caducidad, precio_unitario, tipo, monto)
values (2, 1, 2, '2023-05-27', 24, 'reabastecimiento', 24);

insert into reabastecimiento (  id_lugar, fecha, hora, id_provedor, total_compra)
values ( 1, '2023-05-23', current_time, 1, 0);

insert into concepto (cantidad, id_articulo, id_movimiento, caducidad, precio_unitario, tipo, monto)
values (3, 1, 3, '2023-05-28', 24, 'reabastecimiento', 24);

insert into venta ( id_lugar, fecha, hora, id_empleado, id_cliente)
values (1, current_date, current_time, 1, 1);

insert into concepto (cantidad, id_articulo, id_movimiento, caducidad, tipo)
values (2, 1, 5, '2023-05-27', 'reabastecimiento');
insert into concepto (cantidad, id_articulo, id_movimiento, caducidad, tipo)
values (2, 1, 6, '2023-05-26', 'reabastecimiento');

insert into concepto(cantidad, id_articulo, id_movimiento, tipo)
values (3, 1, 8, 'venta');
select *from venta;
select * from inventario;
select * from movimiento;
select * from concepto;