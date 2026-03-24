# raw_customers.sql

## Descrição

Este arquivo SQL define a estrutura da tabela `raw_customers`, que armazena dados brutos de clientes em sua forma original, sem transformações. Esta tabela faz parte da camada **raw** (bronze) de uma arquitetura de dados, servindo como ponto de entrada inicial para dados de clientes antes de qualquer processamento ou limpeza.

## Propósito

A tabela `raw_customers` é utilizada para:

- Armazenar informações básicas de clientes em formato bruto
- Preservar dados originais sem transformações
- Servir como fonte para processos de ETL/ELT posteriores
- Manter rastreabilidade através de timestamps de carga

## Estrutura da Tabela

### Colunas

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| **customer_id** | `VARCHAR(50)` | Identificador único do cliente |
| **first_name** | `VARCHAR(100)` | Primeiro nome do cliente |
| **last_name** | `VARCHAR(100)` | Sobrenome do cliente |
| **email** | `VARCHAR(255)` | Endereço de e-mail do cliente |
| **registration_timestamp** | `VARCHAR(255)` | Data/hora de registro do cliente armazenada como string (formato bruto) |
| **address_raw** | `TEXT` | Endereço completo do cliente em formato texto não estruturado |
| **load_timestamp** | `TIMESTAMP` | Data/hora de carregamento do registro na tabela (gerado automaticamente) |

## Características Técnicas

### Tipos de Dados

- **Strings flexíveis**: Uso de `VARCHAR` com tamanhos generosos para acomodar variações nos dados de origem
- **Timestamp como string**: O campo `registration_timestamp` é mantido como `VARCHAR` para preservar o formato original dos dados
- **Endereço não estruturado**: Campo `address_raw` como `TEXT` para armazenar endereços completos sem parsing
- **Auditoria automática**: Campo `load_timestamp` com valor padrão `CURRENT_TIMESTAMP` para rastreabilidade

### Observações Importantes

⚠️ **Nota sobre Chave Primária**: A tabela não possui definição explícita de `PRIMARY KEY` ou `UNIQUE CONSTRAINT`, o que pode permitir duplicatas.

⚠️ **Dados Brutos**: Esta é uma tabela de camada raw, portanto não possui validações, normalizações ou transformações aplicadas.

## Exemplo de Uso

### Criação da Tabela

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

### Inserção de Dados

```sql
INSERT INTO raw_customers (
    customer_id, 
    first_name, 
    last_name, 
    email, 
    registration_timestamp, 
    address_raw
)
VALUES (
    'CUST001',
    'João',
    'Silva',
    'joao.silva@email.com',
    '2024-01-15 10:30:00',
    'Rua das Flores, 123, Apto 45, São Paulo, SP, 01234-567'
);
```

### Consulta de Dados

```sql
-- Visualizar todos os clientes carregados
SELECT * FROM raw_customers;

-- Verificar registros carregados nas últimas 24 horas
SELECT * 
FROM raw_customers 
WHERE load_timestamp >= CURRENT_TIMESTAMP - INTERVAL '24 hours';
```

## Dependências

- **Sistema de Banco de Dados**: PostgreSQL, MySQL, ou qualquer SGBD compatível com SQL padrão
- **Permissões necessárias**: `CREATE TABLE`, `INSERT`, `SELECT`

## Integração com Pipeline de Dados

Esta tabela tipicamente faz parte de um fluxo de dados:

1. **Extração** → Dados brutos carregados em `raw_customers`
2. **Transformação** → Processamento para tabelas staging/silver
3. **Carregamento** → Dados limpos e estruturados em tabelas finais/gold

## Melhorias Sugeridas

- Adicionar `PRIMARY KEY` no campo `customer_id`
- Criar índices em campos frequentemente consultados (`email`, `customer_id`)
- Implementar particionamento por `load_timestamp` para grandes volumes
- Adicionar campo `source_system` para rastreabilidade da origem dos dados