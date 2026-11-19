#!/usr/bin/env python
"""PreToolUse guard for the multi-agent verification flow (2026-11-17).

Enforces two rules from docs/ops/multi_agent_ops.md:

1. Write/Edit/MultiEdit/NotebookEdit may only touch files under the
   writable roots: verify/ (the project dir), deliver_bridge/, sim/.
2. Bash/PowerShell may not run `git commit` unless the command carries
   COMMIT_APPROVED=1 (leader-only escape hatch after explicit user
   approval).

Exit codes: 0 = allow, 2 = block (stderr is shown as the reason).
Malformed input fails open (exit 0) so a hook bug never wedges the flow.
"""
import json
import os
import re
import sys


def _winpath(p):
    # Git Bash / MSYS style /c/foo or /c/foo\bar -> C:\foo\bar
    m = re.match(r"^[/\\]([A-Za-z])[/\\](.+)", p)
    if m:
        return m.group(1).upper() + ":\\" + m.group(2).replace("/", "\\")
    return p


def _roots():
    project_dir = os.path.abspath(_winpath(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()))
    repo_root = os.path.dirname(project_dir)
    cands = [
        project_dir,
        os.path.join(repo_root, "deliver_bridge"),
        os.path.join(repo_root, "sim"),
        os.path.expanduser("~/.claude/projects"),  # Claude Code session/memory state (not user code; ~/.claude itself stays guarded)
    ]
    return [os.path.normcase(p) for p in cands]


def _under_writable_root(path):
    p = os.path.normcase(os.path.abspath(_winpath(path)))
    for root in _roots():
        if p == root or p.startswith(root + os.sep):
            return True
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    tool = (data.get("tool_name") or "").lower()
    ti = data.get("tool_input") or {}

    if tool in ("write", "edit", "multiedit"):
        path = ti.get("file_path") or ti.get("path") or ""
        if path and not _under_writable_root(path):
            sys.stderr.write(
                "[path_guard] BLOCKED write outside writable roots: %s\n"
                "writable roots: verify/, deliver_bridge/, sim/\n"
                "sub-agents: present a change plan to the leader instead; "
                "source-of-truth edits need user approval.\n" % path)
            sys.exit(2)
        return
    if tool == "notebookedit":
        path = ti.get("notebook_path") or ""
        if path and not _under_writable_root(path):
            sys.stderr.write(
                "[path_guard] BLOCKED notebook write outside writable roots: %s\n" % path)
            sys.exit(2)
        return
    if tool in ("bash", "powershell"):
        cmd = ti.get("command") or ""
        if re.search(r"\bgit\b[^|;&]{0,80}\bcommit\b", cmd) and "COMMIT_APPROVED=1" not in cmd:
            sys.stderr.write(
                "[path_guard] BLOCKED git commit without approval.\n"
                "sub-agents: never commit - report the proposed commit to the leader.\n"
                "leader: only after the user approves, prefix the command with COMMIT_APPROVED=1.\n")
            sys.exit(2)


if __name__ == "__main__":
    main()
