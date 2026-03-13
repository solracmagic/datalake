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
