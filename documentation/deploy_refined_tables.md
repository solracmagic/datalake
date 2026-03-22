# deploy_refined_tables.sql

## Descrição Geral

Script de implantação responsável por criar todas as tabelas da camada **REFINED** do data warehouse. Este script executa a transformação de dados da camada TRUSTED para a camada REFINED, gerando tabelas analíticas agregadas e pré-calculadas para facilitar consultas de negócio e relatórios. O script é idempotente, removendo tabelas existentes antes de recriá-las.

## Tabelas Envolvidas

### Tabelas de Origem (Camada TRUSTED)
- `trusted_customers` — Dados consolidados de clientes
- `trusted_orders` — Dados consolidados de pedidos
- `trusted_products` — Dados consolidados de produtos
- `trusted_order_items` — Dados consolidados de itens de pedidos

### Tabelas de Destino (Camada REFINED)
- `refined_daily_sales` — Vendas agregadas por dia
- `refined_customer_lifetime_value` — Valor vitalício e métricas por cliente
- `refined_product_performance` — Performance e métricas por produto
- `refined_top_customers` — Top 10 clientes por valor gasto

## Colunas

### refined_daily_sales
- `order_date` — Data do pedido (chave de agrupamento)
- `number_of_orders` — Quantidade de pedidos únicos no dia
- `total_daily_sales` — Soma total de vendas do dia
- `latest_load_timestamp` — Timestamp da carga mais recente

### refined_customer_lifetime_value
- `customer_id` — Identificador único do cliente
- `first_name` — Primeiro nome do cliente
- `last_name` — Sobrenome do cliente
- `email` — Email do cliente
- `total_spent` — Valor total gasto pelo cliente
- `total_orders` — Quantidade total de pedidos realizados
- `first_order_date` — Data do primeiro pedido
- `last_order_date` — Data do último pedido
- `latest_customer_load_timestamp` — Timestamp da última carga de dados do cliente
- `latest_order_load_timestamp` — Timestamp da última carga de dados de pedidos

### refined_product_performance
- `product_id` — Identificador único do produto
- `product_name` — Nome do produto
- `category` — Categoria do produto
- `total_quantity_sold` — Quantidade total vendida
- `total_product_revenue` — Receita total gerada pelo produto
- `average_unit_price` — Preço médio unitário
- `latest_product_load_timestamp` — Timestamp da última carga de dados do produto
- `latest_order_item_load_timestamp` — Timestamp da última carga de itens de pedido

### refined_top_customers
- `customer_id` — Identificador único do cliente
- `first_name` — Primeiro nome do cliente
- `last_name` — Sobrenome do cliente
- `email` — Email do cliente
- `total_spent` — Valor total gasto
- `total_orders` — Quantidade total de pedidos

## Joins e Relacionamentos

### refined_customer_lifetime_value
```sql
trusted_customers c JOIN trusted_orders o 
ON c.customer_id = o.customer_id
```
**Tipo:** INNER JOIN  
**Propósito:** Relacionar clientes com seus pedidos para calcular métricas de valor vitalício

### refined_product_performance
```sql
trusted_products p JOIN trusted_order_items oi 
ON p.product_id = oi.product_id
```
**Tipo:** INNER JOIN  
**Propósito:** Relacionar produtos com itens de pedidos para calcular métricas de performance de vendas

## Filtros e Condições

### refined_top_customers
- **ORDER BY:** `total_spent DESC` — Ordenação decrescente por valor total gasto
- **LIMIT:** `10` — Restrição aos 10 principais clientes

## Transformações

### Funções de Agregação

#### refined_daily_sales
- `COUNT(DISTINCT order_id)` — Contagem de pedidos únicos
- `SUM(total_amount)` — Soma de valores de vendas
- `MAX(load_timestamp)` — Timestamp mais recente
- **Agrupamento:** `order_date`

#### refined_customer_lifetime_value
- `SUM(o.total_amount)` — Total gasto por cliente
- `COUNT(DISTINCT o.order_id)` — Total de pedidos por cliente
- `MIN(o.order_date)` — Data do primeiro pedido
- `MAX(o.order_date)` — Data do último pedido
- `MAX(c.load_timestamp)` e `MAX(o.load_timestamp)` — Timestamps de auditoria
- **Agrupamento:** `customer_id, first_name, last_name, email`

#### refined_product_performance
- `SUM(oi.quantity)` — Quantidade total vendida
- `SUM(oi.line_item_total)` — Receita total do produto
- `AVG(oi.unit_price)` — Preço médio unitário
- `MAX()` — Timestamps de auditoria
- **Agrupamento:** `product_id, product_name, category`

### Subconsultas
A tabela `refined_top_customers` utiliza dados da tabela `refined_customer_lifetime_value` como fonte, criando uma dependência entre as tabelas.

## Parâmetros/Variáveis

Este script não utiliza parâmetros ou variáveis. É um script de execução direta.

## Fluxo de Dados

```
┌─────────────────────┐
│  Camada TRUSTED     │
├─────────────────────┤
│ trusted_customers   │
│ trusted_orders      │
│ trusted_products    │
│ trusted_order_items │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────┐
    │ Agregações & │
    │ Joins        │
    └──────┬───────┘
           │
           ▼
┌─────────────────────────────┐
│    Camada REFINED           │
├─────────────────────────────┤
│ refined_daily_sales         │
│ refined_customer_lifetime_  │
│   value                     │
│ refined_product_performance │
│ refined_top_customers       │
└─────────────────────────────┘
```

### Ordem de Execução
1. **DROP:** Remoção de tabelas existentes (ordem reversa de dependência)
2. **CREATE refined_daily_sales:** Agregação de vendas diárias
3. **CREATE refined_customer_lifetime_value:** Cálculo de métricas de clientes
4. **CREATE refined_product_performance:** Cálculo de métricas de produtos
5. **CREATE refined_top_customers:** Seleção dos top 10 clientes (depende de refined_customer_lifetime_value)

## Observações

### Dependências
- **Ordem de Execução:** A tabela `refined_top_customers` depende de `refined_customer_lifetime_value` estar criada primeiro
- **Camada Anterior:** Todas as tabelas `trusted_*` devem existir e estar populadas antes da execução

### Idempotência
- O script utiliza `DROP TABLE IF EXISTS` para permitir re-execuções sem erros
- A ordem de DROP é reversa à ordem de criação para respeitar dependências

### Possíveis Otimizações
- **Índices:** Considerar criação de índices nas colunas de chave (`customer_id`, `product_id`, `order_date`)
- **Particionamento:** `refined_daily_sales` poderia se beneficiar de particionamento por data
- **Materialização Incremental:** Implementar lógica incremental ao invés de recriação completa
- **Views Materializadas:** Considerar uso de materialized views com refresh automático

### Considerações de Performance
- Todas as tabelas são criadas com `CREATE TABLE AS SELECT` (CTAS), que pode ser custoso em grandes volumes
- Não há índices criados automaticamente, o que pode impactar consultas subsequentes
- Agregações múltiplas podem ser otimizadas com índices nas tabelas TRUSTED

### Auditoria
- Todas as tabelas mantêm campos `latest_*_load_timestamp` para rastreabilidade
- Permite identificar a atualidade dos dados em cada tabela refinada

### Arquitetura de Dados
Este script faz parte de uma arquitetura de data warehouse em camadas (Medallion Architecture):
- **TRUSTED:** Dados limpos e validados
- **REFINED:** Dados agregados e otimizados para análise (camada atual)