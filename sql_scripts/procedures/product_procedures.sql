-- procedura pentru a afla produsele cu stocul sub un anumit nivel pentru o cafenea
-- si ce supplieri le furnizeaza pentru a putea fi reumplute
CREATE PROCEDURE GetLowStockProducts
    @store_id INT,
    @quantity INT
AS
BEGIN
    SELECT p.product_id, p.name, p.unit_price, ISNULL(pi.quantity, 0 ) as quantity, s.company_name
    FROM Products p
             LEFT JOIN ProductInventory pi
                       ON pi.product_id = p.product_id
                           AND pi.coffee_store_id = @store_id
             LEFT JOIN CoffeeStores cs
                       on pi.coffee_store_id = cs.coffee_store_id
             JOIN Suppliers s on p.supplier_id = s.supplier_id
    WHERE ISNULL(pi.quantity, 0 ) < @quantity OR pi.quantity IS NULL
end


EXEC GetLowStockProducts 1, 30

-- cele mai vandute produse per magazin
-- in ultmia luna intreaga (luna trecuta)
CREATE or ALTER PROCEDURE GetBestSellingProductsLastMonth
    @store_id INT
AS
BEGIN
    SELECT p.name,
           count(*) as SoldQuantity,
           FORMAT(DATEADD(MONTH, -1, GETDATE()), 'MMMM yyyy') AS Period
    FROM CoffeeStores cs
             JOIN Orders o on cs.coffee_store_id = o.coffee_store_id
             JOIN OrderDetails od on o.order_id = od.order_id
             JOIN Products p on od.product_id = p.product_id
    WHERE cs.coffee_store_id = @store_id
      AND o.order_date BETWEEN DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
        AND EOMONTH(DATEADD(MONTH, -1, GETDATE()))
    GROUP BY p.product_id, p.name
    ORDER BY count(*) DESC
end

EXEC GetBestSellingProductsLastMonth 2


-- cele mai mari profituri per categorie
SELECT p.category, sum(od.quantity) TotalSold, sum(p.unit_price * od.quantity) as TotalProfit
FROM Products p
    JOIN OrderDetails od on p.product_id = od.product_id
    JOIN Orders o on od.order_id = o.order_id
group by p.category
order by sum(p.unit_price * od.quantity) desc




-- raport evolutia vanzarilor per produs pe luna si an
SELECT p.product_id,
       p.name,
       CONCAT(MONTH(o.order_date), '/', YEAR(o.order_date)) AS SalesMonthYear,
       SUM(od.quantity) AS TotalSold
FROM Products p
         JOIN OrderDetails od ON p.product_id = od.product_id
         JOIN Orders o ON od.order_id = o.order_id
GROUP BY p.product_id, p.name, MONTH(o.order_date), YEAR(o.order_date)
ORDER BY p.product_id, YEAR(o.order_date), MONTH(o.order_date);
