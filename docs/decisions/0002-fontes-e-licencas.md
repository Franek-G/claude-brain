# 0002 — Fontes aproveitadas e como a licença foi respeitada

Data: 2026-10-24. Status: aceita.

## Contexto

A arquitetura foi desenhada lendo repositórios de terceiros. Este repositório é MIT.
Registra-se o que veio de onde, para crédito e para não copiar texto sob licença
incompatível.

## O que veio de onde

| Fonte | Licença | O que se aproveitou | Como |
|---|---|---|---|
| [GatoaoCubo/cexai-2](https://github.com/GatoaoCubo/cexai-2) (privado) | Apache-2.0 | o teste de portões do `RULER.md`; hub como dependência fixada por tag; `CLAUDE.md = @AGENTS.md`; ADRs em `docs/decisions/` | padrões reescritos em palavras próprias; nenhum texto literal |
| [affaan-m/ecc](https://github.com/affaan-m/ecc) | MIT | temas das `rules/common` (git, testes, segurança); receita de hook com stdin JSON e exit 2; a armadilha do hook duplicado | reescrito |
| [debpalash/VoiceStudio](https://github.com/debpalash/VoiceStudio) | AGPL-3.0 | regras "fix quality", "docs no mesmo PR", "sem trailer de agente", "regra mecânica vira teste" | só a ideia, reescrita; AGPL não entra em MIT |
| [obra/superpowers](https://github.com/obra/superpowers) | MIT | hook SessionStart com `additionalContext`; "verificado antes de concluído"; guia de escrita de skills | padrão, reescrito |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Apache-2.0 | formato de `hooks.json`, `plugin.json`, `marketplace.json`; `${CLAUDE_PLUGIN_ROOT}` | formato oficial |
| [anthropics/skills](https://github.com/anthropics/skills) | Apache-2.0 | formato de `SKILL.md` | formato oficial |
| [xerj-org/xerj](https://github.com/xerj-org/xerj) | Apache-2.0 | candidato a `brain-search` opcional (Fase 3) | nada ainda |
| [gupsammy/Claudest](https://github.com/gupsammy/Claudest) | sem licença | ideia da memória FTS5 (Fase 3) | só a ideia |
| vault Obsidian pessoal | próprio | `/resume`, `/compress`, `/preserve`, `suggest_compress.sh`, `preflight_tfidf.py`, `build_claude_md.sh`, GDP | migrados e generalizados |

## Decisão

Padrões podem ser aproveitados de qualquer fonte; texto literal só de fontes MIT ou
Apache-2.0 públicas, com crédito nesta tabela. De repositório privado (cexai-2) e de
AGPL (VoiceStudio) entra só a ideia, reescrita.

## Consequências

Toda adição futura que venha de fora atualiza esta tabela.
