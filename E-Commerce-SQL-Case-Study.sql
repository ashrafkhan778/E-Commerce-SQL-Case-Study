create database case_study ;
use case_study ;


-- Create Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE
);

-- Create Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Create Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create Order Items Table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert Sample Data
INSERT INTO customers VALUES
(1, 'Ashraf Khan', 'ashraf@example.com', '2023-02-10'),
(2, 'Sadiay Tawqeer Khan', 'sadiay@example.com', '2022-11-15'),
(3, 'Ali Raza', 'ali@example.com', '2023-05-01'),
(4, 'Sara Ahmed', 'sara@example.com', '2023-06-20'),
(5, 'Rahul Sharma', 'rahul@example.com', '2024-01-05');

INSERT INTO products VALUES
(101, 'Smartphone', 'Electronics', 25000),
(102, 'Laptop', 'Electronics', 55000),
(103, 'Headphones', 'Accessories', 2000),
(104, 'Chair', 'Furniture', 5000),
(105, 'Watch', 'Accessories', 7000);

INSERT INTO orders VALUES
(201, 1, '2024-01-05', 75000),
(202, 2, '2024-01-15', 2000),
(203, 3, '2024-02-10', 3000),
(204, 4, '2024-02-20', 55000),
(205, 5, '2024-01-25', 12000);

INSERT INTO order_items VALUES
(301, 201, 102, 1),
(302, 202, 103, 1),
(303, 203, 105, 1),
(304, 204, 102, 1),
(305, 205, 104, 2);

INSERT INTO payments VALUES
(401, 201, 'Credit Card', 'Paid'),
(402, 202, 'UPI', 'Paid'),
(403, 203, 'Credit Card', 'Pending'),
(404, 204, 'Net Banking', 'Paid'),
(405, 205, 'UPI', 'Paid');


-- 1 Basic Queries (5 Questions)

-- 1 Retrieve all customers who registered after January 1, 2023.

select * from  customers 
where registration_date > '2023-01-01';

-- 2 Find the total number of orders placed in January 2024.

select  count(*) As total_Orders
from  orders
where order_date between '2024-01-01' and '2024-01-31' ;

-- 3 List all unique product categories available in the system.


select distinct category from products ;

-- 4 Retrieve orders where the total amount is greater than ₹2000.
 
 select * from orders 
 where total_amount > 2000 ;
 
 --  5 Find the total revenue generated from the Electronics category.
  
 
 select sum(p.price * o.quantity) As Total_revenue
 from  products p
 left join order_items o on p.product_id = o.product_id
 where p.category = 'Electronics'  ;
 
-- Joins Queries (5 Questions)

-- 6 Retrieve a list of customers and their corresponding orders, showing customer_id, name, order_id, and order_date.



select c.customer_id,c.name,o.order_id,o.order_date
from  customers c
left join orders o on c.customer_id = o.customer_id ;

-- 7 Get details of all orders with their payment status, displaying order_id, 
-- customer_id, total_amount, and payment_status.

select o.order_id ,o.customer_id,o.total_amount,p.payment_status
from  orders o
left join  payments p on o.order_id = p.order_id ;

-- 8 Fetch the product name, order date, and customer name for all orders.

select p.product_name ,o.order_date ,c.name
from  orders o
left join order_items oi  on o.order_id = oi.order_id
left join products p on  oi.product_id = p.product_id
left join customers c on o.customer_id = c.customer_id ;


-- 9 Find the top 3 customers who have spent the most in total.


select c.customer_id , c.name ,sum(o.total_amount) As Total_Spent
from  customers c 
left join orders o on c.customer_id = o.customer_id
group by c.customer_id , c.name 
order by Total_Spent desc limit 3 ;

-- 10  List the order details, including the order_id, customer name, product name, and quantity.

SELECT o.order_id, c.name AS customer_name, p.product_name, oi.quantity  
FROM orders o  
JOIN order_items oi ON o.order_id = oi.order_id  
JOIN products p ON oi.product_id = p.product_id  
JOIN customers c ON o.customer_id = c.customer_id;


-- Window Functions (5 Questions)
-- 1 Rank customers based on their total spending in descending order.

select * from orders ;

select c.customer_id ,c.name ,sum(o.total_amount) As Total_Spending,
		rank() over(order by sum(o.total_amount) desc ) As Rank_By_Total_Spending
from  customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id ,c.name ;

-- 2 Find the cumulative total revenue by order_date.

select * from orders ;

select order_date, sum(total_amount) over(order by order_date )  AS cumulative_revenu
from orders ;
        
-- 3 Assign a row number to each order based on order_date, partitioned by customer_id.

select * from orders ;

select customer_id ,order_id ,order_date,
	   row_number() over(partition by customer_id order by order_date ) As Order_Number
from orders ;

-- 4  Calculate the difference in total amount spent by each customer compared to their previous order.
SELECT customer_id, order_id, order_date, total_amount,  
       total_amount - LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS amount_difference  
FROM orders;

-- 5 Find the most expensive order per customer using RANK().


SELECT customer_id, order_id, total_amount, rank_order
FROM (
    SELECT customer_id, order_id, total_amount,
           RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rank_order
    FROM orders
) ranked_orders
WHERE rank_order = 1;


-- Case Statements & Aggregations (5 Questions)

-- 1Categorize customers into "High Spenders" (above ₹5000) and "Low Spenders" using a CASE statement.

select * from customers ;
select * from orders ;

select c.customer_id , c.name ,
       sum(o.total_amount) As Total_spent ,
	case 
          when sum(o.total_amount)  > 5000 Then 'High Spenders'
          Else "Low Spenders"
	End as spending_category  
from  customers c
left join orders o on c.customer_id = o.customer_id
group by  c.customer_id , c.name ;

-- 2 Calculate the percentage of orders paid via each payment method

SELECT payment_method,  
       COUNT(*) AS total_orders,  
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_orders  
FROM payments  
GROUP BY payment_method;

-- 3 Find the month with the highest number of orders in 2024.

SELECT MONTH(order_date) AS order_month, COUNT(*) AS order_count  
FROM orders  
WHERE YEAR(order_date) = 2024  
GROUP BY MONTH(order_date)  
ORDER BY order_count DESC  
LIMIT 1;

-- 4 Count the number of pending payments in the payments table.

select count(*) As Pending_payments
from payments
where payment_status = "Pending" ;

--  Find the customer with the highest order frequency in the last 6 months.

SELECT c.customer_id, c.name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.customer_id, c.name
ORDER BY order_count DESC
LIMIT 1;


 