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
