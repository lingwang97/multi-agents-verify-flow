#!/bin/bash
# PreToolUse(Bash) hook. Reminds Claude to evaluate the architecture memory AND the
# add-test-case skill (+ its docs) when module-defining files change, or when the skill's
# MODULES list drifts from json/module.json. Edits happen only after the user confirms.
# Fires once per distinct state (hash kept in .git/), not on every command.

# verify/ root = two levels above this script, so it works wherever Claude was launched
VERIFY="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FILES="script/uvm_env_config_template.json json/module.json script/gen_uvm_env.py"
SKILL_PY=".claude/skills/add-test-case/add_test_case.py"
GITDIR=$(git -C "$VERIFY" rev-parse --absolute-git-dir 2>/dev/null)
STATE="${GITDIR:-$VERIFY}/arch_memory_hook.state"

# 1) uncommitted changes to the module-defining files (vs HEAD)
diff=""
[ -n "$GITDIR" ] && diff=$(git -C "$VERIFY" diff HEAD -- $FILES 2>/dev/null)

# 2) drift between json/module.json modules and the skill's MODULES list
drift=""
PY=$(command -v python3 || command -v python)
if [ -n "$PY" ] && [ -f "$VERIFY/json/module.json" ] && [ -f "$VERIFY/$SKILL_PY" ]; then
  drift=$(PYTHONIOENCODING=utf-8 "$PY" - "$VERIFY/json/module.json" "$VERIFY/$SKILL_PY" 2>/dev/null <<'EOF'
import json, re, sys
mods = set(json.load(open(sys.argv[1], encoding="utf-8")).get("modules", {}))
m = re.search(r"MODULES\s*=\s*\[(.*?)\]", open(sys.argv[2], encoding="utf-8").read(), re.S)
skill = set(re.findall(r"[\"']([\w]+)[\"']", m.group(1))) if m else set()
miss, extra = sorted(mods - skill), sorted(skill - mods)
out = []
if miss: out.append("skill MODULES missing: " + ",".join(miss))
if extra: out.append("skill MODULES extra: " + ",".join(extra))
print("; ".join(out))
EOF
)
fi

if [ -z "$diff" ] && [ -z "$drift" ]; then
  rm -f "$STATE"
  exit 0
fi

cur=$(printf '%s|%s' "$diff" "$drift" | cksum | cut -d' ' -f1,2)
[ "$(cat "$STATE" 2>/dev/null)" = "$cur" ] && exit 0
echo "$cur" > "$STATE"

reason=""
if [ -n "$diff" ]; then
  changed=$(git -C "$VERIFY" diff HEAD --name-only -- $FILES | tr '\n' ' ')
  reason="uncommitted changes in module-defining files: ${changed}. "
fi
[ -n "$drift" ] && reason="${reason}module list drift (${drift}). "

msg="Architecture sync reminder: ${reason}Please evaluate whether the following need a matching update (paths relative to verify/): (1) docs/memory/arch_memory.md - the §0 module table and R1/R2; (2) the add-test-case skill - MODULES in .claude/skills/add-test-case/add_test_case.py and every module enumeration in SKILL.md (frontmatter description, intro, --module usage line, block-level Gotcha, Troubleshooting table), plus the module list in test_case_dev_manual.md and the open-gap list in docs/memory/arch_memory.md §9; (3) module names mentioned in CLAUDE.md and .claude/rules/. Present the evaluation (what to change and how) to the user first and get confirmation before editing any file; if no change is needed, briefly state why."
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$msg"
