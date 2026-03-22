# raw_customers.sql

## Descrição Geral

Este script SQL define a estrutura da tabela `raw_customers`, que armazena dados brutos de clientes na camada raw (bronze) de um data warehouse. A tabela é projetada para receber dados de clientes em seu formato original, sem transformações, servindo como ponto de entrada inicial no pipeline de dados.

## Tabelas Envolvidas

- `raw_customers` — Tabela de destino criada por este script

## Colunas

| Coluna | Tipo de Dado | Descrição |
|--------|--------------|-----------|
| `customer_id` | VARCHAR(50) | Identificador único do cliente |
| `first_name` | VARCHAR(100) | Primeiro nome do cliente |
| `last_name` | VARCHAR(100) | Sobrenome do cliente |
| `email` | VARCHAR(255) | Endereço de e-mail do cliente |
| `registration_timestamp` | VARCHAR(255) | Data e hora de registro do cliente armazenada como string (formato bruto) |
| `address_raw` | TEXT | Endereço completo do cliente em formato não estruturado |
| `load_timestamp` | TIMESTAMP | Timestamp automático de quando o registro foi inserido na tabela |

### Detalhamento das Colunas Principais

- **`customer_id`**: Chave primária lógica para identificação do cliente
- **`first_name` / `last_name`**: Dados pessoais básicos do cliente
- **`email`**: Informação de contato principal
- **`registration_timestamp`**: Mantido como VARCHAR para preservar o formato original dos dados de origem
- **`address_raw`**: Campo TEXT para acomodar endereços de tamanhos variados sem estruturação
- **`load_timestamp`**: Metadado de auditoria com valor padrão automático

## Joins e Relacionamentos

Não aplicável — este script apenas cria a estrutura da tabela, sem realizar joins.

## Filtros e Condições

Não aplicável — não há cláusulas WHERE ou HAVING neste DDL.

## Transformações

Não aplicável — esta é uma tabela raw sem transformações. Os dados são armazenados em seu formato original.

### Valor Padrão

- `load_timestamp` possui valor padrão `CURRENT_TIMESTAMP`, que registra automaticamente o momento da inserção do registro.

## Parâmetros/Variáveis

Não há parâmetros ou variáveis neste script.

## Fluxo de Dados

```
Fonte de Dados (Sistema Transacional/API/Arquivo)
                ↓
         [raw_customers]
                ↓
    (Próxima camada: staging/bronze → silver)
```

1. **Ingestão**: Dados brutos de clientes são carregados diretamente nesta tabela
2. **Preservação**: Formato original é mantido (ex: timestamps como strings)
3. **Auditoria**: Timestamp de carga é registrado automaticamente
4. **Downstream**: Dados serão consumidos por processos de transformação nas camadas subsequentes

## Observações

### Características da Camada Raw

- ✅ **Dados não transformados**: Preserva formato original da fonte
- ✅ **Tipos flexíveis**: VARCHAR/TEXT para acomodar variações nos dados de origem
- ✅ **Auditoria**: Campo `load_timestamp` para rastreabilidade

### Considerações Importantes

1. **Ausência de Chave Primária**: A tabela não define `customer_id` como PRIMARY KEY. Considerar adicionar:
   ```sql
   PRIMARY KEY (customer_id)
   ```

2. **Ausência de Constraints**: Não há validações de NOT NULL ou UNIQUE. Para dados críticos, considerar:
   ```sql
   customer_id VARCHAR(50) NOT NULL,
   email VARCHAR(255) UNIQUE
   ```

3. **Formato de Timestamp**: `registration_timestamp` está como VARCHAR para flexibilidade, mas requer conversão nas camadas seguintes

4. **Endereço Não Estruturado**: `address_raw` em formato TEXT requer parsing posterior para extração de componentes (rua, cidade, CEP, etc.)

### Possíveis Otimizações

- Adicionar índice em `customer_id` para melhor performance em consultas
- Adicionar índice em `load_timestamp` para queries de auditoria
- Considerar particionamento por `load_timestamp` se o volume for alto
- Implementar política de retenção de dados (data retention)

### Dependências

- **Upstream**: Sistema fonte de dados de clientes (CRM, e-commerce, etc.)
- **Downstream**: Tabelas staging/silver que consumirão estes dados para limpeza e transformação

### Próximos Passos Sugeridos

1. Criar tabela staging/silver com tipos de dados apropriados
2. Implementar processo ETL para transformar `registration_timestamp` de VARCHAR para TIMESTAMP
3. Estruturar `address_raw` em componentes individuais
4. Implementar validações de qualidade de dados