# refined_top_customers.sql

## Descrição Geral

Este script SQL cria uma tabela materializada contendo os principais clientes com base no valor total gasto. A query seleciona os 10 clientes que mais gastaram, ordenados de forma decrescente pelo valor total de compras, utilizando dados previamente processados da tabela `refined_customer_lifetime_value`.

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `refined_top_customers` | Destino (CREATE TABLE) | Tabela criada para armazenar os top clientes |
| `refined_customer_lifetime_value` | Origem (FROM) | Tabela fonte contendo métricas de lifetime value dos clientes |

## Colunas

### Colunas Selecionadas

| Coluna | Tipo de Dado | Descrição |
|--------|--------------|-----------|
| `customer_id` | Identificador | ID único do cliente |
| `first_name` | Texto | Primeiro nome do cliente |
| `last_name` | Texto | Sobrenome do cliente |
| `email` | Texto | Endereço de e-mail do cliente |
| `total_spent` | Numérico | Valor total gasto pelo cliente (usado para ordenação) |
| `total_orders` | Numérico | Quantidade total de pedidos realizados pelo cliente |

## Joins e Relacionamentos

Não há joins nesta query. A consulta utiliza apenas uma tabela fonte (`refined_customer_lifetime_value`).

## Filtros e Condições

### Ordenação
- **ORDER BY**: `total_spent DESC` — Ordena os clientes pelo valor total gasto em ordem decrescente (maior para menor)

### Limitação de Resultados
- **LIMIT**: `10` — Restringe o resultado aos 10 primeiros registros (top 10 clientes)

## Transformações

Esta query não aplica transformações complexas. Trata-se de uma seleção direta de colunas com:
- Ordenação por valor gasto
- Limitação de registros

## Parâmetros/Variáveis

Não há parâmetros ou variáveis declarados neste script.

### Valores Configuráveis

- **LIMIT 10**: Valor hardcoded que define quantos top clientes serão retornados. Pode ser ajustado conforme necessidade do negócio.

## Fluxo de Dados

```
refined_customer_lifetime_value
           ↓
    SELECT (6 colunas)
           ↓
    ORDER BY total_spent DESC
           ↓
       LIMIT 10
           ↓
  refined_top_customers
```

### Descrição do Fluxo

1. **Origem**: Leitura da tabela `refined_customer_lifetime_value`
2. **Seleção**: Extração de 6 colunas principais do cliente
3. **Ordenação**: Classificação decrescente por `total_spent`
4. **Limitação**: Seleção apenas dos 10 primeiros registros
5. **Destino**: Criação da tabela `refined_top_customers` com os resultados

## Observações

### Dependências
- ⚠️ **Dependência crítica**: Esta tabela depende da existência prévia de `refined_customer_lifetime_value`
- A execução deve ocorrer após a criação/atualização da tabela fonte

### Considerações de Performance
- ✅ A query é simples e performática para volumes moderados de dados
- ✅ O uso de `LIMIT 10` garante resultado pequeno e rápido
- ⚠️ Considere criar índice em `total_spent` na tabela fonte para otimizar a ordenação

### Possíveis Melhorias

1. **Recriação da Tabela**: 
   - Considere usar `DROP TABLE IF EXISTS` antes do `CREATE TABLE` para permitir re-execuções
   - Alternativa: usar `CREATE OR REPLACE TABLE` (dependendo do SGBD)

2. **Parametrização**:
   - O valor `LIMIT 10` poderia ser parametrizado para maior flexibilidade

3. **Versionamento**:
   - Adicionar colunas de metadados como `created_at` ou `updated_at` para rastreabilidade

4. **Materialização**:
   - Avaliar se uma VIEW seria mais apropriada que uma TABLE, dependendo da frequência de atualização necessária

### Exemplo de Uso Melhorado

```sql
DROP TABLE IF EXISTS refined_top_customers;

CREATE TABLE refined_top_customers AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    total_spent,
    total_orders,
    CURRENT_TIMESTAMP AS created_at
FROM
    refined_customer_lifetime_value
ORDER BY
    total_spent DESC
LIMIT 10;
```

### Casos de Uso

- Dashboards executivos mostrando principais clientes
- Segmentação para campanhas VIP
- Análise de concentração de receita
- Relatórios de customer success