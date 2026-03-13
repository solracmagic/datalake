CREATE TABLE raw_customers (
    customer_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    registration_timestamp VARCHAR(255), -- Timestamp como string na camada raw
    address_raw TEXT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
