--creating customer table 

CREATE TABLE Customer (
    CustomerID NUMBER PRIMARY KEY,
    CustomerName VARCHAR2(100),
    Email VARCHAR2(100),
    City VARCHAR2(50),
    Country VARCHAR2(50)
);

--creating product table

CREATE TABLE Product (
    ProductID NUMBER PRIMARY KEY,
    ProductName VARCHAR2(100),
    Category VARCHAR2(50),
    Price NUMBER(10,2),
    CustomerID NUMBER,
    CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

--insert values into customer table

INSERT INTO Customer VALUES (1, 'John Smith', 'john.smith@gmail.com', 'New York', 'USA');
INSERT INTO Customer VALUES (2, 'Priya Sharma', 'priya.sharma@gmail.com', 'Delhi', 'India');
INSERT INTO Customer VALUES (3, 'Carlos Mendez', NULL, 'Madrid', 'Spain');
INSERT INTO Customer VALUES (4, 'Aisha Khan', 'aisha.khan@gmail.com', NULL, 'UAE');
INSERT INTO Customer VALUES (5, 'Liam Brown', 'liam.brown@gmail.com', 'London', NULL);

--insert values into product table

INSERT INTO Product VALUES (101, 'Laptop', 'Electronics', 850, 1);
INSERT INTO Product VALUES (102, 'Smartphone', 'Electronics', 500, 1);
INSERT INTO Product VALUES (103, 'Tablet', 'Electronics', 300, 2);
INSERT INTO Product VALUES (104, 'Headphones', 'Accessories', 100, NULL);
INSERT INTO Product VALUES (105, 'Watch', 'Accessories', 150, 3);
INSERT INTO Product VALUES (106, 'Camera', 'Electronics', 700, 2);
INSERT INTO Product VALUES (107, 'Shoes', 'Fashion', 80, 4);
INSERT INTO Product VALUES (108, 'Backpack', 'Fashion', NULL, 4);

--DROP TABLE Product CASCADE CONSTRAINTS;
--DROP TABLE Customer CASCADE CONSTRAINTS;

-- desc customer
-- desc product

--select * from customer;
--select * from product;

--left join
SELECT 
    c.CustomerID, 
    c.CustomerName, 
    p.ProductName, 
    p.Price
FROM 
    Customer c
LEFT JOIN 
    Product p
ON 
    c.CustomerID = p.CustomerID;

--right join

SELECT 
    c.CustomerID, 
    c.CustomerName, 
    p.ProductID,
    p.ProductName, 
    p.Price
FROM 
    Customer c
RIGHT JOIN 
    Product p
ON 
    c.CustomerID = p.CustomerID;

--left outer join

SELECT 
    c.CustomerID, 
    c.CustomerName, 
    p.ProductName, 
    p.Price
FROM 
    Customer c
LEFT OUTER JOIN 
    Product p
ON 
    c.CustomerID = p.CustomerID;

--right outer join

SELECT 
    c.CustomerID, 
    c.CustomerName, 
    p.ProductID,
    p.ProductName, 
    p.Price
FROM 
    Customer c
RIGHT OUTER JOIN 
    Product p
ON 
    c.CustomerID = p.CustomerID;

--`inner join

SELECT 
    c.CustomerID, 
    c.CustomerName, 
    p.ProductID,
    p.ProductName, 
    p.Price
FROM 
    Customer c
INNER JOIN 
    Product p
ON 
    c.CustomerID = p.CustomerID;

--full outer join

SELECT 
    c.CustomerID, 
    c.CustomerName, 
    p.ProductID,
    p.ProductName, 
    p.Price
FROM 
    Customer c
FULL OUTER JOIN 
    Product p
ON 
    c.CustomerID = p.CustomerID;

-- symmetric difference

-- Customers without products
SELECT CustomerID, CustomerName FROM Customer
MINUS
SELECT c.CustomerID, c.CustomerName 
FROM Customer c
JOIN Product p ON c.CustomerID = p.CustomerID

UNION

-- Products without customers
SELECT p.ProductID, p.ProductName FROM Product p
MINUS
SELECT p.ProductID, p.ProductName 
FROM Product p
JOIN Customer c ON c.CustomerID = p.CustomerID;

-- Explanation:

-- First part finds customers with no products.

-- Second part finds products with no customers.

-- UNION combines them for the full symmetric difference.