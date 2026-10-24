# Vault de conhecimento de time, operado com o Claude Code

Modelo de um vault Obsidian versionado em git, compartilhado por um time, em que o Claude
lê, escreve e cura notas sem virar fonte de erro. Reescrito a partir de um vault de time de
dados em uso desde 2026; nomes e dados da empresa ficaram de fora. Para o modelo específico
de catálogo de dados, código de trabalho e camada de busca, veja
[data-knowledge-blueprint.md](data-knowledge-blueprint.md).

## 1. Princípio

**Tudo que a IA cria nasce em quarentena.** Um humano promove. A fonte da verdade nunca é
editada direto por um modelo.

## 2. Estrutura de pastas

| Pasta | Papel |
|---|---|
| `00 - Entrada/` | caixa de entrada: recap de reunião, avulsos, arquivos para ingestão. Tudo é processado e sai; o original vai para `_processado/AAAA-MM/` |
| `01 - A Validar/` | **toda nota gerada por IA nasce aqui** com `validado: nao` e `destino:` |
| `Projetos/<P>/` | hub `00 - <P>.md` + `Regras de Negócio/` + `Queries/` + `Sustentação/` |
| `<Catálogo>/` | fonte única por entidade (tabela, sistema, conceito), com linhagem e relações |
| `Reuniões/`, `Diário/` | por tipo e por dia; o Diário recebe a saída da rotina |
| `Ferramentas/` | documentação das skills, setups, regras de trabalho com o Claude |
| `_Templates/`, `scripts/`, `.claude/` | templates de nota, scripts determinísticos, agentes e skills |

Pastas que não são nota (`scripts/`, código de trabalho, `.claude/`) ficam fora do lint, da
auditoria e dos links.

## 3. Frontmatter da quarentena

```yaml
validado: nao
destino: Projetos/<P>/Regras de Negócio
origem: reuniao-2026-10-08 | changelog-<repo> | analise-tabela | ingestao-<id> | rotina
gerado_por: claude
```

Quem valida troca para `validado: sim`; a promoção (script ou botão) move para `destino` e
grava `validado_em` e `validado_por`. Rejeição pede o motivo, que serve para melhorar o agente.

## 4. Convenções de nota

- Frontmatter obrigatório: `tipo` (vocabulário fechado), `tags`, `atualizado` (data
  absoluta). Campos obrigatórios por `tipo`, verificados por lint.
- Toda nota termina com `> Relacionado: [[A]] · [[B]]`. Nenhuma nota sem link de entrada e
  de saída.
- Links por nome, nomes únicos no vault. Em tabela Markdown, `[[Nota\|alias]]`.
- **Nunca apagar nota.** Obsoleta ganha `status: obsoleta` e link para a substituta.
- Código de repositório é linkado pelo GitHub, nunca copiado para o vault.
- Nome de arquivo sem `:` (Windows).

## 5. `CLAUDE.md` do vault

Mapa, não manual: tabela de pastas, regra de validação, padrão de projeto, convenções, e uma
seção **"Antes de qualquer tarefa"** que diz, por tipo de tarefa, quais notas ler primeiro.
As regras combinadas com o Claude vivem numa nota **"Regras de Trabalho"** com três colunas:
regra, desde quando, por quê (o incidente). A memória automática do Claude é atalho; a nota é
a fonte. É o mesmo papel do `decisions.yaml`.

## 6. Skills e agentes

- Skills de consulta seguem o molde "leia sempre, busque o específico, responda citando" (ver
  `brain-core:writing-skills`).
- Agentes são de um item só, rodam em paralelo, carregam uma skill compacta de convenções em
  vez do `CLAUDE.md`, e devolvem uma linha JSON (`~/.claude/rules/brain/agents-and-tokens.md`).
- Um orquestrador por rotina, que lê só um manifesto gerado por script.

## 7. Rotina em três tempos

```
script (pré)              modelo (julgamento)             script (pós)
promover validadas        processar reuniões               lint
changelog dos repos       ingerir conhecimento             gitleaks
snapshot do catálogo      curar projetos tocados           commit + push
status dos projetos       resumo para o Diário             custo da rodada
manifesto JSON ──────────▶                      ──────────▶ Diário/AAAA-MM-DD — Rotina.md
```

Roda num worktree separado, entrega na `main`; conflito fica em branch `rotina/AAAA-MM-DD`
e aparece como pendente. Nada de git ou banco dentro do passo do modelo.

## 8. Ingestão de conhecimento

Arquivo técnico (SQL, notebook, documento, planilha) + uma frase de "para que serve" → script
extrai o texto, **remove credencial e mascara PII antes de qualquer modelo**, acha as tabelas
lidas e escritas, monta um pacote → agente escreve notas tipadas em quarentena (processo,
regra, conceito, relação, exemplo). Divergência com o catálogo vira seção, nunca sobrescreve.
Credencial no original vira aviso para o dono trocar a senha.

## 9. Higiene

- `.gitignore`: configuração de tela do Obsidian, `CLAUDE.local.md`, `settings.local.json`,
  qualquer dado (`*.csv`, `*.xlsx`, `*.parquet`), pasta de ingestão bruta, `_local_pii/`.
- `.gitleaks.toml` com segredos padrão mais CPF, e-mail pessoal, string de conexão e token.
- `.gitattributes` com LF para texto e CRLF para `.ps1`.
- Lint de notas no pre-commit e na rotina; auditoria de links quebrados, órfãs e dead-ends.
- Segunda cópia: `git bundle` diário em armazenamento da empresa.

## 10. Métrica

Um score de 0 a 100 de qualidade de uso, lido dos logs locais do Claude Code: taxa de cache,
erros de ferramenta, custo por requisição, custo da rotina, disponibilidade das conexões,
padrão das notas, fila de validação em dia. Cache é o indicador principal de custo; erros de
ferramenta e padrão das notas são a dimensão de qualidade.
