# raw_orders.sql

## Descrição Geral

Este arquivo SQL define a estrutura da tabela `raw_orders` na camada **raw** (bronze) de um data warehouse. A tabela é projetada para armazenar dados brutos de pedidos sem transformações, mantendo formatos originais como strings para posterior processamento nas camadas superiores (staging/silver ou analytics/gold).

## Tipo de Operação

**DDL (Data Definition Language)** - Criação de tabela

## Estrutura da Tabela

### `raw_orders`

Tabela de armazenamento de dados brutos de pedidos do sistema transacional.

## Colunas

| Coluna | Tipo de Dado | Descrição | Observações |
|--------|--------------|-----------|-------------|
| `order_id` | VARCHAR(50) | Identificador único do pedido | Chave primária lógica |
| `customer_id` | VARCHAR(50) | Identificador do cliente que realizou o pedido | Chave estrangeira lógica para tabela de clientes |
| `order_date_string` | VARCHAR(50) | Data do pedido em formato string | Mantido como string na camada raw para preservar formato original |
| `total_amount_string` | VARCHAR(50) | Valor total do pedido em formato string | Mantido como string na camada raw para preservar formato original |
| `status` | VARCHAR(100) | Status atual do pedido | Ex: "pending", "completed", "cancelled" |
| `load_timestamp` | TIMESTAMP | Data e hora de carga do registro | Valor padrão: timestamp atual da inserção |

## Características de Design

### Camada Raw (Bronze)

- **Preservação de Dados Originais**: Campos como `order_date_string` e `total_amount_string` são mantidos como VARCHAR para preservar o formato exato dos dados de origem
- **Auditoria**: Coluna `load_timestamp` com valor padrão automático para rastreabilidade
- **Sem Constraints**: Não há definição explícita de chaves primárias ou estrangeiras, permitindo flexibilidade na ingestão

### Padrões Aplicados

- **Nomenclatura**: Sufixo `_string` indica campos que serão convertidos em camadas posteriores
- **Rastreabilidade**: `load_timestamp` permite identificar quando cada registro foi carregado
- **Flexibilidade**: Tipos VARCHAR amplos permitem receber diversos formatos sem rejeição

## Fluxo de Dados

```
Sistema Transacional → raw_orders (camada raw) → staging_orders (camada staging) → dim_orders/fact_orders (camada analytics)
```

1. **Ingestão**: Dados são extraídos do sistema fonte e carregados sem transformação
2. **Armazenamento**: Registros mantêm formato original (strings, sem validação)
3. **Timestamp**: Cada carga recebe automaticamente o timestamp de inserção
4. **Processamento Futuro**: Dados serão transformados em camadas subsequentes (conversão de tipos, validações, limpeza)

## Relacionamentos Lógicos

- **`customer_id`** → Relaciona-se com tabela de clientes (raw_customers ou similar)
- **`order_id`** → Pode relacionar-se com tabela de itens de pedido (raw_order_items)

## Observações

### Boas Práticas Implementadas

✅ Separação clara de camadas (raw/bronze)  
✅ Auditoria com `load_timestamp`  
✅ Nomenclatura descritiva indicando tipo de dado original  
✅ Preservação de dados brutos para troubleshooting

### Melhorias Sugeridas

⚠️ **Adicionar Primary Key**: Considerar adicionar constraint de PK em `order_id`
```sql
ALTER TABLE raw_orders ADD PRIMARY KEY (order_id);
```

⚠️ **Adicionar Índices**: Para melhor performance em consultas
```sql
CREATE INDEX idx_customer_id ON raw_orders(customer_id);
CREATE INDEX idx_load_timestamp ON raw_orders(load_timestamp);
```

⚠️ **Adicionar Coluna de Origem**: Para rastreabilidade de fonte de dados
```sql
ALTER TABLE raw_orders ADD COLUMN source_system VARCHAR(100);
```

⚠️ **Particionamento**: Considerar particionamento por `load_timestamp` para grandes volumes
```sql
-- Exemplo para PostgreSQL
CREATE TABLE raw_orders (
    ...
) PARTITION BY RANGE (load_timestamp);
```

### Dependências

- **Upstream**: Sistema transacional de origem (ERP, e-commerce, etc.)
- **Downstream**: Tabelas de staging/silver que consumirão estes dados brutos

### Considerações de Qualidade de Dados

- Dados podem conter inconsistências (formato de data variável, valores nulos, etc.)
- Validações e limpezas devem ser aplicadas nas camadas subsequentes
- `load_timestamp` permite identificar lotes de carga para troubleshooting

---

**Camada**: Raw/Bronze  
**Categoria**: Transacional  
**Domínio**: Vendas/Pedidos  
**Última Atualização da Documentação**: 2025