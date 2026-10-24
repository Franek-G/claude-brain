# Fronteira de privacidade

Este repositório é público e vai para a máquina de qualquer empresa onde eu trabalhe.
Duas direções, duas proibições.

## Nada da empresa entra aqui

| Nunca neste repositório | Onde fica |
|---|---|
| Nome de cliente, de produto interno, de repositório da empresa | `CLAUDE.md` do projeto, no git da empresa |
| Logs de sessão (`CC-Session-Logs/`), transcripts (`.jsonl`) | no projeto (logs) ou só na máquina (transcripts) |
| Decisões sobre código da empresa | `decisions.yaml` do projeto |
| Caminhos da máquina (`/Users/...`, `C:\...`) | `~/.claude/brain.local.json` |
| Segredos, tokens, URLs internas | em lugar nenhum versionado |
| Permissões específicas de um projeto | `.claude/settings.local.json` do projeto |

O que pode entrar: um padrão que você aprendeu (um hook, uma regra de revisão, uma
forma de perguntar) **reescrito de forma genérica**, sem o contexto que o originou.
Passa pelo `RULER.md` como qualquer outra coisa.

## Nada daqui depende da empresa

Instalar o cérebro em uma máquina nova exige só o Claude Code e acesso ao GitHub
público. Nenhum plugin aqui chama serviço externo, manda dado para fora da máquina ou
roda pacote de terceiro. Se um dia um plugin opcional precisar (ex.: busca local com
MCP), ele será opcional, desligado por padrão e documentado aqui.

## Ao sair de uma empresa

`claude plugin uninstall brain-core@claude-brain` e `brain-memory@claude-brain`, ou
nada. O repositório da empresa fica com o `CLAUDE.md`, o `decisions.yaml` e os logs
que a equipe escreveu. Você fica com o cérebro. Zero arquivo em comum.

## Como isso é verificado

`scripts/check.sh` (e o CI) recusa caminho absoluto em `plugins/`, `home/` e
`scripts/`, recusa `CC-Session-Logs/`, `*.jsonl` e `*.local.json` versionados e roda
`gitleaks`. `.gitignore` cobre os mesmos padrões.
