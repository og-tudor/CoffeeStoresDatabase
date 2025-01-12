-- pentru fiecare cafenea, angajatul lunii
-- cele mai multe comenzi procesate
CREATE or ALTER PROCEDURE EmployeesOfTheMonth
AS
BEGIN
    SELECT BestOrders.first_name + ' ' + BestOrders.last_name as EmployeeName,
           BestOrders.NumberOfOrders,
           cs.store_name
    FROM (   SELECT e.employee_id,
                    e.chain_id,
                    e.first_name,
                    e.last_name,
                    count(*) as NumberOfOrders,
                    ROW_NUMBER() over (PARTITION BY e.chain_id ORDER BY count(*) DESC) as RowNumber
             FROM Employees e
                  JOIN Orders o on e.employee_id = o.employee_id
             WHERE o.order_date >= DATEADD(MONTH, -1, GETDATE())
                and o.order_date < GETDATE()
             group by e.employee_id, e.first_name, e.last_name, e.chain_id
         ) BestOrders
        JOIN CoffeeStores cs on BestOrders.chain_id = cs.coffee_store_id
    WHERE BestOrders.RowNumber = 1
end;

EXECUTE EmployeesOfTheMonth



-- toti angajatii care pot beneficia de o promotie la manager daca se deschide o noua cafenea
-- au cel putin 2 ani vechime in companie
-- nu sunt deja manageri (nu au manager_id = 1)
-- numarul de comenzi procesate > de 100

CREATE or ALTER PROCEDURE EmployeesEligibleForPromotion
    @store_id INT
AS
BEGIN
    SELECT count(*) as 'Number of Orders',
           e.last_name + ' ' + e.first_name as 'Employee Name',
          cs.store_name as 'Store Name'
    from Employees e
         join Orders on e.employee_id = Orders.employee_id
         join CoffeeStores cs on e.chain_id = cs.coffee_store_id
    WHERE cs.manager_id != e.employee_id
        AND e.hire_date < DATEADD(YEAR, -2, GETDATE())
        AND cs.coffee_store_id = @store_id
    group by e.first_name, e.last_name, cs.store_name
    having count(*) >= 100;
end;

EXECUTE  EmployeesEligibleForPromotion 3;






-- managerii care au performanta proasta si ar trebui sa fie inlocuiti
-- cafeneaua la care sunt manageri nu a atins obiectivul de venituri niciodata in ultimele 3 luni
-- salariul lor este dublu fata de salariul cel mai mare al unui angajat din aceeasi cafenea

-- verifica daca un magazin este subperformant
CREATE FUNCTION dbo.IsStoreUnderperforming(@StoreId BIGINT)
    RETURNS BIT
AS
BEGIN
    DECLARE @Underperforming BIT = 1;
    DECLARE @Month INT, @Year INT;
    DECLARE @Revenue DECIMAL(18,2), @RevenueGoal DECIMAL(18,2);
    DECLARE @i INT = 0;

    -- parcurgem ultimele 3 luni fata de luna curenta
    WHILE @i < 3
        BEGIN
            SELECT
                @Month = MONTH(DATEADD(MONTH, -@i, GETDATE())),
                @Year  = YEAR(DATEADD(MONTH, -@i, GETDATE()));

            SELECT
                @Revenue = dbo.GetMonthlyRevenue(@StoreId, @Month, @Year),
                @RevenueGoal = revenue_goal
            FROM CoffeeStores
            WHERE coffee_store_id = @StoreId;

            -- daca a fost atuns obiectibul in orice luna, inseamna ca magazinul nu este subperformant
            IF @Revenue >= @RevenueGoal
                BEGIN
                    SET @Underperforming = 0;
                    BREAK;
                END

            SET @i = @i + 1;
        END

    RETURN @Underperforming;
END;
GO

-- returneaza cel mai mare salariu al unui angajat dintr un magazin
-- fara manager
CREATE or ALTER FUNCTION dbo.GetMaxEmployeeSalary(@StoreId BIGINT)
    RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @MaxSalary DECIMAL(18,2);

    SELECT @MaxSalary = MAX(e.salary)
    FROM Employees e
             JOIN CoffeeStores cs on e.chain_id = cs.coffee_store_id
    WHERE cs.manager_id != e.employee_id
      and cs.coffee_store_id = @StoreId;

    RETURN ISNULL(@MaxSalary, 0);
END;
GO
-- test
SELECT dbo.GetMaxEmployeeSalary(3);

-- returneaza managerul dca trebuie inlocuit
-- nu returneaza nimic daca managerul nu trebuie inlocuit
CREATE or ALTER PROCEDURE GetUnderperformingManagers
@store_id INT
AS
BEGIN
    -- daca magazinul a atins obiectivul in ult 3 luni, return
    IF dbo.IsStoreUnderperforming(@store_id) <> 1
        BEGIN
            PRINT 'Magazinul nu este subperformant, managerul nu trebuie inlocuit.';
            RETURN;
        END;

    -- gasim salariul maxim al ang
    DECLARE @MaxEmpSalary DECIMAL(18,2) = dbo.GetMaxEmployeeSalary(@store_id);

    -- returnam managerul daca salariul este > 2x ang
    SELECT
        e.last_name + ' ' + e.first_name AS [Manager Name],
        cs.store_name AS [Store Name],
        e.salary AS [Manager Salary],
        @MaxEmpSalary AS [Max Employee Salary],
        cs.revenue_goal AS [Revenue Goal]
    FROM Employees e
             JOIN CoffeeStores cs ON cs.coffee_store_id = @store_id
    WHERE cs.manager_id = e.employee_id
      AND e.salary > 2 * @MaxEmpSalary;
END;
GO

-- test
EXECUTE GetUnderperformingManagers @store_id = 1;




-- zile de nastere care urmeaza ale angajatilor in urmatoarea luna

CREATE or ALTER PROCEDURE GetUpcomingBirthdays
AS
BEGIN
    SELECT e.first_name + ' ' + e.last_name AS 'Employee Name',
           e.birth_date AS 'Birth Date'
    FROM Employees e
    WHERE MONTH(e.birth_date) = MONTH(DATEADD(month, 1, GETDATE()))
    ORDER BY DAY(e.birth_date)
end;

EXECUTE GetUpcomingBirthdays


