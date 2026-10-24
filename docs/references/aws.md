# Claude Code com AWS

Referência para o dia em que a empresa usa AWS. Pesquisado em 2026-10-24 na
documentação oficial da AWS e do Claude Code; links no fim. Nada disto é plugin do
cérebro: é o que ler antes de configurar o repositório da empresa.

## 1. Em uma frase

Instale `aws-core` (e `aws-data-analytics` se o trabalho é dados), conecte o **AWS MCP
Server gerenciado via proxy SigV4 com `--read-only`**, use perfil SSO, e trave o CLI:
leitura livre, `plan`/`diff`/`synth` livres, `apply`/`deploy` com confirmação, nunca
`-auto-approve`.

## 2. MCP: o servidor gerenciado substituiu os locais

O **Agent Toolkit for AWS** é o sucessor dos servidores MCP do `awslabs/mcp`. A AWS
manda remover `aws-api-mcp-server` e `aws-knowledge-mcp-server` e usar o **AWS MCP
Server** remoto (`https://aws-mcp.<região>.api.aws/mcp`). Ferramentas: busca e leitura
de documentação, `retrieve_skill`, regiões e disponibilidade, `run_script` (Python em
sandbox com acesso à API) e URLs pré-assinadas.

Duas autenticações:

- **OAuth**: `claude mcp add aws-mcp https://aws-mcp.us-east-1.api.aws/mcp --transport http`.
  Precisa da policy `AWSMCPSignInOAuthAccessPolicy`. Sem multi-perfil e sem modo
  somente leitura.
- **SigV4 pelo MCP Proxy for AWS** (recomendado para Claude Code): usa a cadeia de
  credenciais do CLI local, relê do disco a cada chamada (então `aws sso login` vale
  sem reiniciar), e aceita `--read-only` e `--profile <a> <b>`:

  ```bash
  claude mcp add-json --scope project aws-mcp '{"type":"stdio","command":"uvx","args":["mcp-proxy-for-aws-cli@latest","https://aws-mcp.us-east-1.api.aws/mcp","--read-only","--metadata","AWS_REGION=sa-east-1"]}'
  ```

O agente roda sob **o seu** principal IAM. A AWS adicionou as condition keys
`aws:ViaAWSMCPService` e `aws:CalledViaAWSMCP`, com que o admin nega ações mutantes
quando chamadas via MCP; tudo cai no CloudTrail.

Servidores locais ainda úteis (`uvx awslabs.<nome>@latest`, env `AWS_PROFILE`,
`AWS_REGION`, `FASTMCP_LOG_LEVEL=ERROR`):

| Servidor | Para quê | Modo padrão |
|---|---|---|
| `aws-iac-mcp-server` | cfn-lint/cfn-guard, troubleshooting de CloudFormation, docs de CDK | só leitura; sem tool de deploy |
| `aws-dataprocessing-mcp-server` | Glue, EMR, Athena | só leitura; Athena só SELECT; `--allow-write` e `--allow-sensitive-data-access` abrem |
| `redshift-mcp-server` | Redshift Data API | `ACCESS_MODE=read-only` com `BEGIN READ ONLY`; privilégio do usuário de banco é o controle real |
| `s3-tables-mcp-server` | S3 Tables / Iceberg | só leitura; `--allow-write` |
| `billing-cost-management-mcp-server` | Cost Explorer, Budgets, Pricing | não é estritamente só leitura |

**Descontinuados**: `terraform-mcp-server` (use o da HashiCorp, que é o plugin
`terraform` do marketplace oficial), `ccapi-mcp-server`, `aws-api-mcp-server`.

## 3. Plugins oficiais (marketplace `claude-plugins-official`)

Todos vêm de `aws/agent-toolkit-for-aws` ou `awslabs/agent-plugins`. Instale em
**escopo project**: AWS é contexto da empresa.

```bash
claude plugin install aws-core@claude-plugins-official --scope project
claude plugin install aws-data-analytics@claude-plugins-official --scope project
```

- **`aws-core`**: skills `aws-cdk`, `aws-cloudformation`, `aws-serverless`,
  `aws-containers`, `aws-storage`, `aws-observability`, `aws-iam`, `aws-security`,
  `aws-secrets-manager`, `aws-billing-and-cost-management`, `aws-sdk-python-usage`,
  `aws-well-architected-review`, `amazon-bedrock`... O `.mcp.json` dele aponta para o
  AWS MCP Server via `mcp-proxy-for-aws-cli==1.7.0 --skip-auth` (só pula a assinatura
  quando não há credencial; com CLI configurado assina SigV4). **Sem `--read-only`**:
  se quiser o modo só leitura, registre o MCP você mesmo como na seção 2 e não conte
  com o do plugin.
- **`aws-data-analytics`**: 18 skills para engenharia de dados: data lake em S3
  Tables/Iceberg, ingestão, consulta via Athena, Glue Catalog e conexões, Redshift,
  MWAA (autoria, teste, debug, upgrade), MSK, Flink gerenciado, OpenSearch.
- Por stack: `terraform` (MCP da HashiCorp), `aws-serverless` (Lambda, SAM, API
  Gateway), `databases-on-aws`. `aws-agents`, `deploy-on-aws`, `aws-transform` só com
  necessidade concreta.

Antes de instalar em máquina de empresa, leia o `.mcp.json` e os hooks do plugin: o
README da Anthropic avisa que o conteúdo é de terceiros.

## 4. Claude Code via Amazon Bedrock

Quando a empresa exige que o tráfego fique na conta dela: `/setup-bedrock` no Claude
Code, ou manualmente em `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "us-east-1",
    "AWS_PROFILE": "acme-bedrock",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "us.anthropic.claude-opus-4-8",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "us.anthropic.claude-sonnet-4-6",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "us.anthropic.claude-haiku-4-5-20251001-v1:0"
  },
  "awsAuthRefresh": "aws sso login --profile acme-bedrock"
}
```

Fixe os modelos: sem pin o padrão é o Opus mais recente, cobrado como Opus. Prefixos
`eu.`, `apac.`, `global.` via `ANTHROPIC_BEDROCK_REGION_PREFIX`.

IAM mínimo: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`,
`bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile` sobre
`inference-profile/*`, `application-inference-profile/*`, `foundation-model/*`, mais
`aws-marketplace:ViewSubscriptions/Subscribe` condicionado a
`aws:CalledViaLast=bedrock.amazonaws.com`.

Por que a empresa exige: dado fica na conta e região dela, auditoria por IAM e
CloudTrail, fatura consolidada, nenhuma chave da Anthropic para distribuir, SSO por
federação OIDC (Okta/Entra → Cognito → STS). A AWS publica o "Guidance for Claude Code
with Amazon Bedrock" com esse desenho. Custo: sem WebSearch, sem `/logout`, prompt
caching depende da região, e os recursos exclusivos do claude.ai somem (ver
`docs/VSCODE.md`). Sem exigência da empresa, login claude.ai Team/Enterprise é mais
simples.

## 5. Higiene de credenciais

- Nenhuma chave em `CLAUDE.md`, prompt, `.mcp.json` ou log de sessão. Perfis SSO
  (`aws configure sso`, `aws sso login`) ou `aws login` (CLI 2.32+, rotação em 12 h).
  A própria doc do Claude Code cita o alerta da AWS contra access key de usuário IAM.
- **Um perfil só leitura para o agente** e um perfil de deploy para o qual você troca
  de propósito. Deny de ações mutantes com `aws:ViaAWSMCPService` no lado IAM.
- Em `.mcp.json` versionado, `${AWS_PROFILE:-default}` e nunca valor literal.

## 6. Permissões para o `.claude/settings.json` do repositório

Ordem deny → ask → allow; `*` casa texto; ` *` no fim também casa o comando sem
argumento; comandos compostos são divididos e cada parte precisa casar. São
guarda-corpos, não fronteira de segurança: `/usr/bin/aws` ou `sh -c` escapam. IAM é a
fronteira.

```json
{
  "permissions": {
    "allow": [
      "Bash(aws sts get-caller-identity)",
      "Bash(aws * describe-*)", "Bash(aws * list-*)", "Bash(aws * get-*)", "Bash(aws s3 ls *)",
      "Bash(terraform validate *)", "Bash(terraform plan *)",
      "Bash(cdk synth *)", "Bash(cdk diff *)", "Bash(sam validate *)"
    ],
    "ask": [
      "Bash(aws *)",
      "Bash(terraform apply *)", "Bash(terraform destroy *)",
      "Bash(cdk deploy *)", "Bash(cdk destroy *)", "Bash(sam deploy *)",
      "mcp__aws-mcp__aws___run_script"
    ],
    "deny": [
      "Read(./.env)", "Read(~/.aws/**)",
      "Bash(aws configure *)", "Bash(aws iam create-access-key *)",
      "Bash(terraform apply -auto-approve *)", "Bash(cdk deploy * --require-approval never *)"
    ]
  }
}
```

## 7. Molde de `CLAUDE.md` para repositório AWS

```markdown
# <repo>

## Contas (nunca credencial aqui)
- dev: 1111..., sa-east-1, perfil `acme-dev` (`aws sso login --profile acme-dev`)
- prod: 2222..., sa-east-1, perfil `acme-prod-ro` (só leitura; deploy só por CI)

## Stack
Terraform 1.9 + Terragrunt; Glue 4.0 PySpark; Athena/Iceberg em S3 Tables; Airflow em MWAA.

## Nomes e tags
`acme-<env>-<dominio>-<recurso>`; tags Owner, CostCenter, Env.

## Fluxo
- Plano: `make plan ENV=dev` (terraform init -reconfigure && terraform plan -out=tf.plan)
- Nunca rode apply, destroy ou deploy: pare e me mostre o plano.
- Testes: `pytest tests/`; Glue local via `make glue-local`.

## Convenções
Jobs PySpark em `jobs/`, um job Glue por módulo, IAM de menor privilégio, sem `*` em Resource.
```

Mantenha abaixo de 200 linhas. Itens pessoais vão em `CLAUDE.local.md` (no
`.gitignore`); regras por caminho em `.claude/rules/*.md`.

## 8. IaC

- Terraform: `validate` → `plan -out` → revisar → `apply` só com confirmação. Nunca
  `-auto-approve`.
- CDK: `synth` e `diff` antes de `deploy`; nunca `--require-approval never`.
- SAM: `validate` → `deploy --confirm-changeset`.
- CloudFormation: `validate_cloudformation_template` e
  `check_cloudformation_template_compliance` do `aws-iac-mcp-server` (cfn-lint e
  cfn-guard), change set antes de executar.
- Modo plano do Claude Code para toda mudança de infra; deploy fica em `ask` ou só no
  CI. Revisão de segurança antes de PR de infra.

## Não verificado

- Se `--read-only` do proxy esconde as tools ou só recusa chamadas.
- Status atual de `cdk-mcp-server` e `core-mcp-server` (sumiram de `src/`; parecem
  absorvidos pelo `aws-iac`).
- Flag de só leitura do `iam-mcp-server`.

## Fontes

- AWS MCP Server: https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started-aws-mcp-server.html e https://docs.aws.amazon.com/agent-toolkit/latest/userguide/understanding-mcp-server-tools.html
- MCP Proxy for AWS: https://github.com/aws/mcp-proxy-for-aws
- IAM para MCP gerenciado: https://aws.amazon.com/blogs/security/understanding-iam-for-managed-aws-mcp-servers/
- Servidores locais: https://github.com/awslabs/mcp
- Plugins: https://docs.aws.amazon.com/agent-toolkit/latest/userguide/plugins.html e https://github.com/aws/agent-toolkit-for-aws
- Bedrock: https://code.claude.com/docs/en/amazon-bedrock e https://docs.aws.amazon.com/solutions/claude-code-with-amazon-bedrock/
- Permissões e memória: https://code.claude.com/docs/en/permissions , https://code.claude.com/docs/en/memory , https://code.claude.com/docs/en/mcp
- Plugins e skills para AWS (AWS Builder): https://builder.aws.com/content/39vdJOeWD0pbA7hpKpW1a2tBw8x/extending-claude-code-with-plugins-and-skills-for-aws-development
