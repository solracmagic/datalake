# trusted_orders.sql

## Descrição Geral

Esta view consolida dados de pedidos com informações de clientes, realizando transformações e limpeza de dados. Ela integra dados da camada `raw` (dados brutos) com a camada `trusted` (dados confiáveis), aplicando validações e conversões de tipo para garantir qualidade e consistência dos dados de pedidos.

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `raw_orders` | Tabela de origem | Contém dados brutos de pedidos |
| `trusted_customers` | Tabela de referência | Contém dados confiáveis de clientes |

## Colunas

### Colunas de Saída

| Coluna | Tipo | Origem | Descrição |
|--------|------|--------|-----------|
| `order_id` | VARCHAR | `raw_orders` | Identificador único do pedido |
| `customer_id` | VARCHAR | `raw_orders` | Identificador do cliente associado ao pedido |
| `order_date` | DATE | `raw_orders` | Data do pedido (convertida de string) |
| `total_amount` | DECIMAL(10, 2) | `raw_orders` | Valor total do pedido (convertido e formatado) |
| `status` | VARCHAR | `raw_orders` | Status do pedido (espaços em branco removidos) |
| `first_name` | VARCHAR | `trusted_customers` | Primeiro nome do cliente |
| `last_name` | VARCHAR | `trusted_customers` | Sobrenome do cliente |
| `email` | VARCHAR | `trusted_customers` | Endereço de email do cliente |
| `load_timestamp` | TIMESTAMP | `raw_orders` | Data/hora do carregamento do registro |

## Joins e Relacionamentos

**INNER JOIN** entre `raw_orders` e `trusted_customers`:
- **Condição**: `o.customer_id = c.customer_id`
- **Tipo**: Junção interna que garante que apenas pedidos com clientes válidos na camada `trusted` sejam incluídos
- **Impacto**: Pedidos órfãos (sem cliente correspondente) serão excluídos da view

## Filtros e Condições

### Cláusula WHERE

```sql
WHERE o.order_id IS NOT NULL AND TRIM(o.order_id) != ''
```

| Condição | Descrição |
|----------|-----------|
| `o.order_id IS NOT NULL` | Exclui registros onde `order_id` é nulo |
| `TRIM(o.order_id) != ''` | Exclui registros onde `order_id` contém apenas espaços em branco |

**Objetivo**: Garantir que apenas pedidos com identificadores válidos sejam incluídos na view.

## Transformações

### Conversões de Tipo e Limpeza de Dados

| Campo Original | Transformação | Resultado | Motivo |
|---|---|---|---|
| `o.order_date_string` | `CAST(... AS DATE)` | `order_date` | Converte string em tipo DATE para operações de data |
| `o.total_amount_string` | `REPLACE(..., ',', '.')` + `CAST(... AS DECIMAL(10, 2))` | `total_amount` | Normaliza separador decimal (vírgula → ponto) e converte para tipo numérico |
| `o.status` | `TRIM(...)` | `status` | Remove espaços em branco no início e fim |

## Parâmetros/Variáveis

Não há parâmetros ou variáveis de entrada nesta view. Trata-se de uma view estática que seleciona dados das tabelas base sem filtros parametrizados.

## Fluxo de Dados

```
raw_orders (dados brutos)
    ↓
[Validação: order_id não nulo e não vazio]
    ↓
[JOIN com trusted_customers]
    ↓
[Transformações: conversão de tipos, limpeza]
    ↓
trusted_orders (view consolidada)
```

### Etapas do Fluxo

1. **Leitura**: Dados são lidos de `raw_orders` e `trusted_customers`
2. **Validação**: Registros com `order_id` inválido são filtrados
3. **Enriquecimento**: Dados de clientes são adicionados via JOIN
4. **Transformação**: Tipos de dados são convertidos e strings são limpas
5. **Saída**: View consolidada disponibiliza dados confiáveis para consumo

## Observações

### Considerações Importantes

- **Qualidade de Dados**: A view assume que `trusted_customers` contém dados já validados e confiáveis
- **Perda de Dados**: Pedidos sem cliente correspondente em `trusted_customers` serão perdidos (INNER JOIN)
- **Conversão de Datas**: A conversão de `order_date_string` para DATE pode falhar se o formato não for reconhecido pelo banco de dados
- **Conversão de Valores Monetários**: A função `REPLACE` assume que o separador decimal é vírgula; valores com outros formatos podem causar erros

### Possíveis Otimizações

1. **Índices**: Considere criar índices em `raw_orders.customer_id` e `trusted_customers.customer_id` para melhorar performance do JOIN
2. **Validação de Formato**: Adicionar validações mais robustas para `order_date_string` e `total_amount_string` antes da conversão
3. **Logging**: Implementar mecanismo para registrar registros descartados (pedidos órfãos ou com order_id inválido)
4. **LEFT JOIN Alternativo**: Se for necessário preservar pedidos sem cliente, considerar usar LEFT JOIN com tratamento de NULLs

### Dependências

- Tabela `raw_orders` deve estar disponível e atualizada
- Tabela `trusted_customers` deve estar disponível e confiável
- Formato de data em `order_date_string` deve ser compatível com conversão DATE do banco de dados
- Formato de valor monetário em `total_amount_string` deve usar vírgula como separador decimal