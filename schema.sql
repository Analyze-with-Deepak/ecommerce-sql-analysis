-- =====================================================
-- E-COMMERCE DATABASE SCHEMA
-- Brazilian Retail Company (2023 Sales Data)
-- =====================================================
-- This schema reflects real-world data issues like:
-- - Missing customer references
-- - Inconsistent date formats  
-- - Duplicate entries
-- - Null freight costs

-- Drop tables if they exist (safety first)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ORDERS TABLE  
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- PRODUCTS TABLE
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g REAL,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- ORDER ITEMS (FACT TABLE)
CREATE TABLE order_items (
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    seller_id VARCHAR(20),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Indexes for performance (shows optimization thinking)
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
