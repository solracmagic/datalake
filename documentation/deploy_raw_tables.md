# deploy_raw_tables.sql

## Descrição Geral

Script de implantação responsável por criar todas as tabelas da camada RAW (camada de dados brutos) do sistema. Este script implementa uma estratégia de recriação completa das tabelas, removendo estruturas existentes antes de criar novas versões. A camada RAW armazena dados em seu formato original, sem transformações, utilizando tipos de dados flexíveis (principalmente `VARCHAR` e `TEXT`) para acomodar diferentes formatos de entrada.

## Tabelas Envolvidas

### Tabelas Criadas

- `raw_customers` — Armazena dados brutos de clientes
- `raw_products` — Armazena dados brutos de produtos
- `raw_orders` — Armazena dados brutos de pedidos
- `raw_order_items` — Armazena dados brutos de itens de pedidos

## Colunas

### Tabela `raw_customers`

| Coluna | Tipo | Propósito |
|--------|------|-----------|
| `customer_id` | VARCHAR(50) | Identificador único do cliente |
| `first_name` | VARCHAR(100) | Primeiro nome do cliente |
| `last_name` | VARCHAR(100) | Sobrenome do cliente |
| `email` | VARCHAR(255) | Endereço de e-mail do cliente |
| `registration_timestamp` | VARCHAR(255) | Data/hora de registro (formato string) |
| `address_raw` | TEXT | Endereço completo em formato bruto |
| `load_timestamp` | TIMESTAMP | Data/hora de carga dos dados (automático) |

### Tabela `raw_products`

| Coluna | Tipo | Propósito |
|--------|------|-----------|
| `product_id` | VARCHAR(50) | Identificador único do produto |
| `product_name` | VARCHAR(255) | Nome do produto |
| `category_raw` | VARCHAR(100) | Categoria do produto em formato bruto |
| `price_string` | VARCHAR(50) | Preço em formato string |
| `stock_quantity_string` | VARCHAR(50) | Quantidade em estoque em formato string |
| `load_timestamp` | TIMESTAMP | Data/hora de carga dos dados (automático) |

### Tabela `raw_orders`

| Coluna | Tipo | Propósito |
|--------|------|-----------|
| `order_id` | VARCHAR(50) | Identificador único do pedido |
| `customer_id` | VARCHAR(50) | Referência ao cliente (sem FK) |
| `order_date_string` | VARCHAR(50) | Data do pedido em formato string |
| `total_amount_string` | VARCHAR(50) | Valor total em formato string |
| `status` | VARCHAR(50) | Status do pedido |
| `load_timestamp` | TIMESTAMP | Data/hora de carga dos dados (automático) |

### Tabela `raw_order_items`

| Coluna | Tipo | Propósito |
|--------|------|-----------|
| `order_item_id` | VARCHAR(50) | Identificador único do item |
| `order_id` | VARCHAR(50) | Referência ao pedido (sem FK) |
| `product_id` | VARCHAR(50) | Referência ao produto (sem FK) |
| `quantity_string` | VARCHAR(50) | Quantidade em formato string |
| `unit_price_string` | VARCHAR(50) | Preço unitário em formato string |
| `load_timestamp` | TIMESTAMP | Data/hora de carga dos dados (automático) |

## Joins e Relacionamentos

**Não há joins neste script**, pois trata-se apenas de criação de estruturas.

### Relacionamentos Implícitos (sem constraints)

- `raw_orders.customer_id` → `raw_customers.customer_id`
- `raw_order_items.order_id` → `raw_orders.order_id`
- `raw_order_items.product_id` → `raw_products.product_id`

> **Nota:** Os relacionamentos não são implementados via Foreign Keys na camada RAW, permitindo maior flexibilidade na ingestão de dados.

## Filtros e Condições

Não há cláusulas `WHERE`, `HAVING` ou outras condições neste script.

## Transformações

### Valores Padrão

- Todas as tabelas incluem `load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP` para rastreamento automático do momento de inserção dos dados.

### Estratégia de Tipos de Dados

- **Dados numéricos** armazenados como `VARCHAR` (ex: `price_string`, `quantity_string`)
- **Datas** armazenadas como `VARCHAR` (ex: `order_date_string`, `registration_timestamp`)
- **Endereços complexos** armazenados como `TEXT` (ex: `address_raw`)

Esta abordagem permite:
- Aceitar dados em diversos formatos
- Evitar erros de conversão na ingestão
- Postergar validação e transformação para camadas superiores

## Parâmetros/Variáveis

Este script não utiliza parâmetros ou variáveis. É um script DDL estático.

## Fluxo de Dados

```
┌─────────────────────────────────────┐
│  1. DROP TABLE IF EXISTS (4 tabelas)│
│     - Remoção segura de estruturas  │
│       existentes                     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. CREATE TABLE raw_customers      │
│     - Estrutura base de clientes    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  3. CREATE TABLE raw_products       │
│     - Estrutura base de produtos    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  4. CREATE TABLE raw_orders         │
│     - Estrutura base de pedidos     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  5. CREATE TABLE raw_order_items    │
│     - Estrutura de itens de pedidos │
└─────────────────────────────────────┘
```

## Observações

### Características da Camada RAW

- **Sem constraints**: Não há Primary Keys, Foreign Keys ou constraints de validação
- **Tipos flexíveis**: Uso extensivo de `VARCHAR` e `TEXT` para máxima compatibilidade
- **Idempotência**: Script pode ser executado múltiplas vezes devido aos `DROP TABLE IF EXISTS`
- **Auditoria**: Coluna `load_timestamp` em todas as tabelas para rastreabilidade

### Possíveis Otimizações

1. **Adicionar índices** em colunas de ID após carga inicial para melhorar performance de queries
2. **Implementar particionamento** por `load_timestamp` se o volume de dados for muito grande
3. **Considerar compressão** de colunas `TEXT` dependendo do SGBD utilizado

### Dependências

- **Nenhuma dependência externa**: Script autossuficiente
- **Ordem de execução**: Importante manter a ordem de DROP (inversa à criação) para evitar problemas com dependências futuras

### Próximos Passos Sugeridos

1. Criar scripts de carga (ETL) para popular estas tabelas
2. Desenvolver camada STAGING com validações e transformações
3. Implementar camada TRUSTED com dados limpos e tipados corretamente
4. Adicionar procedures de validação de qualidade de dados

### Compatibilidade

Este script é compatível com a maioria dos SGBDs relacionais (PostgreSQL, MySQL, SQL Server, etc.), com possíveis ajustes menores na sintaxe de tipos de dados.