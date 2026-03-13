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
