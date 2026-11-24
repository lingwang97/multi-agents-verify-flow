#!/usr/bin/env python
"""Regression matrix for path_guard.py - run after every edit of the hook:

    python .claude/hooks/test_path_guard.py

A syntax error in the hook makes Claude Code treat it as a non-blocking
error, i.e. every guard silently fails open; this script reports CRASH.
"""
import json
import os
import subprocess
import sys

HOOK_DIR = os.path.dirname(os.path.abspath(__file__))
V = os.path.dirname(os.path.dirname(HOOK_DIR))  # verify/
R = os.path.dirname(V)                          # repo root
ENV = dict(os.environ, CLAUDE_PROJECT_DIR=V)
SUB = {"agent_id": "a1", "agent_type": "dev_agent"}
fails = 0


def run(label, expect, tool, ti, sub=False, mode=None, extra=None, raw=None):
    global fails
    d = {"tool_name": tool, "tool_input": ti}
    if sub:
        d.update(SUB)
    if mode:
        d["permission_mode"] = mode
    if extra:
        d.update(extra)
    p = subprocess.run([sys.executable, os.path.join(HOOK_DIR, "path_guard.py")],
                       input=raw if raw is not None else json.dumps(d),
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                       universal_newlines=True, env=ENV, cwd=V)
    if p.returncode not in (0, 2):
        got = "CRASH"
    elif p.returncode == 2:
        got = "deny"
    else:
        got = "ask" if '"ask"' in p.stdout else "allow"
    ok = got == expect
    fails += not ok
    print("%s %-42s expect=%-5s got=%s" % ("PASS" if ok else "FAIL", label, expect, got))


def W(p):
    return {"file_path": p}


def main():
    s = os.path.join(V, "script", "gen_uvm_env.py")
    rm = os.path.join(V, "uvc", "efuse", "src", "efuse_ref_model.sv")
    for m, e in [("default", "ask"), ("plan", "ask"), (None, "ask"), ("auto", "deny"),
                 ("acceptEdits", "deny"), ("bypassPermissions", "deny"), ("dontAsk", "deny")]:
        run("sub: edit script/ mode=%s" % m, e, "Edit", W(s), True, m)
    run("sub: CLAUDE.md lowercase", "ask", "Edit", W(os.path.join(V.lower(), "claude.md")), True, "default")
    run("sub: .claude/rules mode=auto", "deny", "Write", W(os.path.join(V, ".claude", "rules", "x.md")), True, "auto")
    run("sub: uvm.f", "ask", "Edit", W(os.path.join(V, "tb_top", "filelist", "uvm.f")), True, "default")
    run("sub: top_env.sv", "ask", "Edit", W(os.path.join(V, "env", "top_env.sv")), True, "default")
    run("sub: component/dump_wave.sv", "ask", "Edit", W(os.path.join(V, "tb_top", "component", "dump_wave.sv")), True, "default")
    run("sub: json/module.json", "ask", "Edit", W(os.path.join(V, "json", "module.json")), True, "default")
    run("sub: msys path script/", "ask", "Edit", W("/c" + V[2:].replace("\\", "/") + "/script/sflow/wsim") if V[1] == ":" else W(os.path.join(V, "script", "sflow", "wsim")), True, "default")
    run("sub: relative path script/", "ask", "Edit", W("script/sflow/wsim"), True, "default", {"cwd": V})
    run("sub: notebook in .claude", "ask", "NotebookEdit", {"notebook_path": os.path.join(V, ".claude", "n.ipynb")}, True, "default")
    run("sub: create ref model", "ask", "Write", W(rm), True, "default")
    run("sub: create ref model mode=auto", "deny", "Write", W(rm), True, "auto")
    run("sub: edit ref model mode=auto", "allow", "Edit", W(rm), True, "auto")
    run("sub: uvc driver mode=auto", "allow", "Edit", W(os.path.join(V, "uvc", "efuse", "src", "efuse_driver.sv")), True, "auto")
    run("sub: json/case/<mod>.json mode=auto", "allow", "Edit", W(os.path.join(V, "json", "case", "efuse.json")), True, "auto")
    run("sub: uvm_blk_<mod>.f mode=auto", "allow", "Edit", W(os.path.join(V, "tb_top", "filelist", "uvm_blk_efuse.f")), True, "auto")
    run("sub: tb_top_<mod>.f mode=auto", "allow", "Edit", W(os.path.join(V, "tb_top", "filelist", "tb_top_efuse.f")), True, "auto")
    run("sub: arch_memory mode=auto", "allow", "Edit", W(os.path.join(V, "docs", "memory", "arch_memory.md")), True, "auto")
    run("sub: deliver_bridge mode=auto", "allow", "Write", W(os.path.join(R, "deliver_bridge", "r.md")), True, "auto")
    run("main: edit script/ mode=auto", "allow", "Edit", W(s), False, "auto")
    run("main: ~/.claude/projects", "allow", "Write", W(os.path.join(os.path.expanduser("~"), ".claude", "projects", "m.md")))
    run("sub: outside roots", "deny", "Write", W(os.path.join(os.path.dirname(R), "x.txt")), True, "default")
    run("main: outside roots", "deny", "Write", W(os.path.join(os.path.dirname(R), "x.txt")), False, "auto")
    run("main: commit w/o approval", "deny", "Bash", {"command": "git commit -m x"})
    run("main: commit with approval", "allow", "Bash", {"command": "COMMIT_APPROVED=1 git commit -m x"})
    run("sub: commit with approval", "deny", "Bash", {"command": "COMMIT_APPROVED=1 git commit -m x"}, True, "default")
    run("sub: PowerShell commit", "deny", "PowerShell", {"command": "git commit -m x"}, True, "auto")
    run("sub: other bash", "allow", "Bash", {"command": "git status"}, True, "auto")
    run("malformed input", "allow", "", {}, raw="not json")
    rtl_cases()
    print("FAILS: %d" % fails)
    sys.exit(1 if fails else 0)


def rtl_cases():
    """RTL-access gate, on a throw-away project (answers.json + grants) - the real tree is untouched."""
    global ENV
    import shutil
    import tempfile
    tmp = tempfile.mkdtemp(prefix="pg_rtl_")
    proj = os.path.join(tmp, "verify")
    os.makedirs(os.path.join(proj, "script", "new_project"))
    os.makedirs(os.path.join(proj, ".claude", "state"))
    os.makedirs(os.path.join(tmp, "design", "rtl", "uart"))
    rtl = os.path.join(tmp, "design", "rtl", "uart", "uart.v")
    other = os.path.join(tmp, "design", "rtl", "spi.v")
    saved = ENV
    ENV = dict(os.environ, CLAUDE_PROJECT_DIR=proj)

    def answers(spec):
        with open(os.path.join(proj, "script", "new_project", "answers.json"), "w") as f:
            json.dump({"answers": {"design_root": "design", "spec_dir": spec}, "applied": {}}, f)

    def grants(g):
        with open(os.path.join(proj, ".claude", "state", "rtl_access.json"), "w") as f:
            json.dump({"grants": g}, f)
    try:
        answers("none")
        grants([])
        run("rtl: pre-research, sub Read RTL", "allow", "Read", W(rtl), True, "auto")
        answers("docs/spec")
        run("rtl: doc mode, sub Read RTL, no grant", "deny", "Read", W(rtl), True, "auto")
        run("rtl: doc mode, main session Read RTL", "allow", "Read", W(rtl), False, "auto")
        run("rtl: doc mode, sub Read verify file", "allow", "Read", W(os.path.join(proj, "CLAUDE.md")), True, "auto")
        run("rtl: doc mode, sub Grep in design root", "deny", "Grep", {"pattern": "x", "path": os.path.join(tmp, "design")}, True, "auto")
        run("rtl: doc mode, sub Grep repo root (above)", "deny", "Grep", {"pattern": "x", "path": tmp}, True, "auto")
        run("rtl: doc mode, sub Grep verify/", "allow", "Grep", {"pattern": "x", "path": proj}, True, "auto")
        run("rtl: doc mode, sub Glob abs pattern in RTL", "deny", "Glob", {"pattern": os.path.join(tmp, "design", "**", "*.v"), "path": proj}, True, "auto")
        grants([{"task": "T1", "agent": "dev_agent", "paths": ["design/rtl/uart/**"], "category": "gray-box", "reason": "r"}])
        run("rtl: granted agent, granted path", "allow", "Read", W(rtl), True, "auto")
        run("rtl: granted agent, other path", "deny", "Read", W(other), True, "auto")
        run("rtl: granted path, other agent", "deny", "Read", W(rtl), True, "auto", {"agent_type": "review_agent"})
        grants([{"task": "T2", "agent": "*", "paths": ["design/rtl/spi.v"], "category": "spec-ambiguity", "reason": "r"}])
        run("rtl: wildcard agent, exact file", "allow", "Read", W(other), True, "auto", {"agent_type": "debug_agent"})
    finally:
        ENV = saved
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
