-- CUSTOMER TABLE
CREATE TABLE Customer (
  CustomerID INT PRIMARY KEY,
  CustomerName VARCHAR(50),
  Email VARCHAR(50)
);

-- PRODUCT TABLE
CREATE TABLE Product (
  ProductID INT PRIMARY KEY,
  ProductName VARCHAR(50),
  Price DECIMAL(10,2)
);

-- STORE TABLE
CREATE TABLE Store (
  StoreID INT PRIMARY KEY,
  StoreName VARCHAR(50),
  Location VARCHAR(50),
  RegionID INT
);

-- SALES REPRESENTATIVE TABLE
CREATE TABLE SalesRep (
  RepID INT PRIMARY KEY,
  RepName VARCHAR(50)
);

-- REGION TABLE
CREATE TABLE Region (
  RegionID INT PRIMARY KEY,
  RegionName VARCHAR(50)
);

-- PAYMENT METHOD TABLE
CREATE TABLE PaymentMethod (
  PaymentID INT PRIMARY KEY,
  MethodName VARCHAR(30)
);

-- SALES TABLE
CREATE TABLE Sales (
  SalesID INT PRIMARY KEY,
  CustomerID INT,
  ProductID INT,
  StoreID INT,
  RepID INT,
  PaymentID INT,
  SaleDate DATE,
  Quantity INT,
  TotalAmount DECIMAL(10,2),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
  FOREIGN KEY (StoreID) REFERENCES Store(StoreID),
  FOREIGN KEY (RepID) REFERENCES SalesRep(RepID),
  FOREIGN KEY (PaymentID) REFERENCES PaymentMethod(PaymentID)
);
-- CUSTOMER
INSERT INTO Customer VALUES (1, 'Ravi', 'ravi@gmail.com');
INSERT INTO Customer VALUES (2, 'Supriya', 'supriya@yahoo.com');
INSERT INTO Customer VALUES (3, 'Ankit', 'ankit@gmail.com');
INSERT INTO Customer VALUES (4, 'Kiran', 'kiran@outlook.com');

-- PRODUCT
INSERT INTO Product VALUES (101, 'Laptop', 55000);
INSERT INTO Product VALUES (102, 'Mobile', 15000);
INSERT INTO Product VALUES (103, 'Tablet', 25000);
INSERT INTO Product VALUES (104, 'Headphones', 2000);

-- REGION
INSERT INTO Region VALUES (1, 'South');
INSERT INTO Region VALUES (2, 'North');

-- STORE
INSERT INTO Store VALUES (11, 'Bangalore Store', 'Bangalore', 1);
INSERT INTO Store VALUES (12, 'Delhi Store', 'Delhi', 2);
INSERT INTO Store VALUES (13, 'Chennai Store', 'Chennai', 1);

-- SALESREP
INSERT INTO SalesRep VALUES (501, 'Rajesh');
INSERT INTO SalesRep VALUES (502, 'Sneha');

-- PAYMENT METHOD
INSERT INTO PaymentMethod VALUES (1, 'Credit Card');
INSERT INTO PaymentMethod VALUES (2, 'UPI');
INSERT INTO PaymentMethod VALUES (3, 'Cash');

-- SALES
INSERT INTO Sales VALUES (1001, 1, 101, 11, 501, 1, '2025-10-10', 1, 55000);
INSERT INTO Sales VALUES (1002, 2, 102, 12, 502, 2, '2025-10-11', 2, 30000);
INSERT INTO Sales VALUES (1003, 1, 104, 11, 501, 3, '2025-10-12', 3, 6000);
INSERT INTO Sales VALUES (1004, 3, 103, 13, 502, 1, '2025-10-13', 1, 25000);


----1. Retrieve all sales transactions along with the customer name
SELECT s.SalesID, c.CustomerName, s.TotalAmount, s.SaleDate
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID;

----2. Retrieve all sales transactions along with product details
SELECT s.SalesID, p.ProductName, p.Price, s.Quantity, s.TotalAmount
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID;

----3. Retrieve all sales transactions along with store location details
SELECT s.SalesID, st.StoreName, st.Location, s.TotalAmount
FROM Sales s
JOIN Store st ON s.StoreID = st.StoreID;



----🔹 4. Retrieve all sales transactions along with the sales representative handling them
SELECT s.SalesID, r.RepName, s.TotalAmount
FROM Sales s
JOIN SalesRep r ON s.RepID = r.RepID;




---🔹 5. Retrieve all sales transactions along with customer and product details
SELECT s.SalesID, c.CustomerName, p.ProductName, s.Quantity, s.TotalAmount
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID
JOIN Product p ON s.ProductID = p.ProductID;

----🔹 6. Retrieve all sales transactions along with the region they occurred in
SELECT s.SalesID, st.StoreName, r.RegionName, s.TotalAmount
FROM Sales s
JOIN Store st ON s.StoreID = st.StoreID
JOIN Region r ON st.RegionID = r.RegionID;


---🔹 7. Retrieve all customers and their sales transactions (including customers with no purchases)
SELECT c.CustomerName, s.SalesID, s.TotalAmount
FROM Customer c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID;


---🔹 8. Retrieve all products and their sales (including products never sold)
SELECT p.ProductName, s.SalesID, s.Quantity
FROM Product p
LEFT JOIN Sales s ON p.ProductID = s.ProductID;


---🔹 9. Retrieve all stores and their sales (including stores without sales)
SELECT st.StoreName, s.SalesID, s.TotalAmount
FROM Store st
LEFT JOIN Sales s ON st.StoreID = s.StoreID;



---🔹 10. Retrieve all sales transactions along with payment method details
SELECT s.SalesID, p.MethodName, s.TotalAmount
FROM Sales s
JOIN PaymentMethod p ON s.PaymentID = p.PaymentID;



---11. Retrieve all customers who have purchased more than one product
SELECT c.CustomerName, COUNT(DISTINCT s.ProductID) AS ProductsBought
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerName
HAVING COUNT(DISTINCT s.ProductID) > 1;




---🔹 12. Retrieve all products that have been purchased by more than one customer
SELECT p.ProductName, COUNT(DISTINCT s.CustomerID) AS CustomerCount
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
GROUP BY p.ProductName
HAVING COUNT(DISTINCT s.CustomerID) > 1;





----🔹 13. Retrieve all stores that have recorded more than 100 transactions



SELECT st.StoreName, COUNT(s.SalesID) AS TransactionCount
FROM Store st
LEFT JOIN Sales s ON st.StoreID = s.StoreID
GROUP BY st.StoreName
HAVING COUNT(s.SalesID) > 100;


	
---🔹 14. Retrieve all customers and their most recent purchase
SELECT c.CustomerName, s.SalesID, s.SaleDate, s.TotalAmount
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID
WHERE s.SaleDate = (
    SELECT MAX(s2.SaleDate)
    FROM Sales s2
    WHERE s2.CustomerID = s.CustomerID
);




----🔹 15. Retrieve all customers who have made a purchase in multiple regions
SELECT c.CustomerName
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID
JOIN Store st ON s.StoreID = st.StoreID
JOIN Region r ON st.RegionID = r.RegionID
GROUP BY c.CustomerName
HAVING COUNT(DISTINCT r.RegionID) > 1;



---🔹 16. Retrieve all customers who have purchased the same product more than once
SELECT c.CustomerName, p.ProductName, COUNT(*) AS PurchaseCount
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID
JOIN Product p ON s.ProductID = p.ProductID
GROUP BY c.CustomerName, p.ProductName
HAVING COUNT(*) > 1;



		
---🔹 17. Retrieve all products along with the names of the customers who bought them
SELECT p.ProductName, c.CustomerName
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
JOIN Customer c ON s.CustomerID = c.CustomerID
ORDER BY p.ProductName;



---🔹 18. Retrieve all stores along with the total revenue generated per store
SELECT st.StoreName, SUM(s.TotalAmount) AS TotalRevenue
FROM Store st
LEFT JOIN Sales s ON st.StoreID = s.StoreID
GROUP BY st.StoreName;



----🔹 19. Retrieve all customers who have used more than one payment method
SELECT c.CustomerName, COUNT(DISTINCT s.PaymentID) AS PaymentMethodsUsed
FROM Sales s
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerName
HAVING COUNT(DISTINCT s.PaymentID) > 1;





----🔹 20. Retrieve all regions along with the total sales generated
SELECT r.RegionName, SUM(s.TotalAmount) AS TotalSales
FROM Region r
JOIN Store st ON r.RegionID = st.RegionID
LEFT JOIN Sales s ON st.StoreID = s.StoreID
GROUP BY r.RegionName;



CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Region VARCHAR(30)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    Price DECIMAL(10,2),
    Discount DECIMAL(5,2)
);

CREATE TABLE Stores (
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(50),
    Location VARCHAR(50)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    StoreID INT,
    SaleDate DATE,
    Quantity INT,
    PaymentMethod VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)
);

----Insert Sample Data

INSERT INTO Customers VALUES(1, 'Ravi', 'South'),
INSERT INTO Customers VALUES(2, 'Priya', 'North'),
INSERT INTO Customers VALUES(3, 'Kiran', 'West'),
INSERT INTO Customers VALUES(4, 'Asha', 'South');

---INSERT INTO Products VALUES
INSERT INTO Products VALUES(1, 'Laptop', 60000, 10),
INSERT INTO Products VALUES(2, 'Mobile', 25000, 5),
INSERT INTO Products VALUES(3, 'Headphones', 3000, 0),
INSERT INTO Products VALUES(4, 'Tablet', 20000, 15);

--INSERT INTO Stores VALUES
INSERT INTO Stores VALUES(1, 'TechWorld', 'Bangalore'),
INSERT INTO Stores VALUES(2, 'GadgetHub', 'Mumbai');

----INSERT INTO Sales VALUES
INSERT INTO Sales VALUES(1, 1, 1, 1, '2025-01-15', 1, 'Credit Card'),
INSERT INTO Sales VALUES(2, 2, 2, 2, '2025-02-20', 2, 'Cash'),
INSERT INTO Sales VALUES(3, 1, 3, 1, '2025-03-25', 1, 'Credit Card'),
INSERT INTO Sales VALUES(4, 3, 1, 1, '2025-02-10', 1, 'UPI'),
INSERT INTO Sales VALUES(5, 1, 2, 1, '2025-04-05', 1, 'UPI'),
INSERT INTO Sales VALUES(6, 2, 4, 2, '2025-04-18', 1, 'Credit Card');

----🔹 21. Retrieve all customers along with the store location they frequently purchase from
SELECT c.CustomerName, s.Location AS FrequentStore
FROM Customers c
JOIN Sales sa ON c.CustomerID = sa.CustomerID
JOIN Stores s ON sa.StoreID = s.StoreID
GROUP BY c.CustomerName, s.Location
HAVING COUNT(sa.SaleID) = (
    SELECT MAX(COUNT(*))
    FROM Sales s2
    WHERE s2.CustomerID = c.CustomerID
    GROUP BY s2.StoreID
);


---🔹 22. Retrieve all sales transactions along with customer, product, and store details
SELECT sa.SaleID, c.CustomerName, p.ProductName, s.StoreName, s.Location, sa.SaleDate
FROM Sales sa
JOIN Customers c ON sa.CustomerID = c.CustomerID
JOIN Products p ON sa.ProductID = p.ProductID
JOIN Stores s ON sa.StoreID = s.StoreID;



---🔹 23. Retrieve all customers along with the total amount they have spent
SELECT c.CustomerName, 
       SUM(p.Price * sa.Quantity) AS TotalSpent
FROM Customers c
JOIN Sales sa ON c.CustomerID = sa.CustomerID
JOIN Products p ON sa.ProductID = p.ProductID
GROUP BY c.CustomerName;



----🔹 24. Retrieve all products that have never been sold in a particular region (e.g., ‘South’)
SELECT p.ProductName
FROM Products p
WHERE p.ProductID NOT IN (
    SELECT sa.ProductID
    FROM Sales sa
    JOIN Customers c ON sa.CustomerID = c.CustomerID
    WHERE c.Region = 'South'
);



---🔹 25. Retrieve all customers who have made a purchase every month for the past year
SELECT c.CustomerName
FROM Customers c
JOIN Sales sa ON c.CustomerID = sa.CustomerID
WHERE EXTRACT(YEAR FROM sa.SaleDate) = 2025
GROUP BY c.CustomerName
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM sa.SaleDate)) = 12;


---🔹 26. Retrieve all sales transactions where the product was purchased at a discount
SELECT sa.SaleID, c.CustomerName, p.ProductName, p.Discount
FROM Sales sa
JOIN Customers c ON sa.CustomerID = c.CustomerID
JOIN Products p ON sa.ProductID = p.ProductID
WHERE p.Discount > 0;



---🔹 27. Retrieve all customers along with the first and last product they purchased
SELECT c.CustomerName,
       (SELECT p1.ProductName
        FROM Sales s1 JOIN Products p1 ON s1.ProductID = p1.ProductID
        WHERE s1.CustomerID = c.CustomerID
        ORDER BY s1.SaleDate ASC FETCH FIRST 1 ROWS ONLY) AS FirstProduct,
       (SELECT p2.ProductName
        FROM Sales s2 JOIN Products p2 ON s2.ProductID = p2.ProductID
        WHERE s2.CustomerID = c.CustomerID
        ORDER BY s2.SaleDate DESC FETCH FIRST 1 ROWS ONLY) AS LastProduct
FROM Customers c;



---🔹 28. Retrieve all stores along with the most frequently sold product
SELECT s.StoreName, p.ProductName
FROM Stores s
JOIN Sales sa ON s.StoreID = sa.StoreID
JOIN Products p ON sa.ProductID = p.ProductID
GROUP BY s.StoreName, p.ProductName
HAVING COUNT(sa.SaleID) = (
    SELECT MAX(COUNT(*))
    FROM Sales s2
    WHERE s2.StoreID = s.StoreID
    GROUP BY s2.ProductID
);



----🔹 29. Retrieve all sales transactions where the customer used a credit card
SELECT sa.SaleID, c.CustomerName, sa.SaleDate, sa.PaymentMethod
FROM Sales sa
JOIN Customers c ON sa.CustomerID = c.CustomerID
WHERE sa.PaymentMethod = 'Credit Card';



--🔹 30. Retrieve all customers who have made a purchase but have not returned to buy again
SELECT c.CustomerName
FROM Customers c
JOIN Sales sa ON c.CustomerID = sa.CustomerID
GROUP BY c.CustomerName
HAVING COUNT(sa.SaleID) = 1;