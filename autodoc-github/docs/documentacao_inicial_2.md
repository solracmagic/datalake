Para gerar a documentação completa (dicionário de dados, descrição de tabelas/views e mapeamento de relacionamentos), preciso do **conteúdo completo dos arquivos SQL**.  
Os previews enviados estão truncados e não incluem todas as definições de colunas, `SELECTs` das views ou possíveis junções.

Por favor, envie o **conteúdo integral** destes arquivos:

- `autodoc-github/scripts/deploy_raw_tables.sql`
- `autodoc-github/scripts/deploy_trusted_views.sql`
- `autodoc-github/scripts/deploy_refined_tables.sql`

Assim que eu tiver os scripts completos, gerarei um documento `.md` contendo:

- Visão geral da arquitetura (RAW → TRUSTED → REFINED)
- Dicionário de dados de todas as **tabelas RAW**
- Dicionário de dados de todas as **views TRUSTED**
- Descrição das **tabelas analíticas REFINED**
- **Mapeamento de relacionamentos** entre entidades
- **Fluxo de dados entre camadas**
- Exemplos de estrutura derivados dos próprios SQLs.