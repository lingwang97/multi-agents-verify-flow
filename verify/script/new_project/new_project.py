#!/usr/bin/env python3
"""new_project.py - bootstrap and parameterize a new chip project on this framework.

Subcommands (run from anywhere; --root selects the target verify/ dir):
  bootstrap --dst <repo>   copy the framework per manifest.txt into a new repo
                           (chip-specific state reset; see the manifest)
  detect                   probe the machine/repo for candidate values (JSON)
  status                   show every registered variable: answer / deferred / pending
  set id=value ... | --defer id ...   record answers (validated) in answers.json
  apply [--dry-run]        write the answers into their target files (idempotent)
  check [--markdown]       readiness report: pending items, consistency, paths, tools

The variable registry is vars.json (single home); the interview that drives these
commands is the /new-project skill (.claude/skills/new-project/SKILL.md).

Python 3.6+ (no 3.7-only APIs: no capture_output/text, no required subparsers).
"""
import argparse
import datetime
import glob
import json
import os
import re
import shutil
import socket
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SRC_VERIFY = os.path.dirname(os.path.dirname(HERE))
SRC_REPO = os.path.dirname(SRC_VERIFY)
TODAY = datetime.date.today().isoformat()
NO_LIST = {"", "-", "none", "empty"}


# ----------------------------------------------------------------------------- io
def read_text(path):
    raw = open(path, encoding="utf-8", newline="").read()
    nl = "\r\n" if "\r\n" in raw else "\n"
    return raw.replace("\r\n", "\n"), nl


def write_text(path, text, nl="\n"):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text.replace("\n", nl))


def registry():
    with open(os.path.join(HERE, "vars.json"), encoding="utf-8") as f:
        return json.load(f)


def var_by_id(reg):
    return {v["id"]: v for v in reg["vars"]}


def answers_path(root):
    return os.path.join(root, "script", "new_project", "answers.json")


def load_answers(root):
    p = answers_path(root)
    if not os.path.isfile(p):
        return {"answers": {}, "deferred": [], "applied": {}}
    with open(p, encoding="utf-8") as f:
        a = json.load(f)
    for k, d in (("answers", {}), ("deferred", []), ("applied", {})):
        a.setdefault(k, d)
    return a


def save_answers(root, a):
    write_text(answers_path(root), json.dumps(a, indent=2, ensure_ascii=False) + "\n")


def die(msg):
    sys.stderr.write("new_project: ERROR: %s\n" % msg)
    sys.exit(2)


# ------------------------------------------------------------------ target values
def _sh_get(text, var):
    m = re.search(r"^%s=(.*)$" % re.escape(var), text, re.M)
    if not m:
        return None
    v = m.group(1).strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
        v = v[1:-1]
    return v


def _block_bounds(lines, start, end):
    s = next((i for i, l in enumerate(lines) if l.strip().startswith(start)), None)
    e = next((i for i, l in enumerate(lines) if s is not None and i > s and l.strip().startswith(end)), None)
    return s, e


def _unrender(line_tpl, line):
    pre, _, post = line_tpl.partition("{v}")
    if line.startswith(pre) and line.endswith(post):
        return line[len(pre):len(line) - len(post) if post else None]
    return line


def current_value(var, root):
    """Value currently held by the target file(s) - None if not readable."""
    kind = var["kind"]
    path = os.path.join(root, var["file"]) if "file" in var else None
    try:
        if kind == "json_field":
            with open(path, encoding="utf-8") as f:
                v = json.load(f).get(var["key"])
            return str(v).lower() if isinstance(v, bool) else v
        if kind == "sh_var":
            v = _sh_get(read_text(path)[0], var["var"])
            if v is not None and var.get("repo_path"):
                v = v.replace("$database_path/", "")
            return v
        if kind == "text_file":
            pre, _, post = var["template"].partition("{v}")
            t = read_text(path)[0].strip()
            return t[len(pre):len(t) - len(post) if post else None] if t.startswith(pre) else t
        if kind == "filelist_block":
            lines = read_text(path)[0].split("\n")
            s, e = _block_bounds(lines, var["start"], var["end"])
            if s is None or e is None:
                return None
            return [_unrender(var["line"], l.strip()) for l in lines[s + 1:e]
                    if l.strip() and not l.strip().startswith("//")]
        if kind == "choice_rewrite":
            for key, snip in var["snippets"].items():
                text = read_text(os.path.join(root, key.split("#")[0]))[0]
                for choice, s in snip.items():
                    if s in text:
                        return choice
            return None
    except (OSError, ValueError):
        return None
    return None


# ----------------------------------------------------------------------- detect
def _which(name):
    return shutil.which(name)


def _run(cmd, timeout=20):
    try:
        r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           universal_newlines=True, timeout=timeout)
        return r.returncode, r.stdout
    except (OSError, subprocess.SubprocessError):
        return 1, ""


def _python_candidates():
    seen, out = set(), []
    for c in (_which("python3"), _which("python"), "/opt/anaconda3/bin/python", "/usr/bin/python3"):
        if not c or c in seen or not os.path.exists(c):
            continue
        seen.add(c)
        rc, _ = _run([c, "-c", "import openpyxl"])
        out.append({"value": c, "note": "openpyxl ok" if rc == 0 else "no openpyxl"})
    return out


def _repo_rel(repo, p):
    return os.path.relpath(p, repo).replace("\\", "/")


def detect(root):
    reg = registry()
    repo = os.path.dirname(root)
    ans = load_answers(root)["answers"]
    rtl_dir = ans.get("rtl_dir") or "hdl/rtl"
    out = {}
    for var in reg["vars"]:
        d = {"current": current_value(var, root) if var["kind"] not in ("detect_only", "record_only") else None,
             "candidates": []}
        how = var.get("detect", "")
        if how.startswith("env:"):
            v = os.environ.get(how[4:])
            d["candidates"] = [{"value": v, "note": "exists" if v and os.path.isdir(v) else "path missing"}] if v else []
        elif how.startswith("path:"):
            w = _which(how[5:])
            d["candidates"] = [{"value": w, "note": "on PATH"}] if w else []
        elif how == "python":
            d["candidates"] = _python_candidates()
        elif how == "spec_dir":
            for c in ("verify/docs/spec", "docs/spec", "spec", "doc", "docs"):
                p = os.path.join(repo, c)
                if os.path.isdir(p):
                    n = sum(len(f) for _, _, f in os.walk(p))
                    d["candidates"].append({"value": c, "note": "%d files" % n})
        elif how == "rtl_dir":
            for c in sorted({_repo_rel(repo, os.path.dirname(f)) for ext in ("v", "sv", "vhd")
                             for f in glob.glob(os.path.join(repo, "hdl", "**", "*." + ext), recursive=True)}):
                d["candidates"].append({"value": c, "note": ""})
        elif how == "reg_table":
            for f in sorted(glob.glob(os.path.join(repo, "hdl", "**", "*.csv"), recursive=True)):
                d["candidates"].append({"value": _repo_rel(repo, f), "note": ""})
        elif how == "rtl_files":
            base = os.path.join(repo, rtl_dir)
            files = sorted(f for ext in ("v", "sv", "vhd") for f in glob.glob(os.path.join(base, "**", "*." + ext), recursive=True))
            d["candidates"] = [{"value": [_repo_rel(repo, f) for f in files], "note": "%d files under %s" % (len(files), rtl_dir)}]
        elif how == "include_dirs":
            base = os.path.join(repo, rtl_dir)
            dirs = sorted({_repo_rel(repo, os.path.dirname(f)) for ext in ("vh", "svh", "h")
                           for f in glob.glob(os.path.join(base, "**", "*." + ext), recursive=True)})
            d["candidates"] = [{"value": dirs, "note": "%d dirs with headers" % len(dirs)}]
        elif how == "lsf_queues":
            if _which("bqueues"):
                rc, so = _run(["bqueues", "-o", "QUEUE_NAME", "-noheader"])
                d["candidates"] = [{"value": q, "note": "bqueues"} for q in so.split() if rc == 0]
        elif how == "lsf_hosts_file":
            pats = ["/lsf/conf/lsbatch/*/configdir/lsb.hosts"]
            if os.environ.get("LSF_ENVDIR"):
                pats.append(os.path.join(os.environ["LSF_ENVDIR"], "lsbatch", "*", "configdir", "lsb.hosts"))
            for p in pats:
                d["candidates"] += [{"value": f, "note": ""} for f in sorted(glob.glob(p))]
        elif how == "host":
            h = os.environ.get("HOST") or socket.gethostname()
            parts = h.split("-")
            d["candidates"] = [{"value": parts[2] if len(parts) > 2 else "", "note": "from host %s" % h}]
        out[var["id"]] = d
    return out


# ------------------------------------------------------------------- set/status
def validate(var, raw):
    if var.get("list"):
        if raw.strip().lower() in NO_LIST:
            return []
        return [x.strip() for x in re.split(r"[,\n]", raw) if x.strip()]
    v = raw.strip()
    if var.get("type") == "bool" or var.get("validate") == "^(true|false)$":
        v = v.lower()
    if "choices" in var and v not in var["choices"]:
        die("%s: '%s' not in %s" % (var["id"], v, var["choices"]))
    if var.get("validate") and not re.match(var["validate"], v):
        die("%s: '%s' does not match %s" % (var["id"], v, var["validate"]))
    if '"' in v:
        die("%s: double quotes are not allowed" % var["id"])
    return v


def cmd_set(root, pairs, defers, src=None):
    vb = var_by_id(registry())
    a = load_answers(root)
    if src:  # prefill from another project's answers.json (values re-validated)
        with open(src, encoding="utf-8") as f:
            other = json.load(f)
        for k, v in other.get("answers", {}).items():
            if k in vb:
                a["answers"][k] = validate(vb[k], ",".join(v) if isinstance(v, list) else str(v))
        for k in other.get("deferred", []):
            if k in vb and k not in a["answers"] and k not in a["deferred"]:
                a["deferred"].append(k)
    for p in pairs:
        if "=" not in p:
            die("expected id=value, got '%s'" % p)
        k, raw = p.split("=", 1)
        if k not in vb:
            die("unknown variable '%s'" % k)
        a["answers"][k] = validate(vb[k], raw)
        if k in a["deferred"]:
            a["deferred"].remove(k)
    for k in defers:
        if k not in vb:
            die("unknown variable '%s'" % k)
        if not vb[k].get("deferrable"):
            die("%s cannot be deferred" % k)
        a["answers"].pop(k, None)
        if k not in a["deferred"]:
            a["deferred"].append(k)
    save_answers(root, a)
    print("recorded: %s" % ", ".join((["prefill:" + src] if src else []) + [p.split("=", 1)[0] for p in pairs] + ["defer:" + k for k in defers]))


def cmd_status(root):
    reg = registry()
    a = load_answers(root)
    rows = []
    for v in reg["vars"]:
        if v["kind"] == "detect_only":
            st = "check-only"
        elif v["id"] in a["answers"]:
            st = "answered"
        elif v["id"] in a["deferred"]:
            st = "deferred"
        else:
            st = "pending"
        cur = current_value(v, root) if v["kind"] not in ("detect_only", "record_only") else a["applied"].get(v["id"])
        rows.append((v["phase"], v["id"], st, a["answers"].get(v["id"], v.get("default", "")), cur))
    print("%-5s %-22s %-11s %-40s %s" % ("phase", "id", "state", "answer/default", "current"))
    for r in rows:
        print("%-5s %-22s %-11s %-40s %s" % (r[0], r[1], r[2], str(r[3])[:40], str(r[4])[:60]))


# ------------------------------------------------------------------------ apply
def _apply_var(var, value, root, applied, dry, log):
    kind = var["kind"]
    if kind in ("record_only", "detect_only"):
        pass
    elif kind == "json_field":
        path = os.path.join(root, var["file"])
        text, nl = read_text(path)
        data = json.loads(text)
        newv = (value == "true") if var.get("type") == "bool" else value
        if data.get(var["key"]) != newv:
            data[var["key"]] = newv
            log.append("%s: %s = %s" % (var["file"], var["key"], json.dumps(newv)))
            if not dry:
                write_text(path, json.dumps(data, indent=2, ensure_ascii=False) + "\n", nl)
    elif kind == "sh_var":
        path = os.path.join(root, var["file"])
        text, nl = read_text(path)
        v = value
        if var.get("repo_path") and v and not os.path.isabs(v) and not v.startswith("$"):
            v = "$database_path/" + v
        line = '%s="%s"' % (var["var"], v)
        new, n = re.subn(r"^%s=.*$" % re.escape(var["var"]), lambda m: line, text, flags=re.M)
        if n == 0:
            die("%s: variable %s not found in %s" % (var["id"], var["var"], var["file"]))
        if new != text:
            log.append("%s: %s" % (var["file"], line))
            if not dry:
                write_text(path, new, nl)
    elif kind == "text_file":
        path = os.path.join(root, var["file"])
        content = var["template"].replace("{v}", value)
        old = read_text(path)[0] if os.path.exists(path) else None
        if old is None or old.strip() != content:
            log.append("%s: %s" % (var["file"], content))
            if not dry:
                write_text(path, content + "\n", read_text(path)[1] if old is not None else "\n")
    elif kind == "filelist_block":
        path = os.path.join(root, var["file"])
        text, nl = read_text(path)
        lines = text.split("\n")
        s, e = _block_bounds(lines, var["start"], var["end"])
        if s is None or e is None:
            die("%s: markers '%s'/'%s' not found in %s" % (var["id"], var["start"], var["end"], var["file"]))
        body = [var["line"].replace("{v}", x) for x in value]
        new = "\n".join(lines[:s + 1] + body + lines[e:])
        if new != text:
            log.append("%s: %d line(s) between '%s' markers" % (var["file"], len(body), var["start"].strip("/ -")))
            if not dry:
                write_text(path, new, nl)
    elif kind == "choice_rewrite":
        old = applied.get(var["id"]) or current_value(var, root)
        if old and old != value:
            for key, snip in var["snippets"].items():
                fpath = os.path.join(root, key.split("#")[0])
                text, nl = read_text(fpath)
                if snip[old] in text:
                    log.append("%s: '%s' snippet -> '%s'" % (key.split("#")[0], old, value))
                    if not dry:
                        write_text(fpath, text.replace(snip[old], snip[value]), nl)
                else:
                    log.append("WARN %s: '%s' snippet not found - edit by hand" % (key.split("#")[0], old))
    for rw in var.get("rewrites", []):
        old = applied.get(var["id"])
        if not old or old == value:
            continue
        o, n = rw["pattern"].replace("{v}", old), rw["pattern"].replace("{v}", value)
        for f in rw["files"]:
            fpath = os.path.join(root, f)
            if not os.path.exists(fpath):
                continue
            text, nl = read_text(fpath)
            if o in text:
                log.append("%s: '%s' -> '%s' (x%d)" % (f, o, n, text.count(o)))
                if not dry:
                    write_text(fpath, text.replace(o, n), nl)


def cmd_apply(root, dry, force):
    a = load_answers(root)
    if "bootstrapped_from" not in a and not force:
        die("answers.json has no 'bootstrapped_from' - this looks like the source project, "
            "apply would rewrite it. Run inside a bootstrapped repo, or pass --force.")
    reg = registry()
    log = []
    for var in reg["vars"]:
        if var["id"] not in a["answers"]:
            continue
        value = a["answers"][var["id"]]
        _apply_var(var, value, root, a["applied"], dry, log)
        if not dry and var["kind"] not in ("detect_only",):
            a["applied"][var["id"]] = value
    if not dry:
        save_answers(root, a)
    print(("planned changes (dry run):" if dry else "applied changes:") if log else "nothing to change")
    for l in log:
        print("  " + l)


# ------------------------------------------------------------------------ check
def cmd_check(root, markdown):
    reg = registry()
    vb = var_by_id(reg)
    a = load_answers(root)
    repo = os.path.dirname(root)
    ans = a["answers"]
    res = []  # (level, item, detail)

    for v in reg["vars"]:
        i = v["id"]
        if v["kind"] == "detect_only":
            how = v["detect"]
            ok = bool(os.environ.get(how[4:])) if how.startswith("env:") else bool(_which(how[5:]))
            res.append(("READY" if ok else "WARN", i, "found" if ok else "not found on this machine (%s)" % how))
            continue
        if i in a["deferred"]:
            res.append(("PENDING", i, "deferred by the user"))
            continue
        if i not in ans:
            res.append(("PENDING", i, "not answered yet"))
            continue
        if v["kind"] not in ("record_only", "choice_rewrite"):
            cur = current_value(v, root)
            if cur != ans[i]:
                res.append(("FAIL", i, "target holds %r, answer is %r - run apply" % (cur, ans[i])))
                continue
        if v["kind"] in ("record_only", "choice_rewrite") and a["applied"].get(i) != ans[i]:
            res.append(("FAIL", i, "answer %r not applied yet - run apply" % ans[i]))
            continue
        res.append(("READY", i, str(ans[i])[:80]))

    # path / tool sanity of the answered values
    for f in ans.get("rtl_files", []):
        if not os.path.isfile(os.path.join(repo, f)):
            res.append(("FAIL", "rtl_files", "missing file %s" % f))
    for d in ans.get("include_dirs", []):
        if not os.path.isdir(os.path.join(repo, d)):
            res.append(("FAIL", "include_dirs", "missing dir %s" % d))
    rt = ans.get("reg_table")
    if rt and ans.get("top_enable_ral", "true") == "true":
        p = rt if os.path.isabs(rt) else os.path.join(repo, rt)
        if not os.path.isfile(p):
            res.append(("WARN", "reg_table", "CSV not present yet (%s) - RAL cases fail until it lands" % rt))
    py = ans.get("wsim_python")
    if py:
        if not os.path.exists(py):
            res.append(("WARN", "wsim_python", "%s not found on this machine" % py))
        elif _run([py, "-c", "import openpyxl"])[0] != 0:
            res.append(("WARN", "wsim_python", "%s has no openpyxl (RalGen needs it)" % py))
    if ans.get("lsf_enable") == "TRUE":
        hf = ans.get("lsf_hosts_file")
        if hf and not os.path.isfile(hf):
            res.append(("WARN", "lsf_hosts_file", "%s not found on this machine" % hf))
        if not _which("bsub"):
            res.append(("WARN", "lsf_enable", "bsub not on PATH on this machine"))
    try:
        with open(os.path.join(root, reg["config_file"]), encoding="utf-8") as f:
            cfg = json.load(f)
        if not cfg.get("enable_ral", True) and any(m.get("enable_ral", True) or m.get("adapter_type") for m in cfg.get("modules", [])):
            res.append(("FAIL", "config", "top-level enable_ral=false but a module keeps RAL/adapter"))
        res.append(("READY" if cfg.get("modules") else "PENDING", "modules",
                    "%d module(s) in the config" % len(cfg.get("modules", [])) if cfg.get("modules")
                    else "no modules yet - next stage: /new-verification (spec2json -> json2env --guvc)"))
    except (OSError, ValueError) as e:
        res.append(("FAIL", "config", str(e)))
    bash = _which("bash")
    if bash:
        for s in ("script/sflow/wsim", "script/sflow/wsim_oeda", "script/sflow/flow_env.sh"):
            rc = subprocess.run([bash, "-n", os.path.join(root, s).replace("\\", "/")],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE).returncode
            res.append(("READY" if rc == 0 else "FAIL", "bash -n", s))

    order = {"FAIL": 0, "PENDING": 1, "WARN": 2, "READY": 3}
    res.sort(key=lambda r: order[r[0]])
    counts = {k: sum(1 for r in res if r[0] == k) for k in order}
    if markdown:
        print("| Level | Item | Detail |\n|---|---|---|")
        for r in res:
            print("| %s | `%s` | %s |" % r)
    else:
        for r in res:
            print("%-8s %-20s %s" % r)
    print("\nsummary: " + ", ".join("%s %d" % (k, counts[k]) for k in order))
    sys.exit(1 if counts["FAIL"] else 0)


# -------------------------------------------------------------------- bootstrap
def _glob_re(pat):
    out, i = "", 0
    while i < len(pat):
        if pat.startswith("**/", i):
            out += "(?:.*/)?"
            i += 3
        elif pat.startswith("**", i):
            out += ".*"
            i += 2
        elif pat[i] == "*":
            out += "[^/]*"
            i += 1
        elif pat[i] == "?":
            out += "[^/]"
            i += 1
        else:
            out += re.escape(pat[i])
            i += 1
    return re.compile("^" + out + "$")


def _manifest():
    carry, reset, withs, excl = [], [], {}, []
    for line in open(os.path.join(HERE, "manifest.txt"), encoding="utf-8"):
        line = line.split("#", 1)[0].strip() if not line.lstrip().startswith("#") else ""
        if not line:
            continue
        parts = line.split()
        if parts[0] == "carry":
            carry.append(_glob_re(parts[1]))
        elif parts[0] == "reset":
            reset.append((parts[1], parts[2]))
        elif parts[0].startswith("with:"):
            withs.setdefault(parts[0][5:], []).append(_glob_re(parts[1]))
        elif parts[0] == "exclude":
            excl.append(_glob_re(parts[1]))
    return carry, reset, withs, excl


def _source_files():
    # tracked files plus untracked-but-not-ignored ones (framework edits not committed yet)
    rc, so = _run(["git", "-C", SRC_REPO, "ls-files", "--cached", "--others", "--exclude-standard"], timeout=60)
    if rc == 0 and so.strip():
        return sorted({l.strip() for l in so.splitlines() if l.strip()})
    files = []
    for d, _, fs in os.walk(SRC_REPO):
        if ".git" in d.split(os.sep):
            continue
        files += [_repo_rel(SRC_REPO, os.path.join(d, f)) for f in fs]
    return files


def _sections(text):
    """Split markdown into (preamble, [(heading_line, body), ...]) on '## ' headings."""
    parts = re.split(r"(?m)^(## .*)$", text)
    return parts[0], [(parts[i], parts[i + 1]) for i in range(1, len(parts), 2)]


def _reset(kind, src_text, ctx):
    if kind == "filelist":
        return "\n".join(l for l in src_text.split("\n") if not l.strip() or l.strip().startswith("//"))
    if kind == "config":
        cfg = json.loads(src_text)
        cfg["modules"] = []
        return json.dumps(cfg, indent=2, ensure_ascii=False) + "\n"
    if kind == "arch":
        pre, secs = _sections(src_text)
        pre = re.sub(r"Last updated [^\n]*", "Last updated %s (bootstrapped from %s @ %s; change history: git log)."
                     % (TODAY, ctx["src"], ctx["sha"]), pre, count=1)
        out = [pre]
        for head, body in secs:
            num = re.match(r"## (\d+)\.", head)
            n = num.group(1) if num else ""
            if n in ("1", "3", "5", "8"):
                out.append(head + body)
            elif n == "0":
                out.append(head + "\n\n| Module | UVC state (adapter_type / enable_ral) | Block-level support | Notes |\n"
                           "|---|---|---|---|\n\n- Filled by json2env_agent after the first `--guvc` of this chip.\n\n---\n\n")
            elif n == "7":
                out.append(head + "\n\nTo be written for this chip (system top, register table, init config, DUT wiring, system smoke stimuli).\n\n")
            elif n == "6":
                out.append(head + "\n\n(none yet)\n\n")
            elif n == "9":
                keep = [l for l in body.split("\n") if not l.startswith("| G")]
                out.append(head + "\n".join(keep))
            else:
                out.append(head + body)
        return "".join(out)
    if kind == "fw_env":
        pre, _ = _sections(src_text)
        return pre.rstrip("\n") + "\n\n## %s Initialization\n- Change: environment bootstrapped from `%s` (commit %s) by `script/new_project/new_project.py bootstrap`; framework carried per `script/new_project/manifest.txt`, chip-specific state reset.\n- Reason: new chip project on this framework.\n- Impact: nothing generated yet - run `/new-project`, then the `/new-verification` intake.\n" % (TODAY, ctx["src"], ctx["sha"])
    if kind == "taskboard":
        lines = src_text.split("\n")
        hdr = []
        for l in lines:
            hdr.append(l)
            if l.startswith("|---"):
                break
        rows = [
            "| %s | New-project setup (`/new-project`: identity, inputs, tools, server settings, filelists) | global | leader | /new-project | in progress | bootstrapped from `%s` @ %s |" % (TODAY, ctx["src"], ctx["sha"]),
            "| %s | First real VCS case + one LSF dispatch on this server | global | user | — | pending | after `/new-project` apply and the first `--guvc`; confirms the flow_env.sh site section |" % TODAY,
        ]
        return "\n".join(hdr + rows) + "\n"
    if kind == "oeda_setup":
        return ("# oEDA local flow environment manual (machine-specific)\n\n"
                "> Division of labor: day-to-day commands and the pass criterion are canonized in `verify/CLAUDE.md` (oEDA section), "
                "the Verilator/OPEN_EDA coding rules in `.claude/rules/oeda-verilator.md`; this file covers only how this machine is set up.\n\n"
                "## One-time setup\n\n- Verilator: OSS CAD Suite unpacked and its `environment` sourced in the login shell (`source <oss-cad-suite>/environment`).\n"
                "- UVM-1.2 library: `export UVM_HOME=<path>/uvm-1.2` (wsim_oeda default: `$HOME/tools/uvm-1.2`).\n"
                "- Python 3 with openpyxl for RalGen.\n- Waveforms: an FST viewer (Surfer or GTKWave).\n\n"
                "To be completed for this machine (paths, versions) when the oEDA flow is first run.\n")
    if kind == "answers":
        return json.dumps({"bootstrapped_from": {"repo": ctx["src"], "commit": ctx["sha"], "date": TODAY, "with": ctx["with"]},
                           "answers": {}, "deferred": [], "applied": ctx["applied"]}, indent=2, ensure_ascii=False) + "\n"
    die("unknown reset kind '%s'" % kind)


def cmd_bootstrap(dst, with_flags, force):
    dst = os.path.abspath(dst)
    if os.path.exists(os.path.join(dst, "verify")) and not force:
        die("%s/verify already exists (use --force to overwrite framework files)" % dst)
    carry, reset, withs, excl = _manifest()
    for w in with_flags:
        if w not in withs:
            die("unknown --with flag '%s' (manifest has: %s)" % (w, ", ".join(withs)))
    rc, sha = _run(["git", "-C", SRC_REPO, "rev-parse", "--short", "HEAD"])
    reg = registry()
    applied = {}
    for v in reg["vars"]:
        if v.get("rewrites") or v["kind"] == "choice_rewrite":
            cv = current_value(v, SRC_VERIFY) if v["kind"] != "record_only" else v.get("default")
            if cv:
                applied[v["id"]] = cv
    ctx = {"src": SRC_REPO.replace("\\", "/"), "sha": sha.strip() if rc == 0 else "unknown",
           "with": with_flags, "applied": applied}
    reset_paths = {p for p, _ in reset}
    patterns = carry + [p for w in with_flags for p in withs[w]]
    copied = 0
    for f in _source_files():
        if f in reset_paths or any(e.match(f) for e in excl) or not any(p.match(f) for p in patterns):
            continue
        s, d = os.path.join(SRC_REPO, f), os.path.join(dst, f)
        if not os.path.isfile(s):
            continue
        os.makedirs(os.path.dirname(d), exist_ok=True)
        shutil.copy2(s, d)
        copied += 1
    for p, kind in reset:
        s = os.path.join(SRC_REPO, p)
        src_text, nl = read_text(s) if os.path.isfile(s) else ("", "\n")
        write_text(os.path.join(dst, p), _reset(kind, src_text, ctx), nl)
    print("bootstrap: %d framework files copied, %d files reset -> %s" % (copied, len(reset), dst))
    print("next steps:\n  cd %s && git init   (if this is a new repo)\n"
          "  cd verify && start Claude Code here, then run /new-project" % dst)


# ------------------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=SRC_VERIFY, help="target verify/ directory (default: the one holding this script)")
    sub = ap.add_subparsers(dest="cmd")  # required= is 3.7+; checked below
    b = sub.add_parser("bootstrap")
    b.add_argument("--dst", required=True, help="new repo root")
    b.add_argument("--with", dest="withs", action="append", default=[], help="optional manifest group, e.g. apb-master")
    b.add_argument("--force", action="store_true")
    sub.add_parser("detect")
    sub.add_parser("status")
    s = sub.add_parser("set")
    s.add_argument("pairs", nargs="*")
    s.add_argument("--defer", action="append", default=[])
    s.add_argument("--from", dest="src", help="prefill from another project's answers.json")
    p = sub.add_parser("apply")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--force", action="store_true")
    c = sub.add_parser("check")
    c.add_argument("--markdown", action="store_true")
    args = ap.parse_args()
    if not args.cmd:
        ap.print_help()
        sys.exit(2)
    root = os.path.abspath(args.root)
    if args.cmd == "bootstrap":
        cmd_bootstrap(args.dst, args.withs, args.force)
    elif args.cmd == "detect":
        print(json.dumps(detect(root), indent=2, ensure_ascii=False))
    elif args.cmd == "status":
        cmd_status(root)
    elif args.cmd == "set":
        cmd_set(root, args.pairs, args.defer, args.src)
    elif args.cmd == "apply":
        cmd_apply(root, args.dry_run, args.force)
    elif args.cmd == "check":
        cmd_check(root, args.markdown)


if __name__ == "__main__":
    main()
