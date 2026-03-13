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
