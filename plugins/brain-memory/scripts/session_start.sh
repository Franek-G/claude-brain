#!/usr/bin/env bash
# SessionStart hook: injeta uma linha de contexto sobre onde a memória deste
# diretório vive. Não lê nenhum log; só informa. Silencioso em MODE=NONE.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$(bash "$HERE/detect_mode.sh" 2>/dev/null || true)"
MODE="$(printf '%s\n' "$OUT" | sed -n 's/^MODE=//p')"
[ "$MODE" = NONE ] || [ -z "$MODE" ] && exit 0

ROOT="$(printf '%s\n' "$OUT" | sed -n 's/^ROOT=//p')"
LOGS_DIR="$(printf '%s\n' "$OUT" | sed -n 's/^LOGS_DIR=//p')"
COUNT="$(printf '%s\n' "$OUT" | sed -n 's/^LOG_COUNT=//p')"
LAST=""
if [ -d "$LOGS_DIR" ] && [ "${COUNT:-0}" -gt 0 ]; then
  LAST="$(ls -1 "$LOGS_DIR"/*.md 2>/dev/null | sort | tail -1 | xargs -n1 basename 2>/dev/null)"
fi

MSG="brain-memory: modo $MODE, raiz $ROOT. $COUNT log(s) de sessão em $LOGS_DIR"
[ -n "$LAST" ] && MSG="$MSG (último: $LAST)"
MSG="$MSG. Para carregar contexto use /brain-memory:resume; não leia logs sem pedido."

PY="$(command -v python3 || command -v python || true)"
if [ -n "$PY" ]; then
  "$PY" -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.argv[1]}}))' "$MSG"
else
  ESC="$(printf '%s' "$MSG" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESC"
fi
exit 0
