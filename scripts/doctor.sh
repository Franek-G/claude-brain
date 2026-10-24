#!/usr/bin/env bash
# Verifica a instalação do claude-brain nesta máquina. Exit 1 se houver erro; avisos não falham.
set -u
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ERR=0; WARN=0
ok()   { printf '  ok    %s\n' "$*"; }
warn() { printf '  aviso %s\n' "$*"; WARN=$((WARN+1)); }
err()  { printf '  ERRO  %s\n' "$*"; ERR=$((ERR+1)); }

command -v claude >/dev/null && ok "claude no PATH ($(claude --version 2>/dev/null | head -1))" || err "claude não está no PATH"

if [ -f "$CLAUDE_DIR/plugins/known_marketplaces.json" ] && grep -q '"claude-brain"' "$CLAUDE_DIR/plugins/known_marketplaces.json"; then
  ok "marketplace claude-brain registrado"
else
  err "marketplace claude-brain não registrado (claude plugin marketplace add Franek-G/claude-brain)"
fi

for p in brain-core brain-memory; do
  if [ -f "$CLAUDE_DIR/settings.json" ] && grep -q "\"$p@claude-brain\"" "$CLAUDE_DIR/settings.json"; then
    ok "plugin $p instalado"
  else
    err "plugin $p não instalado (claude plugin install $p@claude-brain --scope user)"
  fi
done

if [ -d "$CLAUDE_DIR/rules/brain" ] && [ -n "$(ls "$CLAUDE_DIR/rules/brain"/*.md 2>/dev/null)" ]; then
  if diff -rq "$REPO_DIR/home/rules" "$CLAUDE_DIR/rules/brain" >/dev/null 2>&1; then
    ok "rules em $CLAUDE_DIR/rules/brain iguais a home/rules"
  else
    warn "rules em $CLAUDE_DIR/rules/brain diferem de home/rules (rode install.sh)"
  fi
else
  err "rules não instaladas em $CLAUDE_DIR/rules/brain"
fi

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  cmp -s "$REPO_DIR/home/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" && ok "CLAUDE.md pessoal igual a home/CLAUDE.md" || warn "CLAUDE.md pessoal difere de home/CLAUDE.md (install.sh --force para substituir)"
else
  warn "sem $CLAUDE_DIR/CLAUDE.md"
fi

if [ -f "$CLAUDE_DIR/brain.local.json" ]; then
  ok "brain.local.json presente"
  V="$(python3 -c "import json;print(json.load(open('$CLAUDE_DIR/brain.local.json')).get('vault',''))" 2>/dev/null || true)"
  if [ -n "$V" ]; then
    case "$V" in "~"*) V="$HOME${V#\~}";; esac
    [ -d "$V" ] && ok "vault: $V" || err "vault configurado não existe: $V"
  else
    warn "vault vazio em brain.local.json (ok se você não usa vault pessoal)"
  fi
else
  err "sem $CLAUDE_DIR/brain.local.json (rode install.sh)"
fi

# duplicatas com instalação antiga (hooks e comandos soltos)
if [ -f "$CLAUDE_DIR/settings.json" ] && grep -q 'suggest_compress' "$CLAUDE_DIR/settings.json"; then
  warn "settings.json ainda tem o hook antigo suggest_compress; o plugin brain-memory já o traz (vai disparar duas vezes). Remova de settings.json."
fi
for c in resume compress preserve; do
  [ -f "$CLAUDE_DIR/commands/$c.md" ] && warn "comando antigo $CLAUDE_DIR/commands/$c.md ainda existe; /$c e /brain-memory:$c coexistem. Apague o antigo."
done

echo
echo "  $ERR erro(s), $WARN aviso(s)"
[ "$ERR" -eq 0 ]
