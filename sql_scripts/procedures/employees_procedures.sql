-- toti angajatii care pot beneficia de o promotie la manager daca se deschide o noua cafenea
-- au cel putin 2 ani vechime in companie
-- nu sunt deja manageri (nu au manager_id = 1)
-- numarul de comenzi procesate > de 40

SELECT count(*) as 'Number of Orders', e.last_name + ' ' + e.first_name as 'Employee Name'
from Employees e
    join Orders on e.employee_id = Orders.employee_id
where e.manager_id != 1
    AND e.hire_date < DATEADD(YEAR, -2, GETDATE())
group by e.first_name, e.last_name
having count(*) > 40;





-- managerii care au performanta proasta si ar trebui sa fie inlocuiti
-- cafeneaua la care sunt manageri nu a atins obiectivul de venituri niciodata in ultimele 3 luni
-- salariul lor este dublu fata de salariul cel mai mare al unui angajat din aceeasi cafenea