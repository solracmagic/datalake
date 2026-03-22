# raw_products.sql

## Descrição Geral

Este arquivo SQL define a estrutura da tabela `raw_products`, que pertence à camada **raw** (bronze) de um data warehouse. Esta tabela é responsável por armazenar dados brutos de produtos conforme recebidos da fonte original, sem transformações ou validações, mantendo tipos de dados primitivos (strings) para campos que posteriormente serão convertidos em tipos mais específicos nas camadas superiores.

## Tabelas Envolvidas

- `raw_products` — Tabela de produtos na camada raw/bronze

## Estrutura da Tabela

### Colunas

| Coluna | Tipo de Dado | Descrição | Constraints |
|--------|--------------|-----------|-------------|
| `product_id` | `VARCHAR(50)` | Identificador único do produto na fonte de origem | - |
| `product_name` | `VARCHAR(255)` | Nome/descrição do produto | - |
| `category_raw` | `VARCHAR(100)` | Categoria do produto em formato bruto, sem normalização | - |
| `price_string` | `VARCHAR(50)` | Preço do produto armazenado como string (pode conter símbolos monetários, vírgulas, etc.) | - |
| `stock_quantity_string` | `VARCHAR(50)` | Quantidade em estoque armazenada como string (permite capturar valores não numéricos da fonte) | - |
| `load_timestamp` | `TIMESTAMP` | Data e hora de carregamento do registro na tabela | `DEFAULT CURRENT_TIMESTAMP` |

## Joins e Relacionamentos

Não aplicável — Este é um script DDL de criação de tabela, sem joins ou relacionamentos explícitos definidos.

## Filtros e Condições

Não aplicável — Não há cláusulas WHERE ou condições neste script.

## Transformações

Não aplicável — Esta é uma tabela raw sem transformações. Os dados são armazenados em seu formato original.

## Parâmetros/Variáveis

Não há parâmetros ou variáveis neste script.

## Fluxo de Dados

```
Fonte de Dados (Sistema Transacional/API/Arquivo)
            ↓
    [Processo de Ingestão]
            ↓
      raw_products (Camada Raw/Bronze)
            ↓
    [Próximas camadas: Staging/Silver ou Trusted/Gold]
```

### Descrição do Fluxo

1. **Ingestão**: Dados brutos de produtos são extraídos da fonte original
2. **Armazenamento Raw**: Dados são inseridos na tabela `raw_products` sem transformações
3. **Timestamp Automático**: O campo `load_timestamp` registra automaticamente o momento da carga
4. **Processamento Futuro**: Dados serão consumidos por processos ETL/ELT para transformação nas camadas subsequentes

## Observações

### Características da Camada Raw

- **Imutabilidade**: Dados devem ser mantidos em seu formato original
- **Auditoria**: O campo `load_timestamp` permite rastreabilidade temporal
- **Flexibilidade**: Uso de `VARCHAR` para campos numéricos permite capturar dados inconsistentes da fonte

### Pontos de Atenção

⚠️ **Ausência de Primary Key**: A tabela não possui chave primária definida, o que pode:
- Permitir duplicatas
- Dificultar operações de UPDATE/DELETE específicas
- Impactar performance em consultas

⚠️ **Tipos de Dados Genéricos**: 
- `price_string` e `stock_quantity_string` são armazenados como strings
- Requer validação e conversão nas camadas superiores (staging/trusted)

### Possíveis Otimizações

1. **Adicionar Primary Key**:
   ```sql
   ALTER TABLE raw_products ADD PRIMARY KEY (product_id, load_timestamp);
   ```

2. **Criar Índices**:
   ```sql
   CREATE INDEX idx_raw_products_load_timestamp ON raw_products(load_timestamp);
   CREATE INDEX idx_raw_products_category ON raw_products(category_raw);
   ```

3. **Adicionar Particionamento** (para grandes volumes):
   ```sql
   -- Particionar por data de carga (sintaxe varia por SGBD)
   PARTITION BY RANGE (load_timestamp);
   ```

### Dependências

- **Upstream**: Sistema fonte de dados de produtos (ERP, e-commerce, API, etc.)
- **Downstream**: Tabelas das camadas staging/silver ou trusted/gold que consumirão estes dados brutos

### Boas Práticas Implementadas

✅ Nomenclatura clara indicando camada raw  
✅ Timestamp automático de carga  
✅ Preservação de dados originais sem transformação  
✅ Comentários inline explicativos

### Melhorias Sugeridas

- Adicionar coluna `source_system` para identificar origem dos dados
- Incluir coluna `batch_id` para rastreamento de lotes de carga
- Considerar adicionar coluna `raw_record` (JSON/TEXT) com registro completo original