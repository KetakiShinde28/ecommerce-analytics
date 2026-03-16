# JOINS - LEFT & INNER

#INNER JOIN: 
#SELECT columns
#FROM table_a a
#INNER JOIN table_b b ON a.matching_column = b.matching_column;

#LEFT JOIN
#SELECT columns
#FROM table_a a
#LEFT JOIN table_b b ON a.matching_column = b.matching_column;
#-----------------------------------------
# Query 1 — Basic INNER JOIN: orders + customers
SELECT o.order_id, o.order_status, o.order_purchase_timestamp, c.customer_city, c.customer_state
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LIMIT 50;

# Query 2 — LEFT JOIN: find orders with no matching customer (data quality check)
SELECT o.order_id, o.order_status, c.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

# Query 3 — Total revenue per order (orders + order_items)
SELECT o.order_id, SUM(p.payment_value) AS 'Total Revenue'
FROM orders o
INNER JOIN order_payments p on p.order_id = o.order_id
GROUP BY o.order_id;

# Query 4 — Which orders have items but no payment recorded? (data quality)
SELECT i.order_id, p.payment_value
FROM order_items i
LEFT JOIN order_payments p on p.order_id = i.order_id
WHERE p.order_id IS NULL;

# Query 5 — 3 table JOIN: orders + items + products
SELECT o.order_id, i.order_item_id, p.product_category_name
FROM orders o
INNER JOIN order_items i ON i.order_id = o.order_id
INNER JOIN products p ON p.product_id = i.product_id
LIMIT 50;

# Query 6 — Top 5 product categories by total revenue 
#(adding WHERE o.order_status = 'delivered' so you're only counting completed revenue, not cancelled orders.)
SELECT pr.product_category_name, 
       ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM orders o
JOIN order_payments p ON p.order_id = o.order_id
JOIN order_items i ON i.order_id = o.order_id
JOIN products pr ON pr.product_id = i.product_id
WHERE o.order_status = 'delivered'
GROUP BY pr.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;

# Query 7 — Join 4 tables: add seller info
SELECT s.seller_state, p.product_category_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(pay.payment_value), 2) AS total_revenue
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN sellers s ON s.seller_id = i.seller_id
JOIN products p ON p.product_id = i.product_id
JOIN order_payments pay ON pay.order_id = o.order_id
GROUP BY s.seller_state, p.product_category_name
ORDER BY total_revenue DESC
LIMIT 20;

# Query 8 — Average review score per product category
SELECT p.product_category_name, 
       AVG(r.review_score) AS 'Avg Review Score'
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
JOIN order_items i ON i.order_id = o.order_id
JOIN products p ON p.product_id = i.product_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;

# Query 9 — Full picture: revenue + reviews + delivery time per category
SELECT 
    p.product_category_name,
    SUM(pay.payment_value) AS total_revenue,
    AVG(r.review_score) AS avg_review_score,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) 
        AS avg_delivery_days
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p ON p.product_id = i.product_id
JOIN order_payments pay ON pay.order_id = o.order_id
JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

# Query 10 — RIGHT JOIN: see all products even if never ordered
SELECT p.product_id, p.product_category_name,
       COUNT(i.order_id) AS times_ordered
FROM order_items i
RIGHT JOIN products p ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY times_ordered ASC;