---
name: resume
description: Carrega o contexto persistente ao retomar trabalho. CLAUDE.md sempre; logs de sessão sob demanda, ranqueados por relevância. Use no início de uma sessão, ou quando o usuário disser "retomar", "em que estávamos", "carregue o contexto", "resume". Argumentos opcionais, N (últimos N logs), termo (top-3 por relevância) ou N termo.
version: 0.1.0
argument-hint: "[N] [termo]"
---

# /resume — carregar contexto

Você está retomando o trabalho do usuário. Reconstrua o contexto **antes** de
responder qualquer outra coisa. Argumentos recebidos: `$ARGUMENTS`.

## Passo 1 — Detectar o modo

Rode:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect_mode.sh"
```

Ele imprime `MODE`, `ROOT`, `CLAUDE_MD`, `PROJECT_CLAUDE_MD` (opcional), `LOGS_DIR`,
`DECISIONS` e `LOG_COUNT`, um por linha, lendo `~/.claude/brain.local.json`.

- `MODE=VAULT`: você está dentro do vault pessoal do usuário.
- `MODE=PROJECT`: há um `CLAUDE.md` neste diretório ou acima; o projeto é a raiz dele.
- `MODE=NONE`: nenhum dos dois. Diga isso ao usuário em uma linha e pergunte se é um
  projeto novo. Não invente contexto.

## Passo 2 — Ler a memória permanente

Leia inteiro cada arquivo em `CLAUDE_MD` e `PROJECT_CLAUDE_MD`. Leia `DECISIONS` se
existir; são as escolhas que não podem ser refeitas sem o usuário.

## Passo 3 — Carregar logs de sessão (lazy)

Interprete `$ARGUMENTS`:

| Argumento | Ação |
|---|---|
| vazio | **0 logs**. Só CLAUDE.md. Avise: "0 logs carregados (lazy). Me diga em que continuamos e eu busco." Quando o usuário disser o foco, rode o ranqueamento com a frase dele e carregue só o que pontuar acima de 0 |
| `N` | os N mais recentes por data de modificação |
| `termo` | top-3 por relevância ao termo |
| `N termo` | top-N por relevância |

Ranqueamento, antes de ler qualquer log:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/preflight_tfidf.py" "<termo>" --top <N> --logs-dir "<LOGS_DIR>"
```

Imprime `<score>\t<caminho>` em ordem decrescente. Se o script falhar, liste
`LOGS_DIR` por data e filtre com `grep -il` pelo termo.

De cada log selecionado leia **só até a linha `## Raw Session Log`** (a Quick
Reference). Leia o restante só se o usuário pedir detalhe, ou se o termo aparecer lá
e não na Quick Reference.

Racional: carregar 3 logs sempre custa tokens que a maioria das sessões não usa.

## Passo 4 — Resumir

Devolva em até 10 linhas:

1. Modo e raiz detectados.
2. Decisões e invariantes principais do CLAUDE.md (e do `decisions.yaml`).
3. Sessões carregadas: data e `outcome` em uma linha cada.
4. Pendências em aberto (checkboxes não marcadas nos logs lidos).
5. Pergunta: "Em que continuamos?"

Não invente nada que não esteja nos arquivos. Se um arquivo não existir, diga.
