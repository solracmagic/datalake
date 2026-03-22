# trusted_customers

## Descrição Geral

Esta view cria uma camada de dados confiável (trusted layer) a partir da tabela bruta `raw_customers`. O objetivo é padronizar, limpar e validar os dados de clientes, removendo registros inválidos e aplicando transformações básicas de formatação. Serve como fonte de dados intermediária para consultas e relatórios que dependem de informações de clientes confiáveis.

## Tabelas Envolvidas

| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `raw_customers` | Origem | Tabela bruta contendo dados originais de clientes |

## Colunas

| Coluna | Tipo de Dado | Origem | Descrição |
|--------|--------------|--------|-----------|
| `customer_id` | Identificador | `raw_customers.customer_id` | Identificador único do cliente (validado) |
| `first_name` | String | `raw_customers.first_name` | Primeiro nome do cliente com espaços em branco removidos |
| `last_name` | String | `raw_customers.last_name` | Sobrenome do cliente com espaços em branco removidos |
| `email` | String | `raw_customers.email` | Endereço de e-mail do cliente com espaços em branco removidos |
| `registration_date` | Timestamp | `raw_customers.registration_timestamp` | Data e hora de registro do cliente convertida para tipo TIMESTAMP |
| `full_address` | String | `raw_customers.address_raw` | Endereço completo do cliente (sem transformação) |
| `load_timestamp` | Timestamp | `raw_customers.load_timestamp` | Data e hora do carregamento do registro na origem |

## Joins e Relacionamentos

Não há joins nesta view. Trata-se de uma seleção simples e transformação de dados de uma única tabela de origem (`raw_customers`).

## Filtros e Condições

### Cláusula WHERE

A view aplica validações de qualidade de dados através de duas condições:

```sql
WHERE
    customer_id IS NOT NULL AND TRIM(customer_id) != ''
```

| Condição | Descrição |
|----------|-----------|
| `customer_id IS NOT NULL` | Exclui registros onde o ID do cliente é nulo |
| `TRIM(customer_id) != ''` | Exclui registros onde o ID do cliente contém apenas espaços em branco |

**Resultado:** Apenas clientes com IDs válidos e não vazios são incluídos na view.

## Transformações

### Funções de Limpeza de Dados

| Coluna | Transformação | Função | Propósito |
|--------|---------------|--------|----------|
| `first_name` | `TRIM()` | Remove espaços em branco no início e fim | Padronizar formato |
| `last_name` | `TRIM()` | Remove espaços em branco no início e fim | Padronizar formato |
| `email` | `TRIM()` | Remove espaços em branco no início e fim | Padronizar formato |
| `registration_timestamp` | `CAST(...AS TIMESTAMP)` | Converte para tipo TIMESTAMP | Garantir tipo de dado consistente |

### Alias de Colunas

- `registration_timestamp` → `registration_date` — Renomeia para melhor clareza semântica
- `address_raw` → `full_address` — Renomeia para melhor clareza semântica

## Parâmetros/Variáveis

Não há parâmetros ou variáveis neste script. A view não aceita argumentos de entrada.

## Fluxo de Dados

```
raw_customers (tabela bruta)
        ↓
[Validação de customer_id]
        ↓
[Limpeza de espaços em branco]
        ↓
[Conversão de tipos de dados]
        ↓
[Renomeação de colunas]
        ↓
trusted_customers (view confiável)
```

**Etapas do fluxo:**

1. **Extração**: Lê dados da tabela `raw_customers`
2. **Validação**: Filtra registros com `customer_id` válido (não nulo e não vazio)
3. **Limpeza**: Remove espaços em branco das colunas de texto (`first_name`, `last_name`, `email`)
4. **Conversão**: Converte `registration_timestamp` para tipo TIMESTAMP explícito
5. **Projeção**: Seleciona e renomeia colunas para a view final

## Observações

### Pontos Importantes

- **Validação Mínima**: A view realiza apenas validação básica de `customer_id`. Outras colunas não são validadas quanto a nulidade ou formato.
- **Sem Deduplicação**: A view não remove duplicatas de clientes. Se existirem múltiplos registros com o mesmo `customer_id`, todos serão incluídos.
- **Preservação de Dados Brutos**: A coluna `address_raw` é mantida sem transformação, preservando dados originais.

### Possíveis Otimizações

1. **Validação Adicional**: Considerar adicionar validações para outras colunas críticas (e-mail, data de registro).
   ```sql
   AND email IS NOT NULL AND TRIM(email) != ''
   AND registration_timestamp IS NOT NULL
   ```

2. **Deduplicação**: Se necessário, adicionar lógica para selecionar apenas o registro mais recente por cliente:
   ```sql
   WHERE customer_id IS NOT NULL AND TRIM(customer_id) != ''
   AND load_timestamp = (SELECT MAX(load_timestamp) 
                         FROM raw_customers rc2 
                         WHERE rc2.customer_id = raw_customers.customer_id)
   ```

3. **Índices**: Garantir que `raw_customers.customer_id` possui índice para melhor performance.

### Dependências

- Tabela `raw_customers` deve existir e estar populada
- Compatibilidade com funções `TRIM()` e `CAST()` do banco de dados utilizado

### Casos de Uso

- Base para relatórios de clientes
- Fonte de dados para modelos analíticos
- Integração com dashboards e ferramentas de BI
- Validação de dados antes de processos downstream