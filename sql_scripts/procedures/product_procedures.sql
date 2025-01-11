-- returneaza toate produsele
CREATE or ALTER PROCEDURE GetAllProducts
AS
BEGIN
    SELECT p.product_id, p.name
    FROM Products p
end

EXEC GetAllProducts

-- procedura pentru a afla produsele cu stocul sub un anumit nivel pentru o cafenea
-- si ce supplieri le furnizeaza pentru a putea fi reumplute
CREATE or ALTER PROCEDURE GetLowStockProducts
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
    WHERE ISNULL(pi.quantity, 0 ) < @quantity
       or pi.quantity IS NULL
    order by ISNULL(pi.quantity, 0 ) ASC
end

EXEC GetLowStockProducts 1, 30

-- procedura pentru a afla pentru store_id = x, cel mai mare stock la produse
-- folosita pentru slider ul de stock (val min = 0 si max = asta)
CREATE or ALTER PROCEDURE GetMaxStockProducts
    @store_id INT
AS
BEGIN
    SELECT MAX(pi.quantity) as MaxStock
    FROM ProductInventory pi
    where pi.coffee_store_id = @store_id
end

EXECUTE GetMaxStockProducts 3



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
        and o.order_date BETWEEN DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
        and EOMONTH(DATEADD(MONTH, -1, GETDATE()))
    group by p.product_id, p.name
    order by count(*) DESC
end

EXEC GetBestSellingProductsLastMonth 2


-- cele mai mari profituri per categorie
CREATE or ALTER PROCEDURE GetProfitPerCategory
    @store_id INT
AS
BEGIN
    SELECT p.category,
           sum(od.quantity) TotalSold,
           sum(p.unit_price * od.quantity) as TotalProfit,
           FORMAT(DATEADD(MONTH, -1, GETDATE()), 'MMMM yyyy') AS Period
    FROM Products p
             JOIN OrderDetails od on p.product_id = od.product_id
             JOIN Orders o on od.order_id = o.order_id
    WHERE o.coffee_store_id = @store_id
        and o.order_date BETWEEN DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
        and EOMONTH(DATEADD(MONTH, -1, GETDATE()))
    group by p.category
    order by sum(p.unit_price * od.quantity) desc
end

EXECUTE GetProfitPerCategory 2




-- raport evolutia vanzarilor per produs pe luna si an
CREATE or ALTER PROCEDURE GetSalesEvolutionPerProduct
    @store_id INT,
    @product_id INT
AS
BEGIN
    SELECT p.product_id,
           p.name,
           CONCAT(MONTH(o.order_date), '/', YEAR(o.order_date)) AS SalesMonthYear,
           SUM(od.quantity) AS TotalSold
    FROM Products p
             JOIN OrderDetails od ON p.product_id = od.product_id
             JOIN Orders o ON od.order_id = o.order_id
    WHERE p.product_id = @product_id
        and o.coffee_store_id = @store_id
    group by p.product_id, p.name, MONTH(o.order_date), YEAR(o.order_date)
    order by p.product_id, YEAR(o.order_date), MONTH(o.order_date);
end

EXECUTE GetSalesEvolutionPerProduct 2, 10