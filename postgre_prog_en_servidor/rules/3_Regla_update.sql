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

CREATE TABLE shoelace_log (
    sl_name    text,          -- shoelace changed
    sl_avail   integer,       -- new available value
    log_who    text,          -- who did it
    log_when   timestamp      -- when
);

SELECT *
FROM shoelace_data;

SELECT *
FROM shoelace_log;

-- Crear regla
CREATE RULE log_shoelace AS ON UPDATE TO shoelace_data
    WHERE NEW.sl_avail <> OLD.sl_avail
    DO INSERT INTO shoelace_log VALUES (
                                    NEW.sl_name,
                                    NEW.sl_avail,
                                    current_user,
                                    current_timestamp
                                );

-- Update datos
UPDATE shoelace_data 
SET sl_avail = 6 
WHERE sl_name = 'sl7';

-- Check tabla de bitacora (auditoria)
SELECT * 
FROM shoelace_log;

-- Limpiar
DROP TABLE shoelace_data;
DROP TABLE shoelace_log;