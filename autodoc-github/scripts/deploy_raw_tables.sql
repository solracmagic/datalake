-- Script para criar todas as tabelas da camada RAW

-- Drop tables if they exist (for re-running the script)
DROP TABLE IF EXISTS raw_order_items;
DROP TABLE IF EXISTS raw_orders;
DROP TABLE IF EXISTS raw_products;
DROP TABLE IF EXISTS raw_customers;

-- raw_customers.sql
CREATE TABLE raw_customers (
    customer_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    registration_timestamp VARCHAR(255),
    address_raw TEXT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- raw_products.sql
CREATE TABLE raw_products (
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category_raw VARCHAR(100),
    price_string VARCHAR(50),
    stock_quantity_string VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- raw_orders.sql
CREATE TABLE raw_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_date_string VARCHAR(50),
    total_amount_string VARCHAR(50),
    status VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- raw_order_items.sql
CREATE TABLE raw_order_items (
    order_item_id VARCHAR(50),
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity_string VARCHAR(50),
    unit_price_string VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
