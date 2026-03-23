CREATE TABLE refined_daily_sales AS
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS number_of_orders_all,
    SUM(total_amount) AS total_daily_sales,
    MAX(load_timestamp) AS latest_load_timestamp
FROM
    trusted_orders
GROUP BY
    order_date;
