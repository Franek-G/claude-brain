# claude-brain — arquitetura proposta

> Escrito em 2026-10-24. Fase 1 implementada no mesmo dia. Interpretação do pedido: *"quero uma configuração minha do
> Claude Code, versionada no GitHub, que eu instale em qualquer empresa onde trabalhar,
> sem levar dado da empresa comigo nem deixar meu método para trás."*

## 1. O que você está pedindo (interpretação)

Três coisas distintas, que hoje estão misturadas na sua máquina:

| Camada | O que é | Onde vive hoje | Onde deve viver |
|---|---|---|---|
| **Cérebro** (método) | Como você trabalha com o Claude: GDP, `/resume`, `/compress`, `/preserve`, hooks, sub-agents, regras de código, permissões base | `~/.claude/commands`, `~/.claude/hooks`, `_claude/15-gdp.md` no vault | **Repo `claude-brain` no GitHub** (portátil, sem dado de empresa, sem caminho absoluto) |
| **Projeto da empresa** (conteúdo) | `CLAUDE.md` do repo, `decisions.yaml`, `CC-Session-Logs/`, permissões do projeto | dentro de cada repo (ex.: `chucktcg-pricer/`) | **Continua no git da empresa**. O cérebro só fornece o *molde* |
| **Estado local** (privado) | transcripts, `~/.claude/projects`, `agent-memory`, vault Obsidian, credenciais | `~/.claude/*`, `~/Documents/Obsidian Vault` | **Nunca entra no cérebro.** Fica na máquina ou no vault |

O desenho inteiro gira em torno de uma fronteira: **nada da empresa sobe para o cérebro,
nada do cérebro depende da empresa.** É o mesmo princípio do cexai-2 ("hub como dependência
fixada, instalado no boot, nunca copiado"), aplicado a você como pessoa em vez de a uma
empresa.

## 2. Mecanismo oficial que torna isso possível

O Claude Code já tem o encaixe certo, não precisa de framework:

- **Marketplace pessoal**: um repo com `.claude-plugin/marketplace.json`. Em qualquer máquina:
  `claude plugin marketplace add Franek-G/claude-brain` e depois
  `claude plugin install brain-core@claude-brain --scope user`. Fixa versão com `#v1.2.0`.
- **Plugins**: pasta com `.claude-plugin/plugin.json` + `skills/`, `agents/`, `hooks/hooks.json`,
  `.mcp.json`. Hooks usam `${CLAUDE_PLUGIN_ROOT}` (sem caminho absoluto) e
  `${CLAUDE_PLUGIN_DATA}` para estado que sobrevive a updates.
- **Camada `~/.claude` fora de plugin**: `~/.claude/CLAUDE.md`, `~/.claude/rules/*.md`
  (carregam sem diálogo de aprovação) e `settings.json`. Plugins não distribuem *rules*
  nem *settings*, então essa camada é instalada por um script de bootstrap.
- **Skills** substituem `commands/` (`.claude/commands/*.md` ainda funciona, mas
  `skills/<nome>/SKILL.md` é o formato atual, com `context: fork`, `allowed-tools`, `paths`).
- **Sub-agents** com `memory: user` ganham `~/.claude/agent-memory/<nome>/MEMORY.md`
  persistente.
- **Hooks**: `SessionStart` com `hookSpecificOutput.additionalContext` injeta contexto;
  `PreToolUse` com exit 2 bloqueia.

Limitação conhecida: sessões cloud (claude.ai/code) não carregam plugins nem settings locais.

## 3. Estrutura do repositório

```
claude-brain/
├── README.md                     instalação em 3 comandos + o que é / o que não é
├── ARQUITETURA.md                este documento
├── RULER.md                      portão de entrada (ver §5)
├── AGENTS.md                     contrato neutro; CLAUDE.md = "@AGENTS.md" (padrão cexai)
├── CLAUDE.md
├── decisions.yaml                decisões do próprio cérebro (schema D### que você já usa)
├── LICENSE                       MIT ou Apache-2.0
├── .claude-plugin/
│   └── marketplace.json          marketplace "claude-brain", source "./plugins/<x>"
├── plugins/
│   ├── brain-core/               IDENTIDADE E MÉTODO
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── gdp/              Guided Decision Protocol (hoje _claude/15-gdp.md)
│   │   │   ├── verify-before-done/   "feito" = re-executado, não resumido (superpowers)
│   │   │   ├── writing-skills/   como escrever/testar uma skill (superpowers + anthropics/skills template)
│   │   │   └── worktrees/        trabalho paralelo isolado
│   │   └── agents/
│   │       ├── planner.md        (ecc)
│   │       ├── code-reviewer.md  (ecc / zebbern)
│   │       ├── security-reviewer.md
│   │       └── root-cause-debugger.md
│   ├── brain-memory/             MEMÓRIA — o que você já construiu, generalizado
│   │   ├── skills/
│   │   │   ├── resume/           hoje ~/.claude/commands/resume.md
│   │   │   ├── compress/         hoje ~/.claude/commands/compress.md
│   │   │   ├── preserve/         hoje ~/.claude/commands/preserve.md
│   │   │   └── decide/           captura decisão no ato (backlog do vault, D### schema)
│   │   ├── hooks/hooks.json      SessionStart: injeta "modo detectado + pendências"
│   │   │                         Stop: suggest_compress (hoje ~/.claude/hooks/)
│   │   └── scripts/
│   │       ├── detect_mode.sh    VAULT | PROJETO | NENHUM — lê brain.local.json, não hardcode
│   │       ├── preflight_tfidf.py  hoje _scripts/ do vault
│   │       └── build_claude_md.sh  hoje _scripts/ do vault
│   ├── brain-guard/              SEGURANÇA — hooks determinísticos, exit 2
│   │   └── hooks/hooks.json      bloqueia: segredo em Write/Edit, `git push --force` em main,
│   │                             `--no-verify`, `rm -rf` fora do repo; avisa: dev-server
│   │                             fora de tmux, arquivo .env tocado
│   ├── brain-company/            MOLDE PARA A EMPRESA
│   │   ├── skills/init-project/  /brain-company:init-project → cria .claude/, CLAUDE.md
│   │   │                         semente, decisions.yaml, CC-Session-Logs/, settings.json
│   │   │                         com allow-list enxuta e `git push` em "ask"
│   │   └── templates/            CLAUDE.md.tmpl, decisions.yaml.tmpl, settings.json.tmpl,
│   │                             .gitattributes (eol=lf), .gitignore
│   └── brain-search/ (opcional, fase 3)  .mcp.json para XERJ ou similar; busca local
│                                 sobre logs/código quando TF-IDF não bastar
├── home/                         CAMADA ~/.claude (não é plugin; instalada por script)
│   ├── CLAUDE.md                 quem você é, idioma, GDP resumido, @imports de rules/
│   ├── rules/
│   │   ├── git-workflow.md       (ecc rules/common, reescrito)
│   │   ├── testing.md
│   │   ├── security.md
│   │   ├── fix-quality.md        "corrija a classe do bug + teste que falhava antes" (VoiceStudio)
│   │   └── attribution.md        sem trailers de agente nos commits (VoiceStudio)
│   ├── settings.base.json        model, hooks que apontam para plugins, permissions base
│   └── brain.local.json.example  { "vault": "...", "logs_dir": "...", "lang": "pt-BR" }
├── scripts/
│   ├── install.sh                idempotente: add marketplace → install plugins → merge
│   │                             settings → symlink rules/CLAUDE.md → cria brain.local.json
│   ├── install.ps1               Windows (máquina de loja/cliente)
│   ├── doctor.sh                 hooks duplicados? CLAUDE.md stale? caminho absoluto? segredo?
│   └── check.sh                  o que o CI roda
├── docs/
│   ├── STARTING-AT-A-COMPANY.md  procedimento dia-1 (cexai STARTING-A-COMPANY-PROJECT)
│   ├── PRIVACY.md                o que nunca sai da empresa / nunca entra no cérebro
│   ├── UPGRADING.md              mover o pin de v1.x para v1.y numa empresa
│   └── decisions/                ADRs datados (cexai docs/decisions)
└── .github/workflows/check.yml   claude plugin validate, lint de SKILL.md, grep de
                                  caminhos absolutos e segredos (gitleaks), build --check
```

## 4. Fluxo de uso

**Dia 1 numa empresa nova (máquina da empresa):**

```bash
claude plugin marketplace add Franek-G/claude-brain#v1.0.0
claude plugin install brain-core@claude-brain brain-memory@claude-brain brain-guard@claude-brain --scope user
bash ~/.claude/plugins/marketplaces/claude-brain/scripts/install.sh   # camada home/
```

**Primeiro repo da empresa:** `cd repo && claude` → `/brain-company:init-project`. Cria o
molde no `.claude/` do repo. Esse molde é da empresa a partir daí; vai no git deles.

**Dia a dia:** `/resume` (lazy, 0 logs) → trabalho → `/decide` quando houver escolha
subjetiva → `/compress` ao fechar (o hook Stop lembra). `/preserve` promove o que é
permanente para o `CLAUDE.md` do projeto.

**Aprendizado que é seu, não da empresa** (um padrão de hook, uma regra de revisão):
vira PR no `claude-brain`, passa pelo RULER. Isso é o único caminho de volta, e é manual
por desenho: nenhum hook sincroniza nada da empresa para o cérebro.

**Saída da empresa:** `claude plugin uninstall ...` ou nada; o repo deles fica com o molde
preenchido, você fica com o cérebro intacto. Zero arquivo em comum.

## 5. RULER — portão de entrada (adaptado do cexai-2)

Nada entra no `claude-brain` sem passar em três perguntas:

1. **Portátil?** Funciona em outra máquina, outro SO, outra empresa, sem editar? Caminho
   absoluto, nome de cliente, URL interna → reprovado (vai para `brain.local.json` ou para
   o projeto).
2. **Usado?** Já doeu pelo menos 2 vezes em projetos reais? Senão fica no backlog
   (`99-backlog`), como você já faz no vault. Isso é o que impede o repo de virar um ecc
   com 311 skills.
3. **Limpo?** Nenhum dado de empregador, nenhum segredo, nenhum log de sessão. `gitleaks`
   e `grep` no CI, não só boa vontade.

## 6. O que aproveitar de cada repositório

| Repo | Levar | Deixar |
|---|---|---|
| **cexai-2** (GatoaoCubo, privado, Apache-2.0) | RULER (teste de dois portões); hub como dependência fixada por tag; `CLAUDE.md = @AGENTS.md`; `docs/decisions/` ADRs; `.claude/settings.json` com allow-list + `git push` em ask; `.gitattributes eol=lf`; bateria de checks com comando por invariante; decisão 0011 (persona carrega bloco "conteúdo não confiável") | 189 skills, 193 schemas, dashboard, runtime Node, orquestrador de 7 agentes. Você já descartou o vocabulário 8F/nuclei em 2026-04 e a razão continua válida |
| **ecc** (affaan-m, MIT, 288k★) | `rules/common/*` (git, testes, segurança) reescritos; agentes `planner`, `code-reviewer`, `security-reviewer`, `tdd-guide`; `contexts/{dev,review,research}.md`; receitas de hook (stdin JSON, exit 2); modelo de dado de "instinto" (id, trigger, confidence, scope project/global, hash do remote) como inspiração para separar aprendizado pessoal do de empresa | 71 agentes/311 skills/97 shims; `npx ecc-universal` (não rodar pacote de terceiro em máquina de empresa); observer em background que grava prompts; `astra-review` manda diff para OpenAI |
| **VoiceStudio** (debpalash, AGPL-3.0) | *Padrões*, reescritos com suas palavras: AGENTS.md neutro; `skills-lock.json` com hash das skills; regras "fix quality", "keep main green", "docs no mesmo PR", "sem trailer de agente", "regra mecânica vira teste, não revisor IA"; `.gitleaks.toml` baseline; `docs/agents/{issue-tracker,triage-labels,domain}.md` como slots por empresa | Tudo específico do produto. Pelo AGPL, não copie texto literal para um repo seu |
| **xerj** (xerj-org, Apache-2.0) | Não é config, é um binário de busca local + MCP. Candidato ao `brain-search` opcional quando TF-IDF não bastar (gatilho do seu backlog: 50+ logs). Padrão de `.mcp.json` com caminho absoluto no `command` | Rerank e proxy de embeddings saem da máquina (opt-in): checar política da empresa antes de indexar código deles |
| **obra/superpowers** (MIT, 304k★) | `hooks/session-start` injetando skill de bootstrap via `additionalContext`; marketplace "o repo é o plugin"; `skills/writing-skills` + teste de skills com sub-agents; `verification-before-completion`; `using-git-worktrees` | A biblioteca inteira de metodologia; pegue 3 skills, não 30 |
| **anthropics/claude-plugins-official** (Apache-2.0) | `hookify`, `security-guidance` (PreToolUse por padrão), `plugin-dev`, `skill-creator`, `claude-md-management`, `session-report`; scripts de CI de validação de marketplace | — |
| **anthropics/skills** | `template/SKILL.md`, `spec/agent-skills-spec.md` | skills docx/pdf/xlsx (source-available, não copiar) |
| **shanraisshan/claude-code-best-practice** (MIT) | um despachante Python único para todos os eventos de hook, dirigido por config; exemplo real de `agent-memory` | — |
| **wshobson/agents** (MIT) | formato de marketplace com plugins pequenos e compostos; `context-save`/`context-restore` | os 70 plugins |
| **gupsammy/Claudest** (sem licença) | *ideia* do `claude-memory`: SQLite+FTS5 de sessões, `extract-learnings` promovendo para CLAUDE.md. É o parente mais próximo do seu compress/preserve/resume; evolução natural do TF-IDF | código (sem licença) |
| **centminmod/my-claude-code-setup** (MIT) | split `activeContext / patterns / decisions / troubleshooting` carregado sob demanda | — |
| **LeanerCloud/dotclaude** | `.gitignore` para `~/.claude` (projects/, plugins/, history, credenciais) | — |
| **awesome-claude-code** | `agnix` / `ctxlint` para lintar CLAUDE.md e SKILL.md no CI; `vir` para destilar transcripts | é índice, não código |
| Evitar | `claude-flow`/`ruflo`, `BMAD-METHOD` (frameworks pesados, lock-in); `context-engineering-intro` (parado); `memvid/claude-brain` (parado) | |

## 7. O que migra do que você já tem

| Hoje | Vai para | Mudança necessária |
|---|---|---|
| `~/.claude/commands/{resume,compress,preserve}.md` | `plugins/brain-memory/skills/*/SKILL.md` | Trocar `/Users/franek/Documents/Obsidian Vault` hardcoded por `detect_mode.sh` lendo `~/.claude/brain.local.json`. Hoje esses comandos quebram em qualquer outra máquina |
| `~/.claude/hooks/suggest_compress.sh` + `settings.json` | `plugins/brain-memory/hooks/hooks.json` | Caminho via `${CLAUDE_PLUGIN_ROOT}`. Remover do `settings.json` para não disparar duas vezes (armadilha documentada no ecc) |
| `_claude/15-gdp.md` (vault) | `plugins/brain-core/skills/gdp/` + resumo em `home/CLAUDE.md` | Já é portátil; só sai do vault |
| `_scripts/{preflight_tfidf.py,build_claude_md.sh}` | `plugins/brain-memory/scripts/` | Parametrizar diretório de logs. O vault passa a chamar a cópia do plugin |
| `decisions.yaml` schema (D###, chosen/rejected/why/superseded_by) | `plugins/brain-company/templates/` + `decisions.yaml` do próprio cérebro | Nenhuma; adicionar `review_at` quando passar de 10 decisões (seu gatilho) |
| `settings.local.json` (153 permissões acumuladas) | `home/settings.base.json` com ~20 regras genéricas | Curadoria: só o que é independente de projeto |
| `vault-curator`, `session-archiver`, `.mcp.json` do obsidian | **ficam no vault** | São específicos do Obsidian, reprovam no portão "portátil" |
| Backlog do vault (`99-backlog.md`) | `docs/decisions/` + issues do repo | Os itens "descartados" viram ADR curto para você não reavaliar o 8F pela terceira vez |

## 8. Fases

1. **Fase 1 — esqueleto (1 sessão):** repo, marketplace.json, `brain-core` com GDP,
   `brain-memory` com os 3 comandos generalizados, `home/`, `install.sh`, CI com
   `claude plugin validate` + gitleaks. Testar instalando numa pasta limpa.
2. **Fase 2 — guard + company (1 sessão):** hooks de bloqueio, `init-project`, templates,
   `STARTING-AT-A-COMPANY.md`. Testar no `chucktcg-pricer`.
3. **Fase 3 — sob demanda:** `/decide`, agentes de revisão, `brain-search`, memória
   FTS5. Cada um só quando o RULER aprovar.

## 9. Decisões que são suas (GDP: eu não chuto)

- **Nome do repo**: `claude-brain`, `dotclaude`, `franek-brain`? Afeta o namespace dos
  comandos (`/brain-memory:resume`).
- **Público ou privado**: público instala em qualquer máquina sem credencial e força a
  disciplina do PRIVACY.md; privado exige `gh auth` na máquina da empresa. Minha
  recomendação: público, porque o conteúdo é método, não dado.
- **Idioma**: nomes de skills/agentes em inglês (passam no portão "portátil"); corpo das
  skills em pt-BR como hoje, ou inglês para poder compartilhar? Hoje tudo é pt-BR.
- **Licença**: MIT (ecc, superpowers) ou Apache-2.0 (cexai, xerj, anthropics).
- **cexai-2 é privado**: reaproveitar RULER e o padrão de hub em palavras suas é
  tranquilo; copiar texto literal para um repo público pede um aceno do GatoaoCubo,
  mesmo com Apache-2.0.
