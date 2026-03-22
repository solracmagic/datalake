# deploy_refined_tables.sql

## Descrição Geral

Script de deployment responsável por criar todas as tabelas da camada **REFINED** do data warehouse. Este script implementa transformações analíticas sobre os dados da camada TRUSTED, gerando visões agregadas e métricas de negócio prontas para consumo em relatórios e dashboards. O script é idempotente, removendo tabelas existentes antes da recriação.

## Tabelas Envolvidas

### Tabelas de Origem (Camada TRUSTED)
- `trusted_orders` — Pedidos validados e confiáveis
- `trusted_customers` — Clientes validados
- `trusted_products` — Produtos validados
- `trusted_order_items` — Itens de pedidos validados

### Tabelas de Destino (Camada REFINED)
- `refined_daily_sales` — Vendas agregadas por dia
- `refined_customer_lifetime_value` — Valor vitalício e métricas por cliente
- `refined_product_performance` — Performance e métricas por produto
- `refined_top_customers` — Top 10 clientes por valor gasto

## Colunas

### refined_daily_sales
- `order_date` — Data do pedido (chave de agregação)
- `number_of_orders` — Quantidade de pedidos únicos no dia
- `total_daily_sales` — Soma total de vendas do dia
- `latest_load_timestamp` — Timestamp da carga mais recente

### refined_customer_lifetime_value
- `customer_id` — Identificador único do cliente
- `first_name`, `last_name`, `email` — Dados cadastrais do cliente
- `total_spent` — Valor total gasto pelo cliente (LTV)
- `total_orders` — Quantidade total de pedidos realizados
- `first_order_date` — Data do primeiro pedido
- `last_order_date` — Data do último pedido
- `latest_customer_load_timestamp` — Timestamp da última carga de dados do cliente
- `latest_order_load_timestamp` — Timestamp da última carga de pedidos

### refined_product_performance
- `product_id` — Identificador único do produto
- `product_name` — Nome do produto
- `category` — Categoria do produto
- `total_quantity_sold` — Quantidade total vendida
- `total_product_revenue` — Receita total gerada pelo produto
- `average_unit_price` — Preço médio unitário
- `latest_product_load_timestamp` — Timestamp da última carga de produtos
- `latest_order_item_load_timestamp` — Timestamp da última carga de itens

### refined_top_customers
- `customer_id` — Identificador único do cliente
- `first_name`, `last_name`, `email` — Dados cadastrais
- `total_spent` — Valor total gasto
- `total_orders` — Quantidade de pedidos

## Joins e Relacionamentos

### refined_customer_lifetime_value
```sql
trusted_customers c JOIN trusted_orders o 
ON c.customer_id = o.customer_id
```
**Tipo:** INNER JOIN  
**Propósito:** Relacionar clientes com seus pedidos para calcular métricas de lifetime value

### refined_product_performance
```sql
trusted_products p JOIN trusted_order_items oi 
ON p.product_id = oi.product_id
```
**Tipo:** INNER JOIN  
**Propósito:** Relacionar produtos com itens vendidos para calcular performance de vendas

## Filtros e Condições

### refined_top_customers
- **ORDER BY:** `total_spent DESC` — Ordenação decrescente por valor gasto
- **LIMIT:** `10` — Restrição aos 10 principais clientes

## Transformações

### Funções de Agregação

#### refined_daily_sales
- `COUNT(DISTINCT order_id)` — Contagem de pedidos únicos
- `SUM(total_amount)` — Totalização de vendas
- `MAX(load_timestamp)` — Timestamp mais recente
- **GROUP BY:** `order_date`

#### refined_customer_lifetime_value
- `SUM(o.total_amount)` — Cálculo do LTV (Lifetime Value)
- `COUNT(DISTINCT o.order_id)` — Total de pedidos por cliente
- `MIN(o.order_date)` — Primeira compra
- `MAX(o.order_date)` — Última compra
- `MAX()` — Timestamps de auditoria
- **GROUP BY:** `customer_id, first_name, last_name, email`

#### refined_product_performance
- `SUM(oi.quantity)` — Volume total vendido
- `SUM(oi.line_item_total)` — Receita total
- `AVG(oi.unit_price)` — Preço médio
- `MAX()` — Timestamps de auditoria
- **GROUP BY:** `product_id, product_name, category`

### Subconsultas
A tabela `refined_top_customers` utiliza dados da tabela `refined_customer_lifetime_value` como fonte, criando uma dependência entre as tabelas.

## Parâmetros/Variáveis

Este script não utiliza parâmetros ou variáveis. Todas as transformações são baseadas em valores fixos e agregações diretas.

## Fluxo de Dados

```
┌─────────────────────┐
│  Camada TRUSTED     │
├─────────────────────┤
│ trusted_orders      │───┐
│ trusted_customers   │───┼──► Agregações e Joins
│ trusted_products    │───┤
│ trusted_order_items │───┘
└─────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│     Camada REFINED              │
├─────────────────────────────────┤
│ refined_daily_sales             │ ◄── Vendas diárias
│ refined_customer_lifetime_value │ ◄── Métricas de clientes
│ refined_product_performance     │ ◄── Performance de produtos
│ refined_top_customers           │ ◄── Top 10 clientes
└─────────────────────────────────┘
          │
          ▼
    Consumo (BI/Analytics)
```

### Ordem de Execução
1. **DROP:** Remoção de tabelas existentes (ordem reversa de dependência)
2. **CREATE:** `refined_daily_sales` (sem dependências)
3. **CREATE:** `refined_customer_lifetime_value` (sem dependências)
4. **CREATE:** `refined_product_performance` (sem dependências)
5. **CREATE:** `refined_top_customers` (depende de `refined_customer_lifetime_value`)

## Observações

### Pontos de Atenção
- ⚠️ **Idempotência:** O script utiliza `DROP TABLE IF EXISTS` para permitir re-execução segura
- ⚠️ **Dependência:** `refined_top_customers` depende de `refined_customer_lifetime_value` estar criada primeiro
- ⚠️ **INNER JOIN:** Apenas registros com correspondência são incluídos (clientes sem pedidos ou produtos sem vendas são excluídos)

### Possíveis Otimizações
- ������ Adicionar índices nas colunas de agregação (`order_date`, `customer_id`, `product_id`)
- ������ Implementar particionamento por data em `refined_daily_sales`
- ������ Considerar materialização incremental ao invés de recriação completa
- ������ Adicionar validações de qualidade de dados (ex: verificar valores nulos)
- ������ Implementar logging de execução e métricas de performance

### Boas Práticas Implementadas
- ✅ Nomenclatura consistente com prefixo `refined_`
- ✅ Preservação de timestamps de auditoria (`load_timestamp`)
- ✅ Uso de `DISTINCT` para evitar duplicações
- ✅ Documentação inline com comentários

### Dependências
- **Pré-requisito:** Todas as tabelas da camada TRUSTED devem estar populadas
- **Ordem de execução:** Este script deve ser executado após a carga da camada TRUSTED
- **Downstream:** Tabelas REFINED são consumidas por ferramentas de BI e relatórios analíticos

### Métricas de Negócio Geradas
- ������ **Vendas Diárias:** Acompanhamento de performance de vendas
- ������ **Customer Lifetime Value:** Identificação de clientes mais valiosos
- ������ **Performance de Produtos:** Análise de produtos mais rentáveis
- ������ **Top Customers:** Segmentação para programas de fidelidade