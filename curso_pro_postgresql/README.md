
Herramientas administrativas:
- `psql` > terminal/texto administrativas y desarrollo
- `pgAdmin` > UI administrativas y de desarrollo

entendiendo postgresql
- organizacion artefactos u objetos logicos como fisicos

servidor fisico
- libreria y archivos fisicos
- servicio > instancia: responde a una direccion IP, tiene sus propios permisos de acceso, mantiene aislada su informacion o datos

*service


*database > es una organizacion logica de datos y codigo. un service puede contener una o mas bases de datos. existe una relacion a archivos fisicos en nuestro directorio de archivos

*schema > una organizacion de datos y codigo. una base de datos puede contener uno o mas esquemas

*tablespace > archivo fisico

*catalog > informacion del sistema-objetos en detalle de meta informacion en la base de datos

*archivos de configuracion > postgresql.conf (info general instalacion), pg_hba.conf (detalles y definicion de seguridad), pg_ident.conf (mapeo de configuraciones)

*metodos de conexion pg_hba.conf >
-trust: menos segura, no password
-password: pide pass, texto simple
-md5: pide pass, cifrada con hash md5
-ident: usa pg_ident.conf, mapea user OS con user database

*roles >
- roles de inicio de sesion: con password asignable de accceso a db
- roles de grupo: con permisos, agrupa a otros dentro de un rol de uso

datos serial (serializable) para id de registros: create sequence ejemplo; select nextval('ejemplo'); select currentval('ejemplo'); select setval('ejemplo', 5);

datos cadenas de texto, operaciones: select lpad('ab',2,'0') AS pad, repeat('-',4)||'zy' AS dash, trim('  tr  ') AS trim;

substring: select split_part('312-4657-2947', '-', 2) AS x;

arreglos: select string_to_array('aaa.bbb.ccc','.') as y;  -- los arreglos  funcionan de manera nativa en postgres

select array[2013,2014,2015] as anios;  select array(select distinc gender from data); 

select '{mysql,postgressql}'::text[] AS x; -- conversion (::typeval[])

select x[3] from (select '{mysql,postgresql,sqlite}'::text[] AS x) as y; --valor posicion 3

select x[2:3] from (select '{mysql,postgresql,sqlite}'::text[] AS x) as y; --valor rango posiciones

select UNNEST(x[2:3]) from (select '{mysql,postgresql,sqlite}'::text[] AS x) as y; --valor indvidual rango posiciones


rangos: select '(0,6)'::int8range;  select '[0,6)'::int8range; select '[2015-07-01,2015-08-01]'::daterange;

rango infinito: select '[100,)'::int8range;

select * from data where '[70.0,71.0)'::numrange @> height;

# probando usar JSON:

create table profiles
(id serial primary key,
 profile JSON
);

insert into profiles(profile) values ('{"name":"mario","tech":["postgresql","ruby","elixir"]}');

select * from profiles;

insert into profiles(profile) values ('{"name":"jesus ferrer","tech":["php","java","oracle"]}');

select json_extract_path_text(profile,'name') from profiles;

select json_extract_path_text(profile,'tech') from profiles;

select json_array_elements('["hello",1.3,"\u2603"]');

create table profiles_b
(id serial primary key,
 profile JSONB
);

select json_extract_path_text(profile,'tech') from profiles;
select jsonb_extract_path_text(profile,'tech') from profiles_b;

select p.id, string_to_array(string_agg(elem,', '), ',') as list from profiles p, json_array_elements_text(p.profile->'tech') elem group by 1;

select id, profile->>'name' from profiles;

select * from profiles where profile->>'name'='jesus ferrer';

select row_to_json(data) from data limit 3;

select row_to_json(row(gender,height)) from data limit 3;

select row_to_json(t) from (select gender, height from data limit 3) t;

select array_to_json(array_agg(row_to_json(t))) 
from (select gender, height from data limit 3) t;


# HStore:

activacion :> create extension hstore; desactivar :> drop extension hstore;

probando usar HStore:

create table hprofiles(id serial primary key, profile hstore);

insert into hprofiles (profile) values('name=>jesus, php=>true, postgresql=>true');
insert into hprofiles (profile) values('name=>ferrer, java=>true, oracle=>true');

select profile->>'name' from hprofiles;

select * from hprofiles where (profile->'ruby')::boolean;
select * from hprofiles where (profile->'php')::boolean=true;

select * from hprofiles where profile@> 'nodejs=>true';
select * from hprofiles where profile ? 'nodejs';

select * from hprofiles where profile ?& ARRAY['ruby','javascript']; -- and

select * from hprofiles where profile ?| ARRAY['ruby','javascript']; -- or

update hprofiles set profile=profile||'html5=>true'::hstore;

update hprofiles set pofile = delete(profile,'go');

select akeys(profiles) from hprofiles;  select skeys(profiles) from hprofiles; || select distinct skeys(profiles) from hprofiles;

select hstore_to_json(profiles) from hprofiles; 


# postGis:

activacion :> create extension postgis;

probando usar postGis:

create table hospitales (
id serial primary key,
location geography,
position geometry(POINT,4326),
name text
);

insert into hospitales (name,location) values ('hospital xxx', ST_POINT(-6.3788,53.2911));

insert into hospitales (name,location) values ('hospital rovirosa', ST_POINT(-7.3497,53.5346));

select name, st_distance(location,st_point(-6237009, 53.34115)::geography) from hospitales; -- mostrar distancia a desde un punto indicado a las ubicaciones guardadas

select name, st_distance(location,st_point(32.7150, 53.34115)::geography) from hospitales;

select name from hospitales where ST_DWithin(location,ST_POINT(-6.237009,53.3411573))::geography, 10000; -- mostrar ubicaciones guardadas dentro de un radio a la redonda de acuerdo a un punto indicado

-parsear a otros formatos:

select name, st_astext(location) from hospitales;

select name, st_asgeojson(location) from hospitales;

select name, st_askml(location) from hospitales;

# Comandos PGSQL:

en ruta de instalacion, binarios

psql --help

conexion linea comandos windows :> psql -h localhost -U postgres

encontrar archivos de configuracion :> select name, setting from pg_settings where category = 'File Locations';

salir del entorno de postgre :> \q

ver configuraciones especificas :> select name, context, unit, setting, boot_val, reset_val from pg_settings where name in ('listen_addresses', 'max_connections', 'shared_buffers', 'effective_cache_size', 'work_mem', 'maintenance_work_mem') order by context, name;

aummentar memoria de trabajo inicial desde psql :> ALTER SYSTEM set work_mem = 8192;

verificar cambio de configuracion :> select pg_reload_conf();   -- salvado en postgresql.auto.conf

ver actividad en la bd :> select * from pg_stat_activity;

cancelar proceso mucha actividad o bloqueado :> select pg_cancel_backend(2345); --select pg_cancel_backend(#pid:process_id);

matar sesion en uso de usuario db :> select pg_terminate_backend(2345);

crear base de datos :> createdb mybase datos;

crear role de sesion :> create role video login password 'x123';

ver roles existentes :> select * from pg_roles;

eliminar rol :> drop role video;

crear role de sesion con password encriptado:> create role video login encrypted password 'x123';

crear role de sesion valido siempre, con password encriptado:> create role video login encrypted password 'x123' valid until 'infinity';

crear role de sesion temporal hasta, con password encriptado:> create role video login encrypted password 'x123' valid until '2019-8-26 00:00';

permisos de rol : - CREATEDB - SUPERUSER - CREATEROLE ej:

crear role de sesion valido siempre, con password encriptado:> create role video login encrypted password 'x123' CREATEDB valid until 'infinity';

crear role que hereda permisos :> create role perras inherit;

otorgar permisos de rol :> grant video to perras;

usar temporalmente permisos dentro de rol :> set role perras;

--- practicando:

create database curso_pg;

drop database curso_pg;

create database curso_pg template template1;

update pg_database SET datistemplate=true where datname='curso_pg'; -- promover database a convertirse en plantilla

create schema video;

grant createdb to video;  grant createdb to video with grant option; 

grant all on all tables in schema video to perras;

grant select on all tables in schema video to perras;


comandos extenciones: SELECT * FROM pg_available_extensions ORDER BY name;

conexion a instancia local: psql -h localhost -d dbpostgres -U postgres

listar bases de datos: \l

listar usuarios db: \du

cambiar a base de datos en uso: \c mydbase