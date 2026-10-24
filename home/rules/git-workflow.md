# Git

- Commits pequenos e atômicos. Mensagem no imperativo, em inglês, primeira linha até
  72 caracteres, corpo explica o porquê quando não for óbvio.
- Nunca `git push --force` em `main`/`master`. Em branch própria, `--force-with-lease`.
- Nunca `--no-verify`. Se o hook falha, o hook está certo até prova em contrário.
- Não faça commit nem push sem o usuário pedir. Em branch padrão, crie branch antes.
- Antes de commitar: `git status` e `git diff --staged`. Nada de `git add -A` sem olhar.
- Não reescreva histórico já publicado.

## Mudança em código de produção

- **Prod é a fonte da verdade.** Antes de alterar script ou regra: `git fetch` e leia a versão
  de produção com `git show origin/main:<arquivo>`. Nunca parta de cópia local.
- **Guarde o original ao lado da proposta** e mostre o diff mínimo, preservando espaços e
  fim de linha (CRLF onde for CRLF).
- **Clone que não é seu** (de colega, de outro time): só `git fetch` e leitura de
  `origin/<branch>`. Nunca `pull`, `checkout` ou `push` sem pedir.
- **Duas aprovações humanas**: a pessoa aprova o resultado antes do push; o time aprova o PR.
  Sem "pode subir", não há push. O Claude nunca faz merge.
- Antes de abrir o PR, confira se a `main` mudou desde o início; se mudou, refaça a partir
  dela.
