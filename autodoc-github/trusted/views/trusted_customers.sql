CREATE VIEW trusted_customers AS
SELECT
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    TRIM(email) AS email,
    CAST(registration_timestamp AS TIMESTAMP) AS registration_date,
    address_raw AS full_address,
    load_timestamp
FROM
    raw_customers
WHERE
    customer_id IS NOT NULL AND TRIM(customer_id) != '';
