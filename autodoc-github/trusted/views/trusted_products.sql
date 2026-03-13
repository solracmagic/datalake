CREATE VIEW trusted_products AS
SELECT
    product_id,
    TRIM(product_name) AS product_name,
    TRIM(category_raw) AS category,
    CAST(REPLACE(price_string, ',', '.') AS DECIMAL(10, 2)) AS price, -- Converte string para decimal, tratando vírgula
    CAST(stock_quantity_string AS INT) AS stock_quantity,
    load_timestamp
FROM
    raw_products
WHERE
    product_id IS NOT NULL AND TRIM(product_id) != '';
