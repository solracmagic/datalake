# refined_customer_lifetime_value.sql

## Descrição Geral

Este script SQL cria uma tabela analítica que consolida informações sobre o **valor do tempo de vida do cliente** (Customer Lifetime Value - CLV). A query agrega dados de clientes e pedidos para fornecer uma visão consolidada do comportamento de compra e do valor total gerado por cada cliente ao longo do tempo.

---

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `refined_customer_lifetime_value` | Destino | Tabela criada para armazenar métricas de CLV |
| `trusted_customers` | Origem | Tabela confiável contendo dados cadastrais dos clientes |
| `trusted_orders` | Origem | Tabela confiável contendo dados dos pedidos realizados |

---

## Colunas

### Colunas de Origem

**Da tabela `trusted_customers` (alias `c`):**
- `customer_id` — Identificador único do cliente
- `first_name` — Primeiro nome do cliente
- `last_name` — Sobrenome do cliente
- `email` — Endereço de e-mail do cliente
- `load_timestamp` — Timestamp de carga dos dados do cliente

**Da tabela `trusted_orders` (alias `o`):**
- `customer_id` — Identificador do cliente (chave estrangeira)
- `order_id` — Identificador único do pedido
- `total_amount` — Valor total do pedido
- `order_date` — Data de realização do pedido
- `load_timestamp` — Timestamp de carga dos dados do pedido

### Colunas de Destino

| Coluna | Tipo de Dado | Descrição |
|--------|--------------|-----------|
| `customer_id` | Identificador | ID único do cliente |
| `first_name` | Texto | Primeiro nome do cliente |
| `last_name` | Texto | Sobrenome do cliente |
| `email` | Texto | E-mail do cliente |
| `total_spent` | Numérico (agregado) | Soma total gasta pelo cliente em todos os pedidos |
| `total_orders` | Inteiro (agregado) | Quantidade total de pedidos realizados pelo cliente |
| `first_order_date` | Data | Data do primeiro pedido do cliente |
| `last_order_date` | Data | Data do pedido mais recente do cliente |
| `latest_customer_load_timestamp` | Timestamp | Timestamp mais recente de carga dos dados do cliente |
| `latest_order_load_timestamp` | Timestamp | Timestamp mais recente de carga dos dados de pedidos |

---

## Joins e Relacionamentos

### JOIN Principal

```sql
trusted_customers c
JOIN trusted_orders o ON c.customer_id = o.customer_id
```

- **Tipo:** INNER JOIN
- **Condição:** `c.customer_id = o.customer_id`
- **Relacionamento:** 1:N (Um cliente pode ter múltiplos pedidos)
- **Impacto:** Apenas clientes que possuem pelo menos um pedido serão incluídos na tabela final

---

## Filtros e Condições

**Nenhum filtro WHERE ou HAVING é aplicado nesta query.**

Todos os clientes que possuem pedidos registrados na tabela `trusted_orders` serão incluídos no resultado.

---

## Transformações

### Funções de Agregação

| Função | Coluna | Resultado | Propósito |
|--------|--------|-----------|-----------|
| `SUM()` | `o.total_amount` | `total_spent` | Calcula o valor total gasto pelo cliente |
| `COUNT(DISTINCT)` | `o.order_id` | `total_orders` | Conta o número único de pedidos |
| `MIN()` | `o.order_date` | `first_order_date` | Identifica a data do primeiro pedido |
| `MAX()` | `o.order_date` | `last_order_date` | Identifica a data do último pedido |
| `MAX()` | `c.load_timestamp` | `latest_customer_load_timestamp` | Captura o timestamp mais recente de atualização do cliente |
| `MAX()` | `o.load_timestamp` | `latest_order_load_timestamp` | Captura o timestamp mais recente de atualização de pedidos |

### Agrupamento

```sql
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
```

Os dados são agrupados por cliente, garantindo que cada linha represente um único cliente com suas métricas agregadas.

---

## Parâmetros/Variáveis

**Não há parâmetros ou variáveis** declarados neste script. A query é executada de forma estática.

---

## Fluxo de Dados

```mermaid
graph LR
    A[trusted_customers] --> C[JOIN por customer_id]
    B[trusted_orders] --> C
    C --> D[Agregação por Cliente]
    D --> E[refined_customer_lifetime_value]
```

### Etapas do Processamento

1. **Extração:** Dados são lidos das tabelas `trusted_customers` e `trusted_orders`
2. **Junção:** As tabelas são unidas através do `customer_id`
3. **Agregação:** Métricas são calculadas para cada cliente usando funções de agregação
4. **Agrupamento:** Resultados são agrupados por cliente
5. **Criação:** A tabela `refined_customer_lifetime_value` é criada com os dados processados

---

## Observações

### Pontos de Atenção

- ⚠️ **INNER JOIN:** Clientes sem pedidos não aparecerão na tabela final. Considere usar `LEFT JOIN` se for necessário incluir todos os clientes.
- 📊 **Métricas de Auditoria:** Os campos `latest_customer_load_timestamp` e `latest_order_load_timestamp` permitem rastreamento de atualização de dados.
- 🔄 **Recriação da Tabela:** O comando `CREATE TABLE` recria a tabela a cada execução. Considere usar `CREATE OR REPLACE` ou `DROP TABLE IF EXISTS` para evitar erros.

### Possíveis Otimizações

1. **Índices:** Criar índices em `customer_id` nas tabelas de origem pode melhorar a performance do JOIN
2. **Particionamento:** Para grandes volumes, considere particionar por data ou faixa de clientes
3. **Materialização Incremental:** Implementar lógica de atualização incremental ao invés de recriação completa

### Dependências

- **Upstream:** `trusted_customers`, `trusted_orders`
- **Downstream:** Tabelas ou relatórios que consomem dados de CLV

### Casos de Uso

- Análise de segmentação de clientes por valor
- Identificação de clientes VIP
- Análise de retenção e recência
- Dashboards executivos de métricas de cliente
- Modelos de churn prediction

---

**Última Atualização da Documentação:** *Gerada automaticamente*