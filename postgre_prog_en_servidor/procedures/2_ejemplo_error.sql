
-- Setup caso
CREATE TABLE ShoeItem (
    s_name    text,          	-- primary key
    s_standard_price   integer, -- standard price
    s_discount   real       	-- discount   
);

INSERT INTO ShoeItem VALUES ('T10',100, 10);
INSERT INTO ShoeItem VALUES ('T20',200, 20);
INSERT INTO ShoeItem VALUES ('T30',300, 30);
INSERT INTO ShoeItem VALUES ('T10',400, 40);

-- Función con impuesto total
CREATE FUNCTION ShoesUnique(s_name text) RETURNS real AS $$
#print_strict_params on
DECLARE
FinalPrice real;
BEGIN
    SELECT (ShoeItem.s_standard_price-ShoeItem.s_discount)*1.08 INTO STRICT FinalPrice
	FROM ShoeItem
	WHERE ShoeItem.s_name = ShoesUnique.s_name;
    RETURN FinalPrice;
END;
$$ LANGUAGE plpgsql;

-- Select datos - Retorns valor
SELECT * 
FROM ShoesUnique('T20');
-- Select datos - Manda error
SELECT * 
FROM ShoesUnique('T10');

-- Limpiar caso
DROP TABLE ShoeItem;
DROP FUNCTION ShoesUnique(text);
