-- =====================================================
-- BUSINESS ANALYSIS QUERIES
-- E-Commerce Revenue, Retention, and Delivery Performance
-- Supabase / PostgreSQL version
-- =====================================================

-- -----------------------------------------------------
-- 1. Monthly Revenue Trend
-- Purpose: Track revenue performance over time
-- Screenshot this one
-- -----------------------------------------------------
SELECT
    TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS month,
    ROUND(SUM(oi.price + COALESCE(oi.freight_value, 0)), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY 1;


-- -----------------------------------------------------
-- 2. Top Product Categories by Revenue
-- Purpose: Find which categories drive the most money
-- Screenshot this one too
-- -----------------------------------------------------
SELECT
    COALESCE(p.product_category_name, 'unknown') AS product_category,
    ROUND(SUM(oi.price + COALESCE(oi.freight_value, 0)), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10;


-- -----------------------------------------------------
-- 3. Top Customers by Lifetime Value
-- Purpose: Identify highest-value customers
-- -----------------------------------------------------
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + COALESCE(oi.freight_value, 0)), 2) AS customer_lifetime_value,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY customer_lifetime_value DESC
LIMIT 10;


-- -----------------------------------------------------
-- 4. Revenue by Customer State
-- Purpose: See which regions contribute the most revenue
-- -----------------------------------------------------
SELECT
    c.customer_state,
    ROUND(SUM(oi.price + COALESCE(oi.freight_value, 0)), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- -----------------------------------------------------
-- 5. Order Status Distribution
-- Purpose: Understand operational order outcomes
-- -----------------------------------------------------
SELECT
    o.order_status,
    COUNT(*) AS total_orders
FROM orders o
GROUP BY o.order_status
ORDER BY total_orders DESC;


-- -----------------------------------------------------
-- 6. Average Delivery Time
-- Purpose: Measure delivery speed
-- -----------------------------------------------------
SELECT
    ROUND(AVG(
        EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date - o.order_purchase_timestamp
        )) / 86400
    )::numeric, 2) AS avg_delivery_days
FROM orders o
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL;


-- -----------------------------------------------------
-- 7. Late Delivery Rate
-- Purpose: Measure how often deliveries arrive after estimate
-- -----------------------------------------------------
SELECT
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS late_deliveries,
    COUNT(*) AS total_deliveries,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
            ) * 100.0
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_pct
FROM orders o
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;


-- -----------------------------------------------------
-- 8. Monthly Order Volume
-- Purpose: Track demand over time
-- -----------------------------------------------------
SELECT
    TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
GROUP BY 1
ORDER BY 1;


-- -----------------------------------------------------
-- 9. Average Order Value
-- Purpose: Measure revenue per order
-- -----------------------------------------------------
SELECT
    ROUND(
        SUM(oi.price + COALESCE(oi.freight_value, 0)) / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- -----------------------------------------------------
-- 10. Repeat Customer Analysis
-- Purpose: Check how many customers placed multiple orders
-- -----------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS repeat_customers
FROM customer_orders
WHERE total_orders > 1;


-- -----------------------------------------------------
-- 11. New vs Repeat Customer Mix
-- Purpose: Understand customer retention profile
-- -----------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'one_time_customer'
        ELSE 'repeat_customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY 1
ORDER BY customer_count DESC;


-- -----------------------------------------------------
-- 12. Highest Freight Cost Categories
-- Purpose: Find categories with higher shipping burden
-- -----------------------------------------------------
SELECT
    COALESCE(p.product_category_name, 'unknown') AS product_category,
    ROUND(AVG(COALESCE(oi.freight_value, 0))::numeric, 2) AS avg_freight_value,
    COUNT(*) AS total_items
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY avg_freight_value DESC
LIMIT 10;
