# 0001 — Marketplace de plugins mais uma camada `home/`

Data: 2026-10-24. Status: aceita.

## Contexto

Quero a mesma configuração do Claude Code em qualquer máquina e em qualquer empresa,
sem copiar dado de empresa e sem depender de ferramenta que a empresa não tenha. Até
hoje a configuração vivia solta em `~/.claude/commands`, `~/.claude/hooks` e num vault
Obsidian, com caminhos absolutos em todo lugar.

## Decisão

O repositório é um **marketplace de plugins** do Claude Code
(`.claude-plugin/marketplace.json`) com plugins pequenos por tema (`brain-core`,
`brain-memory`, depois `brain-guard`, `brain-company`). O que plugin não distribui
(`~/.claude/CLAUDE.md`, `~/.claude/rules/`, `settings.json`) fica em `home/` e é
instalado por `scripts/install.sh`, que só adiciona e nunca remove. Caminhos da
máquina vão para `~/.claude/brain.local.json`, lido por `detect_mode.sh`.

## Alternativas rejeitadas

- **Clonar o repo inteiro em `~/.claude`** (padrão dotfiles): mistura estado local
  (transcripts, cache, credenciais) com configuração; `.gitignore` enorme e frágil.
- **Instalador npm próprio**: rodar pacote de terceiro em máquina de empresa é o que
  as regras de segurança proíbem.
- **Symlinks de `home/` para `~/.claude`**: quebram no Windows e dentro do cache de
  marketplace.

## Consequências

- Fixar versão é `#vX.Y.Z` no `marketplace add`. Atualizar é
  `claude plugin marketplace update claude-brain`.
- Hooks vivem só no plugin. O hook antigo em `settings.json` tem que ser removido para
  não disparar duas vezes; `doctor.sh` avisa.
- Sessões cloud (claude.ai/code) não carregam plugins nem settings locais. Limitação
  aceita.
