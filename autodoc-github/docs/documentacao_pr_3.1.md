# Tabela: `raw_customers`

Arquivo de origem: `autodoc-github/raw/tables/raw_customers.sql`

A tabela `raw_customers` pertence à camada **raw** do pipeline de dados e armazena registros brutos de clientes conforme ingeridos da fonte de origem. Nesta camada, os dados são mantidos com mínima transformação, preservando formatos originais, como timestamps representados em texto.

## Estrutura da Tabela

```sql
CREATE TABLE raw_customers (
    customer_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    registration_timestamp VARCHAR(255), -- Timestamp como string na camada raw
    address_raw TEXT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Dicionário de Dados

| Campo                   | Tipo de Dado     | Restrições / Padrões            | Descrição |
|-------------------------|------------------|---------------------------------|-----------|
| customer_id             | VARCHAR(50)      | —                               | Identificador único do cliente proveniente do sistema de origem. |
| first_name              | VARCHAR(100)     | —                               | Primeiro nome do cliente. |
| last_name               | VARCHAR(100)     | —                               | Sobrenome do cliente. |
| email                   | VARCHAR(255)     | —                               | Endereço de e-mail do cliente. |
| registration_timestamp  | VARCHAR(255)     | —                               | Data e hora de registro do cliente no sistema de origem, armazenada como string na camada raw. |
| address_raw             | TEXT             | —                               | Endereço completo do cliente em formato bruto, sem normalização. |
| load_timestamp          | TIMESTAMP        | DEFAULT CURRENT_TIMESTAMP       | Data e hora em que o registro foi carregado na tabela raw. |

## Observações Técnicas

- A coluna `registration_timestamp` é armazenada como **string**, indicando que o dado ainda não passou por normalização ou tipagem adequada nesta camada.
- O campo `address_raw` mantém o endereço em formato livre, podendo conter múltiplos componentes em um único texto.
- O campo `load_timestamp` registra automaticamente o momento da ingestão do dado no banco.

## Relacionamentos entre Entidades

No arquivo analisado **não há definição explícita de chaves primárias ou estrangeiras**, portanto não é possível identificar relacionamentos formais com outras tabelas a partir deste artefato isolado.

Entretanto:

- `customer_id` atua potencialmente como **identificador lógico do cliente**, podendo ser utilizado como chave de relacionamento em camadas posteriores do pipeline (por exemplo: staging, refined ou analytics).