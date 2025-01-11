-- 1. Locations
CREATE TABLE Locations (
   location_id BIGINT PRIMARY KEY IDENTITY(1,1),
   country VARCHAR(100) NOT NULL,
   region VARCHAR(100),
   city VARCHAR(100) NOT NULL,
   address VARCHAR(255) NOT NULL
);

-- 2. Suppliers
CREATE TABLE Suppliers (
   supplier_id BIGINT PRIMARY KEY IDENTITY(1,1),
   company_name VARCHAR(100) NOT NULL,
   contact_name VARCHAR(100),
   homepage NVARCHAR(MAX),
   location_id BIGINT NOT NULL,
   FOREIGN KEY (location_id) REFERENCES Locations(location_id)
);

-- 3. Products
CREATE TABLE Products (
  product_id BIGINT PRIMARY KEY IDENTITY(1,1),
  supplier_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  unit_price DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);


-- 4. Employees
CREATE TABLE Employees (
   employee_id BIGINT PRIMARY KEY IDENTITY(1,1),
   chain_id BIGINT NULL,
   first_name VARCHAR(100) NOT NULL,
   last_name VARCHAR(100) NOT NULL,
   salary DECIMAL(10, 2) NOT NULL,
   birth_date DATE,
   hire_date DATE NOT NULL,
   phone VARCHAR(20),
   manager_id BIGINT,
   FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);

-- 5. CoffeeStores
CREATE TABLE CoffeeStores (
  coffee_store_id BIGINT PRIMARY KEY IDENTITY(1,1),
  store_name VARCHAR(100) NOT NULL,
  location_id BIGINT NOT NULL,
  manager_id BIGINT,
  revenue_goal DECIMAL(10, 2),
  FOREIGN KEY (location_id) REFERENCES Locations(location_id),
  FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);

-- 6. Customers
CREATE TABLE Customers (
   customer_id BIGINT PRIMARY KEY IDENTITY(1,1),
   name VARCHAR(100) NOT NULL,
   email VARCHAR(100) UNIQUE NOT NULL,
   phone_number VARCHAR(20),
   registration_date DATE DEFAULT GETDATE(),
   preffered_chain_id BIGINT NULL,
   CONSTRAINT FK_Customers_CoffeeStores FOREIGN KEY (preffered_chain_id)
       REFERENCES CoffeeStores(coffee_store_id)
);


-- 7. Orders
CREATE TABLE Orders (
    order_id BIGINT PRIMARY KEY IDENTITY(1,1),
    customer_id BIGINT NULL,
    employee_id BIGINT,
    coffee_store_id BIGINT,
    order_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (coffee_store_id) REFERENCES CoffeeStores(coffee_store_id)
);

-- 8. OrderDetails
CREATE TABLE OrderDetails (
  order_detail_id BIGINT PRIMARY KEY IDENTITY(1,1),
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT DEFAULT 1 CHECK (quantity > 0),
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


-- 9. Expenses
CREATE TABLE Expenses (
  expense_id BIGINT PRIMARY KEY IDENTITY(1,1),
  coffee_store_id BIGINT NOT NULL,
  cost DECIMAL(10, 2) NOT NULL,
  date DATETIME NOT NULL,
  expense_type VARCHAR(100),
  FOREIGN KEY (coffee_store_id) REFERENCES CoffeeStores(coffee_store_id)
);


-- 10. ProductInventory
CREATE TABLE ProductInventory (
  inventory_id BIGINT PRIMARY KEY IDENTITY(1,1),
  coffee_store_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT DEFAULT 0 CHECK (quantity >= 0),
  last_updated DATE DEFAULT GETDATE(),
  FOREIGN KEY (coffee_store_id) REFERENCES CoffeeStores(coffee_store_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
