-- Drop existing tables (if they exist)
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS ProductInventory;
DROP TABLE IF EXISTS CoffeeStores;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Locations;

-- Disable foreign key constraints temporarily
ALTER TABLE OrderDetails NOCHECK CONSTRAINT ALL;
ALTER TABLE Orders NOCHECK CONSTRAINT ALL;
ALTER TABLE Expenses NOCHECK CONSTRAINT ALL;
ALTER TABLE CoffeeStores NOCHECK CONSTRAINT ALL;
-- ALTER TABLE ProductInventory NOCHECK CONSTRAINT ALL;
ALTER TABLE Products NOCHECK CONSTRAINT ALL;
ALTER TABLE Suppliers NOCHECK CONSTRAINT ALL;
ALTER TABLE Employees NOCHECK CONSTRAINT ALL;
ALTER TABLE Customers NOCHECK CONSTRAINT ALL;

-- Delete data from child tables first
DELETE FROM OrderDetails;
DELETE FROM Orders;
DELETE FROM Expenses;
-- DELETE FROM ProductInventory;

-- Delete data from parent tables
DELETE FROM CoffeeStores;
DELETE FROM Products;
DELETE FROM Suppliers;
DELETE FROM Employees;
DELETE FROM Customers;
DELETE FROM Locations;

-- Re-enable foreign key constraints
ALTER TABLE OrderDetails CHECK CONSTRAINT ALL;
ALTER TABLE Orders CHECK CONSTRAINT ALL;
ALTER TABLE Expenses CHECK CONSTRAINT ALL;
ALTER TABLE CoffeeStores CHECK CONSTRAINT ALL;
-- ALTER TABLE ProductInventory CHECK CONSTRAINT ALL;
ALTER TABLE Products CHECK CONSTRAINT ALL;
ALTER TABLE Suppliers CHECK CONSTRAINT ALL;
ALTER TABLE Employees CHECK CONSTRAINT ALL;
ALTER TABLE Customers CHECK CONSTRAINT ALL;