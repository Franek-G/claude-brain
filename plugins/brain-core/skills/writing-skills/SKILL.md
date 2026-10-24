---
name: writing-skills
description: Guia para escrever, revisar ou testar uma skill do Claude Code neste repositório ou em um projeto. Use quando o usuário pedir "crie uma skill", "transforme este comando em skill", "revise esta SKILL.md", ou antes de adicionar qualquer skill ao claude-brain.
version: 0.1.0
---

# Escrevendo skills

Uma skill é uma pasta com `SKILL.md`. O Claude lê a `description` de todas as skills
no início da sessão e carrega o corpo só quando a skill é relevante ou invocada. Por
isso a `description` decide se a skill será usada, e o corpo decide se será usada
bem.

## Antes de escrever: RULER

Se a skill vai para o `claude-brain`, passe pelos três testes de `RULER.md`:
portátil (sem caminho absoluto, nome em inglês comum), usada (doeu duas vezes),
limpa (nada de empresa). Se reprovar em "usada", anote em `docs/BACKLOG.md` com o
gatilho e pare.

## Formato

```markdown
---
name: nome-em-ingles          # kebab-case, igual ao nome da pasta
description: O que faz E quando usar, com as frases que o usuário diria. Até ~3 linhas.
version: 0.1.0
# opcionais:
# disable-model-invocation: true   só o usuário invoca (ex.: compress, que escreve arquivo)
# allowed-tools: Read, Grep, Bash(git *)
# context: fork                    roda em subagente, não polui o contexto principal
# paths: ["src/**/*.py"]           só ativa quando arquivos casam
---

# Título

Corpo em pt-BR. Passos numerados, imperativos, curtos.
```

## Regras de escrita

1. **Description = gatilho + escopo.** Inclua as palavras que o usuário usaria
   ("salve a sessão", "o que decidimos sobre"). Descrição vaga não dispara.
2. **Corpo abaixo de 200 linhas.** Acima disso, mova referência para
   `references/<tema>.md` dentro da pasta e aponte. Limite rígido do formato: 500.
3. **Caminhos via variáveis.** `${CLAUDE_PLUGIN_ROOT}` para scripts do plugin,
   `${CLAUDE_SKILL_DIR}` para a pasta da skill, `~/.claude/brain.local.json` para
   caminhos da máquina. Nunca o caminho da sua pasta pessoal escrito por extenso.
4. **Scripts fazem o trabalho determinístico.** Detectar diretório, contar linhas,
   ranquear arquivos: shell ou Python stdlib em `scripts/`, chamados pela skill. O
   texto da skill fica com o julgamento.
5. **Diga o que não fazer.** "Não cole o histórico cru", "não invente o que não está
   no arquivo". É o que mais evita erro.
6. **Skill que escreve arquivo pede confirmação** antes de gravar, ou usa
   `disable-model-invocation: true`.

## Testar

1. `claude plugin validate <pasta-do-plugin>` para o formato.
2. Rode a skill em uma pasta limpa com `claude --plugin-dir <pasta-do-plugin>`.
3. Teste de disparo: em uma sessão nova, diga a frase do usuário sem citar o nome da
   skill. Se não disparou, a `description` está fraca.
4. Teste com subagente: peça a um subagente que siga a skill em um caso real e
   compare o resultado com o esperado. Ajuste o texto onde ele errou, não adicione
   mais texto onde ele acertou.

## Dois moldes que funcionam

**Skill de consulta a uma base de conhecimento** (vault, wiki, docs do repo). Três passos
fixos:

1. *Leia sempre*: 1 a 3 notas de base, nomeadas, que valem para qualquer tarefa daquele tipo
   (arquitetura, boas práticas, pendências).
2. *Busque o específico*: extraia tabelas, sistemas, termos da tarefa; `grep` na base por
   eles; leia até 4 arquivos a mais, os mais relevantes.
3. *Responda citando*: aplique o que encontrou e liste no início as notas consultadas.

Serve para `/sql`, `/etl`, `/diagnose`, `/projeto`, qualquer domínio. O que muda entre uma e
outra é só a lista do passo 1 e as pastas do passo 2.

**Sub-agente enxuto** para trabalho em paralelo (um por item independente):

```markdown
---
name: <papel>-<alvo>            # ex.: reviewer-table, processor-meeting
description: Faz UMA <coisa>. Use um por item, em paralelo, quando houver 3 ou mais.
tools: Read, Write, Glob, Grep, Bash(python scripts/<um-script>.py *)
model: sonnet                    # menor que o principal para tarefa mecânica
maxTurns: 20
omitClaudeMd: true               # não carrega o CLAUDE.md inteiro
skills:
  - <convencoes-compactas>       # skill curta com as regras de escrita
---
Você processa **um** item; o caminho vem na mensagem. Não varra o repositório.
<passos numerados, o que não fazer, onde pode escrever>
Retorno (uma linha JSON, nada mais): {"item":"...","resultado":"...","alerta":""}
```

A skill compacta de convenções substitui o `CLAUDE.md` no contexto do agente e é o que mantém
o custo baixo. Regras de escala e de retorno estão em `~/.claude/rules/brain/agents-and-tokens.md`.

## Migrar um comando antigo (`.claude/commands/x.md`)

1. Crie `skills/x/SKILL.md`, copie o corpo, adicione `name` e expanda a `description`.
2. Troque todo caminho absoluto por variável ou leitura de `brain.local.json`.
3. Apague o comando antigo depois de testar, para não existir duplicado.
