# RULER — portão de entrada

Nada entra neste repositório sem passar nos três testes. Quem adiciona, testa
primeiro. Se reprovar, o lugar é o backlog (`docs/BACKLOG.md`), o projeto da
empresa ou o seu vault, não aqui.

Adaptado do teste de dois portões do repositório `cexai-2` (GatoaoCubo), que
define "portátil" como: *uma IA sem nenhum contexto sobre este projeto lê o
token e sabe o que significa.*

## 1. Portátil?

Funciona em outra máquina, outro sistema operacional, outra empresa, sem editar?

| Reprova | Vai para |
|---|---|
| Caminho absoluto (`/Users/franek/...`) | `~/.claude/brain.local.json` (gerado pelo `install.sh`) |
| Nome de cliente, URL interna, nome de repo de empresa | `CLAUDE.md` do projeto da empresa |
| Dependência de ferramenta que só uma máquina tem | opcional, com fallback, ou fora |
| Vocabulário que exige ler a documentação para entender (`8F`, `N07`, `pillar`) | fora. Nomes de skill, agente e comando em inglês comum |

Teste literal: cole o nome da skill ou do hook em um modelo que nunca viu este
repositório. Se ele não souber dizer o que é, o nome reprova.

## 2. Usado?

Já doeu pelo menos **duas vezes** em trabalho real?

Uma skill escrita "porque pode ser útil" é custo de contexto sem retorno. O
`ecc` tem 311 skills e o `cexai-2` tem 189; este repositório existe para não
virar isso. Ideia boa sem dor repetida vai para `docs/BACKLOG.md` com o gatilho
que a traria para dentro.

## 3. Limpo?

Nenhum dado de empregador, nenhum segredo, nenhum log de sessão, nenhum
transcript.

Isso não depende de boa vontade: `scripts/check.sh` roda `gitleaks`, procura
caminhos absolutos e recusa arquivos de log. O CI roda o mesmo.

## O caminho de volta

Aprendizado que é seu (um padrão de hook, uma regra de revisão) e passou nos
três testes entra por commit ou PR neste repositório, com uma linha em
`decisions.yaml` se foi escolha entre alternativas. É o único caminho. Nenhum
hook sincroniza nada da empresa para cá, por desenho.
