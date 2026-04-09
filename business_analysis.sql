-- =====================================================
-- BUSINESS ANALYSIS QUERIES
-- Brazilian E-Commerce Dataset (2023)
-- =====================================================
-- Purpose: Extract actionable business insights
-- This demonstrates to recruiters that you can:
-- - Answer real business questions with SQL
-- - Create metrics that drive decisions
-- - Think strategically about e-commerce operations
-- =====================================================

-- ==========================================
-- QUERY 1: MONTHLY SALES TREND ANALYSIS
-- ==========================================
-- Business Question: How are sales trending month-over-month?
-- Shows your ability to work with time series data

SELECT
    STRFTIME('%Y-%m', o.order_purchase_timestamp) as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(oi.price) as total_revenue,
    SUM(oi.freight_value) as total_freight_cost,
    SUM(oi.price) - SUM(oi.freight_value) as net_revenue,
    ROUND(100.0 * SUM(oi.price) / (SELECT SUM(price) FROM order_items), 2) as revenue_percentage
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY STRFTIME('%Y-%m', o.order_purchase_timestamp)
ORDER BY month;

-- ==========================================
-- QUERY 2: CUSTOMER SEGMENTATION BY SPEND
-- ==========================================
-- Business Question: Who are our most valuable customers?
-- Shows RFM (Recency, Frequency, Monetary) analysis thinking

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_city,
        c.customer_state,
        COUNT(DISTINCT o.order_id) as order_count,
        SUM(oi.price) as total_spend,
        MAX(o.order_purchase_timestamp) as last_order_date,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_purchase_timestamp)) as days_since_last_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_city, c.customer_state
)

SELECT
    customer_id,
    customer_city || ', ' || customer_state as location,
    order_count,
    total_spend,
    days_since_last_order,
    CASE
        WHEN total_spend > 500 AND days_since_last_order < 30 THEN 'VIP Customer'
        WHEN total_spend > 200 AND order_count > 2 THEN 'Loyal Customer'
        WHEN days_since_last_order > 90 THEN 'At-Risk Customer'
        ELSE 'Standard Customer'
    END as customer_segment,
    CASE
        WHEN total_spend > 500 THEN 'High'
        WHEN total_spend > 200 THEN 'Medium'
        ELSE 'Low'
    END as spend_level
FROM customer_metrics
ORDER BY total_spend DESC;

-- ==========================================
-- QUERY 3: PRODUCT PERFORMANCE ANALYSIS
-- ==========================================
-- Business Question: Which products drive the most revenue?
-- Shows product management thinking

SELECT
    p.product_id,
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) as orders_count,
    SUM(oi.price) as total_revenue,
    SUM(oi.price) / COUNT(DISTINCT oi.order_id) as avg_price,
    SUM(oi.price) / (SELECT SUM(price) FROM order_items) * 100 as revenue_percentage,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) as revenue_rank
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_id, p.product_category_name
ORDER BY total_revenue DESC;

-- ==========================================
-- QUERY 4: DELIVERY PERFORMANCE METRICS
-- ==========================================
-- Business Question: How efficient is our delivery process?
-- Shows operational analysis skills

SELECT
    c.customer_state,
    COUNT(o.order_id) as total_orders,
    AVG(JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp)) as avg_delivery_days,
    MIN(JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp)) as min_delivery_days,
    MAX(JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp)) as max_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp) <= 7 THEN 1 ELSE 0 END) / COUNT(o.order_id), 2) as pct_delivered_in_7_days,
    ROUND(100.0 * SUM(CASE WHEN JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp) > 14 THEN 1 ELSE 0 END) / COUNT(o.order_id), 2) as pct_delivered_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;

-- ==========================================
-- QUERY 5: CUSTOMER RETENTION ANALYSIS
-- ==========================================
-- Business Question: How many customers return to purchase again?
-- Shows customer lifecycle understanding

WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_purchase_timestamp) as first_order_date
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),

repeat_customers AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) as total_orders,
        MIN(o.order_purchase_timestamp) as first_order_date,
        MAX(o.order_purchase_timestamp) as last_order_date
    FROM orders o
    JOIN first_orders fo ON o.customer_id = fo.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
    HAVING COUNT(DISTINCT o.order_id) > 1
)

SELECT
    'Total Customers' as metric,
    COUNT(DISTINCT customer_id) as value
FROM orders
WHERE order_status = 'delivered'

UNION ALL

SELECT
    'Repeat Customers' as metric,
    COUNT(DISTINCT customer_id) as value
FROM repeat_customers

UNION ALL

SELECT
    'Repeat Purchase Rate' as metric,
    ROUND(100.0 * (SELECT COUNT(DISTINCT customer_id) FROM repeat_customers) /
          (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE order_status = 'delivered'), 2) as value

UNION ALL

SELECT
    'Avg Orders per Repeat Customer' as metric,
    ROUND(AVG(total_orders), 2) as value
FROM repeat_customers;

-- ==========================================
-- QUERY 6: GEOGRAPHIC SALES DISTRIBUTION
-- ==========================================
-- Business Question: Where are our sales concentrated?
-- Shows geographic analysis skills

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.price) as total_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) as avg_order_value,
    ROUND(100.0 * SUM(oi.price) / (SELECT SUM(price) FROM order_items oi JOIN orders o ON oi.order_id = o.order_id WHERE o.order_status = 'delivered'), 2) as revenue_percentage
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- ==========================================
-- QUERY 7: PRODUCT CATEGORY PERFORMANCE
-- ==========================================
-- Business Question: Which categories perform best?
-- Shows product portfolio analysis

SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) as unique_orders,
    SUM(oi.price) as total_revenue,
    SUM(oi.price) / COUNT(DISTINCT oi.order_id) as avg_order_value,
    ROUND(100.0 * SUM(oi.price) / (SELECT SUM(price) FROM order_items oi JOIN orders o ON oi.order_id = o.order_id WHERE o.order_status = 'delivered'), 2) as revenue_percentage,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) as revenue_rank
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

-- ==========================================
-- QUERY 8: SALES FUNNEL ANALYSIS
-- ==========================================
-- Business Question: Where do we lose customers in the process?
-- Shows conversion rate optimization thinking

SELECT
    'Total Orders Placed' as stage,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / COUNT(*), 2) as percentage
FROM orders

UNION ALL

SELECT
    'Orders Approved' as stage,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage
FROM orders
WHERE order_approved_at IS NOT NULL

UNION ALL

SELECT
    'Orders Shipped' as stage,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL

UNION ALL

SELECT
    'Orders Delivered' as stage,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL

UNION ALL

SELECT
    'Orders Canceled' as stage,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage
FROM orders
WHERE order_status = 'canceled';

-- ==========================================
-- QUERY 9: PRICE VS FREIGHT ANALYSIS
-- ==========================================
-- Business Question: How do freight costs impact profitability?
-- Shows cost analysis skills

SELECT
    p.product_category_name,
    AVG(oi.price) as avg_product_price,
    AVG(oi.freight_value) as avg_freight_cost,
    ROUND(AVG(oi.freight_value / oi.price * 100), 2) as avg_freight_percentage,
    ROUND(AVG(oi.price - oi.freight_value), 2) as avg_net_revenue,
    COUNT(*) as order_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY avg_freight_percentage DESC;

-- ==========================================
-- QUERY 10: CUSTOMER LIFETIME VALUE (CLV) ESTIMATE
-- ==========================================
-- Business Question: What is the average customer value?
-- Shows advanced business metrics understanding

WITH customer_lifetime AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) as order_count,
        SUM(oi.price) as total_spend,
        MIN(o.order_purchase_timestamp) as first_order_date,
        MAX(o.order_purchase_timestamp) as last_order_date,
        JULIANDAY(MAX(o.order_purchase_timestamp)) - JULIANDAY(MIN(o.order_purchase_timestamp)) as customer_lifespan_days
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
)

SELECT
    'Average Customer Lifetime (days)' as metric,
    ROUND(AVG(customer_lifespan_days), 2) as value
FROM customer_lifetime

UNION ALL

SELECT
    'Average Orders per Customer' as metric,
    ROUND(AVG(order_count), 2) as value
FROM customer_lifetime

UNION ALL

SELECT
    'Average Revenue per Customer' as metric,
    ROUND(AVG(total_spend), 2) as value
FROM customer_lifetime

UNION ALL

SELECT
    'Estimated Customer Lifetime Value' as metric,
    ROUND(AVG(total_spend) * (365.0 / NULLIF(AVG(customer_lifespan_days), 0)), 2) as value
FROM customer_lifetime;

-- ==========================================
-- EXECUTIVE SUMMARY: KEY BUSINESS METRICS
-- ==========================================
-- Single query to show all critical KPIs

SELECT
    'Total Revenue' as metric,
    ROUND(SUM(price), 2) as value,
    'BRL' as unit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'

UNION ALL

SELECT
    'Total Orders' as metric,
    COUNT(DISTINCT order_id) as value,
    'count' as unit
FROM orders
WHERE order_status = 'delivered'

UNION ALL

SELECT
    'Average Order Value' as metric,
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) as value,
    'BRL' as unit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'

UNION ALL

SELECT
    'Conversion Rate (Approved)' as metric,
    ROUND(100.0 * COUNT(CASE WHEN order_approved_at IS NOT NULL THEN 1 END) / COUNT(*), 2) as value,
    '%' as unit
FROM orders

UNION ALL

SELECT
    'Delivery Success Rate' as metric,
    ROUND(100.0 * COUNT(CASE WHEN order_delivered_customer_date IS NOT NULL THEN 1 END) / COUNT(*), 2) as value,
    '%' as unit
FROM orders
WHERE order_status = 'delivered';

-- ==========================================
-- BONUS: PRODUCT RECOMMENDATION OPPORTUNITIES
-- ==========================================
-- Identifies products frequently bought together
-- Shows you can think about cross-selling

SELECT
    a.product_id as product_a,
    p1.product_category_name as category_a,
    b.product_id as product_b,
    p2.product_category_name as category_b,
    COUNT(*) as co_occurrence_count
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1 ON a.product_id = p1.product_id
JOIN products p2 ON b.product_id = p2.product_id
JOIN orders o ON a.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY a.product_id, p1.product_category_name, b.product_id, p2.product_category_name
ORDER BY co_occurrence_count DESC
LIMIT 10;
