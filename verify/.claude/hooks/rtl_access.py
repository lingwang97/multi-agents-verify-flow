#!/usr/bin/env python3
"""rtl_access.py - leader-side helper for the RTL-access grants (ops §1 "RTL access").

  mode                       show the RTL-access mode (doc / pre-research) and the design root
  list                       list the active grants
  grant --agent A --path P [--path P2 ...] --category C --reason R --task T
                             record a grant the user approved (one dispatch only)
  revoke --task T | --all    remove grants (do it when the task's report is back)

Grants live in .claude/state/rtl_access.json; path_guard.py reads them. Paths are
repo-root relative (or absolute) files, directories or globs inside the design root.
Only the leader (main session) may run this - path_guard blocks sub-agent writes
under .claude/. Python 3.6+.
"""
import argparse
import datetime
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(os.path.dirname(HERE))          # verify/
STATE = os.path.join(PROJ, ".claude", "state", "rtl_access.json")
CATEGORIES = ("spec-ambiguity", "suspected-issue", "gray-box")


def load():
    try:
        with open(STATE, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError):
        return {"grants": []}


def save(d):
    os.makedirs(os.path.dirname(STATE), exist_ok=True)
    with open(STATE, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")


def mode():
    a = {}
    try:
        with open(os.path.join(PROJ, "script", "new_project", "answers.json"), encoding="utf-8") as f:
            a = json.load(f)
    except (OSError, ValueError):
        pass
    ans, app = a.get("answers") or {}, a.get("applied") or {}
    spec = (ans.get("spec_dir") or "").strip()
    doc = bool(spec) and spec.lower() != "none"
    return ("doc (spec_dir=%s): sub-agents need a grant to read the design root" % spec) if doc \
        else "pre-research (spec_dir unset/none): sub-agents read the design root freely", \
        ans.get("design_root") or app.get("design_root") or "hdl"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd")
    sub.add_parser("mode")
    sub.add_parser("list")
    g = sub.add_parser("grant")
    g.add_argument("--agent", required=True, help="agent_type, e.g. dev_agent (or * for any)")
    g.add_argument("--path", action="append", required=True)
    g.add_argument("--category", required=True, choices=CATEGORIES)
    g.add_argument("--reason", required=True)
    g.add_argument("--task", required=True, help="dispatch id, also used to revoke")
    r = sub.add_parser("revoke")
    r.add_argument("--task")
    r.add_argument("--all", action="store_true")
    args = ap.parse_args()
    if args.cmd == "mode":
        m, dr = mode()
        print("mode: %s\ndesign root: %s" % (m, dr))
    elif args.cmd == "list":
        for x in load()["grants"]:
            print("%-10s %-14s %-16s %s | %s" % (x["task"], x["agent"], x["category"], ", ".join(x["paths"]), x["reason"]))
    elif args.cmd == "grant":
        d = load()
        d["grants"].append({"task": args.task, "agent": args.agent, "paths": args.path, "category": args.category,
                            "reason": args.reason, "approved": datetime.date.today().isoformat()})
        save(d)
        print("granted %s -> %s for task %s" % (args.agent, ", ".join(args.path), args.task))
    elif args.cmd == "revoke":
        d = load()
        n = len(d["grants"])
        d["grants"] = [] if args.all else [x for x in d["grants"] if x["task"] != args.task]
        save(d)
        print("revoked %d grant(s)" % (n - len(d["grants"])))
    else:
        ap.print_help()
        sys.exit(2)


if __name__ == "__main__":
    main()
