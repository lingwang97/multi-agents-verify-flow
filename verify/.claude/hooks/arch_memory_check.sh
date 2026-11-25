#!/bin/bash
# PreToolUse(Bash) hook. Reminds Claude to evaluate the module-state documents when
# module-defining files change. Edits happen only after the user confirms.
# Fires once per distinct state (hash kept in .git/), not on every command.
# Module NAMES appear in no instruction file (arch_memory R1: the add-test-case skill
# reads json/module.json), so only the state documents need a matching update.

# verify/ root = two levels above this script, so it works wherever Claude was launched
VERIFY="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FILES="script/uvm_env_config_template.json json/module.json script/gen_uvm_env.py"
GITDIR=$(git -C "$VERIFY" rev-parse --absolute-git-dir 2>/dev/null)
STATE="${GITDIR:-$VERIFY}/arch_memory_hook.state"

# uncommitted changes to the module-defining files (vs HEAD)
diff=""
[ -n "$GITDIR" ] && diff=$(git -C "$VERIFY" diff HEAD -- $FILES 2>/dev/null)

if [ -z "$diff" ]; then
  rm -f "$STATE"
  exit 0
fi

cur=$(printf '%s' "$diff" | cksum | cut -d' ' -f1,2)
[ "$(cat "$STATE" 2>/dev/null)" = "$cur" ] && exit 0
echo "$cur" > "$STATE"

changed=$(git -C "$VERIFY" diff HEAD --name-only -- $FILES | tr '\n' ' ')
msg="Architecture sync reminder: uncommitted changes in module-defining files: ${changed}. If modules were added or removed, evaluate whether these need a matching update (paths relative to verify/): (1) docs/memory/arch_memory.md - the §0 module table and the §9 open-gap list; (2) docs/modules/<mod>.md for added/removed modules (arch R2). Instruction files (add-test-case skill, CLAUDE.md, rules) carry no module names (arch R1) and need no change. Present the evaluation to the user first and get confirmation before editing any file; if no change is needed, briefly state why."
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$msg"
