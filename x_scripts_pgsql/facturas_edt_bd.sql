-- CREACIÓN DEL USUARIO
CREATE USER sistema PASSWORD 'sysx';

-- CREACIÓN DEL TABLESPACE (OPCIONAL)
CREATE TABLESPACE ts_sistema OWNER sistema LOCATION E'C:\\tablespaces\\sistema';

-- CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE sistema OWNER = sistema TABLESPACE = ts_sistema;

-->> CONEXION CON EL USUARIO sistema para lo siguiente:

-- CREACIÓN DE LA TABLA DE PERFILES
CREATE TABLE perfiles(
	id_perfil smallserial,
	perfil varchar(20) not null,
	CONSTRAINT pk_perfiles PRIMARY KEY (id_perfil),
	CONSTRAINT uk_perfiles UNIQUE (perfil)
);

-- CREACIÓN DE LA TABLA DE USUARIOS
CREATE TABLE usuarios (
	id_usuario smallserial,
	usuario varchar(20) NOT NULL,
	nombre varchar(100) NOT NULL,
	clave varchar(32) NOT NULL, -- se usara MD5 sencillo
	id_perfil smallint,
	CONSTRAINT pk_usuarios PRIMARY KEY (id_usuario),
	CONSTRAINT uk_usuarios UNIQUE (usuario),
	CONSTRAINT fk_usuarios_perfiles FOREIGN KEY (id_perfil)
	REFERENCES perfiles (id_perfil) ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- CREACIÓN DE LA TABLA DE CLIENTES
CREATE TABLE terceros(
	id_tercero smallserial,
	identificacion varchar(20) NOT NULL,
	nombre varchar(100) NOT NULL,
	direccion varchar(100) NOT NULL,
	telefono varchar(20) NOT NULL,
	CONSTRAINT pk_terceros PRIMARY KEY (id_tercero),
	CONSTRAINT uk_terceros UNIQUE (identificacion)
);

-- CREACIÓN DE LA TABLA DE PRODUCTOS
CREATE TABLE productos (
	id_producto smallserial,
	nombre varchar(20) NOT NULL,
	cantidad smallint,
	precio smallint,
	id_usuario smallint,
	CONSTRAINT pk_productos PRIMARY KEY (id_producto),
	CONSTRAINT uk_productos UNIQUE (nombre),
	CONSTRAINT fk_productos_usuarios FOREIGN KEY (id_usuario)
	REFERENCES usuarios (id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT ck_cantidad CHECK(cantidad > 0),
	CONSTRAINT ck_precio CHECK(precio > 0)
);

-- CREACIÓN DE LA TABLA DE COMPRAS
CREATE TABLE compras(
	id_compra smallserial,
	fecha date DEFAULT now() NOT NULL,
	id_tercero smallint NOT NULL,
	id_producto smallint NOT NULL,
	cantidad smallint NOT NULL,
	valor smallint NOT NULL,
	id_usuario smallint NOT NULL,
	CONSTRAINT pk_compras PRIMARY KEY (id_compra),
	CONSTRAINT fk_compras_terceros FOREIGN KEY (id_tercero)
	REFERENCES terceros (id_tercero) ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT fk_compras_productos FOREIGN KEY (id_producto)
	REFERENCES productos (id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT ck_compras_cantidad CHECK (cantidad > 0),
	CONSTRAINT ck_compras_valor CHECK (valor > 0),
	CONSTRAINT fk_compras_usuarios FOREIGN KEY (id_usuario)
	REFERENCES usuarios (id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- CREACIÓN DE LA TABLA DE VENTAS
CREATE TABLE ventas (
	id_venta smallserial,
	fecha date DEFAULT now() NOT NULL,
	id_tercero smallint NOT NULL,
	id_producto smallint NOT NULL,
	cantidad smallint NOT NULL,
	valor smallint NOT NULL,
	id_usuario smallint NOT NULL,
	CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
	CONSTRAINT fk_ventas_terceros FOREIGN KEY (id_tercero)
	REFERENCES terceros (id_tercero) ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT fk_ventas_productos FOREIGN KEY (id_producto)
	REFERENCES productos (id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT ck_ventas_cantidad CHECK (cantidad > 0),
	CONSTRAINT ck_ventas_valor CHECK (valor > 0),
	CONSTRAINT fk_ventas_usuario FOREIGN KEY (id_usuario)
	REFERENCES usuarios (id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- CREACIÓN DE LA TABLA DE AUDITORIA
CREATE TABLE auditoria(
	id_auditoria smallserial,
	fecha timestamp NOT NULL DEFAULT now(),
	id_usuario smallint NOT NULL,
	accion varchar(20) NOT NULL,
	tabla varchar(20) NOT NULL,
	anterior json NOT NULL,
	nuevo json,
	CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria),
	CONSTRAINT fk_auditoria_usuarios FOREIGN KEY (id_usuario)
	REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- INSERCIÓN DE DATOS PRUEBAS

-- PERFILES
INSERT INTO perfiles (perfil) VALUES ('ADMINISTRADOR'), ('CAJERO');

-- USUARIOS
INSERT INTO usuarios (usuario, nombre, clave, id_perfil)
VALUES ('zero', 'JESUS FERRER', md5('clave123'), 1),
       ('vendedor', 'ADRIAN HERNANDEZ', md5('clave123'), 2);

-- TERCEROS
INSERT INTO terceros (identificacion, nombre, direccion, telefono)
VALUES ('123456789', 'PROVETODO LTDA', 'CRA 1', '211 EXT 123'),
	('987654321', 'COMPRATODO S.A.', 'AV BUSQUELA', '4857965'),
	('741852963', 'CLIENTE FRECUENTE', 'EL VECINO', '5478414');

-- PRODUCTOS
INSERT INTO productos (nombre, cantidad, precio, id_usuario)
VALUES ('REFRI', 5, 12000, 1),
	('LAVADORA', 1, 8900, 2),
	('SECADORA', 3, 7400, 1),
	('CALENTADOR', 1, 3200, 2);


-- CREACIÓN DE FUNCIONES INICIALES

-- FUNCIÓN DE CONSULTA DE TERCEROS
CREATE OR REPLACE FUNCTION consulta_terceros()
RETURNS SETOF terceros AS
$BODY$
BEGIN
	RETURN QUERY SELECT id_tercero, identificacion, nombre, direccion, telefono FROM terceros ORDER BY nombre;
END;
$BODY$
LANGUAGE plpgsql;
ALTER FUNCTION consulta_terceros() OWNER TO sistema;

-- FUNCIÓN DE CONSULTA DE PRODUCTOS
CREATE OR REPLACE FUNCTION consulta_productos()
RETURNS SETOF productos AS
$BODY$
BEGIN
	RETURN QUERY SELECT id_producto, nombre, cantidad, precio, id_usuario FROM productos ORDER BY nombre;
END;
$BODY$
LANGUAGE plpgsql;
ALTER FUNCTION consulta_productos() OWNER TO sistema;

-- FUNCIÓN DE AUTENTICACIÓN
CREATE OR REPLACE FUNCTION autenticacion(_usuario character varying, _clave character varying)
RETURNS TABLE(id_usuario smallint, nombre character varying, id_perfil smallint, perfil character varying)
AS
$BODY$
BEGIN
	RETURN QUERY SELECT a.id_usuario, a.nombre, b.id_perfil, b.perfil
	FROM usuarios as a NATURAL JOIN perfiles as b
	WHERE a.usuario = _usuario AND a.clave = md5(_clave);
	IF NOT FOUND THEN
		RAISE EXCEPTION 'El usuario o la contraseña no coinciden CON IF';
	END IF;

END;
$BODY$
LANGUAGE plpgsql;

-- FORMA DE USO DE AUTENTICACIÓN
select id_usuario, nombre, id_perfil, perfil from autenticacion('zero', 'clave123');

-- FUNCION TRIGGER PARA AUDITORÍA DE PRODUCTOS
CREATE OR REPLACE FUNCTION tg_productos_auditoria()
RETURNS TRIGGER AS
$BODY$
BEGIN
	IF TG_OP = 'UPDATE' THEN
		INSERT INTO auditoria (id_usuario, accion, tabla, anterior, nuevo)
		SELECT NEW.id_usuario, 'ACTUALIZAR', 'PRODUCTO', row_to_json(OLD.*), row_to_json(NEW.*);
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

-- TRIGGER AUDITORÍA PRODUCTOS
CREATE TRIGGER tg_productos_auditoria
AFTER UPDATE ON productos
FOR EACH ROW EXECUTE PROCEDURE tg_productos_auditoria();


-- FUNCIÓN TRIGGER PARA AUDITORÍA DE COMPRAS
CREATE OR REPLACE FUNCTION tg_compras_auditoria()
RETURNS TRIGGER AS
$BODY$
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO auditoria (id_usuario, accion, tabla, anterior, nuevo)
		SELECT NEW.id_usuario, 'INSERTAR', 'COMPRAS', row_to_json(NEW.*), null;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

-- TRIGGER DE AUDITORÍA DE COMPRAS
CREATE TRIGGER tg_compras_auditoria
AFTER INSERT ON compras
FOR EACH ROW EXECUTE PROCEDURE tg_compras_auditoria();

-- FUNCIÓN DE COMPRAR
CREATE OR REPLACE FUNCTION comprar(
	_cliente smallint,
	_producto smallint,
	_cantidad smallint,
	_valor smallint,
	_usuario smallint
) RETURNS smallint AS
$BODY$
DECLARE
	_idfactura smallint;
BEGIN
	-- SE INSERTA EL REGISTRO DE COMPRAS
	INSERT INTO compras (id_tercero, id_producto, cantidad, valor, id_usuario)
	VALUES (_cliente, _producto, _cantidad, _valor, _usuario) RETURNING id_compra INTO _idfactura;
	IF FOUND THEN
		-- SE ACTUALIZA EL STOCK DEL PRODUCTO
		UPDATE productos
		SET cantidad = cantidad + _cantidad, precio = _valor, id_usuario = _usuario
		WHERE id_producto = _producto;
	ELSE
		RAISE EXCEPTION 'No fue posible insertar el registro de compras';
	END IF;

	RETURN _idfactura;
END;
$BODY$
LANGUAGE plpgsql;

-- FUNCIÓN TRIGGER PARA AUDITORÍA DE VENTAS
CREATE OR REPLACE FUNCTION tg_ventas_auditoria()
RETURNS TRIGGER AS
$BODY$
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO auditoria (id_usuario, accion, tabla, anterior, nuevo)
		SELECT NEW.id_usuario, 'INSERTAR', 'VENTAS', row_to_json(NEW.*), null;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

-- TRIGGER DE AUDITORÍA DE VENTAS
CREATE TRIGGER tg_ventas_auditoria
AFTER INSERT ON ventas
FOR EACH ROW EXECUTE PROCEDURE tg_ventas_auditoria();

-- FUNCIÓN DE VENTAS
CREATE OR REPLACE FUNCTION vender(
	_cliente smallint,
	_producto smallint,
	_cantidad smallint,
	_usuario smallint
) RETURNS smallint AS
$BODY$
DECLARE
	_valor smallint;
	_existencia smallint;
	_idfactura smallint;
BEGIN
	-- SE BUSCA EL PRECIO DE VENTA Y SE VALIDA SI HAY STOCK DE VENTAS
	SELECT CAST(precio * 1.3 AS smallint), cantidad
	INTO STRICT _valor, _existencia
	FROM productos WHERE id_producto = _producto;

	-- SI HAY SUFICIENTE STOCK, SE VENDE
	IF _existencia >= _cantidad THEN
		-- SE INSERTA EL REGISTRO DE VENTAS
		INSERT INTO ventas (id_tercero, id_producto, cantidad, valor, id_usuario)
		VALUES (_cliente, _producto, _cantidad, _valor, _usuario) RETURNING id_venta INTO _idfactura;
		IF FOUND THEN
			-- SE ACTUALIZA EL STOCK DEL PRODUCTO
			UPDATE productos
			SET cantidad = cantidad - _cantidad, id_usuario = _usuario
			WHERE id_producto = _producto;
		ELSE
			RAISE EXCEPTION 'No fue posible insertar el registro de ventas';
		END IF;
	ELSE
		RAISE EXCEPTION 'No existe suficiente cantidad para la venta %', _existencia;
	END IF;

	RETURN _idfactura;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'No se encontró el producto a vender';
END;
$BODY$
LANGUAGE plpgsql;

-- FUNCIONES DE CONSULTA CON PAGINACION

-- CONSULTA VENTAS
CREATE OR REPLACE FUNCTION consulta_ventas(_limite smallint, _pagina smallint)
RETURNS TABLE(id_venta smallint, fecha date, cliente character varying,
		producto character varying, cantidad smallint, valor smallint)
AS
$BODY$
DECLARE
	_inicio smallint;
BEGIN
	_inicio = _limite * _pagina - _limite; -- paginación

	RETURN QUERY SELECT v.id_venta, v.fecha, t.nombre as proveedor,
		p.nombre as producto, v.cantidad, v.valor
	FROM ventas as v INNER JOIN terceros as t
		ON v.id_tercero = t.id_tercero
		INNER JOIN productos as p
		ON v.id_producto = p.id_producto
	LIMIT _limite
	OFFSET _inicio;
END;
$BODY$
LANGUAGE plpgsql;

-- CONSULTA COMPRAS
CREATE OR REPLACE FUNCTION consulta_compras(_limite smallint, _pagina smallint)
RETURNS TABLE(id_compra smallint, fecha date, cliente character varying,
		producto character varying, cantidad smallint, valor smallint)
AS
$BODY$
DECLARE
	_inicio smallint;
BEGIN
	_inicio = _limite * _pagina - _limite;

	RETURN QUERY SELECT c.id_compra, c.fecha, t.nombre as cliente,
		p.nombre as producto, c.cantidad, c.valor
	FROM compras as c INNER JOIN terceros as t
		ON c.id_tercero = t.id_tercero
		INNER JOIN productos as p
		ON c.id_producto = p.id_producto
	LIMIT _limite
	OFFSET _inicio;
END;
$BODY$
LANGUAGE plpgsql;

-- CONSULTA INVENTARIO ACTUAL
CREATE OR REPLACE FUNCTION consulta_inventario(_limite smallint, _pagina smallint)
RETURNS SETOF productos AS
$BODY$
DECLARE
	_inicio smallint;
BEGIN
	_inicio = _limite * _pagina - _limite;
	RETURN QUERY SELECT id_producto, nombre, cantidad, precio, id_usuario
	FROM productos
	ORDER BY id_producto
	LIMIT _limite
	OFFSET _inicio;
END;
$BODY$
LANGUAGE plpgsql;

-- PRUEBA DE LA FUNCIÓN DE VENTAS
SELECT comprar(2::smallint, 2::smallint, 1::smallint, 9000::smallint, 2::smallint);
SELECT vender(1::smallint, 1::smallint, 1::smallint, 1::smallint);
select * from ventas;
select * from compras;
select * from productos;
select * from auditoria;
select cast(anterior->>'cantidad' as smallint) * 3 from auditoria;

-- EJECUCIÓN DE CONSULTAS
SELECT * FROM consulta_ventas(3::smallint, 1::smallint);
SELECT * FROM consulta_compras(3::smallint, 1::smallint);
SELECT * FROM consulta_inventario(2::smallint, 2::smallint);