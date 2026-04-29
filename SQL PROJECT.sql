-- Online Book Store SQL Project by Anushka Nagare

-- Create database
CREATE DATABASE OnlineBookStore;
GO

-- Switch to database
USE OnlineBookStore;
GO

-- Drop tables (in correct order due to foreign keys)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS books;

-- Create Books table
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    genre VARCHAR(100),
    published_year INT,
    price DECIMAL(10,2),
    stock INT
);

-- Create Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100)
);

-- Create Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    book_id INT,
    order_date DATE,
    quantity INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- ===============================
-- DATA IMPORT
-- ===============================

BULK INSERT books
FROM 'C:\Users\anush\Downloads\Books.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

BULK INSERT customers
FROM 'C:\Users\anush\Downloads\Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

BULK INSERT orders
FROM 'C:\Users\anush\Downloads\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- ===============================
-- BASIC QUERIES
-- ===============================

-- 1. Books in Fiction genre
SELECT * 
FROM books 
WHERE LOWER(genre) = 'fiction';

-- 2. Books after 1950
SELECT * 
FROM books 
WHERE published_year > 1950;

-- 3. Customers from Canada
SELECT * 
FROM customers 
WHERE LOWER(country) = 'canada';

-- 4. Orders in November 2023
SELECT * 
FROM orders
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5. Total stock
SELECT SUM(stock) AS total_stock
FROM books;

-- 6. Most expensive book
SELECT TOP 1 * 
FROM books 
ORDER BY price DESC;

-- 7. Customers who ordered quantity > 1
SELECT * 
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.quantity > 1;

-- 8. Orders with amount > 20
SELECT * 
FROM orders 
WHERE total_amount > 20;

-- 9. All genres
SELECT DISTINCT genre 
FROM books;

-- 10. Lowest stock book
SELECT TOP 1 * 
FROM books 
ORDER BY stock ASC;

-- 11. Total revenue
SELECT SUM(total_amount) AS total_revenue 
FROM orders;

-- ===============================
-- ADVANCED QUERIES
-- ===============================

-- 1. Books sold per genre
SELECT b.genre, SUM(o.quantity) AS total_books_sold
FROM books b
INNER JOIN orders o ON b.book_id = o.book_id
GROUP BY b.genre;

-- 2. Average price of Fantasy books (FIXED)
SELECT AVG(price) AS avg_price
FROM books
WHERE LOWER(genre) = 'fantasy';

-- 3. Customers with at least 2 orders
SELECT c.customer_id, c.name
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;

-- 4. Most frequently ordered book
SELECT TOP 1 b.title, COUNT(*) AS times_ordered
FROM books b
INNER JOIN orders o ON b.book_id = o.book_id
GROUP BY b.title
ORDER BY times_ordered DESC;

-- 5. Top 3 expensive Fantasy books
SELECT TOP 3 title, price
FROM books
WHERE LOWER(genre) = 'fantasy'
ORDER BY price DESC;

-- 6. Total quantity sold per author
SELECT b.author, SUM(o.quantity) AS total_quantity
FROM books b
INNER JOIN orders o ON b.book_id = o.book_id
GROUP BY b.author;

-- 7. Cities with customers spending > 30
SELECT c.city
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.city
HAVING SUM(o.total_amount) > 30;

-- 8. Highest spending customer
SELECT TOP 1 c.customer_id, c.name, SUM(o.total_amount) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- 9. Remaining stock
SELECT 
    b.title,
    CASE 
        WHEN b.stock - ISNULL(SUM(o.quantity), 0) < 0 THEN 0
        ELSE b.stock - ISNULL(SUM(o.quantity), 0)
    END AS stock_remaining
FROM books b
LEFT JOIN orders o ON b.book_id = o.book_id
GROUP BY b.title, b.stock
ORDER BY stock_remaining DESC;