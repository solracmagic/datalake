-- Script para criar todas as views da camada TRUSTED

-- Drop views if they exist (for re-running the script)
DROP VIEW IF EXISTS trusted_order_items;
DROP VIEW IF EXISTS trusted_orders;
DROP VIEW IF EXISTS trusted_products;
DROP VIEW IF EXISTS trusted_customers;

-- trusted_customers.sql
CREATE VIEW trusted_customers AS
SELECT
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    TRIM(email) AS email,
    CAST(registration_timestamp AS TIMESTAMP) AS registration_date,
    address_raw AS full_address,
    load_timestamp
FROM
    raw_customers
WHERE
    customer_id IS NOT NULL AND TRIM(customer_id) != '';

-- trusted_products.sql
CREATE VIEW trusted_products AS
SELECT
    product_id,
    TRIM(product_name) AS product_name,
    TRIM(category_raw) AS category,
    CAST(REPLACE(price_string, ',', '.') AS DECIMAL(10, 2)) AS price,
    CAST(stock_quantity_string AS INT) AS stock_quantity,
    load_timestamp
FROM
    raw_products
WHERE
    product_id IS NOT NULL AND TRIM(product_id) != '';

-- trusted_orders.sql
CREATE VIEW trusted_orders AS
SELECT
    o.order_id,
    o.customer_id,
    CAST(o.order_date_string AS DATE) AS order_date,
    CAST(REPLACE(o.total_amount_string, ',', '.') AS DECIMAL(10, 2)) AS total_amount,
    TRIM(o.status) AS status,
    c.first_name,
    c.last_name,
    c.email,
    o.load_timestamp
FROM
    raw_orders o
JOIN
    trusted_customers c ON o.customer_id = c.customer_id
WHERE
    o.order_id IS NOT NULL AND TRIM(o.order_id) != '';

-- trusted_order_items.sql
CREATE VIEW trusted_order_items AS
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    CAST(oi.quantity_string AS INT) AS quantity,
    CAST(REPLACE(oi.unit_price_string, ',', '.') AS DECIMAL(10, 2)) AS unit_price,
    (CAST(oi.quantity_string AS INT) * CAST(REPLACE(oi.unit_price_string, ',', '.') AS DECIMAL(10, 2))) AS line_item_total,
    oi.load_timestamp
FROM
    raw_order_items oi
WHERE
    oi.order_item_id IS NOT NULL AND TRIM(oi.order_item_id) != '';
