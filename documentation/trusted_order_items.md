# trusted_order_items

## Descrição Geral

View que transforma e padroniza dados brutos de itens de pedidos, convertendo campos de texto em tipos numéricos apropriados e calculando o valor total de cada linha de pedido. Esta view atua como camada de transformação entre os dados brutos (`raw_order_items`) e as consultas de negócio, garantindo integridade de dados e consistência de tipos.

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `raw_order_items` | Fonte (tabela bruta) | Tabela de origem contendo dados brutos de itens de pedidos |
| `trusted_order_items` | View (destino) | View de transformação que padroniza os dados |

## Colunas

| Coluna | Tipo de Dado | Origem | Descrição |
|--------|--------------|--------|-----------|
| `order_item_id` | INT | `raw_order_items.order_item_id` | Identificador único do item do pedido |
| `order_id` | INT | `raw_order_items.order_id` | Identificador do pedido ao qual o item pertence |
| `product_id` | INT | `raw_order_items.product_id` | Identificador do produto |
| `quantity` | INT | `raw_order_items.quantity_string` | Quantidade do produto (convertida de texto para inteiro) |
| `unit_price` | DECIMAL(10, 2) | `raw_order_items.unit_price_string` | Preço unitário do produto (convertido de texto com separador de decimal em vírgula) |
| `line_item_total` | DECIMAL(10, 2) | Cálculo | Valor total da linha (quantidade × preço unitário) |
| `load_timestamp` | TIMESTAMP | `raw_order_items.load_timestamp` | Data e hora do carregamento do registro |

## Joins e Relacionamentos

Esta view não utiliza joins explícitos. Ela realiza uma transformação simples de uma única tabela fonte (`raw_order_items`), sem relacionamentos com outras tabelas.

**Relacionamentos implícitos:**
- `order_id` pode ser relacionado com tabelas de pedidos (ex: `orders`)
- `product_id` pode ser relacionado com tabelas de produtos (ex: `products`)

## Filtros e Condições

### Cláusula WHERE

```sql
WHERE
    oi.order_item_id IS NOT NULL 
    AND TRIM(oi.order_item_id) != ''
```

**Condições aplicadas:**
- `order_item_id IS NOT NULL` — Exclui registros onde o identificador do item é nulo
- `TRIM(oi.order_item_id) != ''` — Exclui registros onde o identificador é uma string vazia ou contém apenas espaços em branco

**Objetivo:** Garantir que apenas itens de pedidos válidos e identificáveis sejam inclusos na view.

## Transformações

### Conversão de Tipos de Dados

| Campo Original | Transformação | Campo Resultante | Motivo |
|---|---|---|---|
| `quantity_string` | `CAST(... AS INT)` | `quantity` | Converter quantidade de texto para número inteiro |
| `unit_price_string` | `CAST(REPLACE(..., ',', '.') AS DECIMAL(10, 2))` | `unit_price` | Converter preço de texto (com vírgula como separador decimal) para número decimal |

### Cálculo Derivado

**`line_item_total`** — Multiplicação de quantidade por preço unitário:
```sql
(CAST(oi.quantity_string AS INT) * CAST(REPLACE(oi.unit_price_string, ',', '.') AS DECIMAL(10, 2)))
```

**Tipo resultante:** DECIMAL(10, 2)

**Observação:** O cálculo é realizado após as conversões de tipo, garantindo precisão aritmética.

## Parâmetros/Variáveis

Esta view não utiliza parâmetros ou variáveis de entrada. É uma view estática que sempre consulta a tabela `raw_order_items` completa (respeitando os filtros definidos).

## Fluxo de Dados

```
raw_order_items (dados brutos)
        ↓
[Filtros de validação]
  - order_item_id NOT NULL
  - order_item_id não vazio
        ↓
[Transformações de tipo]
  - quantity_string → INT
  - unit_price_string → DECIMAL(10, 2)
        ↓
[Cálculos derivados]
  - line_item_total = quantity × unit_price
        ↓
trusted_order_items (view padronizada)
```

## Observações

### Pontos de Atenção

1. **Separador de Decimal em Vírgula** — A função `REPLACE(oi.unit_price_string, ',', '.')` assume que os preços originais utilizam vírgula como separador decimal (formato brasileiro/europeu). Se o formato mudar, a transformação falhará.

2. **Precisão de Cálculo** — O `line_item_total` é calculado com tipo `DECIMAL(10, 2)`, permitindo valores até 99.999.999,99. Validar se este intervalo é suficiente para os dados da empresa.

3. **Validação Incompleta** — A view valida apenas `order_item_id`. Não há validação para:
   - `quantity_string` (pode conter valores não numéricos)
   - `unit_price_string` (pode conter valores não numéricos após REPLACE)
   - `order_id` e `product_id` (podem ser nulos ou inválidos)

4. **Possíveis Erros em Tempo de Execução** — Se `quantity_string` ou `unit_price_string` contiverem valores não conversíveis, a query falhará. Considerar usar `TRY_CAST` ou tratamento de erros.

### Recomendações de Otimização

1. **Adicionar Validações Adicionais:**
   ```sql
   WHERE
       oi.order_item_id IS NOT NULL 
       AND TRIM(oi.order_item_id) != ''
       AND oi.order_id IS NOT NULL
       AND oi.product_id IS NOT NULL
       AND oi.quantity_string ~ '^\d+$'  -- validar se é número
       AND oi.unit_price_string ~ '^\d+[.,]\d{2}$'  -- validar formato de preço
   ```

2. **Usar TRY_CAST para Maior Robustez:**
   ```sql
   CAST(TRY_CAST(oi.quantity_string AS INT) AS INT) AS quantity
   ```

3. **Adicionar Índices na Tabela Fonte:**
   - Índice em `raw_order_items(order_item_id)` para melhorar performance da filtragem

4. **Documentar o Formato Esperado** — Adicionar comentários sobre o formato esperado de `quantity_string` e `unit_price_string` no schema da tabela `raw_order_items`.

### Dependências

- Tabela `raw_order_items` deve estar disponível e populada
- Formato de dados em `quantity_string` e `unit_price_string` deve ser consistente
- Permissões de leitura na tabela `raw_order_items`