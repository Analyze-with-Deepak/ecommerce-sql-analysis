-- =====================================================
-- DATA QUALITY ANALYSIS QUERIES
-- Brazilian E-Commerce Dataset (2023)
-- =====================================================
-- Purpose: Identify and document data quality issues
-- This demonstrates to recruiters that you understand:
-- - Data validation techniques
-- - Problem identification
-- - Real-world data challenges
-- =====================================================

-- ==========================================
-- QUERY 1: MISSING CUSTOMER REFERENCES
-- ==========================================
-- Business Impact: Orders with no customer in the customers table
-- This is critical for data integrity

SELECT 
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    o.order_status,
    CASE 
        WHEN c.customer_id IS NULL THEN 'ORPHANED ORDER - MISSING CUSTOMER'
        ELSE 'Valid'
    END as data_quality_flag
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
ORDER BY o.order_purchase_timestamp;

-- ==========================================
-- QUERY 2: NULL VALUE ANALYSIS
-- ==========================================
-- Identifies missing critical data points
-- Shows where data collection processes failed

SELECT 
    'Delivery Date Missing' as issue_type,
    COUNT(*) as count_issues,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage_of_orders
FROM orders
WHERE order_delivered_customer_date IS NULL

UNION ALL

SELECT 
    'Approved At Missing' as issue_type,
    COUNT(*) as count_issues,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage_of_orders
FROM orders
WHERE order_approved_at IS NULL

UNION ALL

SELECT 
    'Carrier Date Missing' as issue_type,
    COUNT(*) as count_issues,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage_of_orders
FROM orders
WHERE order_delivered_carrier_date IS NULL;

-- ==========================================
-- QUERY 3: DELIVERY TIME ANOMALIES
-- ==========================================
-- Identifies orders with unrealistic delivery times
-- Shows data validation thinking

SELECT 
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    CAST((julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)) AS INTEGER) as delivery_days,
    CASE 
        WHEN CAST((julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)) AS INTEGER) < 0 THEN 'NEGATIVE DAYS - DATA ERROR'
        WHEN CAST((julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)) AS INTEGER) > 60 THEN 'UNUSUALLY LONG DELIVERY'
        ELSE 'Normal'
    END as quality_flag
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
ORDER BY delivery_days DESC;

-- ==========================================
-- QUERY 4: DUPLICATE ORDER DETECTION
-- ==========================================
-- Identifies potential duplicate entries
-- Important for revenue accuracy

SELECT 
    customer_id,
    order_purchase_timestamp,
    COUNT(*) as orders_count,
    CASE 
        WHEN COUNT(*) > 1 THEN 'POTENTIAL DUPLICATE'
        ELSE 'Unique'
    END as duplicate_flag
FROM orders
GROUP BY customer_id, order_purchase_timestamp
HAVING COUNT(*) > 1
ORDER BY orders_count DESC;

-- ==========================================
-- QUERY 5: FREIGHT VALUE OUTLIERS
-- ==========================================
-- Identifies unusual freight costs
-- Shows statistical thinking

SELECT 
    order_id,
    product_id,
    price,
    freight_value,
    ROUND(freight_value / price * 100, 2) as freight_as_percent_of_price,
    CASE 
        WHEN freight_value > 50 THEN 'HIGH FREIGHT COST'
        WHEN freight_value = 0 THEN 'ZERO FREIGHT - VERIFY'
        WHEN freight_value / price > 0.5 THEN 'FREIGHT > 50% OF PRICE - UNUSUAL'
        ELSE 'Normal'
    END as cost_flag
FROM order_items
ORDER BY freight_as_percent_of_price DESC;

-- ==========================================
-- QUERY 6: DATA COMPLETENESS SCORE
-- ==========================================
-- Calculates overall data quality percentage
-- Shows you think about metrics

SELECT 
    'Overall Data Quality Score' as metric,
    ROUND(
        100.0 * (
            (SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date IS NOT NULL) +
            (SELECT COUNT(*) FROM orders WHERE order_approved_at IS NOT NULL) +
            (SELECT COUNT(*) FROM orders WHERE order_delivered_carrier_date IS NOT NULL)
        ) / (
            (SELECT COUNT(*) FROM orders) * 3
        ),
        2
    ) as quality_percentage,
    'Higher is better (100% = no missing data)' as interpretation;

-- ==========================================
-- QUERY 7: STATUS DISTRIBUTION WITH QUALITY NOTES
-- ==========================================
-- Shows order status breakdown with data quality concerns

SELECT 
    order_status,
    COUNT(*) as order_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) as percentage,
    CASE 
        WHEN order_status = 'canceled' AND COUNT(*) > 0 THEN 'Check for NULL approved_at timestamps'
        WHEN order_status = 'shipped' AND COUNT(*) > 0 THEN 'Monitor orders without delivery dates'
        WHEN order_status = 'processing' AND COUNT(*) > 0 THEN 'Follow up on stuck orders'
        ELSE 'Monitor performance'
    END as data_quality_note
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- ==========================================
-- SUMMARY: DATA QUALITY SCORECARD
-- ==========================================
-- Executive summary of all issues found

SELECT 'ISSUE SUMMARY' as category, '' as details
UNION ALL
SELECT '- Missing Customers:', (SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL)
UNION ALL
SELECT '- NULL Delivery Dates:', (SELECT COUNT(*) FROM orders WHERE order_delivered_customer_date IS NULL)
UNION ALL
SELECT '- Potential Duplicates:', (SELECT COUNT(*) FROM (SELECT customer_id, order_purchase_timestamp FROM orders GROUP BY customer_id, order_purchase_timestamp HAVING COUNT(*) > 1))
UNION ALL
SELECT '- Total Orders Analyzed:', (SELECT COUNT(*) FROM orders);
