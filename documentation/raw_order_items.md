# raw_order_items.sql

## Descrição Geral

Este script SQL define a estrutura da tabela `raw_order_items`, que armazena dados brutos de itens de pedidos em sua forma original, sem transformações. Esta tabela faz parte da camada **raw** (bronze) de uma arquitetura de dados em camadas, onde os dados são ingeridos exatamente como recebidos da fonte, preservando tipos de dados originais como strings para posterior validação e transformação.

## Tipo de Operação

**DDL (Data Definition Language)** - Criação de tabela

## Estrutura da Tabela

### Tabela Criada
- `raw_order_items`

## Colunas

| Coluna | Tipo de Dado | Descrição | Constraints |
|--------|--------------|-----------|-------------|
| `order_item_id` | VARCHAR(50) | Identificador único do item do pedido | - |
| `order_id` | VARCHAR(50) | Identificador do pedido ao qual o item pertence | - |
| `product_id` | VARCHAR(50) | Identificador do produto | - |
| `quantity_string` | VARCHAR(50) | Quantidade do produto como string (formato bruto) | - |
| `unit_price_string` | VARCHAR(50) | Preço unitário do produto como string (formato bruto) | - |
| `load_timestamp` | TIMESTAMP | Data e hora de carregamento do registro | DEFAULT CURRENT_TIMESTAMP |

## Características da Camada Raw

### Preservação de Dados Originais
- **Campos numéricos como strings**: `quantity_string` e `unit_price_string` são armazenados como VARCHAR para preservar o formato original dos dados
- **Sem validações**: Não há constraints de chave primária, chave estrangeira ou validações de dados
- **Auditoria**: Coluna `load_timestamp` registra automaticamente quando cada registro foi inserido

## Relacionamentos Potenciais

Embora não haja constraints definidos nesta camada, os relacionamentos lógicos esperados são:

- `order_id` → Relaciona-se com a tabela de pedidos (ex: `raw_orders`)
- `product_id` → Relaciona-se com a tabela de produtos (ex: `raw_products`)
- `order_item_id` → Identificador único que pode ser usado como chave primária em camadas superiores

## Fluxo de Dados

```
Fonte de Dados (API/Arquivo/Sistema Externo)
            ↓
    raw_order_items (Camada Raw/Bronze)
            ↓
    [Próxima camada: Staging/Silver]
    (Transformações e validações)
```

### Processo Esperado

1. **Ingestão**: Dados são carregados da fonte externa sem transformação
2. **Timestamp**: Registro automático do momento de carga via `load_timestamp`
3. **Preservação**: Dados numéricos mantidos como string para validação posterior
4. **Próximos passos**: Dados serão transformados em camadas subsequentes (staging/silver)

## Observações

### Boas Práticas Implementadas
✅ Nomenclatura clara indicando camada raw  
✅ Sufixo `_string` para campos que serão convertidos posteriormente  
✅ Timestamp de auditoria automático  
✅ Tamanho adequado para VARCHAR (50 caracteres)

### Considerações Importantes

- **Sem Primary Key**: A ausência de PK é intencional na camada raw para permitir duplicatas e facilitar troubleshooting
- **Sem Foreign Keys**: Relacionamentos não são enforçados nesta camada
- **Tipos de Dados**: A conversão de `quantity_string` e `unit_price_string` para tipos numéricos deve ocorrer em camadas superiores
- **Validação**: Dados inválidos ou nulos devem ser tratados em processos ETL subsequentes

### Próximas Etapas Recomendadas

1. Criar tabela staging/silver com conversões de tipo:
   - `quantity_string` → `quantity` (INTEGER)
   - `unit_price_string` → `unit_price` (DECIMAL/NUMERIC)
2. Implementar validações de dados
3. Adicionar constraints apropriados (PK, FK)
4. Criar índices para otimização de consultas

### Possíveis Otimizações

- **Particionamento**: Considerar particionamento por `load_timestamp` se o volume de dados for alto
- **Índices**: Em camadas superiores, criar índices em `order_item_id`, `order_id` e `product_id`
- **Retenção**: Definir política de retenção de dados para a camada raw

## Dependências

### Tabelas Relacionadas (Esperadas)
- `raw_orders` - Tabela de pedidos
- `raw_products` - Tabela de produtos

### Sistemas Upstream
- Sistema de origem dos dados de pedidos (não especificado no script)

### Sistemas Downstream
- Camada staging/silver para transformação de dados
- Processos ETL/ELT de transformação

---

**Versão da Documentação**: 1.0  
**Data de Criação**: Baseado no script fornecido  
**Camada de Dados**: Raw/Bronze (Ingestão)