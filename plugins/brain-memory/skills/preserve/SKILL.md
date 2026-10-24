---
name: preserve
description: Promove um aprendizado permanente para a memória que carrega em toda sessão. Fatos e convenções vão para o CLAUDE.md do projeto (ou fragment do vault); decisões subjetivas vão para decisions.yaml com chosen, rejected e why. Use quando o usuário disser "preserve", "guarde isso para sempre", "registre a decisão", "isso vale para todas as sessões".
version: 0.1.0
argument-hint: "[o que preservar]"
---

# /preserve — atualizar a memória permanente

Adiciona conhecimento que deve **sempre** estar carregado em sessões futuras. Use só
para o que é duradouro. Para conteúdo de uma sessão, use `/brain-memory:compress`.
Argumento recebido: `$ARGUMENTS`.

## Passo 1 — Coletar e classificar

Se `$ARGUMENTS` estiver vazio, pergunte: "O que preservar?". Classifique:

- **Decisão subjetiva** (escolha entre alternativas, com tradeoff): vai para
  `decisions.yaml`. Pergunte as alternativas consideradas e a razão da escolha, se não
  estiverem claras.
- **Fato, aprendizado ou convenção** (algo que é verdade, não uma escolha): vai para o
  `CLAUDE.md`.

Em dúvida, pergunte. A regra de classificação está em `/brain-core:gdp`.

## Passo 2 — Detectar destino

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect_mode.sh"
```

Use `ROOT`, `CLAUDE_MD`, `PROJECT_CLAUDE_MD` e `DECISIONS`. Se houver
`PROJECT_CLAUDE_MD` (projeto dentro do vault), o destino é o projeto, não a raiz.

## Passo 3a — Decisão

Edite `DECISIONS` (`<destino>/decisions.yaml`). Se não existir, crie com o cabeçalho
de schema de `/brain-core:gdp`. Leia o último `id` e acrescente:

```yaml
  - id: D###
    date: YYYY-MM-DD
    topic: <≤ 60 caracteres>
    chosen: <escolha>
    rejected: [<alternativas>]
    why: <razão>
```

Se a nova decisão substitui uma anterior, adicione `superseded_by: D###` na antiga.
Não apague histórico.

## Passo 3b — Fato ou convenção

**Se existir `<ROOT>/_claude/`** (CLAUDE.md gerado por fragments, padrão do vault):

1. Liste `_claude/*.md` e escolha o fragment cuja seção corresponde ao tema. Se nenhum
   servir, crie `_claude/<NN>-<nome>.md` com prefixo numérico na posição certa.
2. Edite o fragment. Não duplique: se algo parecido já existe, refine o bullet em vez
   de adicionar outro.
3. Regenere:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/build_claude_md.sh" --root "<ROOT>"
   ```

**Senão**, edite a seção apropriada do `CLAUDE.md` do destino diretamente, com a
mesma regra de não duplicar.

## Passo 4 — Arquivar se o CLAUDE.md passar de 280 linhas

1. Candidatos: subseções marcadas como concluídas, projetos com `status: archived`,
   conteúdo de fragments com prefixo `99-`.
2. Proteja sempre as seções de abordagem, caminhos-chave, skills, ferramentas e
   projetos ativos.
3. Mova para `CLAUDE-Archive.md` ao lado, prefixando cada bloco com
   `## Archived YYYY-MM-DD — <título original>`.
4. Mostre o que será movido e **peça confirmação antes de salvar**.
5. Remova do fragment de origem e regenere.

## Passo 5 — Confirmar

Mostre o diff aplicado e o caminho do arquivo. Se foi decisão, exiba a entrada YAML
completa.
