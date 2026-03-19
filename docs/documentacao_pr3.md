# Documentação Técnica — Tabela `raw_customers`

**Arquivo de Origem:** `autodoc-github/raw/tables/raw_customers.sql`  
**Tipo:** Tabela  
**Camada:** Raw  

## Descrição Geral

A tabela `raw_customers` armazena dados brutos de clientes ingeridos na camada **raw** do pipeline de dados. Nesta camada, os dados são mantidos o mais próximo possível do formato original da fonte, sem normalização ou transformações significativas.

Alguns campos, como `registration_timestamp`, permanecem armazenados como **string**, refletindo exatamente o formato recebido da origem.

---

# Estrutura da Tabela

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

# Dicionário de Dados

| Campo | Tipo de Dado | Restrições | Descrição |
|---|---|---|---|
| customer_id | VARCHAR(50) | — | Identificador único do cliente conforme fornecido pela fonte de dados. |
| first_name | VARCHAR(100) | — | Primeiro nome do cliente. |
| last_name | VARCHAR(100) | — | Sobrenome do cliente. |
| email | VARCHAR(255) | — | Endereço de e-mail associado ao cliente. |
| registration_timestamp | VARCHAR(255) | — | Data e hora de registro do cliente na origem. Armazenado como string na camada raw. |
| address_raw | TEXT | — | Endereço completo do cliente no formato original recebido da fonte. |
| load_timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data e hora em que o registro foi carregado na tabela. |

---

# Características da Camada Raw

- Dados preservam o **formato original da fonte**.
- Estruturas podem conter:
  - Campos textuais não normalizados.
  - Tipos de dados genéricos (ex.: datas armazenadas como `VARCHAR`).
- A coluna `load_timestamp` registra o momento de ingestão do dado no ambiente.

---

# Relacionamentos

Nenhum **PRIMARY KEY**, **FOREIGN KEY** ou relacionamento explícito foi definido neste arquivo.

No entanto, o campo abaixo pode servir como identificador lógico em camadas posteriores:

| Campo | Possível Uso |
|---|---|
| customer_id | Identificação do cliente em processos de transformação ou integração com outras tabelas. |

---

# Fluxo de Dados (Potencial)

Embora não haja definição explícita neste arquivo, a tabela segue um padrão comum de pipelines de dados:

```
Fonte Externa
      │
      ▼
raw_customers  (camada raw - dados brutos)
      │
      ▼
camadas de transformação (staging / curated / marts)
```

---

# Exemplo de Registro

Exemplo ilustrativo de como um registro pode aparecer na tabela:

```json
{
  "customer_id": "CUST_10293",
  "first_name": "Ana",
  "last_name": "Silva",
  "email": "ana.silva@email.com",
  "registration_timestamp": "2024-07-18T14:32:11Z",
  "address_raw": "Rua das Flores, 123 - São Paulo - SP - Brasil",
  "load_timestamp": "2026-03-19 00:10:05"
}
```