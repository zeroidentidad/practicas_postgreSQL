CREATE OR REPLACE FUNCTION f_actualizar_capacidad_granjas() RETURNS TRIGGER 
AS $ actualizar_capacidad_granjas$
    DECLARE
        vn_capacidad    INTEGER;
        vn_granja_id    INTEGER;
    BEGIN
    
    IF TG_OP = 'DELETE' THEN
        vn_granja_id = OLD.granja_id;
    ELSE
        vn_granja_id = NEW.granja_id;
    END IF;    
    
    SELECT SUM(capacidad)
      INTO nv_capacidad
      FROM galpon_granja a
     WHERE a.granja_id = vn_granja_id;
    
     UPDATE granjas a
     SET capacidad = COALESCE(nv_capacidad,0)
     WHERE a.id = vn_granja_id;
        
    END;
$actualizar_capacidad_granjas$ LANGUAGE plpgsql;

CREATE TRIGGER tg_actualizar_capacidad_granjas
AFTER INSERT OR UPDATE OR DELETE ON galpon_granja
    FOR EACH ROW EXECUTE PROCEDURE f_actualizar_capacidad_granjas();