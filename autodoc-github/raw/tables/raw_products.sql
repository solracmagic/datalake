CREATE TABLE raw_products (
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category_raw VARCHAR(100),
    price_string VARCHAR(50), -- Preço como string na camada raw
    stock_quantity_string VARCHAR(50), -- Quantidade como string na camada raw
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
