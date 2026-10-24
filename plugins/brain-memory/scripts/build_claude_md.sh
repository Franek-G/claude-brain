#!/usr/bin/env bash
# Concatena os fragments de <root>/_claude/*.md em <root>/CLAUDE.md, em ordem alfabética.
#
# Uso:
#   build_claude_md.sh --root <dir>            gera CLAUDE.md
#   build_claude_md.sh --root <dir> --check    exit 1 se CLAUDE.md está fora de sincronia
# Sem --root, usa o diretório atual.
set -euo pipefail

ROOT="$(pwd -P)"; MODE=build; MAX_LINES="${BRAIN_CLAUDE_MD_MAX_LINES:-280}"
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$(cd "$2" && pwd -P)"; shift 2;;
    --check) MODE=check; shift;;
    *) echo "ERRO: argumento desconhecido '$1'" >&2; exit 2;;
  esac
done

OUT="$ROOT/CLAUDE.md"
FRAGS_DIR="$ROOT/_claude"
[ -d "$FRAGS_DIR" ] || { echo "ERRO: $FRAGS_DIR não existe" >&2; exit 1; }

N=$(find "$FRAGS_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
[ "$N" -gt 0 ] || { echo "ERRO: nenhum fragment .md em $FRAGS_DIR" >&2; exit 1; }

TMP="$(mktemp -t claude_md.XXXXXX)"
trap 'rm -f "$TMP"' EXIT
find "$FRAGS_DIR" -maxdepth 1 -name "*.md" -type f -print0 | sort -z | while IFS= read -r -d '' f; do
  cat "$f" >> "$TMP"; printf '\n' >> "$TMP"
done

case "$MODE" in
  check)
    if [ ! -f "$OUT" ]; then echo "CLAUDE.md não existe. Rode o build." >&2; exit 1; fi
    if ! diff -q "$OUT" "$TMP" >/dev/null 2>&1; then
      echo "CLAUDE.md está fora de sincronia com _claude/*.md. Rode o build." >&2; exit 1
    fi
    echo "CLAUDE.md sincronizado";;
  build)
    cp "$TMP" "$OUT"
    LINES=$(wc -l < "$OUT" | tr -d ' ')
    echo "CLAUDE.md gerado: $N fragments, $LINES linhas"
    if [ "$LINES" -gt "$MAX_LINES" ]; then
      echo "aviso: CLAUDE.md tem $LINES linhas (>$MAX_LINES). Considere arquivar via /brain-memory:preserve." >&2
    fi;;
esac
