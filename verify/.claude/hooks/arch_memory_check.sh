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
  reason="未提交改动的模块定义文件: ${changed}。"
fi
[ -n "$drift" ] && reason="${reason}模块清单不一致(${drift})。"

msg="架构同步提醒：${reason}请评估以下内容是否需要随之更新（路径相对 verify/）：(1) docs/memory/arch_memory.md 的 §0 模块表和 R1/R2；(2) add-test-case skill：.claude/skills/add-test-case/add_test_case.py 的 MODULES、SKILL.md 里所有模块枚举（description、简介、--module 用法行、块级 Gotcha、Troubleshooting 表）、test_case_dev_manual.md 的模块列表与 §7 缺口表；(3) CLAUDE.md 里的模块和 filelist 说明。请先把评估结论（哪些要改、怎么改）告诉用户，得到用户确认后才可修改，确认前不要编辑任何文件；若判断无需改动，请简短说明理由。"
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$msg"
