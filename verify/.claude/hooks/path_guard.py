#!/usr/bin/env python
"""PreToolUse guard for the multi-agent verification flow (2026-11-17).

Enforces the rules from docs/ops/multi_agent_ops.md §1/§6:

1. Write/Edit/MultiEdit/NotebookEdit may only touch files under the
   writable roots: verify/ (the project dir), deliver_bridge/, sim/.
2. Bash/PowerShell `git commit`:
   - inside a subagent: always blocked, even with COMMIT_APPROVED=1;
   - main session (leader): blocked unless the command carries
     COMMIT_APPROVED=1 (escape hatch after explicit user approval).
3. Tiered confirmation (2026-11-23): a subagent Write/Edit of a
   source-of-truth file, or the creation of a reference model, needs the
   user. In a prompting permission mode (default/plan) the hook returns
   permissionDecision "ask" - the prompt surfaces in the main session and
   the user's answer is the approval. In modes that resolve prompts without
   a human (auto, acceptEdits, bypassPermissions, dontAsk) "ask" is not a
   gate (verified live 2026-11-23: auto mode let it through), so the call
   is blocked instead. The main session is not affected.

A call comes from a subagent when the hook input carries `agent_id`
(Claude Code common hook input field).

Exit codes: 0 = allow (or JSON decision on stdout), 2 = block (stderr is
shown as the reason). Malformed input fails open (exit 0) so a hook bug
never wedges the flow.
"""
import fnmatch
import json
import os
import re
import sys

# Source-of-truth paths, relative to the project dir (verify/), "/" separators.
# Module-private filelists (uvm_blk_<mod>.f, tb_top_<mod>.f) are excluded below.
SOT_PREFIXES = ("script/", ".claude/", "utils/")
SOT_FILES = {
    "CLAUDE.md",
    "json/module.json",
    "env/top_env.sv",
    "env/top_vseqr.sv",
    "env/top_pkg.sv",
    "test/base_test.sv",
    "seq/base_seq.sv",
    "seq/soc_sequence_lib.sv",
    "tb_top/tb_top/tb_top_soc.sv",
    "tb_top/macro/tb_define.sv",
    "tb_top/component/vif_declare.sv",
}
SOT_GLOBS = ("tb_top/filelist/*.f",)
SOT_GLOB_EXCEPT = ("tb_top/filelist/uvm_blk_*.f", "tb_top/filelist/tb_top_*.f")
REF_MODEL_GLOB = "uvc/*/src/*_ref_model.sv"
# Permission modes that settle prompts without a human: "ask" would not gate.
NO_PROMPT_MODES = {"auto", "acceptEdits", "bypassPermissions", "dontAsk"}


def _winpath(p):
    # Git Bash / MSYS style /c/foo or /c/foo\bar -> C:\foo\bar
    m = re.match(r"^[/\\]([A-Za-z])[/\\](.+)", p)
    if m:
        return m.group(1).upper() + ":\\" + m.group(2).replace("/", "\\")
    return p


def _project_dir():
    return os.path.abspath(_winpath(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()))


def _abs(path, cwd):
    p = _winpath(path)
    if not os.path.isabs(p):
        p = os.path.join(cwd or os.getcwd(), p)
    return os.path.abspath(p)


def _roots():
    project_dir = _project_dir()
    repo_root = os.path.dirname(project_dir)
    cands = [
        project_dir,
        os.path.join(repo_root, "deliver_bridge"),
        os.path.join(repo_root, "sim"),
        os.path.expanduser("~/.claude/projects"),  # Claude Code session/memory state (not user code; ~/.claude itself stays guarded)
    ]
    return [os.path.normcase(p) for p in cands]


def _under_writable_root(abspath):
    p = os.path.normcase(abspath)
    for root in _roots():
        if p == root or p.startswith(root + os.sep):
            return True
    return False


def _rel_to_project(abspath):
    """Project-relative path with '/' separators, or None when outside verify/."""
    proj = _project_dir()
    p = os.path.normcase(abspath)
    root = os.path.normcase(proj)
    if not p.startswith(root + os.sep):
        return None
    return abspath[len(proj) + 1:].replace("\\", "/")


def _is_source_of_truth(rel):
    lrel = rel.lower()  # Windows paths are case-insensitive
    if lrel.startswith(SOT_PREFIXES) or lrel in {f.lower() for f in SOT_FILES}:
        return True
    if any(fnmatch.fnmatchcase(lrel, g) for g in SOT_GLOBS):
        return not any(fnmatch.fnmatchcase(lrel, g) for g in SOT_GLOB_EXCEPT)
    return False


def _gate(reason, data):
    mode = data.get("permission_mode")
    if mode in NO_PROMPT_MODES:
        sys.stderr.write(
            "%s\n[path_guard] BLOCKED: permission mode '%s' cannot guarantee a user prompt. "
            "Stop and report to the leader; the user switches to default mode (Shift+Tab) "
            "and the task is re-dispatched.\n" % (reason, mode))
        sys.exit(2)
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "ask",
        "permissionDecisionReason": reason}}))


def _check_write(path, data, tool):
    cwd = data.get("cwd")
    ap = _abs(path, cwd)
    if not _under_writable_root(ap):
        sys.stderr.write(
            "[path_guard] BLOCKED write outside writable roots: %s\n"
            "writable roots: verify/, deliver_bridge/, sim/\n"
            "sub-agents: present a change plan to the leader instead; "
            "source-of-truth edits need user approval.\n" % path)
        sys.exit(2)
    if not data.get("agent_id"):
        return  # main session (leader): tiered confirmation is not hook-enforced
    agent = data.get("agent_type") or "subagent"
    rel = _rel_to_project(ap)
    if rel is None:
        return  # deliver_bridge/, sim/, session state: direct-edit tier
    if _is_source_of_truth(rel):
        _gate("[path_guard] %s wants to edit the source-of-truth file %s. "
              "Per ops section 1 this needs a user-approved change plan - allow only if you approved it." % (agent, rel), data)
    elif tool == "write" and fnmatch.fnmatch(rel, REF_MODEL_GLOB) and not os.path.exists(ap):
        _gate("[path_guard] %s wants to create the reference model %s. "
              "Per the dev_agent charter this needs a user-approved development plan." % (agent, rel), data)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    tool = (data.get("tool_name") or "").lower()
    ti = data.get("tool_input") or {}

    if tool in ("write", "edit", "multiedit"):
        path = ti.get("file_path") or ti.get("path") or ""
        if path:
            _check_write(path, data, tool)
        return
    if tool == "notebookedit":
        path = ti.get("notebook_path") or ""
        if path:
            _check_write(path, data, tool)
        return
    if tool in ("bash", "powershell"):
        cmd = ti.get("command") or ""
        if not re.search(r"\bgit\b[^|;&]{0,80}\bcommit\b", cmd):
            return
        if data.get("agent_id"):
            sys.stderr.write(
                "[path_guard] BLOCKED git commit from a sub-agent (%s).\n"
                "sub-agents never commit, COMMIT_APPROVED=1 is leader-only - "
                "report the proposed commit to the leader.\n" % (data.get("agent_type") or "subagent"))
            sys.exit(2)
        if "COMMIT_APPROVED=1" not in cmd:
            sys.stderr.write(
                "[path_guard] BLOCKED git commit without approval.\n"
                "leader: only after the user approves, prefix the command with COMMIT_APPROVED=1.\n")
            sys.exit(2)


if __name__ == "__main__":
    main()
