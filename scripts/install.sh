#!/usr/bin/env bash
# Instala o claude-brain nesta máquina. Idempotente: rode quantas vezes quiser.
#
#   bash scripts/install.sh            # marketplace do GitHub + plugins + camada home/
#   bash scripts/install.sh --local    # usa este checkout como marketplace (desenvolvimento)
#   bash scripts/install.sh --force    # sobrescreve ~/.claude/CLAUDE.md (faz backup antes)
#
# O que faz:
#   1. registra o marketplace "claude-brain" e instala brain-core e brain-memory (escopo user)
#   2. copia home/rules/*.md para ~/.claude/rules/brain/
#   3. copia home/CLAUDE.md para ~/.claude/CLAUDE.md (só se não existir, ou com --force)
#   4. mescla home/settings.base.json em ~/.claude/settings.json (só adiciona)
#   5. cria ~/.claude/brain.local.json a partir do exemplo (só se não existir)
#   6. roda doctor.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MARKET_NAME="claude-brain"
MARKET_SRC="Franek-G/claude-brain"
PLUGINS=(brain-core brain-memory)
LOCAL=0; FORCE=0
for a in "$@"; do
  case "$a" in
    --local) LOCAL=1;;
    --force) FORCE=1;;
    -h|--help) sed -n '2,16p' "$0"; exit 0;;
    *) echo "argumento desconhecido: $a" >&2; exit 2;;
  esac
done
[ "$LOCAL" = 1 ] && MARKET_SRC="$REPO_DIR"

PY="$(command -v python3 || command -v python || true)"
[ -n "$PY" ] || { echo "ERRO: python3 não encontrado (os scripts usam só a stdlib)" >&2; exit 1; }
command -v claude >/dev/null || { echo "ERRO: 'claude' não está no PATH. Instale o Claude Code primeiro." >&2; exit 1; }

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }
mkdir -p "$CLAUDE_DIR/rules/brain"

# 1. marketplace + plugins
if [ -f "$CLAUDE_DIR/plugins/known_marketplaces.json" ] && grep -q "\"$MARKET_NAME\"" "$CLAUDE_DIR/plugins/known_marketplaces.json"; then
  say "marketplace $MARKET_NAME já registrado"
else
  say "registrando marketplace $MARKET_NAME ($MARKET_SRC)"
  claude plugin marketplace add "$MARKET_SRC"
fi
for p in "${PLUGINS[@]}"; do
  if [ -f "$CLAUDE_DIR/settings.json" ] && grep -q "\"$p@$MARKET_NAME\"" "$CLAUDE_DIR/settings.json"; then
    say "plugin $p já instalado"
  else
    say "instalando $p@$MARKET_NAME"
    claude plugin install "$p@$MARKET_NAME" --scope user
  fi
done

# 2. rules
say "copiando rules para $CLAUDE_DIR/rules/brain/"
cp "$REPO_DIR/home/rules/"*.md "$CLAUDE_DIR/rules/brain/"

# 3. CLAUDE.md
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  say "criando $CLAUDE_DIR/CLAUDE.md"
  cp "$REPO_DIR/home/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
elif cmp -s "$REPO_DIR/home/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
  say "CLAUDE.md já atualizado"
elif [ "$FORCE" = 1 ]; then
  BK="$CLAUDE_DIR/CLAUDE.md.bak-$(date +%Y%m%d-%H%M%S)"
  say "CLAUDE.md difere; backup em $BK e sobrescrevendo (--force)"
  cp "$CLAUDE_DIR/CLAUDE.md" "$BK"; cp "$REPO_DIR/home/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
else
  say "AVISO: $CLAUDE_DIR/CLAUDE.md existe e difere de home/CLAUDE.md. Use --force para substituir (faz backup)."
fi

# 4. settings merge (só adiciona)
say "mesclando permissões base em $CLAUDE_DIR/settings.json"
"$PY" - "$REPO_DIR/home/settings.base.json" "$CLAUDE_DIR/settings.json" <<'PYEOF'
import json, sys, os
base_path, target_path = sys.argv[1:3]
with open(base_path, encoding="utf-8") as f:
    base = json.load(f)
base.pop("_comment", None)
target = {}
if os.path.exists(target_path):
    with open(target_path, encoding="utf-8") as f:
        target = json.load(f)
changed = False
perms = target.setdefault("permissions", {})
for key in ("allow", "ask", "deny"):
    for rule in base.get("permissions", {}).get(key, []):
        lst = perms.setdefault(key, [])
        if rule not in lst:
            lst.append(rule); changed = True
for key, val in base.items():
    if key != "permissions" and key not in target:
        target[key] = val; changed = True
if changed:
    with open(target_path, "w", encoding="utf-8") as f:
        json.dump(target, f, indent=2, ensure_ascii=False); f.write("\n")
    print("    settings.json atualizado")
else:
    print("    nada a adicionar")
PYEOF

# 5. brain.local.json
if [ ! -f "$CLAUDE_DIR/brain.local.json" ]; then
  say "criando $CLAUDE_DIR/brain.local.json"
  cp "$REPO_DIR/home/brain.local.json.example" "$CLAUDE_DIR/brain.local.json"
  if [ -t 0 ]; then
    read -r -p "    Caminho do vault pessoal (Enter para nenhum): " VAULT_PATH
    if [ -n "${VAULT_PATH:-}" ]; then
      "$PY" - "$CLAUDE_DIR/brain.local.json" "$VAULT_PATH" <<'PYEOF'
import json, sys
p, v = sys.argv[1:3]
d = json.load(open(p, encoding="utf-8")); d["vault"] = v
json.dump(d, open(p, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
PYEOF
    fi
  else
    echo "    edite 'vault' em $CLAUDE_DIR/brain.local.json se usar um vault pessoal"
  fi
else
  say "brain.local.json já existe"
fi

# 6. doctor
say "verificando"
bash "$REPO_DIR/scripts/doctor.sh" || true
say "pronto. Abra uma sessão nova do Claude Code para carregar os plugins."
