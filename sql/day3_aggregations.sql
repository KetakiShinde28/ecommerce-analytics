# Query 1 — Total orders + total revenue + avg order value by customer state
SELECT c.customer_state,
	COUNT(DISTINCT o.order_id) AS total_orders, 
	SUM(p.payment_value) AS total_revenue, 
    SUM(p.payment_value) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_payments p on p.order_id = o.order_id
JOIN customers c on c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY `total_revenue` DESC;

# Query 2 — Same but by customer city, top 20
SELECT c.customer_city,
	COUNT(DISTINCT o.order_id) AS total_orders, 
	SUM(p.payment_value) AS total_revenue, 
    SUM(p.payment_value) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_payments p on p.order_id = o.order_id
JOIN customers c on c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city
ORDER BY `total_revenue` DESC;

# Query 3 — Which seller has the highest avg review score with at least 10 reviews
SELECT s.seller_id, AVG(r.review_score) AS avg_review_score, COUNT(r.review_id) AS total_reviews
FROM order_reviews r
JOIN orders o on o.order_id = r.order_id
JOIN order_items i on i.order_id = o.order_id
JOIN sellers s on s.seller_id = i.seller_id
GROUP BY s.seller_id
HAVING COUNT(r.review_id) >= 10
ORDER BY avg_review_score DESC
LIMIT 1;

# Query 4 — WHERE vs HAVING side by side — run both, compare results
SELECT order_status, COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY order_status;

#AND
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
HAVING COUNT(*) > 1000;

# Query 5 — Monthly order counts (month-over-month)
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month, COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

# Query 6 — Month over month GROWTH (the upgrade)
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    COUNT(order_id) - LAG(COUNT(order_id)) 
        OVER (ORDER BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS growth,
    ROUND((COUNT(order_id) - LAG(COUNT(order_id)) 
        OVER (ORDER BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')))
        * 100.0 / LAG(COUNT(order_id)) 
        OVER (ORDER BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')), 2) AS growth_pct
FROM orders
GROUP BY order_month
ORDER BY order_month;

# Query 7 — Top 10 cities by unique customers
SELECT customer_city, COUNT(DISTINCT customer_id) AS unique_customers
FROM customers
GROUP BY customer_city
ORDER BY unique_customers DESC
LIMIT 10;

# Query 8 — Cities with high customers but low orders (underperforming markets)
SELECT 
    c.customer_city,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    COUNT(o.order_id) AS total_orders,
    COUNT(o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id) AS orders_per_customer
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_city
HAVING orders_per_customer < 1.2
ORDER BY unique_customers DESC;

# Query 9 — Revenue by payment type
SELECT p.payment_type, SUM(p.payment_value) AS total_revenue
FROM order_payments p
JOIN orders o ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_revenue DESC;

# Query 10 — Sellers with high revenue but bad reviews (at-risk sellers)
SELECT 
    s.seller_id,
    SUM(p.payment_value) AS total_revenue,
    AVG(r.review_score) AS avg_review_score,
    COUNT(r.review_id) AS total_reviews
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN sellers s ON s.seller_id = i.seller_id
JOIN order_payments p ON p.order_id = o.order_id
JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id
HAVING total_revenue > 100000   -- high revenue threshold
   AND avg_review_score < 3.5   -- bad reviews threshold
ORDER BY total_revenue DESC;