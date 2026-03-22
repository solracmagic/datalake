# refined_daily_sales.sql

## Descrição Geral

Este script SQL cria uma tabela agregada de vendas diárias (`refined_daily_sales`) a partir dos dados de pedidos confiáveis. O objetivo é consolidar informações de vendas por data, fornecendo métricas essenciais para análise de desempenho comercial diário.

## Tabelas Envolvidas

### Tabela de Origem
- `trusted_orders` — Tabela fonte contendo os dados de pedidos validados e confiáveis

### Tabela de Destino
- `refined_daily_sales` — Tabela agregada criada por este script, armazenando métricas diárias de vendas

## Colunas

### Colunas de Entrada (trusted_orders)
- `order_date` — Data do pedido, utilizada como chave de agrupamento
- `order_id` — Identificador único do pedido, usado para contagem de pedidos distintos
- `total_amount` — Valor total do pedido, somado para calcular vendas diárias
- `load_timestamp` — Timestamp de carga dos dados, usado para rastrear a atualização mais recente

### Colunas de Saída (refined_daily_sales)
- `order_date` — Data de referência das vendas
- `number_of_orders` — Quantidade de pedidos únicos realizados no dia
- `total_daily_sales` — Valor total de vendas acumuladas no dia
- `latest_load_timestamp` — Timestamp da carga mais recente dos dados daquele dia

## Joins e Relacionamentos

Não há joins neste script. A query opera sobre uma única tabela (`trusted_orders`).

## Filtros e Condições

Não há cláusulas `WHERE` ou `HAVING` aplicadas. Todos os registros da tabela `trusted_orders` são processados e agregados.

## Transformações

### Funções de Agregação
- **`COUNT(DISTINCT order_id)`** — Conta o número de pedidos únicos por data, evitando duplicatas
- **`SUM(total_amount)`** — Calcula o valor total de vendas diárias somando todos os valores de pedidos
- **`MAX(load_timestamp)`** — Identifica o timestamp mais recente de carga para cada data

### Agrupamento
- **`GROUP BY order_date`** — Agrupa todos os registros pela data do pedido, consolidando métricas por dia

## Parâmetros/Variáveis

Não há parâmetros ou variáveis definidos neste script.

## Fluxo de Dados

```
trusted_orders
      ↓
[Agrupamento por order_date]
      ↓
[Agregações: COUNT DISTINCT, SUM, MAX]
      ↓
refined_daily_sales
```

1. **Extração**: Leitura de todos os registros da tabela `trusted_orders`
2. **Agrupamento**: Dados são agrupados por `order_date`
3. **Agregação**: Para cada data, são calculadas:
   - Quantidade de pedidos únicos
   - Soma total de vendas
   - Timestamp mais recente de carga
4. **Criação**: Tabela `refined_daily_sales` é criada com os resultados agregados

## Observações

### Características
- **Camada de Dados**: Este script faz parte da camada **Refined** (dados refinados/agregados), processando dados da camada **Trusted** (dados confiáveis)
- **Tipo de Operação**: `CREATE TABLE` — cria uma nova tabela; executar novamente causará erro se a tabela já existir

### Possíveis Otimizações
- Considerar usar `CREATE TABLE IF NOT EXISTS` ou `CREATE OR REPLACE TABLE` dependendo do SGBD
- Adicionar índice em `order_date` para consultas futuras mais rápidas
- Implementar como `CREATE TABLE AS SELECT` (CTAS) com particionamento por data, se o volume for grande

### Recomendações
- **Incremental Load**: Para ambientes de produção, considerar implementar carga incremental ao invés de recriar toda a tabela
- **Validação de Dados**: Adicionar filtros para excluir datas nulas ou inválidas
- **Documentação de Negócio**: Definir claramente o fuso horário considerado para `order_date`

### Dependências
- **Upstream**: Depende da existência e população da tabela `trusted_orders`
- **Downstream**: Pode ser utilizada por dashboards, relatórios gerenciais e análises de tendências de vendas

### Casos de Uso
- Análise de performance de vendas diárias
- Identificação de tendências e sazonalidades
- Base para KPIs de vendas
- Fonte para dashboards executivos