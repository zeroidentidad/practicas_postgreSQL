-- CREACIÓN DEL USUARIO
CREATE USER dragones PASSWORD 'xD' LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION; -- como superusuario para extensiones

-- CREACIÓN DEL TABLESPACE (OPCIONAL)
CREATE TABLESPACE ts_dragones OWNER dragones LOCATION E'C:\\tablespaces\\dragones';

-- CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE dragones OWNER = dragones TABLESPACE = ts_dragones;

-->> CONEXION CON EL USUARIO dragones para lo siguiente:

-- GENERACIÓN:
create table generacion(
id serial primary key, 
expiracion timestamp not null
);

-- DRAGON:
create table dragon(
id serial primary key,
nacimientofecha timestamp not null,
nickname varchar(64),
"isPublic"     BOOLEAN NOT NULL,
"saleValue"    INTEGER NOT NULL,
"sireValue"    INTEGER NOT NULL,
"generacionId" integer,
foreign key ("generacionId") references generacion(id)
);

-- RASGO:
create table rasgo(
id serial primary key,
"tipoRasgo" varchar not null,
"valorRasgo" varchar not null
);

-- RASGO - DRAGON:
create table rasgoDragon(
"rasgoId" integer,
"dragonId" integer,
foreign key ("rasgoId") references rasgo(id),
foreign key ("dragonId") references dragon(id)
);

-- CUENTA:
create table cuenta(
id             serial primary key,
"usernameHash" character(64),
"passwordHash" character(64),
"sesionId"    character(36),
balance        INTEGER NOT NULL
);

-- CUENTA - DRAGON:
CREATE TABLE cuentaDragon(
  "cuentaId" INTEGER REFERENCES cuenta(id),
  "dragonId"  INTEGER REFERENCES dragon(id),
  PRIMARY KEY ("cuentaId", "dragonId")
);



/*
drop table cuentaDragon;
drop table cuenta;
drop table rasgoDragon;
drop table dragon;
drop table generacion;

drop table rasgo;

truncate cuentaDragon;
truncate cuenta cascade;
truncate rasgoDragon;
truncate dragon cascade;
truncate generacion cascade;
*/