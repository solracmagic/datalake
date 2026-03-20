# Documentação Técnica — Tabela `raw_customers`

## Visão Geral

A tabela `raw_customers` pertence à camada **raw** do pipeline de dados e armazena registros brutos de clientes conforme recebidos da fonte de origem. Os dados ainda não passaram por processos de padronização ou transformação.

O campo `registration_timestamp` é armazenado como **string**, indicando que a normalização ou conversão de tipo deve ocorrer em camadas posteriores do pipeline (por exemplo: staging ou trusted).

---

## Estrutura da Tabela

```sql
CREATE TABLE raw_customers (
    customer_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    registration_timestamp VARCHAR(255),
    address_raw TEXT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Dicionário de Dados

| Campo | Tipo de Dado | Restrições | Descrição |
|---|---|---|---|
| `customer_id` | VARCHAR(50) | - | Identificador único do cliente conforme fornecido pela fonte de origem. |
| `first_name` | VARCHAR(100) | - | Primeiro nome do cliente. |
| `last_name` | VARCHAR(100) | - | Sobrenome do cliente. |
| `email` | VARCHAR(255) | - | Endereço de e-mail do cliente. |
| `registration_timestamp` | VARCHAR(255) | - | Data e hora de registro do cliente no sistema de origem. Armazenado como string na camada raw. |
| `address_raw` | TEXT | - | Endereço completo do cliente em formato bruto, sem padronização ou estrutura definida. |
| `load_timestamp` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data e hora em que o registro foi carregado na tabela raw. |

---

## Observações de Modelagem

- A tabela **não possui chave primária definida**.
- Não há **restrições de integridade referencial (FOREIGN KEY)**.
- Todos os campos podem aceitar valores `NULL`, exceto quando implicitamente definidos pela fonte de ingestão.
- O campo `load_timestamp` é preenchido automaticamente no momento da inserção do registro.

---

## Exemplo de Registro

```json
{
  "customer_id": "CUST-10045",
  "first_name": "Maria",
  "last_name": "Silva",
  "email": "maria.silva@email.com",
  "registration_timestamp": "2024-01-15T10:32:45Z",
  "address_raw": "Rua das Flores, 120 - São Paulo - SP - Brasil",
  "load_timestamp": "2024-01-15T10:33:10"
}
```

---

## Relacionamentos

Nenhum relacionamento explícito foi identificado neste arquivo.  
A tabela `raw_customers` atua como **ponto de ingestão inicial** para dados de clientes e pode servir como fonte para processos de transformação em camadas posteriores do pipeline de dados.