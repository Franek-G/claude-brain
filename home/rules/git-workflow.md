# Git

- Commits pequenos e atômicos. Mensagem no imperativo, em inglês, primeira linha até
  72 caracteres, corpo explica o porquê quando não for óbvio.
- Nunca `git push --force` em `main`/`master`. Em branch própria, `--force-with-lease`.
- Nunca `--no-verify`. Se o hook falha, o hook está certo até prova em contrário.
- Não faça commit nem push sem o usuário pedir. Em branch padrão, crie branch antes.
- Antes de commitar: `git status` e `git diff --staged`. Nada de `git add -A` sem olhar.
- Não reescreva histórico já publicado.
