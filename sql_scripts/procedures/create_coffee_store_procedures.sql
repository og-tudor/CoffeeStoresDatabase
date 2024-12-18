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
    @store_id INT
AS
BEGIN
    SELECT cs.store_name AS 'Store Name',
        l.city AS 'City',
        l.address AS 'Address',
        e.last_name + ' ' + e.first_name as 'Manager',
        cs.revenue_goal AS 'Monthly Revenue Goal',
        SUM(od.quantity * p.unit_price) as 'Total Revenue'
    FROM CoffeeStores cs
        JOIN Employees e on cs.manager_id = e.employee_id
        JOIN Locations l on cs.location_id = l.location_id
        JOIN Orders o on cs.coffee_store_id = o.coffee_store_id
        JOIN OrderDetails od on o.order_id = od.order_id
        JOIN Products p on od.product_id = p.product_id
    WHERE cs.coffee_store_id = @store_id
    group by cs.revenue_goal, e.last_name, l.address, l.city, cs.store_name, e.first_name;
END;



EXECUTE GetCoffeeStoreDetails @store_id = 1;


-- how many customers aren't registered in the loyalty program
CREATE OR ALTER PROCEDURE GetUnregisteredCustomers
AS
BEGIN
    SELECT count(*) as 'Unregistered Customers',
           o.coffee_store_id
    FROM Orders o
    WHERE o.customer_id IS NULL
    group by o.coffee_store_id
END;

-- how many customers are / aren't registered in the loyalty program per store
    CREATE OR ALTER PROCEDURE GetRegisteredANDUnregisteredCustomers
    @store_id INT
    AS
    BEGIN
        SELECT
            COALESCE(r.coffee_store_id, u.coffee_store_id) AS coffee_store_id,
            ISNULL(r.Registered_Customers, 0) AS Registered_Customers,
            ISNULL(u.Unregistered_Customers, 0) AS Unregistered_Customers
        FROM
            -- Subquery pentru clienți înregistrați
            (SELECT
                 preffered_chain_id AS coffee_store_id,
                 COUNT(*) AS Registered_Customers
             FROM Customers
             GROUP BY preffered_chain_id) AS r
                FULL OUTER JOIN
            -- Subquery pentru clienți neînregistrați
                (SELECT
                     o.coffee_store_id,
                     COUNT(*) AS Unregistered_Customers
                 FROM Orders o
                 WHERE o.customer_id IS NULL
                 GROUP BY o.coffee_store_id) AS u
            ON r.coffee_store_id = u.coffee_store_id
        WHERE COALESCE(r.coffee_store_id, u.coffee_store_id) = @store_id;
    END;


EXECUTE GetRegisteredANDUnregisteredCustomers @store_id = 2;



-- raport cu cheltuieli detaliate pe categorii
-- pe luna / an
-- pentru fiecare cafenea
CREATE or ALTER PROCEDURE GetMonthlyExpensesByCategory
    @store_id INT,
    @year INT,
    @month INT
AS
BEGIN
    SELECT
        FORMAT(ex.date, 'yyyy-MM') AS ExpenseMonth,
        ex.coffee_store_id,
        ex.expense_type,
        SUM(ex.cost) AS TotalAmount
    FROM Expenses ex
    WHERE ex.coffee_store_id = @store_id
        AND YEAR(ex.date) = @year
        AND MONTH(ex.date) = @month
    GROUP BY
        FORMAT(ex.date, 'yyyy-MM'),
        ex.coffee_store_id,
        ex.expense_type
    ORDER BY
        ExpenseMonth,
        ex.coffee_store_id,
        ex.expense_type;
END;


    EXECUTE GetMonthlyExpensesByCategory @store_id = 1, @year = 2024, @month = 10;