# raw_orders.sql

## Descrição Geral

Este script SQL define a estrutura da tabela `raw_orders` na camada **raw** (bronze) de um data warehouse. A tabela é projetada para armazenar dados brutos de pedidos sem transformações, mantendo formatos originais como strings para campos que posteriormente serão convertidos em tipos de dados apropriados nas camadas subsequentes (staging/silver ou analytics/gold).

## Tipo de Operação

**DDL (Data Definition Language)** - Criação de tabela

## Estrutura da Tabela

### `raw_orders`

Tabela de armazenamento de dados brutos de pedidos do sistema fonte.

## Colunas

| Coluna | Tipo de Dado | Descrição | Observações |
|--------|--------------|-----------|-------------|
| `order_id` | `VARCHAR(50)` | Identificador único do pedido | Chave primária natural (não declarada) |
| `customer_id` | `VARCHAR(50)` | Identificador do cliente que realizou o pedido | Chave estrangeira para tabela de clientes |
| `order_date_string` | `VARCHAR(50)` | Data do pedido em formato string | Armazenada como texto para preservar formato original |
| `total_amount_string` | `VARCHAR(50)` | Valor total do pedido em formato string | Armazenada como texto para preservar formato original |
| `status` | `VARCHAR(100)` | Status atual do pedido | Ex: "pending", "completed", "cancelled" |
| `load_timestamp` | `TIMESTAMP` | Data e hora de carga do registro | Valor padrão: timestamp atual da inserção |

## Tabelas Envolvidas

- **`raw_orders`** (tabela sendo criada)

## Joins e Relacionamentos

Não aplicável - este é um script de criação de tabela (DDL).

**Relacionamentos esperados:**
- `customer_id` → Relaciona-se com tabela de clientes (raw_customers ou similar)
- Esta tabela serve como fonte para tabelas transformadas em camadas superiores

## Filtros e Condições

Não aplicável - script DDL sem queries de seleção.

## Transformações

Não aplicável neste script. As transformações ocorrerão em etapas posteriores do pipeline:
- Conversão de `order_date_string` para tipo `DATE` ou `TIMESTAMP`
- Conversão de `total_amount_string` para tipo `DECIMAL` ou `NUMERIC`
- Validação e limpeza de dados

## Parâmetros/Variáveis

Não há parâmetros ou variáveis neste script.

## Fluxo de Dados

```
Sistema Fonte (ERP/CRM)
         ↓
    [Extração]
         ↓
   raw_orders (camada raw/bronze)
         ↓
   [Transformação ETL]
         ↓
Camada Staging/Silver → Camada Analytics/Gold
```

### Características da Camada Raw:

1. **Preservação de dados originais**: Campos como datas e valores monetários são mantidos como strings
2. **Auditoria**: Campo `load_timestamp` permite rastreabilidade
3. **Sem transformações**: Dados armazenados exatamente como recebidos da fonte

## Observações

### ⚠️ Pontos de Atenção

1. **Ausência de chave primária**: A tabela não declara `order_id` como `PRIMARY KEY`, o que pode permitir duplicatas
2. **Ausência de constraints**: Não há validações de `NOT NULL` ou `UNIQUE`
3. **Tipos genéricos**: Uso de `VARCHAR` para todos os campos textuais pode consumir mais espaço

### ������ Sugestões de Melhoria

```sql
-- Versão otimizada sugerida:
CREATE TABLE raw_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_date_string VARCHAR(50),
    total_amount_string VARCHAR(50),
    status VARCHAR(100),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    source_system VARCHAR(50), -- Identificar sistema de origem
    batch_id VARCHAR(100) -- Rastrear lote de carga
);

-- Índices recomendados:
CREATE INDEX idx_raw_orders_customer ON raw_orders(customer_id);
CREATE INDEX idx_raw_orders_load_ts ON raw_orders(load_timestamp);
```

### ������ Dependências

- **Upstream**: Sistema fonte de pedidos (ERP, e-commerce, etc.)
- **Downstream**: Tabelas de staging/transformação (ex: `stg_orders`, `dim_orders`)

### ������ Padrão de Arquitetura

Esta tabela segue o padrão **Medallion Architecture**:
- **Bronze/Raw Layer**: Armazenamento de dados brutos sem transformação
- Preparação para processamento nas camadas Silver (staging) e Gold (analytics)

### ������ Casos de Uso

- Auditoria e rastreamento de dados originais
- Reprocessamento de dados em caso de falhas
- Análise de qualidade de dados na origem
- Histórico completo de cargas