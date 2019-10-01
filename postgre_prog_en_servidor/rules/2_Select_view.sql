-- Setup caso
CREATE TABLE shoelace_data (
    sl_name    text,          -- primary key
    sl_avail   integer,       -- available number of pairs
    sl_color   text,          -- shoelace color
    sl_len     real,          -- shoelace length
    sl_unit    text           -- length unit
);

INSERT INTO shoelace_data VALUES ('sl1', 5, 'negro', 80.0, 'cm');
INSERT INTO shoelace_data VALUES ('sl2', 6, 'negro', 100.0, 'cm');
INSERT INTO shoelace_data VALUES ('sl3', 0, 'negro', 35.0 , 'pulgada');
INSERT INTO shoelace_data VALUES ('sl4', 8, 'negro', 40.0 , 'pulgada');
INSERT INTO shoelace_data VALUES ('sl5', 4, 'cafe', 1.0 , 'm');
INSERT INTO shoelace_data VALUES ('sl6', 0, 'cafe', 0.9 , 'm');
INSERT INTO shoelace_data VALUES ('sl7', 7, 'cafe', 60 , 'cm');
INSERT INTO shoelace_data VALUES ('sl8', 1, 'cafe', 40 , 'pulgada');

SELECT *
FROM shoelace_data;

CREATE TABLE unit (
    un_name    text,          -- primary key
    un_fact    real           -- factor to transform to cm
);

INSERT INTO unit VALUES ('cm', 1.0);
INSERT INTO unit VALUES ('m', 100.0);
INSERT INTO unit VALUES ('pulgada', 2.54);

SELECT *
FROM unit;
/*
CREATE RULE "_RETURN" AS ON SELECT TO shoelace DO INSTEAD
    SELECT s.sl_name,
           s.sl_avail,
           s.sl_color,
           s.sl_len,
           s.sl_unit,
           s.sl_len * u.un_fact AS sl_len_cm
      FROM shoelace_data s, unit u
     WHERE s.sl_unit = u.un_name;
*/

-- Crear vista
CREATE VIEW shoelace AS
    SELECT s.sl_name,
           s.sl_avail,
           s.sl_color,
           s.sl_len,
           s.sl_unit,
           s.sl_len * u.un_fact AS sl_len_cm
      FROM shoelace_data s, unit u
     WHERE s.sl_unit = u.un_name;

-- Seleccionar datos
SELECT * 
FROM shoelace;

-- Limpiar
DROP VIEW shoelace;
DROP TABLE shoelace_data;
DROP TABLE unit;