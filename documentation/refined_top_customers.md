# refined_top_customers.sql

## Descrição Geral

Este script SQL cria uma tabela materializada contendo os principais clientes com base no valor total gasto. A query seleciona os 10 clientes que mais gastaram, ordenados de forma decrescente pelo valor total de suas compras, utilizando dados previamente processados da tabela `refined_customer_lifetime_value`.

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

- **LIMIT 10**: Valor hardcoded que define quantos clientes serão retornados. Pode ser ajustado conforme necessidade do negócio.

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
refined_top_customers (tabela criada)
```

### Etapas do Processamento

1. **Leitura**: Acessa todos os registros da tabela `refined_customer_lifetime_value`
2. **Ordenação**: Ordena os clientes pelo campo `total_spent` em ordem decrescente
3. **Limitação**: Seleciona apenas os 10 primeiros registros
4. **Criação**: Materializa os resultados na nova tabela `refined_top_customers`

## Observações

### Dependências
- **Tabela Upstream**: `refined_customer_lifetime_value` deve existir e estar populada antes da execução deste script
- Esta tabela faz parte de uma camada "refined" de um pipeline de dados

### Considerações Importantes

⚠️ **Atenção**: 
- O script utiliza `CREATE TABLE` sem verificação de existência. Se a tabela já existir, ocorrerá erro
- Considere usar `CREATE TABLE IF NOT EXISTS` ou `CREATE OR REPLACE TABLE` dependendo do SGBD

### Possíveis Otimizações

1. **Recriação Incremental**: 
   ```sql
   DROP TABLE IF EXISTS refined_top_customers;
   CREATE TABLE refined_top_customers AS ...
   ```

2. **Parametrização do Limite**:
   - Tornar o valor `10` configurável via variável ou parâmetro

3. **Índices**: 
   - Considerar criar índice em `customer_id` para consultas futuras
   - A tabela fonte deveria ter índice em `total_spent` para otimizar a ordenação

4. **View Materializada**:
   - Dependendo do SGBD, considerar usar `MATERIALIZED VIEW` para facilitar atualizações

### Casos de Uso

- Dashboards executivos mostrando principais clientes
- Segmentação para campanhas de marketing VIP
- Análise de concentração de receita
- Relatórios de performance de vendas

### Frequência de Atualização Recomendada

- **Diária**: Para acompanhamento regular
- **Semanal/Mensal**: Para análises estratégicas
- **Tempo Real**: Se integrado a dashboards operacionais (considerar usar VIEW ao invés de TABLE)