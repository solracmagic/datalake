# raw_products.sql

## Descrição Geral

Este arquivo SQL define a estrutura da tabela `raw_products`, que pertence à camada **raw** (bronze) de um data warehouse. A tabela é responsável por armazenar dados brutos de produtos conforme recebidos da fonte original, sem transformações ou validações, mantendo tipos de dados genéricos (principalmente strings) para garantir a ingestão completa dos dados.

## Tabelas Envolvidas

- `raw_products` — Tabela de produtos na camada raw/bronze

## Estrutura de Colunas

| Coluna | Tipo de Dado | Descrição |
|--------|--------------|-----------|
| `product_id` | VARCHAR(50) | Identificador único do produto (armazenado como string na camada raw) |
| `product_name` | VARCHAR(255) | Nome/descrição do produto |
| `category_raw` | VARCHAR(100) | Categoria do produto em formato bruto, sem padronização |
| `price_string` | VARCHAR(50) | Preço do produto armazenado como string (pode conter símbolos de moeda, formatações diversas) |
| `stock_quantity_string` | VARCHAR(50) | Quantidade em estoque armazenada como string (permite capturar valores não numéricos ou formatados) |
| `load_timestamp` | TIMESTAMP | Data e hora de carregamento do registro, preenchida automaticamente com o timestamp atual |

## Joins e Relacionamentos

Não aplicável — este é um script DDL de criação de tabela, sem joins ou relacionamentos definidos.

## Filtros e Condições

Não aplicável — não há cláusulas WHERE ou condições neste script.

## Transformações

Não aplicável — esta é uma tabela raw sem transformações. Os dados são armazenados em seu formato original.

## Parâmetros/Variáveis

Não há parâmetros ou variáveis neste script.

## Fluxo de Dados

```
Fonte de Dados Original
         ↓
   [raw_products]
         ↓
(Próxima camada: staging/silver)
```

1. **Ingestão**: Dados brutos são carregados diretamente da fonte (API, arquivo CSV, banco transacional, etc.)
2. **Armazenamento**: Todos os campos são armazenados como strings para evitar falhas de tipo durante a carga
3. **Timestamp**: Cada registro recebe automaticamente um timestamp de carga
4. **Próximo passo**: Dados serão transformados e validados em camadas subsequentes (staging/silver ou trusted/gold)

## Observações

### Boas Práticas Implementadas

- ✅ **Camada Raw/Bronze**: Mantém dados no formato original sem transformações
- ✅ **Tipos Flexíveis**: Uso de VARCHAR permite capturar dados inconsistentes ou mal formatados
- ✅ **Auditoria**: Campo `load_timestamp` permite rastreabilidade temporal dos dados
- ✅ **Nomenclatura Clara**: Sufixos `_raw` e `_string` indicam claramente que os dados não foram tratados

### Pontos de Atenção

⚠️ **Ausência de Chave Primária**: A tabela não possui constraint de PRIMARY KEY definida. Considere adicionar:
```sql
ALTER TABLE raw_products ADD PRIMARY KEY (product_id, load_timestamp);
```

⚠️ **Sem Validações**: Por design, não há validações (NOT NULL, CHECK, etc.), o que é apropriado para camada raw

⚠️ **Duplicatas**: Sem constraints, a tabela pode acumular registros duplicados em cargas sucessivas

### Recomendações

1. **Particionamento**: Para grandes volumes, considere particionar por `load_timestamp`
2. **Índices**: Adicionar índice em `product_id` para consultas de lookup
3. **Retenção**: Definir política de retenção de dados (ex: manter apenas últimos 90 dias)
4. **Próxima Camada**: Criar tabela `stg_products` ou `silver_products` com:
   - Conversão de `price_string` para DECIMAL
   - Conversão de `stock_quantity_string` para INTEGER
   - Padronização de `category_raw`
   - Validações e limpeza de dados

### Dependências

- Nenhuma dependência direta
- Esta tabela serve como fonte para camadas downstream (staging/silver)

### Exemplo de Uso

```sql
-- Inserção de dados brutos
INSERT INTO raw_products (product_id, product_name, category_raw, price_string, stock_quantity_string)
VALUES ('P001', 'Notebook Dell', 'Eletrônicos', 'R$ 3.500,00', '15 unidades');

-- Consulta para análise de qualidade
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT product_id) as unique_products,
    MIN(load_timestamp) as first_load,
    MAX(load_timestamp) as last_load
FROM raw_products;
```

---

**Versão da Documentação**: 1.0  
**Última Atualização**: 2024  
**Camada**: Raw/Bronze