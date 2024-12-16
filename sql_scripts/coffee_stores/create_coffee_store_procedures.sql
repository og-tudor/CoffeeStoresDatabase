-- afiseaza toate cafenelele, orasul in care se afla si obiectivul de venituri si managerul responsabil
CREATE or ALTER PROCEDURE GetCoffeeStoresRevenue
AS
    BEGIN
        SELECT cs.store_name AS 'Coffee Store',
               l.city AS 'City',
               cs.revenue_goal AS 'Revenue Goal',
               e.last_name + ' ' + e.first_name as 'Manager'
        FROM CoffeeStores cs
            JOIN Locations l ON cs.location_id = l.location_id
            JOIN Employees e on cs.manager_id = e.employee_id
    end;

EXECUTE GetCoffeeStoresRevenue;


-- afiseaza veniturile si cheltuielile lunare per cafenea

CREATE FUNCTION GetMonthlyRevenue
(
    @StoreId BIGINT,  -- Id-ul cafenelei
    @Month INT,       -- Luna pentru care calculăm veniturile
    @Year INT         -- Anul pentru care calculăm veniturile
)
    RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Revenue DECIMAL(18, 2);

    SELECT @Revenue = SUM(od.quantity * p.unit_price)
    FROM Orders o
             JOIN OrderDetails od ON o.order_id = od.order_id
             JOIN Products p ON od.product_id = p.product_id
    WHERE o.coffee_store_id = @StoreId
      AND MONTH(o.order_date) = @Month
      AND YEAR(o.order_date) = @Year;

    -- Returnează venitul calculat
    RETURN ISNULL(@Revenue, 0);
END;

CREATE FUNCTION GetMonthlyExpenses
(
    @StoreId BIGINT,  -- Id-ul cafenelei
    @Month INT,       -- Luna pentru care calculăm cheltuielile
    @Year INT         -- Anul pentru care calculăm cheltuielile
)
    RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Expenses DECIMAL(18, 2);

    SELECT @Expenses = SUM(exp.cost)
    FROM Expenses exp
    WHERE exp.coffee_store_id = @StoreId
      AND MONTH(exp.date) = @Month
      AND YEAR(exp.date) = @Year;

    -- Returnează cheltuielile calculate
    RETURN ISNULL(@Expenses, 0);
END;

-- arata veniturile si cheltuielile lunare per cafenea pentru un anumit an
CREATE or ALTER PROCEDURE GetMonthlySalesAndExpenses
    @store_id INT,
    @year INT
AS
BEGIN
    SELECT
        cs.store_name AS 'StoreName',
        MONTH(o.order_date) AS 'Month',
        YEAR(o.order_date) AS 'Year',
        dbo.GetMonthlyRevenue(cs.coffee_store_id, MONTH(o.order_date), YEAR(o.order_date)) AS 'MonthlyRevenue',
        dbo.GetMonthlyExpenses(cs.coffee_store_id, MONTH(o.order_date), YEAR(o.order_date)) AS 'MonthlyExpenses'
    FROM CoffeeStores cs
             LEFT JOIN Orders o ON cs.coffee_store_id = o.coffee_store_id
    WHERE cs.coffee_store_id = @store_id
        AND YEAR(o.order_date) = @year
    GROUP BY cs.store_name, MONTH(o.order_date), YEAR(o.order_date), cs.coffee_store_id
    ORDER BY YEAR(o.order_date) DESC, MONTH(o.order_date) DESC, cs.store_name DESC;
end;


EXECUTE GetMonthlySalesAndExpenses @store_id = 1, @year = 2024;

-- procedura returneaza lista cu id, name pentru toate cafenelele
CREATE or Alter PROCEDURE GetCoffeeStores
AS
BEGIN
    SELECT coffee_store_id, store_name
    FROM CoffeeStores;
END;



-- procedura pentru a afisa detalii despre o cafena
CREATE OR ALTER PROCEDURE GetCoffeeStoreDetails
    @store_id INT,
    @month INT,
    @year INT
AS
BEGIN
    -- Declarăm variabile locale
    DECLARE @store_name NVARCHAR(100);
    DECLARE @city NVARCHAR(100);
    DECLARE @revenue_goal DECIMAL(10,2);
    DECLARE @manager_name NVARCHAR(100);

    -- Extragem datele principale pentru cafenea
    SELECT
        @store_name = cs.store_name,
        @city = l.city,
        @revenue_goal = cs.revenue_goal,
        @manager_name = CONCAT(e.first_name, ' ', e.last_name)
    FROM CoffeeStores cs
             LEFT JOIN Employees e ON cs.manager_id = e.employee_id
             JOIN Locations l ON cs.location_id = l.location_id
    WHERE cs.coffee_store_id = @store_id;

    -- Returnăm datele împreună cu subquery-urile filtrate
    SELECT
        @store_name AS store_name,
        @city AS city,
        @revenue_goal AS revenue_goal,
        @manager_name AS manager_name,
        -- Subquery pentru top product
        (SELECT TOP 1 p.name
         FROM Products p
                  JOIN OrderDetails od ON p.product_id = od.product_id
                  JOIN Orders o ON od.order_id = o.order_id
         WHERE o.coffee_store_id = @store_id
           AND MONTH(o.order_date) = @month
           AND YEAR(o.order_date) = @year
         GROUP BY p.name
         ORDER BY SUM(od.quantity) DESC) AS top_product,
        -- Subquery pentru total revenue
        (SELECT SUM(od.quantity * p.unit_price)
         FROM Products p
                  JOIN OrderDetails od ON p.product_id = od.product_id
                  JOIN Orders o ON od.order_id = o.order_id
         WHERE o.coffee_store_id = @store_id
           AND MONTH(o.order_date) = @month
           AND YEAR(o.order_date) = @year) AS total_revenue;
END;



EXECUTE GetCoffeeStoreDetails @store_id = 1 , @month = 4, @year = 2024;
