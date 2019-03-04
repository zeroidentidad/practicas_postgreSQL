-- NOMBRES DE LOS LENGUAJES PROCEDURALES DE DIFERENTES SGBDR
POSTGRESQL - plpgsql, pljava, plperl, plc, plpython
SQL SERVER - TRANSACT
ORACLE - plsql


-- CREAMOS LA FUNCIÓN SALUDAR
CREATE FUNCTION saludar()
RETURNS character varying
AS
$$
DECLARE
  nombre character varying;
BEGIN
  RETURN 'Hola Mundo';
END;
$$
LANGUAGE plpgsql;

-- EJECUTAMOS LA FUNCIÓN SALUDAR
SELECT saludar();

-- EJECUTAR LA FUNCIÓN DENTRO DE UNA CONSULTA
SELECT nombre, valor, saludar() FROM COLORES;

-- CREAR UNA FUNCIÓN QUE SE LLAME DESCUENTO
CREATE OR REPLACE FUNCTION descuentofijo(_valor integer)
RETURNS real
AS
$BODY$
DECLARE
  nuevo_valor real;
BEGIN
  nuevo_valor = _valor * .9;
  RETURN nuevo_valor;
END;
$BODY$
LANGUAGE plpgsql;


-- LLAMADO DE FUNCIÓN
SELECT codigo, nombre, valor, descuentofijo(valor), vencimiento
FROM PRODUCTOS;

-- CREAR FUNCION DE ALARMA DE VENCIMIENTO
CREATE OR REPLACE FUNCTION alarma_vencimiento(_fecha date)
RETURNS character varying
AS
$BODY$
DECLARE
  meses integer;
  dias integer;
  total integer;
  diferencia interval;
BEGIN
  meses = date_part('MONTH', age(_fecha, now()));
  dias = date_part('DAY', age(_fecha, now()));
  -- diferencia = age(_fecha, now());
  -- RAISE NOTICE 'Los dias son: %', dias;
  -- RAISE NOTICE 'La diferencia es: %', diferencia;
  total = meses * 30 + dias;
  IF total < 60 THEN
    RETURN 'CUIDADO!!! SE VENCE EN MENOS DE 2 MESES';
  ELSE
    RETURN 'AUN QUEDA TIEMPO';
  END IF;
END;
$BODY$
LANGUAGE plpgsql;

-- SE LLAMA LA FUNCIÓN DE ALERTA
SELECT codigo, nombre, valor, vencimiento, alarma_vencimiento(vencimiento)
FROM PRODUCTOS;

-- CONDICIONALES
IF a < b AND c > d OR e = f OR g <> h THEN
  -- TODA TU LÓGICA SI ES VERDADERO AQUÍ
ELSIF i > j THEN
  -- TODA TU LÓGICA SI ES VERDADERA LA CONDICIÓN DEL ELSIF
ELSE
  -- TODA TU LÓGICA SI NO SE CUMPLEN TODAS LAS ANTERIORES
END IF;

-- CONCATENAR CADENAS DE CARACTERES
'HOLA ' + ' MUNDO';
||
'HOLA ' || ' MUNDO';


-- CREAR UNA FUNCIÓN QUE NOS PERMITA PAGINAR LOS RESULTADOS DE UNA CONSULTA
-- RECORDANDO LIMIT Y OFFSET
SELECT *
FROM VENTAS
LIMIT 5 OFFSET 5;

-- FORMULA PARA AVERIGUAR EL OFFSET
CANTIDAD DE REGISTROS * PAGINA QUE SE QUIERE VER - CANTIDAD DE REGISTROS
5 * 1 - 5 = 0
5 * 2 - 5 = 5

-- CREACIÓN DE LA FUNCIÓN
CREATE OR REPLACE FUNCTION ventas_paginadas(_registros integer, _pagina integer)
RETURNS SETOF ventas
AS
$BODY$
DECLARE
  inicio integer;
BEGIN
  inicio = _registros * _pagina - _registros;
  RETURN QUERY SELECT consecutivo, producto, cantidad
  FROM ventas
  LIMIT _registros OFFSET inicio;
END;
$BODY$
LANGUAGE plpgsql;


-- LLAMADO DE LA FUNCIÓN QUE PERMITE PAGINAR
SELECT * FROM ventas_paginadas(5, 3);

-- TIPOS DE DATOS
-- SON TODOS LOS TIPOS DE DATOS QUE ACEPTA POSTGRESQL
-- %TYPE PERMITE COPIAR EL TIPO DE DATO EXACTO DE UNA COLUMNA (ATRIBUTO)
-- DE UNA TABLA (RELACIÓN).
DECLARE
  mi_variable productos.nombre%TYPE;


-- TIPO DE DATO
-- %ROWTYPE PERMITE COPIAR LA ESTRUCTURA DE UNA TABLA PARA ALMACENAR
-- LA INFORMACIÓN DE UN REGISTRO
DECLARE
  mi_fila productos%ROWTYPE;
  mi_fila.valor;

-- CICLOS
-- FOR
CREATE OR REPLACE FUNCTION repetir_for()
RETURNS void
AS
$BODY$
DECLARE
  iteracion integer;
BEGIN
  FOR iteracion IN 1..10 LOOP
    RAISE NOTICE 'Voy en la iteración: %', iteracion;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

-- EJECUCIÓN
SELECT repetir_for();

-- CREAR FUNCION PARA RECORRER UN SELECT
CREATE OR REPLACE FUNCTION obtener_ventas()
RETURNS SETOF ventas
AS
$BODY$
DECLARE
  fila ventas%ROWTYPE;
BEGIN
  FOR fila IN SELECT * FROM VENTAS LOOP
    -- fila.valor = fila.valor * 3;
    RETURN NEXT fila;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

-- llamado a la función
SELECT * FROM obtener_ventas();

-- WHILE
-- SE EJECUTA MIENTRAS QUE LA CONDICIÓN SE CUMPLA
CREATE OR REPLACE FUNCTION mientras()
RETURNS void
AS
$BODY$
DECLARE
  valor integer;
BEGIN
  valor = 5;
  WHILE valor < 50 LOOP
    RAISE NOTICE 'voy en el valor: %', valor;
    valor = valor + 10;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

-- llamado de la función
SELECT * FROM mientras();

-- PROCEDIMIENTO DE AUDITORIA
-- CREO UNA TABLA DE AUDITORIA
CREATE TABLE auditoria(
  consecutivo smallserial,
  nombre varchar(20),
  accion varchar(50),
  fecha timestamp DEFAULT now()
)

-- CREACIÓN DE LA FUNCIÓN
CREATE OR REPLACE FUNCTION fn_mostrar_ventas(_nombre character varying)
RETURNS SETOF ventas
AS
$BODY$
BEGIN
  -- REGISTRAR LA AUDITORIA
  INSERT INTO auditoria (consecutivo, nombre, accion, fecha)
  VALUES (DEFAULT, _nombre, 'CONSULTA VENTAS', DEFAULT);

  -- DEVUELVO LO SOLICITADO
  RETURN QUERY SELECT * FROM ventas;
END;
$BODY$
LANGUAGE plpgsql;

-- LLAMADO DE LA FUNCIÓN
SELECT * FROM auditoria;
SELECT * FROM fn_mostrar_ventas('Jesus Ferrer');








