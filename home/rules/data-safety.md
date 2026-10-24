# Dados

Vale para qualquer plataforma de dados (Databricks, Redshift, BigQuery, Snowflake, Postgres).

- **Escrita só na área designada** (sandbox, dev, schema pessoal). Catálogos de produção e
  espelhos são somente leitura, mesmo quando a permissão permitiria escrever.
- **Nunca `SELECT *` nem leitura linha a linha** em tabela com dado pessoal (CPF, nome,
  e-mail, telefone, nascimento, endereço, senha). Explore estrutura por
  `information_schema`; valide com agregados (`COUNT`, `GROUP BY`, `MIN/MAX`). Nenhum valor
  pessoal vai para nota, log ou resposta.
- **Dado pessoal é mascarado por script antes de qualquer modelo ver.** Arquivo solto com
  possível credencial ou PII fica fora do git e passa por limpeza determinística primeiro.
- **Plano antes de executar.** `CREATE`, `INSERT`, `UPDATE`, `DROP`, job ou pipeline:
  investigue, mostre o que será criado ou alterado, em qual catálogo e schema, e espere o ok.
- **Nenhuma tabela de rascunho sobrando.** Simulação em CTE ou `TEMP VIEW`; se precisar
  materializar, `tmp_<data>_<tema>` apagada na mesma sessão. Antes de criar tabela nova, diga
  qual e por quê.
- **Login é do humano.** O Claude nunca roda `auth login`, nunca gera, pede, cola ou manipula
  token, PAT ou senha. Conexão caída: diga o comando que a pessoa roda e siga sem a etapa.
- **Ajuste em produção sai como código**, em branch e PR, nunca executado direto pelo Claude.
  Validação sombra (regra antiga contra nova, só agregados) antes do PR.
- **Prod é a fonte da verdade** para qualquer mudança de regra: parta do código em
  `origin/main` e do dado de prod, nunca de cópia local.
- **Warehouse e perfil sempre explícitos** em cada comando: cada chamada Bash é um shell novo.
