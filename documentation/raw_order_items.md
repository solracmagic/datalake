# raw_order_items.sql

## Descrição Geral

Este script SQL define a estrutura da tabela `raw_order_items`, que armazena dados brutos de itens de pedidos em sua forma original, sem transformações. Esta tabela faz parte da camada **raw** (bronze) de uma arquitetura de data warehouse, onde os dados são mantidos em seu formato mais próximo da fonte original, incluindo tipos de dados como strings para valores numéricos que serão posteriormente transformados em camadas superiores.

## Tabelas Envolvidas

- `raw_order_items` — Tabela de destino sendo criada

## Colunas

| Coluna | Tipo de Dado | Descrição |
|--------|--------------|-----------|
| `order_item_id` | VARCHAR(50) | Identificador único do item do pedido |
| `order_id` | VARCHAR(50) | Identificador do pedido ao qual o item pertence (chave estrangeira lógica) |
| `product_id` | VARCHAR(50) | Identificador do produto associado ao item |
| `quantity_string` | VARCHAR(50) | Quantidade do produto armazenada como string na camada raw |
| `unit_price_string` | VARCHAR(50) | Preço unitário do produto armazenado como string na camada raw |
| `load_timestamp` | TIMESTAMP | Data e hora de carregamento do registro (valor padrão: timestamp atual) |

## Joins e Relacionamentos

Esta tabela não possui joins definidos no script de criação, mas estabelece relacionamentos lógicos com outras tabelas:

- **Relacionamento com pedidos**: `order_id` referencia a tabela de pedidos (provavelmente `raw_orders`)
- **Relacionamento com produtos**: `product_id` referencia a tabela de produtos (provavelmente `raw_products`)

## Filtros e Condições

Não há filtros ou condições aplicados neste script de criação de tabela.

## Transformações

Não há transformações aplicadas nesta camada. As seguintes características são notáveis:

- **Preservação de formato original**: Campos numéricos (`quantity_string`, `unit_price_string`) são mantidos como VARCHAR para preservar o formato original dos dados de origem
- **Auditoria automática**: Uso de `DEFAULT CURRENT_TIMESTAMP` para rastreamento automático do momento de inserção dos dados

## Parâmetros/Variáveis

Não há parâmetros ou variáveis definidos neste script.

## Fluxo de Dados

```
Fonte de Dados (Sistema Transacional/API/Arquivo)
    ↓
raw_order_items (Camada Raw/Bronze)
    ↓
[Próximas camadas: Staging/Silver → Curated/Gold]
```

1. **Ingestão**: Dados brutos são carregados diretamente da fonte
2. **Armazenamento**: Dados são armazenados sem transformação, preservando tipos originais
3. **Timestamp**: Cada registro recebe automaticamente um timestamp de carga
4. **Processamento futuro**: Dados serão consumidos por processos ETL/ELT para transformação em camadas superiores

## Observações

### Boas Práticas Implementadas
- ✅ Uso de camada raw para preservação de dados originais
- ✅ Auditoria com `load_timestamp` para rastreabilidade
- ✅ Comentários explicativos sobre campos em formato string

### Pontos de Atenção
- ⚠️ **Ausência de chaves primárias**: Não há definição de PRIMARY KEY para `order_item_id`
- ⚠️ **Ausência de chaves estrangeiras**: Relacionamentos não são enforçados no nível de banco de dados
- ⚠️ **Ausência de constraints**: Não há validações de NOT NULL ou UNIQUE
- ⚠️ **Tipos de dados genéricos**: VARCHAR(50) pode ser insuficiente para alguns cenários

### Recomendações de Otimização
1. **Adicionar constraints**:
   ```sql
   ALTER TABLE raw_order_items 
   ADD CONSTRAINT pk_raw_order_items PRIMARY KEY (order_item_id);
   ```

2. **Adicionar índices** para melhorar performance de consultas:
   ```sql
   CREATE INDEX idx_order_id ON raw_order_items(order_id);
   CREATE INDEX idx_product_id ON raw_order_items(product_id);
   ```

3. **Considerar particionamento** por `load_timestamp` se o volume de dados for alto

### Dependências
- Esta tabela será consumida por processos de transformação em camadas superiores (staging/silver)
- Depende de processos de ingestão de dados que populam a tabela
- Relaciona-se logicamente com tabelas `raw_orders` e `raw_products`

### Uso Típico
Esta tabela é utilizada como ponto de entrada de dados no data warehouse, servindo como:
- Fonte para processos de ETL/ELT
- Backup dos dados originais
- Base para auditoria e reconciliação de dados