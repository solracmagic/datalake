# raw_customers.sql

## Descrição Geral

Este script SQL define a estrutura da tabela `raw_customers`, que armazena dados brutos de clientes na camada raw de um data warehouse. A tabela é projetada para receber dados de origem sem transformações significativas, mantendo formatos originais (como timestamps em formato string) para posterior processamento em camadas superiores.

## Tabelas Envolvidas

- `raw_customers` — Tabela de destino criada por este script

## Colunas

| Coluna | Tipo de Dado | Descrição |
|--------|--------------|-----------|
| `customer_id` | `VARCHAR(50)` | Identificador único do cliente |
| `first_name` | `VARCHAR(100)` | Primeiro nome do cliente |
| `last_name` | `VARCHAR(100)` | Sobrenome do cliente |
| `email` | `VARCHAR(255)` | Endereço de e-mail do cliente |
| `registration_timestamp` | `VARCHAR(255)` | Data e hora de registro do cliente armazenada como string (formato bruto) |
| `address_raw` | `TEXT` | Endereço completo do cliente em formato bruto/não estruturado |
| `load_timestamp` | `TIMESTAMP` | Data e hora de carregamento do registro na tabela (gerado automaticamente) |

## Joins e Relacionamentos

Não aplicável — Este é um script DDL de criação de tabela, sem joins ou relacionamentos definidos.

## Filtros e Condições

Não aplicável — Não há cláusulas de filtro neste script de criação de tabela.

## Transformações

Não aplicável — Esta é uma tabela raw sem transformações. Os dados são armazenados em seu formato original.

## Parâmetros/Variáveis

Não há parâmetros ou variáveis definidos neste script.

## Fluxo de Dados

```
Fonte de Dados (Sistema Transacional)
            ↓
    [raw_customers]
            ↓
Camadas Superiores (Staging/Trusted/Analytics)
```

1. **Ingestão**: Dados brutos de clientes são carregados diretamente da fonte
2. **Armazenamento**: Dados mantidos em formato original sem transformações
3. **Timestamp Automático**: Cada registro recebe automaticamente um `load_timestamp` no momento da inserção
4. **Processamento Posterior**: Dados serão transformados em camadas subsequentes do pipeline

## Observações

### Características da Camada Raw

- **Formato Original**: Campos como `registration_timestamp` são mantidos como `VARCHAR` para preservar o formato original da fonte
- **Dados Não Estruturados**: O campo `address_raw` usa tipo `TEXT` para acomodar endereços em diversos formatos
- **Auditoria**: O campo `load_timestamp` permite rastreabilidade de quando cada registro foi carregado

### Considerações Importantes

⚠️ **Chave Primária**: A tabela não possui constraint de `PRIMARY KEY` definida. Considere adicionar:
```sql
ALTER TABLE raw_customers ADD PRIMARY KEY (customer_id);
```

⚠️ **Validação de Email**: Não há validação de formato de email. Considere adicionar constraint ou validação em camadas superiores.

### Possíveis Otimizações

1. **Indexação**: Criar índice em `customer_id` para melhorar performance de consultas
2. **Particionamento**: Se o volume for alto, considere particionar por `load_timestamp`
3. **Constraints**: Adicionar `NOT NULL` em campos obrigatórios como `customer_id` e `email`

### Dependências

- Esta tabela serve como fonte para camadas de transformação (staging/trusted)
- Provavelmente alimenta processos ETL/ELT subsequentes
- Pode ser referenciada por views ou procedures de transformação de dados

### Padrão de Nomenclatura

O prefixo `raw_` indica claramente que esta é uma tabela da camada raw, seguindo boas práticas de organização de data warehouse em arquitetura medallion (bronze/silver/gold) ou similar.