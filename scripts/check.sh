#!/usr/bin/env bash
# Checks do repositório. O CI roda isto; rode antes de dizer "pronto".
#   1. JSON válido
#   2. shell e Python compilam
#   3. SKILL.md: name == pasta, description presente, <= 500 linhas
#   4. hooks.json: comandos usam ${CLAUDE_PLUGIN_ROOT} e o script existe
#   5. nenhum caminho absoluto em plugins/, home/, scripts/
#   6. nenhum arquivo proibido versionado (logs, transcripts, *.local.json)
#   7. claude plugin validate (se o CLI estiver disponível)
#   8. gitleaks (se instalado)
set -u
cd "$(dirname "$0")/.."
FAIL=0
fail() { printf 'FAIL  %s\n' "$*"; FAIL=1; }
pass() { printf 'ok    %s\n' "$*"; }
PY="$(command -v python3 || command -v python || true)"

# 1
for f in $(git ls-files '*.json' 2>/dev/null || find . -name '*.json' -not -path './node_modules/*'); do
  "$PY" -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$f" 2>/dev/null && pass "json $f" || fail "json inválido: $f"
done

# 2
for f in $(find plugins scripts -name '*.sh'); do bash -n "$f" && pass "bash -n $f" || fail "sintaxe: $f"; done
for f in $(find plugins scripts -name '*.py'); do "$PY" -m py_compile "$f" && pass "py_compile $f" || fail "sintaxe: $f"; done
find . -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null

# 3
for s in plugins/*/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$s")")"
  name="$(sed -n '2,15p' "$s" | sed -n 's/^name: *//p' | head -1)"
  [ "$name" = "$dir" ] && pass "skill $dir name" || fail "skill $s: name '$name' != pasta '$dir'"
  grep -q '^description: ..*' "$s" && pass "skill $dir description" || fail "skill $s: sem description"
  n=$(wc -l < "$s" | tr -d ' '); [ "$n" -le 500 ] && pass "skill $dir $n linhas" || fail "skill $s: $n linhas (>500)"
done

# 4
for h in plugins/*/hooks/hooks.json; do
  plugin_dir="$(dirname "$(dirname "$h")")"
  "$PY" - "$h" "$plugin_dir" <<'PYEOF' || FAIL=1
import json, sys, re, os
h, root = sys.argv[1:3]
d = json.load(open(h, encoding="utf-8"))
bad = 0
for event, groups in d.get("hooks", {}).items():
    for g in groups:
        for hk in g.get("hooks", []):
            cmd = hk.get("command", "")
            if "${CLAUDE_PLUGIN_ROOT}" not in cmd:
                print(f"FAIL  {h}: {event} sem CLAUDE_PLUGIN_ROOT: {cmd}"); bad = 1; continue
            for m in re.findall(r"\$\{CLAUDE_PLUGIN_ROOT\}/([^\s\"']+)", cmd):
                p = os.path.join(root, m)
                if not os.path.isfile(p):
                    print(f"FAIL  {h}: script não existe: {p}"); bad = 1
print(("FAIL  " if bad else "ok    ") + f"hooks {h}")
sys.exit(bad)
PYEOF
done

# 5
if grep -rnE '(/Users/[A-Za-z0-9_.-]+/|(^|[ "'"'"'=:(])/home/[A-Za-z0-9_.-]+/|C:\\\\)' plugins home scripts 2>/dev/null | grep -v 'scripts/check.sh' ; then
  fail "caminho absoluto em plugins/, home/ ou scripts/ (mova para brain.local.json)"
else
  pass "sem caminho absoluto em plugins/ home/ scripts/"
fi

# 6
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git ls-files | grep -E '(CC-Session-Logs/|\.jsonl$|\.local\.json$|\.local\.md$)' ; then
    fail "arquivo proibido versionado"
  else
    pass "nenhum log/transcript/local.json versionado"
  fi
fi

# 7
if command -v claude >/dev/null 2>&1; then
  for t in . plugins/*; do
    out="$(claude plugin validate "$t" 2>&1)"; rc=$?
    if [ $rc -eq 0 ]; then pass "claude plugin validate $t"; else fail "claude plugin validate $t"; printf '%s\n' "$out" | sed 's/^/      /'; fi
  done
else
  echo "skip  claude não disponível; plugin validate não rodou"
fi

# 8
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --no-banner --redact -c .gitleaks.toml -s . >/dev/null 2>&1 && pass "gitleaks" || fail "gitleaks encontrou segredo"
else
  echo "skip  gitleaks não instalado (o CI roda)"
fi

echo
[ "$FAIL" -eq 0 ] && echo "todos os checks passaram" || { echo "há falhas"; exit 1; }
