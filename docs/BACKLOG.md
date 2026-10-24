# Backlog

Ideias que reprovaram no portão "usado?" do `RULER.md`, com o gatilho que as traz
para dentro. Revisar quando o gatilho disparar, não antes.

## Fase 2 — guard e company

- **`brain-guard`**: hooks PreToolUse determinísticos (exit 2): segredo em Write/Edit,
  `git push --force` em main, `--no-verify`, `rm -rf` fora do repo. *Gatilho:* a
  primeira vez que um desses escapar das rules em texto.
- **`brain-company:init-project`**: planta `.claude/`, `CLAUDE.md` semente,
  `decisions.yaml`, `CC-Session-Logs/`, `settings.json` com allow-list enxuta no repo
  da empresa. *Gatilho:* o próximo repositório novo (hoje faço à mão em 5 minutos).
- **`docs/STARTING-AT-A-COMPANY.md`**: procedimento dia-1. *Gatilho:* o primeiro dia-1.
- **`scripts/install.ps1`**: Windows. *Gatilho:* precisar instalar numa máquina
  Windows (a máquina da loja ChuckTCG é candidata).

## Fase 3 — sob demanda

- **`/brain-memory:decide`**: captura a decisão no ato com o schema `D###`, perguntando
  os campos que faltam. *Gatilho:* mais de 10 decisões registradas em 3 meses.
- **Agentes de revisão** (`planner`, `code-reviewer`, `security-reviewer`), inspirados
  em `ecc/agents/`. *Gatilho:* pedir a mesma revisão manualmente 3 vezes.
- **`brain-search`**: MCP de busca local (XERJ ou similar) sobre logs e código quando
  o TF-IDF não bastar. *Gatilho:* 50+ logs de sessão num projeto e ranqueamento
  devolvendo coisa irrelevante.
- **Memória FTS5** (ideia do `claude-memory` em gupsammy/Claudest): SQLite com busca
  full-text sobre sessões, `extract-learnings` automático. *Gatilho:* o mesmo do
  brain-search, se a solução via MCP for pesada demais.
- **`review_at` em `decisions.yaml`**: decisão vencida é flagada. *Gatilho:* 10+
  decisões.
- **TF-IDF para BM25**: ~30 linhas. *Gatilho:* o mesmo de 50+ logs.
- **Framework de nudges declarativos** (YAML com trigger, cadência, template) em vez de
  um hook por nudge. *Gatilho:* o terceiro hook de sugestão.

## Descartado (não revisitar sem mudança de contexto)

Decidido em 2026-04 ao filtrar o repositório `cex`, confirmado em 2026-10:

- Pipeline 8F, 7 nuclei, 12 pillars: vocabulário próprio sem retorno para uso solo.
- Catálogos de centenas de skills/agentes pré-fabricados (ecc: 311; cexai-2: 189).
- Orquestrador multi-agente autônomo, grid de crews, dashboard web.
- Observer em background que grava prompts e chamadas de ferramenta (ecc
  continuous-learning v2): grava código de empresa.
- Instaladores multi-harness para 10+ editores.
