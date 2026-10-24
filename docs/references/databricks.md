# Claude Code com Databricks (em AWS)

Referência para o dia em que a empresa usa Databricks. Pesquisado em 2026-10-24 na
documentação oficial; links no fim. Nada disto é plugin do cérebro: é o que ler antes
de configurar o repositório da empresa.

## 1. Em uma frase

**Skills ensinam o agente a trabalhar; MCP deixa o agente trabalhar.** Instale as
skills oficiais da Databricks, conecte os MCPs gerenciados via Unity Gateway com OAuth,
e trave o CLI com permissões: leitura livre, deploy em `dev` com confirmação, `prod`
nunca a partir da sessão.

## 2. Skills oficiais (plugin `databricks`)

Repositório `databricks/databricks-agent-skills`, ~35 skills (`databricks-core`, `-dabs`,
`-jobs`, `-pipelines`, `-dbsql`, `-unity-catalog`, `-python-sdk`, `-apps`,
`-model-serving`, `-vector-search`...). Já está no marketplace oficial da Anthropic.

```bash
claude plugin install databricks@claude-plugins-official --scope project
```

Ou pelo CLI da Databricks, que é a rota canônica (o marketplace pode atrasar):

```bash
databricks aitools install --agents claude-code --scope project --skills databricks-dabs,databricks-dbsql,databricks-unity-catalog
```

O plugin traz `/databricks:setup`, `/databricks:doctor` e três hooks: um roteador em
`UserPromptSubmit`, contexto em `SessionStart` e dica de autenticação em `PostToolUse`
de Bash. São scripts Python que rodam a cada prompt; leia-os antes de instalar em
máquina de empresa.

Escopo **project**, não user: Databricks é contexto da empresa, não do cérebro.

Desinstale antes o `databricks-solutions/ai-dev-kit` e o `databrickslabs/mcp` se
existirem: ambos estão **descontinuados** e conflitam com as skills oficiais.

## 3. MCP: Unity Gateway, não endpoints legados

Os MCPs gerenciados vivem como objetos do Unity Catalog em `system.ai`:
`system.ai.dbsql` (SQL), `system.ai.genie_one_mcp` (Genie), `system.ai.sandbox`,
`system.ai.web_search`, mais conectores externos. URL:
`https://<workspace>/ai-gateway/mcp-services/<catalog>.<schema>.<service>`. As
permissões do UC valem sempre. Os endpoints antigos em `/api/2.0/mcp/...` existem, mas
pulam a governança do Gateway; não use em integração nova.

Registro recomendado, pelo CLI do Unity Gateway (precisa de admin da conta ter
habilitado o beta):

```bash
uv tool install git+https://github.com/databricks/unity-gateway
ug mcp add --agents claude --names system.ai.dbsql
ug doctor
```

Manual, com o cliente OAuth embutido do Claude Code:

```bash
claude mcp add --transport http --scope project --client-id claude-code --callback-port 3118 \
  databricks-sql "https://<workspace>/ai-gateway/mcp-services/system.ai.dbsql"
```

Depois `/mcp` para autenticar. Em `.mcp.json` versionado, use só `${VAR}` para host e
nunca token literal.

## 4. Autenticação

- **Humano no terminal: OAuth U2M.** `databricks auth login --host https://<ws>.cloud.databricks.com`
  cria um perfil nomeado em `~/.databrickscfg`; o token fica no keychain do SO (CLI
  1.0+). Use `-p <perfil>` em todo comando.
- **CI e automação: OAuth M2M** com service principal.
- **PAT é legado.** A Databricks recomenda OAuth e admins podem desligar PAT no
  workspace. Se a empresa ainda usa, o PAT fica em variável de ambiente, nunca em
  `CLAUDE.md`, `.mcp.json` ou log de sessão.

## 5. Fluxo de desenvolvimento

- **Databricks Asset Bundles (DABs) é a unidade de trabalho.** Ciclo:
  `databricks bundle validate -t dev` → `deploy -t dev` → `run -t dev <job>` →
  `summary`. Templates: `default-python`, `default-sql`, `dbt-sql`, `pydabs`.
  `bundle generate job --existing-job-id` e `deployment bind` adotam recursos já
  existentes.
- **Targets**: `dev` com `mode: development` (prefixo `[dev <user>]`, schedules
  pausados, sem lock) e `default: true`; `prod` com `mode: production`, verificação
  de `git.branch: main` e `run_as` service principal.
- **Databricks Connect para teste local**: `DatabricksSession.builder.getOrCreate()`.
  `databricks-connect` e `pyspark` não coexistem no mesmo venv. `pytest` no terminal
  usa o perfil DEFAULT: aponte-o para serverless ou cluster de dev. Mantenha a
  transformação como função sobre DataFrame para a maioria dos testes rodar em
  SparkSession local; Connect só para integração.
- **Notebook como código**: arquivos `.py` iniciados com
  `# Databricks notebook source`, células separadas por `# COMMAND ----------`. Saídas
  não são versionadas.
- **dbt**: `dbt-databricks` 1.8+ em venv próprio, OAuth, segredos por variável de
  ambiente; o template `dbt-sql` do DAB roda dbt como task de job.

## 6. Permissões para o `.claude/settings.json` do repositório

Avaliação é deny, depois ask, depois allow; primeira regra que casa vence; cada
subcomando de `&&`/`|` é avaliado separadamente. São casamentos de texto, não
fronteira de segurança: `sh -c` ou caminho absoluto escapam. Para garantia dura, hook
`PreToolUse` ou sandbox.

```json
{
  "permissions": {
    "allow": [
      "Bash(databricks bundle validate *)", "Bash(databricks bundle summary *)",
      "Bash(databricks auth profiles *)", "Bash(databricks auth describe *)",
      "Bash(databricks jobs list *)", "Bash(databricks jobs get *)", "Bash(databricks jobs list-runs *)",
      "Bash(databricks clusters list *)", "Bash(databricks warehouses list *)",
      "Bash(databricks catalogs list *)", "Bash(databricks schemas list *)",
      "Bash(databricks tables list *)", "Bash(databricks tables get *)",
      "Bash(databricks pipelines list *)", "Bash(uv run pytest *)"
    ],
    "ask": [
      "Bash(databricks bundle deploy *)", "Bash(databricks bundle run *)",
      "Bash(databricks jobs run-now *)", "Bash(databricks jobs create *)",
      "Bash(databricks api post *)", "Bash(databricks api patch *)"
    ],
    "deny": [
      "Bash(databricks bundle destroy *)", "Bash(databricks api delete *)",
      "Read(~/.databrickscfg)", "Read(./.env)"
    ]
  }
}
```

`-t prod` em regra `deny` funciona, mas `-p <perfil-prod>` ou um `databricks.yml` com
`prod` como target padrão escapam. Por isso: `dev` com `default: true` e a frase
"nunca deploy em prod a partir desta sessão" no `CLAUDE.md`. Se a equipe usa
`/sql/statements`, trate DDL como `ask`; o mesmo para qualquer tool `mcp__databricks-*`
que não seja SELECT.

## 7. Molde de `CLAUDE.md` para repositório Databricks

```markdown
# <projeto> — pipelines Databricks (AWS)

## Ambientes
- dev: perfil `acme-dev` (OAuth U2M), bundle target `dev` (default)
- prod: perfil `acme-prod`, target `prod`, run_as service principal.
  NUNCA deploy/run/destroy em prod a partir desta sessão; prod é só CI.

## Dados (Unity Catalog)
- catálogos `acme_dev`, `acme_prod`; schemas por domínio (`bronze_sales`, `silver_sales`, `gold_finance`)
- tabelas snake_case, Delta gerenciadas, liquid clustering (sem particionamento abaixo de 1 TB)
- DDL/DROP/ALTER fora do bundle só com aprovação explícita

## Fluxo
- `uv sync`; `uv run pytest tests/` (unit: DataFrames locais; `tests/integration` via Databricks Connect, DEFAULT = acme-dev serverless)
- `databricks bundle validate -t dev` antes de cada commit; `deploy -t dev && run -t dev <job>` para testar
- notebooks são `.py` (`# Databricks notebook source`); lógica compartilhada em `src/<pkg>/`

## Segredos
- nenhum token no repo; autenticação só por perfil do CLI. `.databrickscfg` e `.env` são proibidos.
```

## 8. Checklist de revisão (Spark, Delta, UC, custo)

- **Layout**: sem particionamento abaixo de 1 TB; liquid clustering (`CLUSTER BY`)
  em vez de partição ou Z-order; se particionar, >= 1 GB por partição e nunca em
  coluna de alta cardinalidade.
- **Delta**: tabelas gerenciadas com predictive optimization; `CREATE OR REPLACE` em
  vez de drop e recriar; MERGE com condição estreita usando predicado de
  clustering, Low Shuffle Merge, optimized writes; nada de `.cache()` em Delta; nunca
  tocar nos Parquet diretamente.
- **Joins e skew**: AQE já cuida de skew e coalesce; `broadcast()` explícito quando o
  lado pequeno é conhecido; prefira AQE a hints manuais de SKEW.
- **Governança**: catálogo é a fronteira de isolamento (por ambiente ou time),
  schema por time, menor privilégio; `MODIFY` em prod só para service principal.
- **Custo**: serverless para a maioria dos jobs; SQL warehouse para SQL; compute
  clássico só com configuração custom; nunca all-purpose cluster em automação.

## 9. Claude Code rodando em modelo hospedado pela Databricks

Quando a empresa quer gasto e governança dentro do Databricks:
`ANTHROPIC_BASE_URL=https://<workspace>/ai-gateway/anthropic`, `ANTHROPIC_MODEL=<nome
UC do modelo>`, `CLAUDE_CODE_USE_GATEWAY=1` e header
`x-databricks-use-coding-agent-mode: true`. `ug usage` mostra consumo. Recursos
exclusivos do claude.ai somem (ver `docs/VSCODE.md`).

## Não verificado

- Não há post oficial do blog da Databricks sobre Claude Code; só docs e artigos de
  comunidade. Nada oficial sobre Claude Agent SDK em Databricks Apps.
- `aitools` e `ug` são de 2026 e estão em beta; dependem de admin da conta habilitar
  Unity Gateway e apps OAuth.

## Fontes

- MCP gerenciado: https://docs.databricks.com/aws/en/generative-ai/mcp/managed-mcp
- Claude Code + Unity Gateway: https://docs.databricks.com/aws/en/ai-gateway/coding-agent-claude
- Skills oficiais: https://docs.databricks.com/aws/en/agent-skills/ e https://github.com/databricks/databricks-agent-skills
- `aitools`: https://docs.databricks.com/aws/en/dev-tools/cli/reference/aitools-commands
- Autenticação do CLI: https://docs.databricks.com/aws/en/dev-tools/cli/authentication
- DABs: https://docs.databricks.com/aws/en/dev-tools/cli/bundle-commands e https://docs.databricks.com/aws/en/dev-tools/bundles/deployment-modes
- Databricks Connect e testes: https://docs.databricks.com/aws/en/dev-tools/databricks-connect/python/testing
- Permissões do Claude Code: https://code.claude.com/docs/en/permissions
- Partições, Delta, AQE, UC, compute: https://docs.databricks.com/aws/en/tables/partitions , https://docs.databricks.com/aws/en/delta/best-practices , https://docs.databricks.com/aws/optimizations/aqe , https://docs.databricks.com/aws/en/data-governance/unity-catalog/best-practices , https://docs.databricks.com/aws/en/compute/choose-compute
