# AGENTS.md — contrato para qualquer agente neste repositório

Este repositório é a configuração pessoal do Claude Code de Franek. Qualquer
agente (Claude Code, Codex, Gemini CLI) que trabalhe aqui segue isto.

## O que é

Um marketplace de plugins do Claude Code mais uma camada `home/` para
`~/.claude`. Conteúdo é **método**: skills, hooks, regras. Veja
[ARQUITETURA.md](ARQUITETURA.md).

## Regras de trabalho

1. **RULER antes de adicionar.** Leia [RULER.md](RULER.md). Nada entra sem passar
   nos três testes (portátil, usado, limpo).
2. **Nomes em inglês, corpo em pt-BR.** Nomes de plugin, skill, agente, hook e
   arquivo são palavras inglesas comuns. O texto das skills e docs é pt-BR.
3. **Sem caminho absoluto.** Scripts leem `~/.claude/brain.local.json` ou usam
   `${CLAUDE_PLUGIN_ROOT}`. `scripts/check.sh` recusa `/Users/`, `/home/`, `C:\`.
4. **Decisão subjetiva vai para `decisions.yaml`** com `chosen`, `rejected`, `why`.
   Decisão de arquitetura vai para `docs/decisions/NNNN-slug.md`.
5. **Guided Decision Protocol.** Usuário decide o quê; agente decide como;
   escolha com mais de um caminho razoável é perguntada antes. Está em
   `plugins/brain-core/skills/gdp/SKILL.md`.
6. **Hooks não duplicam.** Um hook vive no plugin **ou** em `settings.json`, nunca
   nos dois (dispararia duas vezes).
7. **Commits sem trailer de agente.** A autoria é a identidade git do humano.
8. **Antes de dizer "pronto", rode `bash scripts/check.sh`.** Pronto é
   re-executado, não resumido.

## Layout

```
.claude-plugin/marketplace.json
plugins/<nome>/.claude-plugin/plugin.json
plugins/<nome>/skills/<skill>/SKILL.md
plugins/<nome>/hooks/hooks.json         comandos via ${CLAUDE_PLUGIN_ROOT}
plugins/<nome>/scripts/
home/                                   CLAUDE.md, rules/, settings.base.json
scripts/                                install.sh, doctor.sh, check.sh
docs/                                   PRIVACY.md, BACKLOG.md, decisions/
```
