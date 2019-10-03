
-- Setup caso 
CREATE TABLE ShoeItem (
    s_name    text,          	-- primary key
    s_standard_price   integer, -- standard price
    s_discount   real       	-- discount   
);

INSERT INTO ShoeItem VALUES ('T10',100, 10);
INSERT INTO ShoeItem VALUES ('T20',200, 20);
INSERT INTO ShoeItem VALUES ('T30',300, 30);

-- ------------------------------------
-- Identificar el impuesto total sobre el precio estándar.
-- ------------------------------------

-- Función con impuesto total
CREATE FUNCTION SalesTax(tax real) RETURNS real AS $$
BEGIN
    RETURN tax * 0.08;
END;
$$ LANGUAGE plpgsql;

-- Select datos usando func
SELECT * 
FROM SalesTax(2);
SELECT * 
FROM SalesTax(5);

-- Select en Table con input de columna
SELECT *
FROM ShoeItem, SalesTax (s_standard_price);

-- ------------------------------------
-- Calcular el precio final después del descuento con el impuesto aplicable
-- ------------------------------------

-- Función con precio total
CREATE FUNCTION FinalPrice(s_standard_price real, s_discount real, OUT FinalPrice real) AS $$
DECLARE DiscountedPrice real;
DECLARE Tax real;
BEGIN
    DiscountedPrice := s_standard_price - s_discount;
    Tax:= DiscountedPrice * 0.08;
    FinalPrice = DiscountedPrice + Tax;
END;
$$ LANGUAGE plpgsql;

-- Select en Table con inputs de columnas
SELECT *
FROM ShoeItem, 
SalesTax (s_standard_price),
FinalPrice(s_standard_price,s_discount);

-- ------------------------------------
-- Mostrar el precio final junto con el impuesto aplicado
-- ------------------------------------

-- Función con precio total e impuestos
CREATE FUNCTION FinalPriceNTax(s_standard_price real, s_discount real, OUT FinalPrice real, OUT Tax real) AS $$
DECLARE DiscountedPrice real;
BEGIN
    DiscountedPrice := s_standard_price - s_discount;
    Tax:= DiscountedPrice * 0.08;
    FinalPrice = DiscountedPrice + Tax;
END;
$$ LANGUAGE plpgsql;

-- Select en Table con inputs de columnas
SELECT *
FROM ShoeItem, 
SalesTax (s_standard_price),
FinalPriceNTax(s_standard_price,s_discount);


-- Limpiar caso
DROP TABLE ShoeItem;
DROP FUNCTION SalesTax(real);
DROP FUNCTION FinalPrice(real,real);
DROP FUNCTION FinalPriceNTax(real,real);
