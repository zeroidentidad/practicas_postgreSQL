# Comandos basicos

config "pg_hba.conf" conexion local confiable (solo en el mismo equipo), agregar:

local    all            postgres        127.0.0.1/32            trust    #a:

host    all            postgres        127.0.0.1/32            trust


## Metacomandos mas usados:

\l  # listar bds
\c  # conectar bd a usar
\?  # mostrar info ayuda
\d  # mostar relaciones objetos de la bd
\d+ table # mostrar detalle estructura objeto bd
\i 	# ejecutar comandos desde archivo de texto
\! 	# ejecutar comandos desde el shell del sistema operativo de manera interactiva

conectar por cmd cuando en localhost se configuro conexion de manera confiable: $> psql -U postgres -h 127.0.0.1

modificar superusuario contraseña postgres: $> ALTER ROLE postgres PASSWORD 'xpass'

metacomando de ayuda en el SQL: \h  - ejemplo: \h create

dedicar espacio en disco en linux:

1- chown -R postgres /home/username/misdb

2- chgrp -R postgres /home/username/misdb

3- psql -U postgres

4- CREATE TABLESPACE tbl_misdb LOCATION '/home/username/misdb';

crear db que use el tablespace creado:

1- CREATE DATABASE dbejemplo TABLESPACE = tbl_misdb;

2- \! ls -la


# Funciones select:

longitud campo caracteres: select char_length('texto o campo de prueba aqui ');

fecha actual: select now();

crear secuencia para campo id: 

\c midb

create sequence secuencia_regs;

usar secuencia para campo id:

insert into tabla values('valor1', 10, nextval('secuencia_regs'));


# Sobre diseño de BD:

tipos de atributos: simple - monovaluado, identificador principal, identificador alternativo, multivaluado, opcional, compuesto

## Practicas sentencias:

DDL:

CREATE USER nombre PASSWORD 'contraseña'

CREATE DATABASE nombredb OWNER = usuario TABLESPACE = un_tablespace

\db -metacomando listar tablespace

CREATE TABLE nombre_tabla (
columna1_tipo_dato,
columna2_tipo_dato (tamaño),
columna3_tipo_dato NOT NULL,
columna4_tipo_dato DEFAULT valor_x_defecto,
columna5_tipo_dato SERIAL,
CONSTRAINT nombre_constraint1 CHECK (columnaN > valor and columnaN < valor),
CONSTRAINT nombre_constraint2 PRIMARY KEY (columnaN, ..., columnaM),
CONSTRAINT nombre_constraint3 UNIQUE (columnaN, ..., columnaM),
CONSTRAINT nombre_constraint4 FOREIGN KEY (columnaN, ..., columnaM) REFERENCES otra_tabla(columnaN, ..., columnaM) ON DELETE acción ON UPDATE accion
) 

Practica:

postgres=# create tablespace tbl_curso_edteam location 'C:\PostgreSQL10\tablespaces_train';
postgres=# create user pedro password 'pedro';
postgres=# create user pablo password 'pablo';
postgres=# create database clase04 OWNER=pedro TABLESPACE=tbl_curso_edteam;

postgres=# create table propietarios(identificacion varchar (12), nom_nombres varchar (100) not null, nom_apellidos varchar(100) not null, email varchar (200), constraint pk_propietarios primary key(identificacion));

postgres=# create table telefonos(identificacion varchar (12), telefono varchar (30), constraint pk_telefonos primary key(identificacion,telefono), constraint fk_telefonos_propietarios FOREIGN KEY (identificacion) REFERENCES propietarios(identificacion) on update restrict on delete restrict);

postgres=# create table departamentos(codigo smallserial, nombre varchar (100) not null, constraint pk_departamentos primary key(codigo));

Ver seriales creados con metacomando: \ds

postgres=# create table ciudades(codigo smallserial, nombre varchar (100), departamento smallint not null, constraint pk_ciudades primary key(codigo), constraint fk_ciudades_departamentos foreign key(departamento) references departamentos(codigo) on update restrict on delete restrict);

postgres=# create table viviendas(codigo smallserial, dir_calle varchar (50) not null, dir_numero smallint not null, habitantes smallint not null, descripcion text not null, propietario varchar(12) not null, ciudad smallint not null, constraint pk_viviendas primary key(codigo), constraint fk_viviendas_propietarios foreign key(propietario) references propietarios(identificacion) on update restrict on delete restrict, constraint fk_viviendas_ciudades foreign key(ciudad) references ciudades(codigo) on update restrict on delete restrict);

DDL modificar usuario pass: ALTER USER pablo PASSWORD 'x' -- con superuser o admin

DDL modificar BD: 

ALTER DATABASE mibd RENAME TO nuevo_nombre
ALTER DATABASE mibd OWNER TO nuevo_usuario
ALTER DATABASE mibd SET TABLESPACE nuevo_tablespace

CDL GRANTS y REVOKES:

GRANT: Permite realizar una accion sobre un objeto - GRANT accion ON objeto TO usuario
ejemplo: 

GRANT CONNECT ON DATABASE clase04 TO pablo;
GRANT SELECT ON ciudades TO pablo;

GRANT INSERT ON departamentos TO pablo;

REVOKE: Restringe realizar una accion sobre un objeto - REVOKE accion ON objeto FROM usuario
ejemplo: 

REVOKE SELECT ON ciudades FROM pablo;
REVOKE CONNECT ON DATABASE clase04 FROM pablo;

DML INSERTs:

INSERT INTO tabla (campo1, campo2, …, campoN) VALUES (valor1, valor2, …., valorN)

INSERT INTO tabla (campo5, campo3, campo1, campo18, …, campoN) VALUES (valor5, valor1, valor18, …, valorN)

INSERT INTO tabla VALUES (valor1, valor2, …, valorN)

INSERT INTO tabla VALUES (DEFAULT, valorN, valorM, …, valorZ)

INSERT INTO tabla VALUES (valorA1, valorA2, … valorAN),
			(valorB1, valorB2, …, valorBN),
			(valorC1, valorC2, … valorCN)

INSERT INTO tabla SELECT consulta_aqui

Practica:

=# insert into departamentos(codigo,nombre) values(default, 'TABASCO');

=# insert into departamentos values(default, 'CHIAPAS');

=# insert into departamentos values(default, 'CAMPECHE'), (default, 'VERACRUZ'), (default, 'PUEBLA');

DML UPDATEs:

UPDATE tabla SET campo1 = valor1, campo2 = valor2, …, campoN = valorN WHERE campoM = valorM

Where:
	WHERE campoM = valorM (=, >, <, <>)
	WHERE campoM BETWEEN valor1 AND valor2
	WHERE campoM IN (valor1, valor2, …, valorN)
	WHERE campoM IN SELECT consulta
	WHERE campoM NOT IN…

Practica:

=# update departamentos SET nombre = 'YUCATAN' WHERE codigo=8;

=# update departamentos SET nombre = 'ACTUALIZADO' where codigo between 3 and 5;

DML DELETEs:

DELETE FROM tabla WHERE campoN = valorN

Where:
	WHERE campoM = campoM (=, >, <, <>)
	WHERE campoM BETWEEN valor1 AND valor2
	WHERE campoM IN (valor1, valor2, …, valorN)
	WHERE campoM IN SELECT consulta
	WHERE campoM NOT IN…

DELETE FROM tabla; -> Otra forma es con TRUNCATE : TRUNCATE departamentos;

Practica:

=# DELETE from departamentos WHERE nombre = 'ACTUALIZADO'; -- postgresql es Case Sensitive

# Algebra relacional sql

sobre hacer backup herramienta instalada: 

En archivo comprimido asi:

pg_dump --host localhost --port 5432 --username postgres --verbose --file backup_mmddyyyy.backup mibasedatos

En archivo plano asi:

pg_dump --host localhost --port 5432 --username postgres --verbose --inserts --column-inserts --file backup_mmddyyyy.backup mibasedatos

pg_dump --host localhost --port 5432 --username postgres --verbose --inserts --column-inserts --file backup_mmddyyyy.sql mibasedatos

Sobre hacer restauración backup en psql: 

ir a la ruta donde se guardo el archivo exportado: cd /ruta/archivo

luego conectarse a la base de datos a usar: =>/ruta/archivo$ psql -U usuariobd -d mibd

ejecutar la sentencia del metacomando de importación: =>/ruta/archivo$ \i archivo_resp.backup

Operaciones de conjuntos

Union: el UNION no muestra los repetidos, UNION ALL muestra todos los registros y los que estan repetidos

Intersección: el INTERSECT muestra registro o información que existe ó es la misma en dos relaciones o tablas diferentes. Su equivalencia en filtrado (WHERE) es con el IN con una subconsulta con la misma estructura

Diferencia: el EXCEPT muestra la información que esta en la segunda relación pero que no se encuentra en la primera tabla, es decir, se descarta el conjunto que si hay en ambas. Su equivalencia en filtrado (WHERE) es con el NOT IN con una subconsulta con la misma estructura

JOIN: la combinación relacional. Tipos son:

CROSS JOIN, producto cartesiano de las relaciones que intervienen en la combinación, asi:

SELECT a.campo1, a.campo2, …, a.campoN, b.campo1, b.campo2, …, b.campoN
FROM tabla1 as a CROSS JOIN tabla2 as b

NATURAL JOIN, combina relaciones de manera natural entre clave primaria de una y clave foránea de otra, asi:

SELECT a.campo1, a.campo2, …, a.campoN, b.campo1, b.campo2, …, b.campoN
FROM tabla1 as a NATURAL INNER JOIN tabla2 as b

INNER JOIN, combina dos relaciones cuando se necesita especificar el/los atributo(s) con que se combinarán, asi:

SELECT a.campo1, a.campo2, …, a.campoN, b.campo1, b.campo2, …, b.campoN
FROM tabla1 as a INNER JOIN tabla2 as b ON a.campo1 = b.campo1 (AND a.campo2 = b.campo2 …)

LEFT JOIN, combina realizando primero un INNER JOIN y luego añade aquellas filas de la relación nombrada en la parte izquierda de la sentencia que no satisfacen la combinación con la relación de la parte derecha, asi:

SELECT a.campo1, a.campo2, …, a.campoN, b.campo1, b.campo2, …, b.campoN
FROM tabla1 as a LEFT JOIN tabla2 as b ON a.campo1 = b.campo1

RIGHT JOIN, combina realizando primero un INNER JOIN y luego añade aquellas filas de la relación nombrada en la parte derecha de la sentencia que no satisfacen la combinación con la relación de la parte izquierda, asi:

SELECT a.campo1, a.campo2, …, a.campoN, b.campo1, b.campo2, …, b.campoN
FROM tabla1 as a RIGHT JOIN tabla2 as b ON a.campo1 = b.campo1

FULL JOIN, combina relaciones realizando primero un INNER JOIN y luego realiza un Left Join y por último un Right Join, asi:

SELECT a.campo1, a.campo2, …, a.campoN, b.campo1, b.campo2, …, b.campoN
FROM tabla1 as a FULL JOIN tabla2 as b ON a.campo1 = b.campo1

Backup BD remota: pg_dump -h 45.55.140.220 --port 5432 --username estudiante --inserts --column-inserts --verbose --file mibackup.sql algebra

JOIN multiple, asi:

select v.numero, v.valor, c.nombre as cliente, e.nombre as vendedor from ventas_contado v INNER JOIN clientes c ON v.identificacion=c.indentificacion INNER JOIN vendedor e ON v.vendedor=e.codigo

# Notas sobre SELECT a fondo

Funcion fecha actual: SELECT now();

Obtener parte de la fecha: SELECT date_part('MONTH', now());

Ejercicios:

select nombre, valor from colores where nombre='azul';

select nombre, valor from colores where UPPER(nombre)=UPPER('azul');

select consecutivo, producto, cantidad from ventas where producto = 4;

select from ventas where cantidad > 15; select from ventas where cantidad < 15;

select from ventas where producto <> 4; select from ventas where producto != 4;

select from ventas where producto <= 3; select from ventas where producto >= 3;

select * from nombres where nombre like 'Andres%'; select * from nombres where nombre like '%gmail.com';

select * from nombres where nombre like '%el%';

select * from nombres where nombre like 'Carlos Acero_'; -- comodin de un solo caracter

select * from nombres where nombre ILKE 'CARLOS ___RO_';

select * from nombres where nombre ilike 'CARLOS%'; -- con ILIKE se evita el case sensitive en PgSQL

select * from ventas where cantidad between 10 and 15;

select * from productos where vencimiento between '2019-03-01' and '2019-03-15';

select * from distintos where color_a IN('AZUL', 'rolo', verde', 'amarillo');

select * from distintos where color_a IN(select nombre from colores);

select * from distintos where color_a IS NULL; -- nulo no siginifica vacio ' '

select * from distintos where color_a NOT IN(select nombre from colores);

select * from colores where nombre EXISTS(select * from nombres); -- mostrar info de la consulta si de la subconsulta se obtuvo información, es decir, existe algo que retorne valor

select * from colores where nombre EXISTS(select 1 from nombres where 3 = 8);

select *, CASE WHEN valor > 500 THEN 'Caro' ELSE 'Economico' END from productos;

select *, CASE WHEN valor < 500 THEN 'Economico' WHEN valor = 1200 THEN 'Normal' WHEN valor > 1200 THEN 'Caro' END from productos;

select v.consecutivo, v.producto, p.nombre, v.cantidad, p.valor, v.cantidad * p.valor AS valor_total FROM ventas v INNER JOIN productos p ON v.producto = p.codigo

EL INTO, tabla temporal calculada y uso:

select v.consecutivo, v.producto, p.nombre, v.cantidad, p.valor, v.cantidad * p.valor AS valor_total INTO tmp_consulta FROM ventas v INNER JOIN productos p ON v.producto = p.codigo

select * from tmp_consulta;

select DISTINCT color_a, color_b from distintos; -- muestra los valores unicos descartando despues de cada uno los iguales, para no repetir de la proyecccion en la consulta

select DISTINCT ON (color_a) color_a, color_b from distintos ORDER BY color_a, color_b; -- saber el primer registro y toda su info de las columnas proyectadas

select DISTINCT ON (color_a) color_a, color_b from distintos ORDER BY color_a, color_b DESC; -- saber el ultimo registro y toda su info de las columnas proyectadas

## Clausulas de agregación: MIN, MAX, SUM, COUNT, AVG

select MIN(cantidad) as minimo from ventas; select MAX(cantidad) as maximo from ventas;

select AVG(cantidad) as promedio from ventas; select SUM(cantidad) as suma_total from ventas;

select COUNT(cantidad) as cantitad_ventas from ventas;

select MIN(cantidad) minimo, MAX(cantidad) maximo, COUNT(cantidad) cuenta, SUM(cantidad) suma, AVG(cantidad) promedio from ventas;

select PRODUCTO, SUM(CANTIDAD) AS SUMA FROM VENTAS GROUP BY PRODUCTO; -- necesario agrupar cuando se usa funcion de agregación

select v.producto, p.nombre, sum(v.cantidad) AS SUMA from ventas as v INNER JOIN productos p ON v.producto = p.codigo group by v.producto, p.nombre

## Formas de ordenamiento:

select producto, cantidad from ventas order by producto, cantidad; -- ASC por default

select producto, cantidad from ventas order by producto, cantidad DESC;

select producto, cantidad from ventas order by 1, 2; -- orden por numero de columna sin saber su nombre

select producto, cantidad from ventas order by producto DESC, cantidad ASC; 

## Filtro por grupo HAVING:

select producto, SUM(cantidad) AS SUMA from ventas group by producto having SUM(cantidad) > 18;

select nombre, count(*) cantidad from nombres group by nombre having count(*) > 1; -- util ver registros repetidos

## Paginación registros:

select * from ventas LIMIT 5;  select * from ventas order by producto DESC LIMIT 5;


select * from ventas LIMIT 5;  select * from ventas order by producto DESC LIMIT 5 OFFSET 5;

select * from ventas order by consecutivo DESC LIMIT 5 OFFSET 0;

select * from ventas order by consecutivo DESC LIMIT 5 OFFSET 5;

# Ejemplo PLpgSQL

```sql
CREATE TABLE productos(
  nombre varchar(20),
  cantidad smallint,
  precio smallint,
  ultima_modificacion timestamp,
  ultimo_usuario_bd text
)

-- CREACIÓN DE TRIGGER (STANDAR)
-- CREATE TRIGGER nombre
-- CUANDO ACCION[ES]
-- AS
--  AQUÍ EL CÓDIGO

-- CREAR LA FUNCIÓN QUE SOLICITA POSTGRES
CREATE OR REPLACE FUNCTION valida_productos()
RETURNS TRIGGER AS
$BODY$
BEGIN
  IF NEW.nombre IS NULL OR length(NEW.nombre) = 0 THEN
     RAISE EXCEPTION 'El nombre debe contener alguna información';
  END IF;
  IF NEW.cantidad < 0 THEN
     RAISE EXCEPTION 'La cantidad no puede ser negativa';
  END IF;
  IF NEW.precio < 0 THEN
     RAISE EXCEPTION 'El precio no puede ser negativo';
  END IF;

  NEW.ultima_modificacion = now();
  NEW.ultimo_usuario_bd = user;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

-- CREACIÓN DEL TRIGGER
CREATE TRIGGER valida_productos
BEFORE INSERT OR UPDATE
ON productos
FOR EACH ROW EXECUTE PROCEDURE valida_productos();

SELECT * FROM productos;

INSERT INTO productos (nombre, cantidad, precio)
VALUES ('PAPA', 10, 1000);

UPDATE productos SET cantidad = 15 WHERE nombre = 'PAPA';

-- CREACIÓN DE UNA AUDITORÍA

-- 1. CREAR TABLA DE AUDITORIA
CREATE TABLE auditoria_productos(
  accion varchar(20),
  fecha timestamp,
  nombre varchar(20),
  cantidad smallint,
  precio smallint
)

-- 2. CREAR LA FUNCIÓN DE AUDITORÍA
CREATE OR REPLACE FUNCTION auditoria_productos()
RETURNS TRIGGER AS
$BODY$
BEGIN
  IF TG_OP = 'INSERT' THEN
     INSERT INTO auditoria_productos (accion, fecha, nombre, cantidad, precio)
     VALUES ('INSERTAR', now(), NEW.nombre, NEW.cantidad, NEW.precio);
     RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
     INSERT INTO auditoria_productos (accion, fecha, nombre, cantidad, precio)
     VALUES ('BORRAR', now(), OLD.nombre, OLD.cantidad, OLD.precio);
     RETURN NULL;
  ELSIF TG_OP = 'UPDATE' THEN
     INSERT INTO auditoria_productos (accion, fecha, nombre, cantidad, precio)
     VALUES ('ANTES ACTUALIZAR', now(), OLD.nombre, OLD.cantidad, OLD.precio);
     INSERT INTO auditoria_productos (accion, fecha, nombre, cantidad, precio)
     VALUES ('DESPUES ACTULIZAR', now(), NEW.nombre, NEW.cantidad, NEW.precio);
     RETURN NEW;
  END IF;
END;
$BODY$
LANGUAGE plpgsql;

-- 3. CREAR EL TRIGGER
CREATE TRIGGER auditoria_productos
AFTER INSERT OR UPDATE OR DELETE
ON productos
FOR EACH ROW EXECUTE PROCEDURE auditoria_productos();

-- 4. Prueba del trigger
SELECT * FROM PRODUCTOS;
SELECT * FROM AUDITORIA_PRODUCTOS;

-- 4.1 INSERTAR
INSERT INTO PRODUCTOS (nombre, cantidad, precio)
VALUES ('YUCA', 5, 1900);
INSERT INTO PRODUCTOS (nombre, cantidad, precio)
VALUES ('CARNE', 40, 3500);
INSERT INTO PRODUCTOS (nombre, cantidad, precio)
VALUES ('ARROZ', 22, 2200);

-- 4.2 BORRAR
DELETE FROM productos WHERE nombre = 'PAPA';

-- 4.3 ACTUALIZAR
UPDATE productos SET cantidad = 20 WHERE nombre = 'CARNE';


-- 5 CREAR TRIGGER PARA CONTROLAR LA CANTIDAD DE INVENTARIO
-- 5.1 CREAR UNA TABLA PARA LAS COMPRAS
CREATE TABLE compras(
  consecutivo smallserial,
  fecha date,
  nombre varchar(20),
  cantidad smallint,
  precio smallint
)

-- 5.2 CREAR UNA TABLA PARA LAS VENTAS
CREATE TABLE ventas(
  consecutivo smallserial,
  fecha date,
  nombre varchar(20),
  cantidad smallint,
  precio smallint
)

-- 5.3 CREAR FUNCION QUE CONTROLE LAS COMPRAS
CREATE OR REPLACE FUNCTION compra_productos()
RETURNS TRIGGER AS
$BODY$
BEGIN
  PERFORM nombre FROM productos WHERE nombre = NEW.nombre; -- si exite o no registro con PERFORM
  IF FOUND THEN
	UPDATE productos
	SET cantidad = cantidad + NEW.cantidad, precio = NEW.precio
	WHERE nombre = NEW.nombre;
  ELSE 
	INSERT INTO productos (nombre, cantidad, precio)
	VALUES (NEW.nombre, NEW.cantidad, NEW.precio);
  END IF;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

-- 5.4 CREAR LA FUNCION DE VENTAS
CREATE OR REPLACE FUNCTION venta_productos()
RETURNS TRIGGER AS
$BODY$
DECLARE
  producto productos%ROWTYPE;
BEGIN
  SELECT * INTO producto FROM productos WHERE nombre = NEW.nombre;
  IF FOUND THEN
    IF producto.cantidad >= NEW.cantidad THEN
       UPDATE productos
       SET cantidad = cantidad - NEW.cantidad
       WHERE nombre = NEW.nombre;
    ELSE
      RAISE EXCEPTION 'No hay suficiente cantidad para la venta: %', producto.cantidad;
    END IF;
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'No existe el producto a vender: %', NEW.nombre;
  END IF;
END;
$BODY$
LANGUAGE plpgsql;

-- 5.5 CREAR EL TRIGGER DE COMPRAS
CREATE TRIGGER compra_productos
AFTER INSERT
ON compras
FOR EACH ROW EXECUTE PROCEDURE compra_productos();

-- 5.6 CREAR EL TRIGGER DE VENTAS
CREATE TRIGGER venta_productos
BEFORE INSERT
ON ventas
FOR EACH ROW EXECUTE PROCEDURE venta_productos();

-- 5.7 Prueba de funcionamiento
SELECT * FROM productos;
SELECT * FROM auditoria_productos;
SELECT * FROM compras;
SELECT * FROM ventas;

-- 5.7.1 COMPRANDO UN PRODUCTO EXISTENTE
INSERT INTO compras (fecha, nombre, cantidad, precio)
VALUES (now(), 'YUCA', 2, 2000);

-- 5.7.2 COMPRANDO UN PRODUCTO QUE NO EXISTE
INSERT INTO compras (fecha, nombre, cantidad, precio)
VALUES (now(), 'PAPA', 10, 1500);

-- 5.7.3 VENDIENDO UN PRODUCTO QUE NO EXISTE
INSERT INTO ventas (fecha, nombre, cantidad, precio)
VALUES (now(), 'MORA', 5, 200);

-- 5.7.4 VENDIENDO UN PRODUCTO EXISTENTE PERO SIN LA SUFICIENTE CANTIDAD
INSERT INTO ventas (fecha, nombre, cantidad, precio)
VALUES (now(), 'YUCA', 8, 2000);

-- 5.7.5 VENDIENDO UN PRODUCTO EXISTENTE CON SUFICIENTE CANTIDAD
INSERT INTO ventas (fecha, nombre, cantidad, precio)
VALUES (now(), 'ARROZ', 2, 2000);

-- VARIABLES DE LOS TRIGGER
-- NEW Contiene la información del nuevo registro que se esté trabajando
-- OLD Contiene la información del registro anterior a la operación
-- TG_OP Contiene el nombre de la operación que estamos realizando

-- MOMENTOS DE EJECUCION DEL TRIGGER (CUANDO?)
-- BEFORE Antes de realizar la acción
-- AFTER Despues de realizar la acción

-- ACCIONES
-- INSERT, UPDATE, DELETE

-- CAPTURAR EL RAISE EXCEPTION EN JAVA
-- try {
--   // aqui la conexion
--   // sentencia
-- // resultset
-- } catch (SQLException sqle) {
--  System.out.println(sqle.getMessage());
-- }
```