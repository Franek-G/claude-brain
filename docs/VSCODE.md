# Claude Code no VS Code

Como trabalhar com o cérebro dentro do VS Code. Fonte: documentação oficial em
[code.claude.com/docs/en/vs-code](https://code.claude.com/docs/en/vs-code), lida em
2026-10-24.

## Instalação

1. Extensão `anthropic.claude-code` (VS Code 1.94+). Pela linha de comando:

   ```bash
   code --install-extension anthropic.claude-code
   ```

2. O CLI `claude` continua necessário no terminal: a extensão traz o próprio motor
   para o painel, mas não coloca `claude` no PATH.
3. **Nada mais a configurar para o cérebro.** Extensão, CLI e app desktop lêem os
   mesmos arquivos: `~/.claude/settings.json`, `~/.claude/CLAUDE.md`,
   `~/.claude/rules/`, plugins e histórico de sessões. Os plugins instalados com
   `claude plugin install ... --scope user` aparecem no painel. Se instalou pelo
   terminal com o painel aberto, rode `/reload-plugins` nele.

## Atalhos que valem decorar (macOS)

| Atalho | Ação |
|---|---|
| `Cmd+Esc` | alterna foco entre editor e Claude |
| `Cmd+Shift+Esc` | nova conversa em outra aba |
| `Option+K` | insere `@arquivo#linhas` da seleção atual |
| `Shift` + arrastar | anexa arquivos à conversa |
| `/plan <tarefa>` | modo plano; o plano abre como Markdown para comentar antes de editar |
| passar o mouse numa mensagem | rewind: volta o código, bifurca a conversa, ou ambos |

## Fluxo recomendado

1. **Abra a pasta do repositório**, não um arquivo solto. O `CLAUDE.md` do projeto
   e o modo detectado pelo `brain-memory` dependem disso.
2. **`/brain-memory:resume`** na primeira mensagem. O hook de início já informa o
   modo e quantos logs existem.
3. **Plano antes de mudança grande.** `/plan` ou o seletor de modo. Comente o plano
   no Markdown antes de aprovar.
4. **Referencie código com `@`**, não colando. `Option+K` sobre a seleção.
   `@terminal:nome` para saída de terminal.
5. **Revise diffs antes de aceitar.** Fique no modo Manual; Auto e Edit-automatically
   pulam a confirmação. Cada mudança tem Aceitar/Rejeitar.
6. **`/clear` entre tarefas sem relação, `/compact <foco>` em sessão longa.** `/btw`
   para pergunta lateral que não deve entrar no contexto.
7. **`/brain-memory:compress`** ao fechar. O hook `Stop` lembra em sessões longas.
8. **Sessões paralelas em worktrees**: `claude --worktree <nome>` cria
   `.claude/worktrees/<nome>` em branch própria. Mantenha `.claude/worktrees/` no
   `.gitignore`. Cada aba do painel pode rodar num worktree.

## Configurações

As chaves `claudeCode.*` ficam nas **configurações de usuário**, nunca no
`.vscode/settings.json` do repositório: `initialPermissionMode`, por exemplo, é
ignorada em escopo de workspace. Padrões documentados: `preferredLocation: panel`,
`autosave: true`, `attachOpenFile: true`, `respectGitIgnore: true`,
`allowDangerouslySkipPermissions: false`. Deixe este último em `false`.

Modelo padrão não é chave da extensão: é `"model"` em `~/.claude/settings.json`, ou
`/model` no painel.

O que **este repositório** traz em `.vscode/`:

| Arquivo | Para quê |
|---|---|
| `extensions.json` | 24 extensões recomendadas; lista e critério abaixo |
| `settings.json` | LF, newline final, ShellCheck ao salvar, Ruff e shell-format como formatadores, markdownlint sem MD013/MD033/MD041, Code Spell Checker em en + pt-BR, schema do GitHub Actions, esconde `CC-Session-Logs` e worktrees da busca |
| `tasks.json` | `Cmd+Shift+B`-style: **brain: check** (padrão de teste), **brain: doctor**, **brain: validate plugins**, **brain: testar plugin sem instalar** |

Rode uma task com `Cmd+Shift+P` → "Tasks: Run Task".

### Extensões recomendadas

IDs e contagens conferidos na API do Marketplace em 2026-10-24. Critério: entra o
que serve ao conteúdo deste repositório (Markdown, shell, YAML, JSON, Python, git)
ou à stack de dados que o cérebro acompanha. Ao abrir a pasta, o VS Code oferece
instalar o que faltar; na linha de comando, `code --install-extension <id>`.

| Grupo | Extensão | ID | Para quê |
|---|---|---|---|
| Claude | Claude Code | `anthropic.claude-code` | o painel; veja acima |
| Editor | EditorConfig | `editorconfig.editorconfig` | respeita `.editorconfig` |
| Shell | ShellCheck | `timonwong.shellcheck` | lint dos `scripts/*.sh` e hooks |
| Shell | Bash IDE | `mads-hartmann.bash-ide-vscode` | símbolos e ir à definição em shell |
| Shell | shell-format | `foxundermoon.shell-format` | formata shell com shfmt embutido |
| Dados de config | YAML | `redhat.vscode-yaml` | `decisions.yaml`, workflows; schemas |
| Dados de config | Even Better TOML | `tamasfe.even-better-toml` | `pyproject.toml` de projetos |
| Python | Python | `ms-python.python` | base: debug, envs, IntelliSense |
| Python | Ruff | `charliermarsh.ruff` | lint e format; substitui Black, isort, flake8 |
| Python | Jupyter | `ms-toolsai.jupyter` | notebooks; Databricks depende dela |
| Markdown | markdownlint | `DavidAnson.vscode-markdownlint` | lint de SKILL.md e docs |
| Markdown | Markdown All in One | `yzhang.markdown-all-in-one` | TOC, tabelas, atalhos |
| Markdown | Markdown Preview Mermaid | `bierner.markdown-mermaid` | diagramas em ARQUITETURA.md e ADRs |
| Qualidade | Error Lens | `usernamehw.errorlens` | diagnósticos inline, de qualquer linter |
| Qualidade | Code Spell Checker | `streetsidesoftware.code-spell-checker` | typos; dicionário pt-BR em `...-portuguese-brazilian` |
| Git | GitLens | `eamodio.gitlens` | blame e histórico inline |
| Git | GitHub Pull Requests | `GitHub.vscode-pull-request-github` | revisar PR no editor |
| Git | GitHub Actions | `GitHub.vscode-github-actions` | CI do `check.sh` |
| Stack | Databricks | `databricks.databricks` | rodar código local no cluster; veja [references/databricks.md](references/databricks.md) |
| Stack | SQLTools + driver Databricks | `mtxr.sqltools`, `databricks.sqltools-databricks-driver` | consultas SQL com resultado no editor |
| Stack | Remote - SSH | `ms-vscode-remote.remote-ssh` | editar em máquina remota |
| Stack | Container Tools | `ms-azuretools.vscode-containers` | Docker e dev containers; o antigo `vscode-docker` virou pacote vazio que aponta para esta |

Ficaram de fora, de propósito: Prettier e ESLint (JS/CSS, sem uso aqui), Live
Server e Thunder Client (web), Copilot (concorre com o Claude Code no mesmo
painel), e Path Intellisense, Todo Tree, Better Comments e DotENV (sem atualização
há 2 a 8 anos).

#### Como conferir uma extensão

A página do Marketplace é renderizada em JavaScript e não responde a `curl`. A API
pública responde, com nome, instalações e data da última versão:

```bash
curl -s -X POST "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json;api-version=7.1-preview.1" \
  -d '{"filters":[{"criteria":[{"filterType":7,"value":"charliermarsh.ruff"}]}],"flags":914}' \
  | jq '.results[0].extensions[0] | {displayName, lastUpdated, installs: (.statistics[] | select(.statisticName=="install") | .value)}'
```

`filterType: 7` filtra pelo ID `publisher.name`. Olhe `lastUpdated`, não só
instalações: extensão popular pode estar abandonada ou ter virado pacote vazio.
Critério de entrada: decisão D008 em `decisions.yaml`.

## Limitações conhecidas

- **Sessões cloud (claude.ai/code) não carregam plugins locais** nem
  `~/.claude/settings.json`. O cérebro só vale em máquina.
- A extensão não funciona em Restricted Mode: confie na pasta.
- Com provedor terceiro (Bedrock, Vertex) somem recursos do claude.ai (barra de uso,
  ditado, aba Web). Relevante em empresa que exige Bedrock; veja
  [references/aws.md](references/aws.md).
- Checkpoints cobrem só edições por ferramenta de arquivo, não mudanças via Bash. Não
  substituem git.
- Remote-SSH e WSL com a extensão não estão documentados; dev containers sim.
