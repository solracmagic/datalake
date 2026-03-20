CREATE TABLE raw_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_date_string VARCHAR(50), -- Data como string na camada raw
    total_amount_string VARCHAR(50), -- Valor total como string na camada raw
    status VARCHAR(100),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
