# Documentação Técnica – Tabela `raw_customers`

Arquivo analisado: `autodoc-github/raw/tables/raw_customers.sql`

## Visão Geral

A tabela `raw_customers` pertence à camada **raw** do pipeline de dados. Essa camada normalmente armazena dados conforme recebidos da fonte original, com transformações mínimas ou inexistentes.

Nesta tabela são registrados dados brutos de clientes, incluindo identificação, informações de contato e metadados de ingestão.

Observação: o campo `registration_timestamp` é armazenado como **string (`VARCHAR`)**, indicando que a normalização do tipo de dado provavelmente ocorre em camadas posteriores do pipeline (ex.: staging ou trusted).

---

# Estrutura da Tabela

**Tabela:** `raw_customers`

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
| `customer_id` | VARCHAR(50) | Nenhuma definida | Identificador único do cliente proveniente da fonte de dados original. |
| `first_name` | VARCHAR(100) | Nenhuma definida | Primeiro nome do cliente. |
| `last_name` | VARCHAR(100) | Nenhuma definida | Sobrenome do cliente. |
| `email` | VARCHAR(255) | Nenhuma definida | Endereço de e-mail associado ao cliente. |
| `registration_timestamp` | VARCHAR(255) | Nenhuma definida | Data e hora de registro do cliente armazenadas como string na camada raw. |
| `address_raw` | TEXT | Nenhuma definida | Endereço completo do cliente armazenado em formato textual bruto, sem estruturação. |
| `load_timestamp` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data e hora em que o registro foi carregado no ambiente de dados. |

---

# Metadados de Ingestão

A tabela contém um campo dedicado ao controle de ingestão:

| Campo | Função |
|---|---|
| `load_timestamp` | Indica o momento em que o registro foi carregado no banco de dados, permitindo auditoria e rastreabilidade do processo de ingestão. |

---

# Relacionamentos entre Entidades

No arquivo analisado **não há definição explícita de chaves primárias ou estrangeiras**.

Portanto:

- Não existem relacionamentos formais definidos nesta estrutura.
- O campo `customer_id` é o candidato natural a chave de identificação lógica da entidade cliente.

### Possível relacionamento lógico

Embora não esteja definido no arquivo, o campo abaixo pode ser utilizado para relacionamentos em outras tabelas:

| Campo | Possível uso |
|---|---|
| `customer_id` | Referência para tabelas de pedidos, transações, eventos ou dimensões de clientes em camadas posteriores do pipeline. |

---

# Exemplo de Estrutura de Registro

Exemplo ilustrativo de como um registro pode ser armazenado nesta tabela:

```json
{
  "customer_id": "CUST_10231",
  "first_name": "Maria",
  "last_name": "Silva",
  "email": "maria.silva@email.com",
  "registration_timestamp": "2024-02-10T14:22:31Z",
  "address_raw": "Rua das Flores, 123 - São Paulo - SP - Brasil",
  "load_timestamp": "2026-03-19 00:30:15"
}
```

---

# Observações Estruturais

- A tabela não define **PRIMARY KEY**.
- Não existem **FOREIGN KEYS**.
- O campo de data de registro (`registration_timestamp`) está armazenado como **string**, indicando que a padronização para tipo `TIMESTAMP` pode ocorrer em etapas posteriores do processamento de dados.
- O campo `address_raw` armazena o endereço em formato textual único, sem separação em atributos estruturados (ex.: cidade, estado, CEP).

---

Se desejar, posso também gerar automaticamente:
- um **README completo do schema `raw`**, ou  
- um **diagrama de relacionamento entre todas as tabelas do repositório** conforme você enviar mais arquivos SQL.