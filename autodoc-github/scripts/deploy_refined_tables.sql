-- Script para criar todas as tabelas da camada REFINED

-- Drop tables if they exist (for re-running the script)
DROP TABLE IF EXISTS refined_top_customers;
DROP TABLE IF EXISTS refined_product_performance;
DROP TABLE IF EXISTS refined_customer_lifetime_value;
DROP TABLE IF EXISTS refined_daily_sales;

-- refined_daily_sales.sql
CREATE TABLE refined_daily_sales AS
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(total_amount) AS total_daily_sales,
    MAX(load_timestamp) AS latest_load_timestamp
FROM
    trusted_orders
GROUP BY
    order_date;

-- refined_customer_lifetime_value.sql
CREATE TABLE refined_customer_lifetime_value AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    SUM(o.total_amount) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    MAX(c.load_timestamp) AS latest_customer_load_timestamp,
    MAX(o.load_timestamp) AS latest_order_load_timestamp
FROM
    trusted_customers c
JOIN
    trusted_orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email;

-- refined_product_performance.sql
CREATE TABLE refined_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.line_item_total) AS total_product_revenue,
    AVG(oi.unit_price) AS average_unit_price,
    MAX(p.load_timestamp) AS latest_product_load_timestamp,
    MAX(oi.load_timestamp) AS latest_order_item_load_timestamp
FROM
    trusted_products p
JOIN
    trusted_order_items oi ON p.product_id = oi.product_id
GROUP BY
    p.product_id, p.product_name, p.category;

-- refined_top_customers.sql
CREATE TABLE refined_top_customers AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    total_spent,
    total_orders
FROM
    refined_customer_lifetime_value
ORDER BY
    total_spent DESC
LIMIT 10;
