# trusted_products

## Descrição Geral

View que transforma e normaliza dados brutos de produtos da tabela `raw_products`, realizando limpeza de dados, conversão de tipos e validação básica. Esta view serve como camada intermediária confiável entre os dados brutos e as consultas de negócio, garantindo consistência e qualidade dos dados de produtos.

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `raw_products` | Fonte | Tabela de origem contendo dados brutos de produtos |

## Colunas

| Coluna | Tipo | Origem | Descrição |
|--------|------|--------|-----------|
| `product_id` | VARCHAR | `raw_products.product_id` | Identificador único do produto (validado) |
| `product_name` | VARCHAR | `raw_products.product_name` | Nome do produto com espaços em branco removidos |
| `category` | VARCHAR | `raw_products.category_raw` | Categoria do produto normalizada |
| `price` | DECIMAL(10, 2) | `raw_products.price_string` | Preço convertido de string para decimal |
| `stock_quantity` | INT | `raw_products.stock_quantity_string` | Quantidade em estoque convertida para inteiro |
| `load_timestamp` | TIMESTAMP | `raw_products.load_timestamp` | Data e hora do carregamento dos dados |

## Joins e Relacionamentos

Não há joins nesta view. A consulta opera exclusivamente sobre a tabela `raw_products` sem relacionamentos com outras tabelas.

## Filtros e Condições

### Cláusula WHERE

```sql
WHERE
    product_id IS NOT NULL AND TRIM(product_id) != ''
```

**Condições aplicadas:**
- `product_id IS NOT NULL` — Exclui registros onde o identificador do produto é nulo
- `TRIM(product_id) != ''` — Exclui registros onde o identificador é uma string vazia ou contém apenas espaços em branco

**Objetivo:** Garantir que apenas produtos com identificadores válidos sejam inclusos na view.

## Transformações

### Limpeza de Dados (TRIM)

- **`TRIM(product_name)`** — Remove espaços em branco no início e fim do nome do produto
- **`TRIM(category_raw)`** — Remove espaços em branco no início e fim da categoria

### Conversão de Tipos

| Transformação | Função | Descrição |
|---------------|--------|-----------|
| `price` | `CAST(REPLACE(price_string, ',', '.') AS DECIMAL(10, 2))` | Converte string de preço para decimal, substituindo vírgula por ponto (tratamento de formato brasileiro) |
| `stock_quantity` | `CAST(stock_quantity_string AS INT)` | Converte string de quantidade para inteiro |

**Nota:** A transformação de `price` inclui tratamento especial para formato de número brasileiro (vírgula como separador decimal).

## Parâmetros/Variáveis

Não há parâmetros ou variáveis nesta view. A consulta é estática e não aceita argumentos de entrada.

## Fluxo de Dados

```
raw_products (dados brutos)
    ↓
[Validação de product_id]
    ↓
[Limpeza de espaços em branco]
    ↓
[Conversão de tipos de dados]
    ↓
trusted_products (view confiável)
```

**Etapas do fluxo:**

1. **Leitura** — Dados são lidos da tabela `raw_products`
2. **Filtragem** — Registros com `product_id` inválido são descartados
3. **Normalização** — Espaços em branco são removidos de campos de texto
4. **Conversão** — Strings numéricas são convertidas para tipos apropriados
5. **Saída** — Dados limpos e tipados são disponibilizados através da view

## Observações

### Considerações de Qualidade

- ✅ **Validação básica** — A view implementa filtro para garantir `product_id` válido
- ⚠️ **Conversão de preço** — Assume que valores em `price_string` seguem formato brasileiro (vírgula como separador decimal)
- ⚠️ **Sem validação de range** — Não há validação se preço é positivo ou se quantidade é não-negativa

### Possíveis Otimizações

1. **Adicionar validação de dados:**
   ```sql
   AND CAST(REPLACE(price_string, ',', '.') AS DECIMAL(10, 2)) > 0
   AND CAST(stock_quantity_string AS INT) >= 0
   ```

2. **Tratamento de erros de conversão** — Considerar usar `TRY_CAST` ou equivalente para evitar falhas em conversões inválidas

3. **Índices** — Se `raw_products` é grande, considerar índice em `product_id` para melhorar performance

### Dependências

- Tabela `raw_products` deve existir e conter as colunas: `product_id`, `product_name`, `category_raw`, `price_string`, `stock_quantity_string`, `load_timestamp`
- Formato de preço em `price_string` deve ser compatível com separador decimal em vírgula

### Casos de Uso

- Consultas de catálogo de produtos
- Relatórios de inventário
- Análises de preços
- Integrações com sistemas de negócio que requerem dados confiáveis