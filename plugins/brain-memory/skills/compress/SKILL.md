---
name: compress
description: Salva a sessão atual como um log estruturado em CC-Session-Logs/ do projeto (ou no diretório de logs do vault), preservando decisões, aprendizados, fixes, arquivos tocados e pendências. Use ao encerrar uma sessão ou quando o usuário disser "salve a sessão", "compress", "feche a sessão", "registre o que fizemos".
version: 0.1.0
disable-model-invocation: true
---

# /compress — salvar a sessão

Encerre a sessão preservando o que importa. Não improvise: pergunte ao usuário o que
vale guardar.

## Passo 1 — Detectar destino

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect_mode.sh"
```

- `MODE=VAULT`: destino é `LOGS_DIR` (o diretório de logs do vault). O campo
  `project:` do frontmatter é o nome da pasta de projeto do vault se o `pwd` estiver
  dentro de uma; senão vazio.
- `MODE=PROJECT`: destino é `LOGS_DIR` (`<raiz>/CC-Session-Logs/`). Crie a pasta se
  não existir. `project:` é o nome da pasta raiz.
- `MODE=NONE`: pergunte ao usuário onde salvar antes de continuar.

Nome do arquivo: `<YYYY-MM-DD-HH-mm>-<slug>.md`.

## Passo 2 — Perguntar o que preservar

Em **uma única mensagem**, ofereça os blocos, todos marcados por padrão:

- [x] Decisões tomadas
- [x] Aprendizados-chave
- [x] Soluções e fixes aplicados
- [x] Arquivos modificados
- [x] Setup / config alterados
- [x] Pendências
- [x] Erros e workarounds

Aguarde a resposta antes de escrever.

## Passo 3 — Slug

3 a 5 palavras em kebab-case descrevendo a sessão (ex.: `pricer-lorcana-playwright-fix`).
Pergunte se não estiver óbvio.

## Passo 4 — Escrever o log

Use exatamente este formato, omitindo seções não selecionadas:

```markdown
---
type: session
date: YYYY-MM-DD HH:mm
project: <nome ou vazio>
topics: [lista, curta]
outcome: <uma frase>
tags: []
---

# Sessão: YYYY-MM-DD HH:mm — <slug>

## Quick Reference
- **Tópicos:** ...
- **Projeto:** ...
- **Resultado:** ...

## Decisões
- ...

## Aprendizados
- ...

## Soluções e fixes
- ...

## Arquivos modificados
- ...

## Setup / config
- ...

## Pendências
- [ ] ...

## Erros e workarounds
- ...

---

## Raw Session Log
<resumo cronológico em prosa; sintetize, não cole o histórico cru>
```

A Quick Reference é o que `/brain-memory:resume` lê primeiro. Ela tem que bastar
para alguém decidir se vale abrir o resto.

## Passo 5 — Confirmar

Devolva o caminho do arquivo criado e uma linha de resumo. Se algum item for
permanente (vale para todas as sessões futuras), sugira `/brain-memory:preserve`
para ele.

Não registre segredos, tokens ou dados pessoais de terceiros no log.
