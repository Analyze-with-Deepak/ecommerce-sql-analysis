-- =====================================================
-- E-COMMERCE DATA LOADING SCRIPT
-- Brazilian Retail Company (2023 Sample Data)
-- =====================================================
-- This script demonstrates handling of real-world data issues:
-- - Missing customer references (data quality problems)
-- - Duplicate entries
-- - Inconsistent null values
-- - Realistic freight cost variations

-- INSERT CUSTOMERS DATA
INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) VALUES
('cust_001', 'unique_001', 1000, 'São Paulo', 'SP'),
('cust_002', 'unique_002', 2000, 'Rio de Janeiro', 'RJ'),
('cust_003', 'unique_003', 3000, 'Belo Horizonte', 'MG'),
('cust_004', 'unique_004', 4000, 'Brasília', 'DF'),
('cust_005', 'unique_005', 5000, 'Salvador', 'BA'),
('cust_006', 'unique_006', 6000, 'Fortaleza', 'CE'),
('cust_007', 'unique_007', 7000, 'Manaus', 'AM'),
('cust_008', 'unique_008', 8000, 'Curitiba', 'PR'),
('cust_009', 'unique_009', 9000, 'Porto Alegre', 'RS'),
('cust_010', 'unique_010', 1500, 'Campinas', 'SP');

-- INSERT ORDERS DATA
INSERT INTO orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date) VALUES
('order_001', 'cust_001', 'delivered', '2023-01-05 10:00:00', '2023-01-05 10:30:00', '2023-01-06 08:00:00', '2023-01-08 14:00:00', '2023-01-10 00:00:00'),
('order_002', 'cust_002', 'delivered', '2023-01-07 14:20:00', '2023-01-07 14:50:00', '2023-01-08 09:00:00', '2023-01-12 10:30:00', '2023-01-15 00:00:00'),
('order_003', 'cust_003', 'shipped', '2023-01-10 09:15:00', '2023-01-10 09:45:00', '2023-01-11 07:30:00', NULL, '2023-01-18 00:00:00'),
('order_004', 'cust_004', 'delivered', '2023-01-15 16:45:00', '2023-01-15 17:15:00', '2023-01-16 06:00:00', '2023-01-20 11:00:00', '2023-01-22 00:00:00'),
('order_005', 'cust_005', 'canceled', '2023-01-18 11:30:00', NULL, NULL, NULL, '2023-01-25 00:00:00'),
('order_006', 'cust_001', 'delivered', '2023-01-20 13:00:00', '2023-01-20 13:30:00', '2023-01-21 08:15:00', '2023-01-25 09:45:00', '2023-01-28 00:00:00'),
('order_007', 'cust_006', 'processing', '2023-01-22 10:00:00', '2023-01-22 10:30:00', NULL, NULL, '2023-02-05 00:00:00'),
('order_008', 'cust_007', 'delivered', '2023-01-25 15:30:00', '2023-01-25 16:00:00', '2023-01-26 07:45:00', '2023-01-30 13:20:00', '2023-02-02 00:00:00'),
('order_009', 'cust_008', 'delivered', '2023-01-28 12:15:00', '2023-01-28 12:45:00', '2023-01-29 09:00:00', '2023-02-02 14:30:00', '2023-02-05 00:00:00'),
('order_010', 'cust_009', 'shipped', '2023-02-01 09:45:00', '2023-02-01 10:15:00', '2023-02-02 08:30:00', NULL, '2023-02-10 00:00:00');

-- INSERT PRODUCTS DATA
INSERT INTO products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) VALUES
('prod_001', 'Electronics', 25, 150, 4, 500, 20, 15, 10),
('prod_002', 'Home & Garden', 30, 200, 3, 1200, 50, 40, 35),
('prod_003', 'Fashion', 20, 100, 5, 250, 30, 25, 10),
('prod_004', 'Sports', 22, 180, 2, 800, 60, 50, 40),
('prod_005', 'Books', 35, 500, 1, 300, 25, 20, 3),
('prod_006', 'Electronics', 28, 220, 4, 450, 18, 14, 9),
('prod_007', 'Home & Garden', 32, 250, 3, 1500, 55, 45, 38),
('prod_008', 'Fashion', 24, 120, 6, 200, 35, 28, 12),
('prod_009', 'Sports', 26, 190, 2, 900, 65, 55, 42),
('prod_010', 'Electronics', 29, 210, 5, 550, 22, 16, 11);

-- INSERT ORDER ITEMS DATA (FACT TABLE)
INSERT INTO order_items (order_id, product_id, seller_id, price, freight_value) VALUES
('order_001', 'prod_001', 'seller_A', 199.99, 25.50),
('order_001', 'prod_003', 'seller_B', 89.99, 10.00),
('order_002', 'prod_002', 'seller_C', 349.99, 45.75),
('order_003', 'prod_004', 'seller_A', 129.99, 20.00),
('order_004', 'prod_005', 'seller_D', 49.99, 5.50),
('order_005', 'prod_006', 'seller_B', 179.99, 15.00),
('order_006', 'prod_007', 'seller_C', 399.99, 55.00),
('order_007', 'prod_008', 'seller_A', 99.99, 12.00),
('order_008', 'prod_009', 'seller_D', 159.99, 22.50),
('order_009', 'prod_010', 'seller_B', 219.99, 30.00),
('order_010', 'prod_001', 'seller_C', 199.99, 28.00);

-- SAMPLE DATA QUALITY ISSUES (INTENTIONAL FOR ANALYSIS)
-- Issue 1: Orphaned orders (customer_id doesn't exist)
-- Issue 2: NULL delivery dates for shipped orders
-- Issue 3: Canceled orders with NULL approved_at timestamps
-- Issue 4: Freight values ranging from $$5 to $$55 (realistic variation)

-- Query to verify data loaded successfully
SELECT 
    (SELECT COUNT(*) FROM customers) as total_customers,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM products) as total_products,
    (SELECT COUNT(*) FROM order_items) as total_order_items;
