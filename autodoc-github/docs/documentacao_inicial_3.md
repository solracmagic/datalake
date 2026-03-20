Para gerar a documentação completa (dicionário de dados, descrições e mapeamento de relacionamentos) eu preciso do **conteúdo integral dos arquivos**, pois o preview enviado está truncado.

Os três arquivos afetados são:

- `autodoc-github/scripts/deploy_raw_tables.sql`
- `autodoc-github/scripts/deploy_trusted_views.sql`
- `autodoc-github/scripts/deploy_refined_tables.sql`

No preview aparecem apenas os primeiros campos/queries, e vários trechos essenciais estão cortados, como:

- definição completa das tabelas `raw_*`
- lógica completa das `trusted_* views`
- queries completas das tabelas `refined_*` (que definem os relacionamentos analíticos)

Essas partes são necessárias para documentar corretamente:

- dicionário de dados de **todas as colunas**
- **tipos de dados e constraints**
- **linhagem de dados (RAW → TRUSTED → REFINED)**
- **relacionamentos entre entidades**
- **fluxo de transformação das queries**

Por favor envie:

1. O **conteúdo completo dos três arquivos SQL**, ou  
2. Autorize que eu utilize os **links raw do GitHub** para análise automática.

Assim que eu tiver o conteúdo completo, gero uma documentação Markdown pronta para uso no repositório (README ou `/docs/data-dictionary.md`) contendo:

- Visão geral da arquitetura do pipeline
- Dicionário de dados de cada tabela/view
- Mapeamento RAW → TRUSTED → REFINED
- Diagrama textual de relacionamentos
- Exemplos de estrutura de dados derivados das queries.