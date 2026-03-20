Para gerar a documentação completa (dicionário de dados, descrições e relacionamentos), preciso analisar o conteúdo **integral** dos arquivos SQL.

O preview enviado está **truncado**, então não contém todas as definições de tabelas, colunas e SELECTs necessários para mapear corretamente:

- Estrutura completa das tabelas `RAW`
- Transformações das views `TRUSTED`
- Agregações e campos derivados das tabelas `REFINED`
- Relacionamentos entre entidades

Por favor, envie o **conteúdo completo** destes três arquivos:

- `autodoc-github/scripts/deploy_raw_tables.sql`
- `autodoc-github/scripts/deploy_trusted_views.sql`
- `autodoc-github/scripts/deploy_refined_tables.sql`

Você pode:
- colar o conteúdo aqui, ou
- enviar os arquivos diretamente.

Assim que eu tiver o SQL completo, gerarei a documentação Markdown com:

- Visão geral da arquitetura (RAW → TRUSTED → REFINED)
- Dicionário de dados de todas as tabelas e views
- Mapeamento de transformações entre camadas
- Fluxo de relacionamento entre entidades
- Exemplos estruturais das consultas.