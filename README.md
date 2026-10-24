# claude-brain

Minha configuração pessoal do [Claude Code](https://code.claude.com), versionada
para ser instalada em qualquer máquina e em qualquer empresa onde eu trabalhe.

É **método**, não dado: como eu trabalho com o Claude (protocolo de decisão,
memória entre sessões, hooks, regras de código). Nada de empresa entra aqui, e
nada daqui depende de uma empresa. Leia [RULER.md](RULER.md) antes de adicionar
qualquer coisa e [docs/PRIVACY.md](docs/PRIVACY.md) para a fronteira.

## Instalar (qualquer máquina com Claude Code)

```bash
claude plugin marketplace add Franek-G/claude-brain
claude plugin install brain-core@claude-brain --scope user
claude plugin install brain-memory@claude-brain --scope user
bash ~/.claude/plugins/marketplaces/claude-brain/scripts/install.sh
```

O último comando instala a camada que plugin não distribui: `~/.claude/CLAUDE.md`,
`~/.claude/rules/` e `~/.claude/brain.local.json` (caminhos desta máquina, nunca
versionados). Para fixar uma versão, use `Franek-G/claude-brain#v0.1.0`.

Verifique com `bash ~/.claude/plugins/marketplaces/claude-brain/scripts/doctor.sh`.

## O que vem dentro

| Plugin | Conteúdo | Comandos |
|---|---|---|
| `brain-core` | Guided Decision Protocol (quem decide o quê) e o guia de escrita de skills | `/brain-core:gdp`, `/brain-core:writing-skills` |
| `brain-memory` | Memória entre sessões: carregar contexto, salvar sessão, promover aprendizado. Hook `Stop` que sugere salvar sessões longas | `/brain-memory:resume`, `/brain-memory:compress`, `/brain-memory:preserve` |
| `home/` | `CLAUDE.md` pessoal, `rules/` (git, testes, segurança, qualidade de fix, atribuição), `settings.base.json` | instalado por `scripts/install.sh` |

Fases 2 e 3 (hooks de bloqueio, molde para repo de empresa, busca local) estão
descritas em [ARQUITETURA.md](ARQUITETURA.md) e só entram quando o
[RULER](RULER.md) aprovar.

## Como funciona no dia a dia

1. `/brain-memory:resume` no início: lê o `CLAUDE.md` do projeto e, sob demanda,
   os logs de sessão relevantes.
2. Trabalho normal. Decisões subjetivas são perguntadas antes
   ([GDP](plugins/brain-core/skills/gdp/SKILL.md)).
3. `/brain-memory:compress` ao fechar: grava um log estruturado em
   `<repo>/CC-Session-Logs/`. O hook lembra em sessões longas.
4. `/brain-memory:preserve` quando algo for permanente: vai para o `CLAUDE.md`
   do projeto ou para o `decisions.yaml`.

Tudo isso escreve **no repositório onde você está**, nunca aqui.

## Estrutura

```
.claude-plugin/marketplace.json   marketplace pessoal
plugins/brain-core/               método
plugins/brain-memory/             memória (skills, hooks, scripts)
home/                             camada ~/.claude
scripts/                          install.sh, doctor.sh, check.sh
docs/                             PRIVACY.md, VSCODE.md, references/, decisions/ (ADRs)
decisions.yaml                    decisões do próprio cérebro
RULER.md                          portão de entrada
```

## No VS Code

Extensão `anthropic.claude-code`; o cérebro funciona nela sem configuração extra porque
extensão e CLI lêem os mesmos arquivos. Atalhos, fluxo e as tasks deste repositório
estão em [docs/VSCODE.md](docs/VSCODE.md). Boas práticas por stack em
[docs/references/](docs/references/).

## Desenvolver

```bash
bash scripts/check.sh            # o mesmo que o CI roda
claude --plugin-dir plugins/brain-memory   # testar um plugin sem instalar
```

Licença [MIT](LICENSE). Padrões aproveitados de outros projetos estão creditados
em [docs/decisions/0002-fontes-e-licencas.md](docs/decisions/0002-fontes-e-licencas.md).
