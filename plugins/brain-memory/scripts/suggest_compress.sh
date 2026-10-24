#!/usr/bin/env bash
# Stop hook: sugere /brain-memory:compress se a sessão foi longa.
# Não bloqueia. Threshold em linhas do transcript (400 ≈ sessão substancial).
set -u
THRESHOLD="${BRAIN_COMPRESS_THRESHOLD:-400}"
PY="$(command -v python3 || command -v python || true)"

INPUT="$(cat 2>/dev/null || true)"
TRANSCRIPT=""
if [ -n "$PY" ] && [ -n "$INPUT" ]; then
  TRANSCRIPT="$(printf '%s' "$INPUT" | "$PY" -c 'import sys,json
try:
    print(json.load(sys.stdin).get("transcript_path",""))
except Exception:
    pass' 2>/dev/null || true)"
fi
[ -z "$TRANSCRIPT" ] && TRANSCRIPT="${CLAUDE_TRANSCRIPT_PATH:-}"
[ -z "$TRANSCRIPT" ] && exit 0
[ -f "$TRANSCRIPT" ] || exit 0

LINES=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
[ -z "$LINES" ] && exit 0

if [ "$LINES" -gt "$THRESHOLD" ]; then
  MSG="Transcript com $LINES linhas (>$THRESHOLD). Considere /brain-memory:compress antes de fechar."
  if [ -n "$PY" ]; then
    "$PY" -c 'import json,sys; print(json.dumps({"systemMessage": sys.argv[1]}))' "$MSG"
  else
    printf '{"systemMessage":"%s"}\n' "$MSG"
  fi
fi
exit 0
