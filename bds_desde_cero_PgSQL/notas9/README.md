# Ejemplo emulación NoSQL con MongoDB desde una terminal online: 

https://www.tutorialspoint.com/mongodb_terminal_online.php

db.productos.insert({ codigo:"001", producto:"TOMATE", cantidad: 20, precio: 15 });

db.productos.find(); db.productos.find().pretty(); -- formateo de salida

db.productos.find({precio:{$gt:10}}, {producto:1}); -- esta funcion recibe 2 campos, el primero corresponde al filtro y el segundo a la proyección

db.productos.find({precio:{$gt:10}}, {producto:1, _id:0}); -- :1 (mostrar), :0 (no mostrar) $gt (grand than)


##Ejemplo NoSQL con PostgreSQL:

create table minosql(
consecutivo serial,
informacion json
)

select * from minosql;

insert into minosql (informacion) values('{"codigo":"001", "nombre":"PAPA", "cantidad":20, "precio":15}');
insert into minosql (informacion) values('{"codigo":"001", "nombre":"PAPA", "cantidad":20, "precio":15}'::json);

insert into minosql (informacion) values('{"codigo":"001", "nombre":"YUCA", "cantidad":25, "precio":15}'::json);

select informacion -> 'nombre' AS info from minosql;
select informacion ->> 'nombre' AS info from minosql;

select informacion ->> 'nombre' AS info, informacion ->> 'cantidad' AS cant from minosql
where informacion ->> 'nombre'='PAPA';

select row_to_json(clientes) from clientes;

select row_to_json(antes) from OLD AS antes;
select row_to_json(nueva) from NEW AS nueva;

ejemplo practico:

create table auditoria {
	consecutivo serial,
	accion varchar,
	fecha timestamp,
	idusuario smallint,
	tabla varchar,
	antes json,
	nueva json
}