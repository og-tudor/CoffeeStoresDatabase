-- Populating Locations
SET IDENTITY_INSERT Locations ON;
INSERT INTO Locations (location_id, country, region, city, address)
VALUES
    (1, 'Romania', 'Constanta', 'Constanta', 'Str. Mircea cel Batran 10'),
    (2, 'Romania', 'Municipality of Bucharest', 'Bucharest', 'Calea Victoriei 100'),
    (3, 'Romania', 'Prahova', 'Sinaia', 'Str. Octavian Goga 5'),
    (4, 'Spain', 'Catalonia', 'Barcelona', 'Carrer de Mallorca 101'),
    (5, 'Colombia', 'Bogotá', 'Bogotá', 'Carrera 15 #23-10');
SET IDENTITY_INSERT Locations OFF;

-- Populating Suppliers
SET IDENTITY_INSERT Suppliers ON;
INSERT INTO Suppliers (supplier_id, company_name, contact_name, homepage, location_id)
VALUES
    (1, 'Latino Beans', 'Juan Perez', 'www.latinobeans.com', 5),
    (2, 'Iberian Goods', 'Carlos Garcia', 'www.iberiangoods.es', 4),
    (3, 'Andean Coffee', 'Maria Sanchez', 'www.andeancoffee.co', 5),
    (4, 'Amazon Flavors', 'Pedro Alvarado', 'www.amazonflavors.com', 5),
    (5, 'Mediterranean Spices', 'Ana Martinez', 'www.mediterraneanspices.com', 4);
SET IDENTITY_INSERT Suppliers OFF;

-- Populating Employees
SET IDENTITY_INSERT Employees ON;
INSERT INTO Employees (employee_id, chain_id, first_name, last_name, birth_date, hire_date, phone, manager_id)
VALUES
    -- CEO (no manager)
    (1, 1,  'Pablo', 'Escobar', '1980-05-15', '2010-06-01', '+40 123 456 789', NULL),
    -- Managers (report to CEO)
    (2, 1,  'Tudor', 'Frecus', '1990-07-10', '2015-03-01', '+40 234 567 890', 1),
    (3, 2,  'Matei', 'Aldea', '1985-09-12', '2018-08-15', '+40 345 678 901', 1),
    (4, 3,  'David', 'Aldea', '1992-02-18', '2020-05-10', '+40 456 789 012', 2),
    -- Employees (report to Managers)
    (5, 1, 'Radu', 'Diaconu', '1995-11-25', '2022-01-20', '+40 567 890 123', 3),
    (6, 1, 'Ana', 'Popa', '1993-04-30', '2022-02-15', '+40 678 901 234', 3),
    (7, 2, 'Cristian', 'Georgescu', '1997-08-05', '2022-03-10', '+40 789 012 345', 4),
    (8, 2, 'Andreea', 'Stoica', '1996-01-15', '2022-04-05', '+40 890 123 456', 4),
    (9, 3, 'Mihai', 'Popescu', '1998-03-20', '2022-05-01', '+40 901 234 567', 5),
    (10, 3, 'Maria', 'Ionescu', '1999-06-25', '2022-06-15', '+40 012 345 678', 5);
SET IDENTITY_INSERT Employees OFF;

-- Populating CoffeeStores
SET IDENTITY_INSERT CoffeeStores ON;
INSERT INTO CoffeeStores (coffee_store_id, store_name, location_id, manager_id, revenue_goal)
VALUES
    (1, 'BOB', 1, 2, 50000.00),
    (2, 'Energy by BOB', 2, 3, 70000.00),
    (3, 'BOB and all', 3, 4, 40000.00);
SET IDENTITY_INSERT CoffeeStores OFF;

-- Populating Customers
SET IDENTITY_INSERT Customers ON;
INSERT INTO Customers (customer_id, name, email, phone_number, registration_date)
VALUES
    (1, 'Alice Walker', 'alice.walker@example.com', '+40 701 123 456', '2023-12-01'),
    (2, 'Bob Marley', 'bob.marley@example.com', '+40 702 234 567', '2023-11-15'),
    (3, 'Charlie Brown', 'charlie.brown@example.com', '+40 703 345 678', '2023-10-20'),
    (4, 'Diana Prince', 'diana.prince@example.com', '+40 704 456 789', '2023-09-12'),
    (5, 'Ethan Hunt', 'ethan.hunt@example.com', '+40 705 567 890', '2023-08-25');
SET IDENTITY_INSERT Customers OFF;

-- Populating Products with coffee and food items
SET IDENTITY_INSERT Products ON;
INSERT INTO Products (product_id, supplier_id, name, category, unit_price)
VALUES
    (1, 1, 'Arabica Coffee', 'Beverage', 10.50),
    (2, 2, 'Brazilian Beans', 'Beverage', 12.00),
    (3, 3, 'Colombian Roast', 'Beverage', 15.00),
    (4, 4, 'Peruvian Coffee', 'Beverage', 8.00),
    (5, 5, 'Turkey Sandwich', 'Food', 25.00),
    (6, 1, 'Chocolate Cookies', 'Food', 18.00),
    (7, 2, 'Chicken Sandwich', 'Food', 15.00),
    (8, 3, 'Crackers', 'Food', 10.00),
    (9, 4, 'Latte', 'Beverage', 12.00),
    (10, 5, 'Mocha', 'Beverage', 8.00);
SET IDENTITY_INSERT Products OFF;


-- Populating ProductInventory (products distributed to specific coffee stores)
SET IDENTITY_INSERT ProductInventory ON;
INSERT INTO ProductInventory (inventory_id, coffee_store_id, product_id, quantity, last_updated)
VALUES
    -- Cluj Coffee House
    (1, 1, 1, 100, '2023-12-01'), -- Arabica Coffee
    (2, 1, 2, 50, '2023-12-01'),  -- Brazilian Beans
    (3, 1, 5, 20, '2023-12-01'),  -- Turkey Sandwich
    (4, 1, 6, 30, '2023-12-01'),  -- Chocolate Cookies

    -- Bucharest Espresso
    (5, 2, 3, 80, '2023-12-01'),  -- Colombian Roast
    (6, 2, 4, 70, '2023-12-01'),  -- Peruvian Coffee
    (7, 2, 7, 40, '2023-12-01'),  -- Chicken Sandwich
    (8, 2, 9, 60, '2023-12-01'),  -- Latte

    -- Timisoara Caffe
    (9, 3, 8, 100, '2023-12-01'), -- Crackers
    (10, 3, 10, 50, '2023-12-01'); -- Mocha
SET IDENTITY_INSERT ProductInventory OFF;

-- Populating Orders
SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (order_id, customer_id, employee_id, coffee_store_id, order_date)
VALUES
    (1, 5, 2, 1, '2023-12-17 09:00:00'),
    (2, 3, 3, 2, '2023-12-17 10:00:00'),
    (3, 4, 4, 3, '2023-12-17 11:30:00'),
    (4, 2, 5, 1, '2023-12-18 08:00:00'),
    (5, 3, 2, 2, '2023-12-18 09:15:00'),
    (6, 2, 4, 3, '2023-12-18 10:45:00'),
    (7, 1, 5, 1, '2023-12-18 12:00:00'),
    (8, 4, 3, 2, '2023-12-19 14:00:00'),
    (9, 2, 4, 3, '2023-12-19 15:30:00'),
    (10, 3, 5, 1, '2023-12-19 16:00:00');
SET IDENTITY_INSERT Orders OFF;

-- Populating OrderDetails
SET IDENTITY_INSERT OrderDetails ON;

INSERT INTO OrderDetails (order_detail_id, order_id, product_id, quantity)
VALUES
    (1, 1, 1, 2), (2, 1, 2, 4), (3, 2, 3, 3), (4, 2, 4, 2),
    (5, 3, 5, 1), (6, 3, 6, 3), (7, 4, 7, 2), (8, 4, 8, 5),
    (9, 5, 9, 4), (10, 5, 10, 3), (11, 6, 1, 6), (12, 6, 2, 2),
    (13, 7, 3, 5), (14, 7, 4, 3), (15, 8, 5, 4), (16, 8, 6, 1),
    (17, 9, 7, 3), (18, 9, 8, 6), (19, 10, 9, 2), (20, 10, 10, 1),
    (21, 1, 3, 2), (22, 2, 4, 3), (23, 3, 5, 2), (24, 4, 6, 4),
    (25, 5, 7, 3), (26, 6, 8, 2), (27, 7, 9, 5), (28, 8, 10, 1),
    (29, 9, 1, 3), (30, 10, 2, 2);

SET IDENTITY_INSERT OrderDetails OFF;



-- Populating Expenses
SET IDENTITY_INSERT Expenses ON;
INSERT INTO Expenses (expense_id, coffee_store_id, cost, date, expense_type)
VALUES
    (1, 1, 500.00, '2023-11-01', 'Electricity'),
    (2, 1, 200.00, '2023-11-01', 'Water'),
    (3, 1, 1500.00, '2023-11-01', 'Salaries'),
    (4, 1, 700.00, '2023-11-01', 'Rent'),
    (5, 1, 500.00, '2023-12-01', 'Electricity'),
    (6, 1, 200.00, '2023-12-01', 'Water'),
    (7, 1, 1500.00, '2023-12-01', 'Salaries'),
    (8, 1, 700.00, '2023-12-01', 'Rent'),
    (9, 1, 1000.00, '2023-12-01', 'Marketing'),
    (10, 2, 700.00, '2023-12-01', 'Rent'),
    (11, 2, 1000.00, '2023-12-01', 'Marketing'),
    (12, 3, 400.00, '2023-12-01', 'Cleaning'),
    (13, 3, 300.00, '2023-12-01', 'Supplies'),
    (14, 3, 800.00, '2023-12-01', 'Maintenance');
SET IDENTITY_INSERT Expenses OFF;
