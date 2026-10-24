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
| `extensions.json` | recomenda Claude Code, EditorConfig, ShellCheck, YAML, Python |
| `settings.json` | LF, newline final, ShellCheck ao salvar, schema do GitHub Actions, esconde `CC-Session-Logs` da busca |
| `tasks.json` | `Cmd+Shift+B`-style: **brain: check** (padrão de teste), **brain: doctor**, **brain: validate plugins**, **brain: testar plugin sem instalar** |

Rode uma task com `Cmd+Shift+P` → "Tasks: Run Task".

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
