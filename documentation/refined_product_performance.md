# refined_product_performance.sql

## Descrição Geral

Este script SQL cria uma tabela analítica consolidada que apresenta métricas de desempenho de vendas por produto. A tabela agrega informações de produtos e itens de pedidos para fornecer uma visão unificada do desempenho comercial de cada produto, incluindo volumes de vendas, receita gerada e informações de preço.

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `refined_product_performance` | Destino | Tabela criada para armazenar as métricas de desempenho de produtos |
| `trusted_products` | Origem | Tabela confiável contendo informações cadastrais dos produtos |
| `trusted_order_items` | Origem | Tabela confiável contendo detalhes dos itens vendidos em pedidos |

## Colunas

### Colunas de Origem

- **`p.product_id`** — Identificador único do produto
- **`p.product_name`** — Nome/descrição do produto
- **`p.category`** — Categoria à qual o produto pertence
- **`oi.quantity`** — Quantidade vendida em cada item de pedido
- **`oi.line_item_total`** — Valor total da linha do item (quantidade × preço)
- **`oi.unit_price`** — Preço unitário do produto no momento da venda
- **`p.load_timestamp`** — Timestamp de carga dos dados de produtos
- **`oi.load_timestamp`** — Timestamp de carga dos dados de itens de pedido

### Colunas Calculadas (Saída)

- **`product_id`** — Identificador do produto (chave primária)
- **`product_name`** — Nome do produto
- **`category`** — Categoria do produto
- **`total_quantity_sold`** — Quantidade total vendida do produto (agregação)
- **`total_product_revenue`** — Receita total gerada pelo produto (agregação)
- **`average_unit_price`** — Preço unitário médio do produto ao longo das vendas
- **`latest_product_load_timestamp`** — Data/hora da última atualização dos dados do produto
- **`latest_order_item_load_timestamp`** — Data/hora da última atualização dos itens de pedido relacionados

## Joins e Relacionamentos

### JOIN Principal

```sql
trusted_products p
JOIN trusted_order_items oi ON p.product_id = oi.product_id
```

- **Tipo:** INNER JOIN
- **Condição:** Relacionamento 1:N entre produtos e itens de pedido
- **Chave:** `product_id`
- **Comportamento:** Apenas produtos que possuem vendas registradas serão incluídos na tabela final

## Filtros e Condições

Este script **não possui cláusulas WHERE ou HAVING**. Todos os produtos com vendas registradas são incluídos na agregação.

## Transformações

### Funções de Agregação

| Função | Coluna | Propósito |
|--------|--------|-----------|
| `SUM()` | `oi.quantity` | Totaliza a quantidade vendida de cada produto |
| `SUM()` | `oi.line_item_total` | Calcula a receita total gerada por produto |
| `AVG()` | `oi.unit_price` | Calcula o preço médio de venda do produto |
| `MAX()` | `p.load_timestamp` | Identifica a carga mais recente dos dados de produto |
| `MAX()` | `oi.load_timestamp` | Identifica a carga mais recente dos itens de pedido |

### Agrupamento

```sql
GROUP BY p.product_id, p.product_name, p.category
```

Os dados são agrupados por produto (identificador, nome e categoria), consolidando todas as vendas de cada produto em uma única linha.

## Parâmetros/Variáveis

Este script **não utiliza parâmetros ou variáveis**. É uma operação de criação de tabela estática baseada nos dados existentes nas tabelas trusted.

## Fluxo de Dados

```
┌─────────────────────┐
│ trusted_products    │
│ (Dados Cadastrais)  │
└──────────┬──────────┘
           │
           │ JOIN (product_id)
           │
           ▼
┌─────────────────────┐
│ trusted_order_items │
│ (Dados de Vendas)   │
└──────────┬──────────┘
           │
           │ Agregação (SUM, AVG, MAX)
           │ Agrupamento (product_id, product_name, category)
           │
           ▼
┌──────────────────────────┐
│ refined_product_         │
│ performance              │
│ (Métricas Consolidadas)  │
└──────────────────────────┘
```

### Etapas do Processamento

1. **Leitura:** Carrega dados de `trusted_products` e `trusted_order_items`
2. **Relacionamento:** Realiza JOIN entre produtos e itens vendidos
3. **Agregação:** Calcula métricas de vendas por produto
4. **Persistência:** Cria e popula a tabela `refined_product_performance`

## Observações

### Pontos de Atenção

- ⚠️ **Produtos sem vendas não aparecem:** O uso de INNER JOIN exclui produtos que nunca foram vendidos
- ⚠️ **Recriação da tabela:** O comando `CREATE TABLE` pode falhar se a tabela já existir
- 📊 **Camada Refined:** Esta tabela pertence à camada refined/analytics, adequada para consumo por ferramentas de BI

### Possíveis Otimizações

1. **Adicionar índices:**
   ```sql
   CREATE INDEX idx_product_id ON refined_product_performance(product_id);
   CREATE INDEX idx_category ON refined_product_performance(category);
   ```

2. **Usar CREATE OR REPLACE ou DROP/CREATE:**
   ```sql
   DROP TABLE IF EXISTS refined_product_performance;
   CREATE TABLE refined_product_performance AS ...
   ```

3. **Considerar LEFT JOIN:** Se for necessário incluir produtos sem vendas:
   ```sql
   FROM trusted_products p
   LEFT JOIN trusted_order_items oi ON p.product_id = oi.product_id
   ```

### Dependências

- **Upstream:** `trusted_products`, `trusted_order_items`
- **Downstream:** Dashboards de análise de produtos, relatórios de vendas, análises de categoria

### Casos de Uso

- Análise de produtos mais vendidos
- Identificação de produtos de maior receita
- Análise de desempenho por categoria
- Monitoramento de variação de preços
- Relatórios gerenciais de vendas