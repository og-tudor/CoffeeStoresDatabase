-- procedura pentru a afla produsele cu stocul sub un anumit nivel pentru o cafenea
-- si ce supplieri le furnizeaza pentru a putea fi reumplute
CREATE OR ALTER PROCEDURE GetProductsToRefill
    @store_id INT,
    @quantity INT
    AS
BEGIN
SELECT p.product_id, p.name, ISNULL(pi.quantity, 0) AS quantity, s.company_name, s.contact_name, l.address
FROM Products p
    LEFT JOIN ProductInventory pi ON p.product_id = pi.product_id
    JOIN Suppliers s ON p.supplier_id = s.supplier_id
    JOIN Locations l on s.location_id = l.location_id
    JOIN dbo.CoffeeStores CS on l.location_id = CS.location_id
WHERE ISNULL(pi.quantity, 0) < @quantity
    AND pi.coffee_store_id = @store_id;
END;

EXECUTE GetProductsToRefill @store_id = 2, @quantity = 50;