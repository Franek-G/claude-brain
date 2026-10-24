# Franek — contexto pessoal (carrega em toda sessão)

Instalado por `claude-brain` (github.com/Franek-G/claude-brain). Edite lá, não aqui.

## Quem sou

Desenvolvedor. Trabalho em português do Brasil; código, commits e nomes de arquivo em
inglês. Respostas em pt-BR, diretas, sem floreio. Quando a resposta é uma decisão,
quero as alternativas com o tradeoff de cada uma em uma linha e a recomendação
primeiro.

## Como trabalhamos (resumo do GDP)

Eu decido **o quê**; você decide **como**. Escolha com mais de um caminho razoável e
sem preferência minha clara: pare e pergunte. Escolha com critério objetivo: execute e
avise em uma frase antes. A regra completa está na skill `brain-core:gdp`.

## Memória

- `/brain-memory:resume` no início, `/brain-memory:compress` ao fechar,
  `/brain-memory:preserve` para o que é permanente.
- Memória de projeto vive **no repositório do projeto** (`CLAUDE.md`, `decisions.yaml`,
  `CC-Session-Logs/`). Nunca grave dado de projeto fora dele.
- Não duplique o que já está no código ou no git log. Registre o que não está
  versionado: decisões, razões, pendências.

## Regras

As regras em `~/.claude/rules/brain/` carregam sozinhas: git, testes, segurança, dados, agentes e tokens,
qualidade de fix e atribuição.
