#10 SELECT QUERIES

#Query 1 — See the raw data first, always
SELECT * FROM orders
limit 20;
#Query 2 — What order statuses even exist?
SELECT order_status
FROM orders
GROUP BY order_status;

# OR

SELECT DISTINCT order_status 
FROM orders;

#Query 3 — Filter to only delivered orders
SELECT *
FROM orders
WHERE order_status = 'delivered';

#Query 4 — Find all orders that are NOT delivered
SELECT order_id, order_status, order_purchase_timestamp, order_estimated_delivery_date
FROM orders
WHERE order_status != 'delivered'
ORDER BY order_purchase_timestamp DESC;

#Query 5 — Most recent 100 orders placed
SELECT order_id, order_purchase_timestamp
FROM orders
ORDER BY order_purchase_timestamp DESC
LIMIT 100;

#Query 6 — Orders placed in a specific date range
SELECT order_id, order_status, order_purchase_timestamp
FROM orders
WHERE order_purchase_timestamp BETWEEN date('2017-05-01') and date('2017-06-1')
ORDER BY order_purchase_timestamp;

#Query 7 — Filter on two conditions at once (Orders invioced in the month of Feb 2018)
SELECT order_id, customer_id, order_purchase_timestamp, order_status
FROM orders
WHERE order_status = 'invoiced'
AND order_purchase_timestamp BETWEEN date('2018-02-01') and date('2018-02-28');

#Query 8 — Orders that were either cancelled OR unavailable
SELECT *
FROM orders
WHERE order_status = 'canceled' or order_status = 'unavailable';

# OR

SELECT order_id, order_status, order_purchase_timestamp
FROM olist_orders
WHERE order_status IN ('cancelled', 'unavailable')
ORDER BY order_purchase_timestamp DESC;

#Query 9 — Orders where delivery date is missing
SELECT order_id,order_status, order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date is NULL;

#Query 10 — Join orders to customers, see full picture
SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 50;

# COUNT + GROUP BY Aggregations

#Query 11 — How many orders per status?
SELECT order_status, COUNT(*) AS'Total'
FROM orders
GROUP BY order_status;

#Query 12 — How many orders per month?
SELECT MONTHNAME(order_purchase_timestamp) as 'Months', 
	COUNT(*) as 'Total orders'
FROM orders
GROUP BY MONTH(order_purchase_timestamp), MONTHNAME(order_purchase_timestamp)
ORDER BY MONTH(order_purchase_timestamp);

#Query 13 — Which month had the most orders ever?
SELECT MONTHNAME(order_purchase_timestamp) as 'Months', 
	COUNT(*) as 'Total orders'
FROM orders
GROUP BY MONTH(order_purchase_timestamp), MONTHNAME(order_purchase_timestamp)
ORDER BY `Total orders` DESC
LIMIT 1;

#Query 14 — How many unique customers placed orders?
SELECT COUNT(DISTINCT customer_id)
FROM orders;

#Query 15 — Orders per status per year
SELECT order_status, YEAR(order_purchase_timestamp) AS 'Year', COUNT(order_id) AS 'Total Orders'
FROM orders
GROUP BY order_status, YEAR(order_purchase_timestamp);

#Query 16 — Average days between purchase and delivery
SELECT ROUND(AVG(datediff(order_delivered_customer_date, order_purchase_timestamp)), 1) AS 'Avg Del Time'
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

#Query 17 — How many orders came from each state?
SELECT c.customer_state, COUNT(o.order_id) AS 'Orders'
FROM customers c
JOIN orders o on o.customer_id = c.customer_id
GROUP BY c.customer_state;

#Query 18 — What % of all orders are delivered?
SELECT
(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders)) AS 'Delivered Percentage'
FROM orders
WHERE order_status = 'delivered';

#Query 19 — Find months with fewer than 500 orders (slow periods)
SELECT MONTHNAME(order_purchase_timestamp) AS 'Slow period', COUNT(*) AS 'Total Orders'
FROM orders
GROUP BY MONTH(order_purchase_timestamp), MONTHNAME(order_purchase_timestamp)
HAVING COUNT(*) < 500
ORDER BY MONTH(order_purchase_timestamp);

# Query 20 — Business summary: orders, delivery rate, avg delivery time
SELECT 
	COUNT(*) AS 'Total Orders',
	(COUNT(order_delivered_customer_date) * 100 / COUNT(*)) AS 'Delivery Rate',
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS 'Avg Delivery Time'
FROM orders;