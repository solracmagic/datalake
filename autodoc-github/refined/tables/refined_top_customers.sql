CREATE TABLE refined_top_customers AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    total_spent,
    total_orders
FROM
    refined_customer_lifetime_value
ORDER BY
    total_spent DESC
LIMIT 10; -- Exemplo: Os 10 clientes com maior gasto
