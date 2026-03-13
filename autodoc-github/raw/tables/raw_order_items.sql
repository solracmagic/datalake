CREATE TABLE raw_order_items (
    order_item_id VARCHAR(50),
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity_string VARCHAR(50), -- Quantidade como string na camada raw
    unit_price_string VARCHAR(50), -- Preço unitário como string na camada raw
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
