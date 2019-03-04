--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 7 (class 2615 OID 16675)
-- Name: contabilidad; Type: SCHEMA; Schema: -; Owner: estudiante
--

CREATE SCHEMA contabilidad;


ALTER SCHEMA contabilidad OWNER TO estudiante;

--
-- TOC entry 183 (class 3079 OID 11787)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2043 (class 0 OID 0)
-- Dependencies: 183
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 206 (class 1255 OID 16696)
-- Name: alarma_vencimiento(date); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION alarma_vencimiento(_fecha date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.alarma_vencimiento(_fecha date) OWNER TO estudiante;

--
-- TOC entry 201 (class 1255 OID 16690)
-- Name: descuentofijo(integer); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION descuentofijo(_valor integer) RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
  nuevo_valor real;
BEGIN
  nuevo_valor = _valor * .9;
  RETURN nuevo_valor;
END;
$$;


ALTER FUNCTION public.descuentofijo(_valor integer) OWNER TO estudiante;

--
-- TOC entry 197 (class 1255 OID 16677)
-- Name: fn_decir_vendo(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_decir_vendo(producto character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 'Vendo ' || producto;
END;
$$;


ALTER FUNCTION public.fn_decir_vendo(producto character varying) OWNER TO postgres;

--
-- TOC entry 198 (class 1255 OID 16678)
-- Name: fn_descuento(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_descuento(valor integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  valor_con_descuento integer;
BEGIN
  valor_con_descuento = valor - (valor * 0.1)::integer;
  RETURN valor_con_descuento::integer;
END;
$$;


ALTER FUNCTION public.fn_descuento(valor integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 177 (class 1259 OID 16666)
-- Name: ventas; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE ventas (
    consecutivo smallint NOT NULL,
    producto smallint,
    cantidad smallint
);


ALTER TABLE ventas OWNER TO estudiante;

--
-- TOC entry 205 (class 1255 OID 16709)
-- Name: fn_mostrar_ventas(character varying); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION fn_mostrar_ventas(_nombre character varying) RETURNS SETOF ventas
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- REGISTRAR LA AUDITORIA
  INSERT INTO auditoria (consecutivo, nombre, accion, fecha)
  VALUES (DEFAULT, _nombre, 'CONSULTA VENTAS', DEFAULT);

  -- DEVUELVO LO SOLICITADO
  RETURN QUERY SELECT * FROM ventas;
END;
$$;


ALTER FUNCTION public.fn_mostrar_ventas(_nombre character varying) OWNER TO estudiante;

--
-- TOC entry 199 (class 1255 OID 16688)
-- Name: fn_propietarios_insertar(character varying, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_propietarios_insertar(_nombre character varying, _nacimiento date) RETURNS smallint
    LANGUAGE plpgsql
    AS $$
DECLARE
  anios smallint;
  consecutivo smallint;
BEGIN
  anios = date_part('YEAR', age(now(), _nacimiento));
  INSERT INTO propietarios
	(codigo, nombre, edad, nacimiento, registro)
  VALUES (DEFAULT, upper(_nombre), anios, _nacimiento, DEFAULT)
  RETURNING codigo INTO consecutivo;
  RETURN consecutivo;
END;
$$;


ALTER FUNCTION public.fn_propietarios_insertar(_nombre character varying, _nacimiento date) OWNER TO postgres;

--
-- TOC entry 190 (class 1255 OID 16676)
-- Name: fn_saludar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_saludar() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  nombre character varying;
BEGIN
  nombre = 'Mundo';
  RETURN 'Hola ' || nombre;
END;
$$;


ALTER FUNCTION public.fn_saludar() OWNER TO postgres;

--
-- TOC entry 204 (class 1255 OID 16701)
-- Name: mientras(); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION mientras() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  valor integer;
BEGIN
  valor = 5;
  WHILE valor < 50 LOOP
    RAISE NOTICE 'voy en el valor: %', valor;
    valor = valor + 10;
  END LOOP;
END;
$$;


ALTER FUNCTION public.mientras() OWNER TO estudiante;

--
-- TOC entry 203 (class 1255 OID 16700)
-- Name: obtener_ventas(); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION obtener_ventas() RETURNS SETOF ventas
    LANGUAGE plpgsql
    AS $$
DECLARE
  fila ventas%ROWTYPE;
BEGIN
  FOR fila IN SELECT * FROM VENTAS LOOP
    -- fila.valor = fila.valor * 3;
    RETURN NEXT fila;
  END LOOP;
END;
$$;


ALTER FUNCTION public.obtener_ventas() OWNER TO estudiante;

--
-- TOC entry 202 (class 1255 OID 16699)
-- Name: repetir_for(); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION repetir_for() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  iteracion integer;
BEGIN
  FOR iteracion IN 1..10 LOOP
    RAISE NOTICE 'Voy en la iteración: %', iteracion;
  END LOOP;
END;
$$;


ALTER FUNCTION public.repetir_for() OWNER TO estudiante;

--
-- TOC entry 200 (class 1255 OID 16689)
-- Name: saludar(); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION saludar() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  nombre character varying;
BEGIN
  RETURN 'Hola Mundo';
END;
$$;


ALTER FUNCTION public.saludar() OWNER TO estudiante;

--
-- TOC entry 207 (class 1255 OID 16697)
-- Name: ventas_paginadas(integer, integer); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION ventas_paginadas(_registros integer, _pagina integer) RETURNS SETOF ventas
    LANGUAGE plpgsql
    AS $$
DECLARE
  inicio integer;
BEGIN
  inicio = _registros * _pagina - _registros;
  RETURN QUERY SELECT consecutivo, producto, cantidad
  FROM ventas
  LIMIT _registros OFFSET inicio;
END;
$$;


ALTER FUNCTION public.ventas_paginadas(_registros integer, _pagina integer) OWNER TO estudiante;

--
-- TOC entry 208 (class 1255 OID 16698)
-- Name: ventas_paginadas2(integer, integer); Type: FUNCTION; Schema: public; Owner: estudiante
--

CREATE FUNCTION ventas_paginadas2(_registros integer, _pagina integer) RETURNS SETOF ventas
    LANGUAGE plpgsql
    AS $$
DECLARE
  inicio integer;
BEGIN
  inicio = _registros * _pagina - _registros;
  RETURN QUERY SELECT consecutivo, producto, cantidad
  FROM ventas
  LIMIT _registros OFFSET inicio;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE EXCEPTION 'NO SE ENCUENTRAN LOS DATOS';
END;
$$;


ALTER FUNCTION public.ventas_paginadas2(_registros integer, _pagina integer) OWNER TO estudiante;

--
-- TOC entry 182 (class 1259 OID 16704)
-- Name: auditoria; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE auditoria (
    consecutivo smallint NOT NULL,
    nombre character varying(20),
    accion character varying(50),
    fecha timestamp without time zone DEFAULT now()
);


ALTER TABLE auditoria OWNER TO estudiante;

--
-- TOC entry 181 (class 1259 OID 16702)
-- Name: auditoria_consecutivo_seq; Type: SEQUENCE; Schema: public; Owner: estudiante
--

CREATE SEQUENCE auditoria_consecutivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auditoria_consecutivo_seq OWNER TO estudiante;

--
-- TOC entry 2044 (class 0 OID 0)
-- Dependencies: 181
-- Name: auditoria_consecutivo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: estudiante
--

ALTER SEQUENCE auditoria_consecutivo_seq OWNED BY auditoria.consecutivo;


--
-- TOC entry 175 (class 1259 OID 16658)
-- Name: colores; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE colores (
    nombre character varying(20),
    valor character varying(20)
);


ALTER TABLE colores OWNER TO estudiante;

--
-- TOC entry 171 (class 1259 OID 16646)
-- Name: distintos; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE distintos (
    color_a character varying(20),
    color_b character varying(20)
);


ALTER TABLE distintos OWNER TO estudiante;

--
-- TOC entry 172 (class 1259 OID 16649)
-- Name: nombres; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE nombres (
    nombre character varying(50)
);


ALTER TABLE nombres OWNER TO estudiante;

--
-- TOC entry 174 (class 1259 OID 16654)
-- Name: productos; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE productos (
    codigo smallint NOT NULL,
    nombre character varying(20),
    valor integer,
    vencimiento date
);


ALTER TABLE productos OWNER TO estudiante;

--
-- TOC entry 173 (class 1259 OID 16652)
-- Name: productos_codigo_seq; Type: SEQUENCE; Schema: public; Owner: estudiante
--

CREATE SEQUENCE productos_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE productos_codigo_seq OWNER TO estudiante;

--
-- TOC entry 2045 (class 0 OID 0)
-- Dependencies: 173
-- Name: productos_codigo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: estudiante
--

ALTER SEQUENCE productos_codigo_seq OWNED BY productos.codigo;


--
-- TOC entry 180 (class 1259 OID 16681)
-- Name: propietarios; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE propietarios (
    codigo smallint NOT NULL,
    nombre character varying(50) NOT NULL,
    edad smallint NOT NULL,
    nacimiento date NOT NULL,
    registro date DEFAULT now() NOT NULL
);


ALTER TABLE propietarios OWNER TO postgres;

--
-- TOC entry 179 (class 1259 OID 16679)
-- Name: propietarios_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE propietarios_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE propietarios_codigo_seq OWNER TO postgres;

--
-- TOC entry 2046 (class 0 OID 0)
-- Dependencies: 179
-- Name: propietarios_codigo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE propietarios_codigo_seq OWNED BY propietarios.codigo;


--
-- TOC entry 178 (class 1259 OID 16672)
-- Name: tmp_consulta; Type: TABLE; Schema: public; Owner: estudiante; Tablespace: 
--

CREATE TABLE tmp_consulta (
    consecutivo smallint,
    producto smallint,
    nombre character varying(20),
    cantidad smallint,
    valor integer,
    valor_total integer
);


ALTER TABLE tmp_consulta OWNER TO estudiante;

--
-- TOC entry 176 (class 1259 OID 16664)
-- Name: ventas_consecutivo_seq; Type: SEQUENCE; Schema: public; Owner: estudiante
--

CREATE SEQUENCE ventas_consecutivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ventas_consecutivo_seq OWNER TO estudiante;

--
-- TOC entry 2047 (class 0 OID 0)
-- Dependencies: 176
-- Name: ventas_consecutivo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: estudiante
--

ALTER SEQUENCE ventas_consecutivo_seq OWNED BY ventas.consecutivo;


--
-- TOC entry 1911 (class 2604 OID 16707)
-- Name: consecutivo; Type: DEFAULT; Schema: public; Owner: estudiante
--

ALTER TABLE ONLY auditoria ALTER COLUMN consecutivo SET DEFAULT nextval('auditoria_consecutivo_seq'::regclass);


--
-- TOC entry 1907 (class 2604 OID 16657)
-- Name: codigo; Type: DEFAULT; Schema: public; Owner: estudiante
--

ALTER TABLE ONLY productos ALTER COLUMN codigo SET DEFAULT nextval('productos_codigo_seq'::regclass);


--
-- TOC entry 1909 (class 2604 OID 16684)
-- Name: codigo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY propietarios ALTER COLUMN codigo SET DEFAULT nextval('propietarios_codigo_seq'::regclass);


--
-- TOC entry 1908 (class 2604 OID 16669)
-- Name: consecutivo; Type: DEFAULT; Schema: public; Owner: estudiante
--

ALTER TABLE ONLY ventas ALTER COLUMN consecutivo SET DEFAULT nextval('ventas_consecutivo_seq'::regclass);


--
-- TOC entry 2035 (class 0 OID 16704)
-- Dependencies: 182
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO auditoria (consecutivo, nombre, accion, fecha) VALUES (1, 'Jesus Ferrer', 'CONSULTA VENTAS', '2016-04-18 17:10:40.493818');


--
-- TOC entry 2048 (class 0 OID 0)
-- Dependencies: 181
-- Name: auditoria_consecutivo_seq; Type: SEQUENCE SET; Schema: public; Owner: estudiante
--

SELECT pg_catalog.setval('auditoria_consecutivo_seq', 1, true);


--
-- TOC entry 2028 (class 0 OID 16658)
-- Dependencies: 175
-- Data for Name: colores; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO colores (nombre, valor) VALUES ('azul', '#0000FF');
INSERT INTO colores (nombre, valor) VALUES ('verde', '#00FF00');
INSERT INTO colores (nombre, valor) VALUES ('rojo', '#FF0000');
INSERT INTO colores (nombre, valor) VALUES (NULL, 'sin');
INSERT INTO colores (nombre, valor) VALUES ('amarillo', '#FFFF00');


--
-- TOC entry 2024 (class 0 OID 16646)
-- Dependencies: 171
-- Data for Name: distintos; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO distintos (color_a, color_b) VALUES ('azul', 'rojo');
INSERT INTO distintos (color_a, color_b) VALUES ('azul', 'azul');
INSERT INTO distintos (color_a, color_b) VALUES ('azul', 'verde');
INSERT INTO distintos (color_a, color_b) VALUES ('rojo', 'rojo');
INSERT INTO distintos (color_a, color_b) VALUES ('rojo', 'rojo');
INSERT INTO distintos (color_a, color_b) VALUES ('rojo', NULL);
INSERT INTO distintos (color_a, color_b) VALUES (NULL, 'rojo');
INSERT INTO distintos (color_a, color_b) VALUES ('rojo', 'verde');
INSERT INTO distintos (color_a, color_b) VALUES ('rojo', 'azul');
INSERT INTO distintos (color_a, color_b) VALUES ('verde', 'azul');
INSERT INTO distintos (color_a, color_b) VALUES ('verde', 'rojo');
INSERT INTO distintos (color_a, color_b) VALUES ('verde', 'verde');


--
-- TOC entry 2025 (class 0 OID 16649)
-- Dependencies: 172
-- Data for Name: nombres; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO nombres (nombre) VALUES ('Alexander Gonzalez');
INSERT INTO nombres (nombre) VALUES ('Altemar Perez');
INSERT INTO nombres (nombre) VALUES ('Andres Kong');
INSERT INTO nombres (nombre) VALUES ('Andres Medallo');
INSERT INTO nombres (nombre) VALUES ('Anthony Canales');
INSERT INTO nombres (nombre) VALUES ('Ariel Giannone');
INSERT INTO nombres (nombre) VALUES ('Carlos Aceros');
INSERT INTO nombres (nombre) VALUES ('Carlos Alliot');
INSERT INTO nombres (nombre) VALUES ('Cristian Cruz Benel');
INSERT INTO nombres (nombre) VALUES ('Diego Fernando');
INSERT INTO nombres (nombre) VALUES ('Diego Quiroga');
INSERT INTO nombres (nombre) VALUES ('Escuela Digital');
INSERT INTO nombres (nombre) VALUES ('Heber Quequejana');
INSERT INTO nombres (nombre) VALUES ('Hugo Brito');
INSERT INTO nombres (nombre) VALUES ('jcris1998@gmail.com');
INSERT INTO nombres (nombre) VALUES ('Joe MCh');
INSERT INTO nombres (nombre) VALUES ('Jonathan Barrero');
INSERT INTO nombres (nombre) VALUES ('Jose');
INSERT INTO nombres (nombre) VALUES ('Jose Angel Lemus');
INSERT INTO nombres (nombre) VALUES ('jquerejeta@ikasle.aeg.es');
INSERT INTO nombres (nombre) VALUES ('Carlos Aceros');


--
-- TOC entry 2027 (class 0 OID 16654)
-- Dependencies: 174
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO productos (codigo, nombre, valor, vencimiento) VALUES (1, 'PAPA', 100, '2016-05-31');
INSERT INTO productos (codigo, nombre, valor, vencimiento) VALUES (2, 'YUCA', 75, '2016-06-15');
INSERT INTO productos (codigo, nombre, valor, vencimiento) VALUES (3, 'PLATANO', 101, '2016-07-01');
INSERT INTO productos (codigo, nombre, valor, vencimiento) VALUES (4, 'CARNE', 2000, '2016-07-02');
INSERT INTO productos (codigo, nombre, valor, vencimiento) VALUES (5, 'ARROZ', 1200, '2016-12-31');


--
-- TOC entry 2049 (class 0 OID 0)
-- Dependencies: 173
-- Name: productos_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: estudiante
--

SELECT pg_catalog.setval('productos_codigo_seq', 5, true);


--
-- TOC entry 2033 (class 0 OID 16681)
-- Dependencies: 180
-- Data for Name: propietarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO propietarios (codigo, nombre, edad, nacimiento, registro) VALUES (1, 'JESUS FERRER', 36, '1979-01-01', '2016-04-18');
INSERT INTO propietarios (codigo, nombre, edad, nacimiento, registro) VALUES (2, 'PEDRO PEREZ', 34, '1980-01-15', '2016-04-18');
INSERT INTO propietarios (codigo, nombre, edad, nacimiento, registro) VALUES (3, 'LEIDY GONZALEZ', 14, '2002-03-31', '2016-04-18');


--
-- TOC entry 2050 (class 0 OID 0)
-- Dependencies: 179
-- Name: propietarios_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('propietarios_codigo_seq', 3, true);


--
-- TOC entry 2031 (class 0 OID 16672)
-- Dependencies: 178
-- Data for Name: tmp_consulta; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (1, 1, 'PAPA', 10, 100, 1000);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (2, 1, 'PAPA', 7, 100, 700);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (3, 2, 'YUCA', 3, 75, 225);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (4, 2, 'YUCA', 16, 75, 1200);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (5, 3, 'PLATANO', 1, 101, 101);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (6, 3, 'PLATANO', 5, 101, 505);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (7, 4, 'CARNE', 13, 2000, 26000);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (8, 4, 'CARNE', 17, 2000, 34000);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (9, 4, 'CARNE', 48, 2000, 96000);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (10, 4, 'CARNE', 20, 2000, 40000);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (11, 4, 'CARNE', 10, 2000, 20000);
INSERT INTO tmp_consulta (consecutivo, producto, nombre, cantidad, valor, valor_total) VALUES (12, 4, 'CARNE', 3, 2000, 6000);


--
-- TOC entry 2030 (class 0 OID 16666)
-- Dependencies: 177
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: estudiante
--

INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (1, 1, 10);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (2, 1, 7);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (3, 2, 3);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (4, 2, 16);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (5, 3, 1);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (6, 3, 5);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (7, 4, 13);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (8, 4, 17);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (9, 4, 48);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (10, 4, 20);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (11, 4, 10);
INSERT INTO ventas (consecutivo, producto, cantidad) VALUES (12, 4, 3);


--
-- TOC entry 2051 (class 0 OID 0)
-- Dependencies: 176
-- Name: ventas_consecutivo_seq; Type: SEQUENCE SET; Schema: public; Owner: estudiante
--

SELECT pg_catalog.setval('ventas_consecutivo_seq', 12, true);


--
-- TOC entry 1916 (class 2606 OID 16687)
-- Name: pk_propietarios; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY propietarios
    ADD CONSTRAINT pk_propietarios PRIMARY KEY (codigo);


--
-- TOC entry 1914 (class 2606 OID 16671)
-- Name: pk_ventas; Type: CONSTRAINT; Schema: public; Owner: estudiante; Tablespace: 
--

ALTER TABLE ONLY ventas
    ADD CONSTRAINT pk_ventas PRIMARY KEY (consecutivo);


--
-- TOC entry 2042 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-04-18 16:30:31

--
-- PostgreSQL database dump complete
--

