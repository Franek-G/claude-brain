#!/usr/bin/env bash
# Detecta onde a memória deste diretório vive.
#
# Saída (uma chave por linha, formato KEY=value):
#   MODE               VAULT | PROJECT | NONE
#   ROOT               raiz do vault ou do projeto
#   CLAUDE_MD          CLAUDE.md principal a ler
#   PROJECT_CLAUDE_MD  CLAUDE.md de projeto dentro do vault (só em VAULT, se houver)
#   LOGS_DIR           onde os logs de sessão ficam
#   DECISIONS          decisions.yaml do destino
#   LOG_COUNT          quantos .md existem em LOGS_DIR
#
# Configuração da máquina: ~/.claude/brain.local.json (gerado por scripts/install.sh)
#   { "vault": "/caminho/do/vault" ou "",
#     "vault_logs_dir": "Areas/Work/Session-Logs",
#     "project_logs_dir": "CC-Session-Logs" }
set -u

CONFIG="${BRAIN_LOCAL_CONFIG:-$HOME/.claude/brain.local.json}"
PY="$(command -v python3 || command -v python || true)"

read_cfg() {
  # $1 = chave, $2 = default
  if [ -n "$PY" ] && [ -f "$CONFIG" ]; then
    "$PY" - "$CONFIG" "$1" "$2" <<'PYEOF'
import json, sys
path, key, default = sys.argv[1:4]
try:
    with open(path, encoding="utf-8") as f:
        print(json.load(f).get(key, default) or default)
except Exception:
    print(default)
PYEOF
  else
    printf '%s\n' "$2"
  fi
}

VAULT="$(read_cfg vault "")"
VAULT_LOGS="$(read_cfg vault_logs_dir "Areas/Work/Session-Logs")"
PROJECT_LOGS="$(read_cfg project_logs_dir "CC-Session-Logs")"

HERE="$(pwd -P)"
MODE=NONE ROOT="" CLAUDE_MD="" PROJECT_CLAUDE_MD="" LOGS_DIR="" DECISIONS=""

# Expande ~ no caminho do vault
case "$VAULT" in "~"*) VAULT="$HOME${VAULT#\~}";; esac

if [ -n "$VAULT" ] && [ -d "$VAULT" ]; then
  VAULT_P="$(cd "$VAULT" && pwd -P)"
  case "$HERE/" in
    "$VAULT_P"/*)
      MODE=VAULT; ROOT="$VAULT_P"
      CLAUDE_MD="$ROOT/CLAUDE.md"
      LOGS_DIR="$ROOT/$VAULT_LOGS"
      DECISIONS="$ROOT/decisions.yaml"
      # CLAUDE.md de projeto entre o pwd e a raiz do vault
      d="$HERE"
      while [ "$d" != "$ROOT" ] && [ -n "$d" ] && [ "$d" != "/" ]; do
        if [ -f "$d/CLAUDE.md" ]; then PROJECT_CLAUDE_MD="$d/CLAUDE.md"; DECISIONS="$d/decisions.yaml"; break; fi
        d="$(dirname "$d")"
      done
      ;;
  esac
fi

if [ "$MODE" = NONE ]; then
  d="$HERE"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -f "$d/CLAUDE.md" ]; then
      MODE=PROJECT; ROOT="$d"
      CLAUDE_MD="$d/CLAUDE.md"
      LOGS_DIR="$d/$PROJECT_LOGS"
      DECISIONS="$d/decisions.yaml"
      break
    fi
    d="$(dirname "$d")"
  done
fi

LOG_COUNT=0
if [ -n "$LOGS_DIR" ] && [ -d "$LOGS_DIR" ]; then
  LOG_COUNT=$(find "$LOGS_DIR" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')
fi

printf 'MODE=%s\n' "$MODE"
printf 'ROOT=%s\n' "$ROOT"
printf 'CLAUDE_MD=%s\n' "$CLAUDE_MD"
[ -n "$PROJECT_CLAUDE_MD" ] && printf 'PROJECT_CLAUDE_MD=%s\n' "$PROJECT_CLAUDE_MD"
printf 'LOGS_DIR=%s\n' "$LOGS_DIR"
printf 'DECISIONS=%s\n' "$DECISIONS"
printf 'LOG_COUNT=%s\n' "$LOG_COUNT"
exit 0
