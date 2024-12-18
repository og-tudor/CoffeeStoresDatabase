-- toti angajatii care pot beneficia de o promotie la manager daca se deschide o noua cafenea
-- au cel putin 2 ani vechime in companie
-- nu sunt deja manageri (nu au manager_id = 1)
-- numarul de comenzi procesate > de 40

SELECT count(*) as 'Number of Orders', e.last_name + ' ' + e.first_name as 'Employee Name'
from Employees e
    join Orders on e.employee_id = Orders.employee_id
    join CoffeeStores cs on e.chain_id = cs.coffee_store_id
where cs.manager_id != e.employee_id
    AND e.hire_date < DATEADD(YEAR, -2, GETDATE())
group by e.first_name, e.last_name
having count(*) > 0;






-- managerii care au performanta proasta si ar trebui sa fie inlocuiti
-- cafeneaua la care sunt manageri nu a atins obiectivul de venituri niciodata in ultimele 3 luni
-- salariul lor este dublu fata de salariul cel mai mare al unui angajat din aceeasi cafenea

CREATE or ALTER PROCEDURE GetUnderperformingManagers
AS
BEGIN
    SET NOCOUNT ON;

    WITH LastThreeMonths AS (
        SELECT DISTINCT TOP 3
            YEAR(order_date) AS Year,
            MONTH(order_date) AS Month
        FROM Orders
        ORDER BY YEAR(order_date) DESC, MONTH(order_date) DESC
    ),
         MonthlyRevenues AS (
             SELECT
                 cs.coffee_store_id,
                 dbo.GetMonthlyRevenue(cs.coffee_store_id, Month, Year) AS Revenue,
                 cs.revenue_goal AS TargetGoal
             FROM LastThreeMonths
                      CROSS JOIN CoffeeStores cs
         ),
         UnderperformingStores AS (
             SELECT
                 coffee_store_id
             FROM MonthlyRevenues
             GROUP BY coffee_store_id
             HAVING COUNT(*) = 3 AND SUM(CASE WHEN Revenue >= TargetGoal THEN 1 ELSE 0 END) = 0
         ),
         MaxEmpSalaries AS (
             SELECT
                 cs.coffee_store_id,
                 MAX(e.salary) AS max_salary
             FROM Employees e
                      JOIN CoffeeStores cs ON e.chain_id = cs.coffee_store_id
             WHERE cs.manager_id != e.employee_id
             GROUP BY cs.coffee_store_id
         )
    SELECT
        e.last_name + ' ' + e.first_name AS 'Manager Name',
        cs.store_name AS 'Store Name',
        e.salary AS 'Manager Salary',
        ms.max_salary AS 'Max Employee Salary',
        cs.revenue_goal AS 'Revenue Goal'
    FROM Employees e
             JOIN CoffeeStores cs ON e.chain_id = cs.coffee_store_id
             JOIN MaxEmpSalaries ms ON ms.coffee_store_id = cs.coffee_store_id
             JOIN UnderperformingStores us ON us.coffee_store_id = cs.coffee_store_id
    WHERE cs.manager_id = e.employee_id
      AND e.salary > 2 * ms.max_salary
    ORDER BY cs.store_name;
END;

    EXECUTE GetUnderperformingManagers;
