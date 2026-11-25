#!/usr/bin/env python3
"""new_project.py - bootstrap a chip project on this framework and keep its values.

Subcommands (run from anywhere; --root selects the target verify/ dir):
  bootstrap --dst <repo>        copy the framework per manifest.txt into a new repo
  detect   [--stage S]          candidate values per variable (JSON)
  scan     [--markdown]         structural scan of the design sources -> suggested
                                values for the verification-stage file lists (JSON)
  status   [--stage S]          every registered variable: answer / deferred / pending
  set id=value ... [--defer id] [--from answers.json]   record answers (validated)
  apply    [--stage S] [--dry-run]   write the answers into their target files (idempotent)
  check    [--stage S] [--markdown] [--lint [--top T]]   readiness report

Stages: project (/new-project: framework migration) and verification
(/new-verification: inputs, config top level, register table, design file lists).
The registry is vars.json; the interviews live in the two skills.
Python 3.6+ (no 3.7-only APIs: no capture_output/text, no required subparsers).
"""
import argparse
import csv
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
STAGES = ("project", "verification")
DEFAULT_DESIGN_ROOT = "hdl"   # placeholder in the framework repo; a project sets design_root


# ----------------------------------------------------------------------------- io
def read_text(path):
    raw = open(path, encoding="utf-8", newline="", errors="replace").read()
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


def stage_vars(reg, stage):
    return [v for v in reg["vars"] if stage in (None, "all", v["stage"])]


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


def _run(cmd, timeout=20, cwd=None):
    try:
        r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           universal_newlines=True, timeout=timeout, cwd=cwd)
        return r.returncode, r.stdout
    except (OSError, subprocess.SubprocessError):
        return 1, ""


def _which(name):
    return shutil.which(name)


def _posix(p):
    return p.replace("\\", "/")


def repo_of(root):
    return os.path.dirname(root)


def design_root(root, a=None):
    a = a or load_answers(root)
    return a["answers"].get("design_root") or a["applied"].get("design_root") or DEFAULT_DESIGN_ROOT


def resolve(repo, p):
    return p if os.path.isabs(p) else os.path.join(repo, p)


def repo_rel(repo, p):
    ap = os.path.abspath(p)
    rr = os.path.abspath(repo)
    if os.path.normcase(ap).startswith(os.path.normcase(rr) + os.sep):
        return _posix(os.path.relpath(ap, rr))
    return _posix(ap)


def default_of(var, root, a=None):
    d = var.get("default")
    if isinstance(d, str) and "{design_root}" in d:
        d = d.replace("{design_root}", design_root(root, a))
    return d


# ------------------------------------------------------------- filelist paths
FLAG_RE = re.compile(r"^(-[fvy])\s+(.*)$")


def render_path(item):
    """Filelist path for a repo-root relative or absolute item; keeps -f/-v/-y."""
    m = FLAG_RE.match(item)
    flag, p = (m.group(1) + " ", m.group(2)) if m else ("", item)
    if not (os.path.isabs(p) or p.startswith("$") or p.startswith("/")):
        p = "../../../" + p
    return flag + p


def unrender_path(text):
    m = FLAG_RE.match(text)
    flag, p = (m.group(1) + " ", m.group(2)) if m else ("", text)
    if p.startswith("../../../"):
        p = p[len("../../../"):]
    return flag + p


def _line_unrender(tpl, line):
    pre, _, post = tpl.partition("{p}")
    if line.startswith(pre) and (not post or line.endswith(post)):
        return unrender_path(line[len(pre):len(line) - len(post) if post else None])
    return line


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
    e = None
    if s is not None:
        e = next((i for i in range(s + 1, len(lines)) if lines[i].strip().startswith(end)), None)
    return s, e


def current_value(var, root):
    """Value currently held by the target file(s); None if not readable."""
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
                return []
            return [_line_unrender(var["line"], l.strip()) for l in lines[s + 1:e]
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


def infer_from_rewrites(var, root):
    """Value a record_only var currently has in the docs, read through its rewrite pattern."""
    for rw in var.get("rewrites", []):
        pre, _, post = rw["pattern"].partition("{v}")
        rx = re.compile(re.escape(pre) + r"(.+?)" + re.escape(post))
        for f in rw["files"]:
            p = os.path.join(root, f)
            if os.path.isfile(p):
                m = rx.search(read_text(p)[0])
                if m:
                    return m.group(1)
    return var.get("default")


# ------------------------------------------------------------------- design scan
SRC_EXT = (".v", ".sv", ".vp", ".svp", ".vg")
HDR_EXT = (".vh", ".svh", ".h", ".inc")
FL_EXT = (".f", ".flist", ".vc")
SKIP_DIRS = {"tb", "testbench", "sim", "simulation", "verif", "verification", "test", "tests",
             ".git", "__pycache__", "obj_dir", "work", "csrc"}
IP_DIRS = {"ip", "ips", "vendor", "third_party", "thirdparty", "3rdparty"}
GATE_DIRS = {"syn", "synth", "netlist", "netlists", "gate", "pnr", "apr", "layout"}
LIB_HINTS = ("stdcell", "std_cell", "stdcells", "lib", "libs", "libraries", "foundry")
BACKUP_RE = re.compile(r"(\.bak|\.orig|\.old|\.swp|~)$|^#")
TB_RE = re.compile(r"(^tb_|_tb\.|_tb_|^test_|_test\.)", re.I)
COMMENT_RE = re.compile(r"/\*.*?\*/|//[^\n]*", re.S)
MOD_RE = re.compile(r"^\s*(?:module|macromodule)\s+(?:automatic\s+|static\s+)?(\w+)", re.M)
IFC_RE = re.compile(r"^\s*(?:interface|program)\s+(?:automatic\s+|static\s+)?(\w+)", re.M)
PKG_RE = re.compile(r"^\s*package\s+(?:automatic\s+|static\s+)?(\w+)\s*;", re.M)
IMPORT_RE = re.compile(r"\bimport\s+(\w+)\s*::")
INCLUDE_RE = re.compile(r'`include\s+"([^"]+)"')
DEFINE_RE = re.compile(r"^\s*`define\s+\w+", re.M)
INST_RE = re.compile(r"^\s*([A-Za-z_]\w*)\s*(?:#\s*\((?:[^()]|\([^()]*\))*\)\s*)?([A-Za-z_]\w*)\s*(?:\[[^\]]*\]\s*)?\(", re.M)
KEYWORDS = set("""module macromodule endmodule interface endinterface program endprogram package endpackage
if else for foreach while do case casex casez endcase assign always always_ff always_comb always_latch
initial final function endfunction task endtask begin end fork join join_any join_none wire reg logic
bit byte int integer input output inout parameter localparam generate endgenerate genvar return
typedef struct union enum class endclass virtual import export assert assume cover property sequence
default disable wait repeat forever posedge negedge or and not nand nor xor xnor buf bufif0 bufif1
notif0 notif1 pmos nmos cmos tran tranif0 tranif1 rtran pullup pulldown supply0 supply1 tri real
string void automatic static const signed unsigned var specify endspecify defparam primitive
endprimitive table endtable config endconfig""".split())
REG_COLS = ("RegName", "FieldName", "OffsetAddr", "EndAddr", "BitEnd")


def _classify(path, text):
    parts = [x.lower() for x in _posix(path).split("/")]
    name = parts[-1]
    if BACKUP_RE.search(name):
        return "skip:backup"
    if TB_RE.search(name):
        return "skip:testbench"
    if name.endswith(".vg") or "netlist" in name or set(parts[:-1]) & GATE_DIRS:
        return "gate"
    if name.endswith((".vp", ".svp")) or "`pragma protect" in text or "`protect" in text or set(parts[:-1]) & IP_DIRS:
        return "ip"
    if "`celldefine" in text and any(h in p for p in parts[:-1] for h in LIB_HINTS):
        return "lib"
    if name.endswith(HDR_EXT):
        return "header"
    body = COMMENT_RE.sub("", text)
    if DEFINE_RE.search(body) and not (MOD_RE.search(body) or PKG_RE.search(body) or IFC_RE.search(body)
                                       or re.search(r"^\s*class\s", body, re.M)):
        return "define"
    if PKG_RE.search(body):
        return "package"
    return "rtl"


def scan_design(root):
    a = load_answers(root)
    repo = repo_of(root)
    droot = design_root(root, a)
    rdir = a["answers"].get("rtl_dir") or droot
    base = resolve(repo, rdir)
    res = {"design_root": droot, "rtl_dir": rdir, "stats": {}, "suggestions": {}, "tops": [], "warnings": []}
    if not os.path.isdir(base):
        res["warnings"].append("scan root %s does not exist yet" % rdir)
        return res
    files, filelists, csvs = [], [], []
    for d, dirs, fs in os.walk(base):
        dirs[:] = sorted(x for x in dirs if x.lower() not in SKIP_DIRS)
        for f in sorted(fs):
            p = os.path.join(d, f)
            low = f.lower()
            if low.endswith(SRC_EXT + HDR_EXT):
                files.append(p)
            elif low.endswith(FL_EXT):
                filelists.append(p)
            elif low.endswith(".csv"):
                csvs.append(p)
    info = {}
    for p in files:
        try:
            text = open(p, encoding="utf-8", errors="replace").read(2 * 1024 * 1024)
        except OSError:
            continue
        cat = _classify(os.path.relpath(p, base), text)
        body = COMMENT_RE.sub("", text) if not cat.startswith("skip") else ""
        info[p] = {"cat": cat, "mods": MOD_RE.findall(body), "ifcs": IFC_RE.findall(body),
                   "pkgs": PKG_RE.findall(body), "imports": set(IMPORT_RE.findall(body)),
                   "includes": INCLUDE_RE.findall(body),
                   "insts": INST_RE.findall(body) if cat in ("rtl", "ip", "package") else []}
    stats = {}
    for i in info.values():
        stats[i["cat"]] = stats.get(i["cat"], 0) + 1
    res["stats"] = stats

    def R(p):
        return repo_rel(repo, p)

    def by(c):
        return [p for p in sorted(info) if info[p]["cat"] == c]

    # modules / hierarchy
    defined = {}
    for p, i in info.items():
        for m in i["mods"]:
            defined.setdefault(m, []).append(p)
    for m, ps in sorted(defined.items()):
        if len(ps) > 1:
            res["warnings"].append("module %s defined in %d files: %s" % (m, len(ps), ", ".join(R(x) for x in ps)))
    children = {}
    for p, i in info.items():
        if i["cat"] not in ("rtl", "ip", "package"):
            continue
        for m in i["mods"]:
            children.setdefault(m, set())
        own = i["mods"][0] if i["mods"] else None
        for typ, _inst in i["insts"]:
            if typ in KEYWORDS or not own:
                continue
            children.setdefault(own, set()).add(typ)
    instantiated = set(c for cs in children.values() for c in cs)
    known = set(defined) | set(n for i in info.values() for n in i["ifcs"])
    missing = sorted(c for c in instantiated if c not in known)
    if missing:
        res["warnings"].append("instantiated but not defined in the scan (IP/library missing?): %s" % ", ".join(missing[:20]))

    def size(m, seen=None):
        seen = seen if seen is not None else set()
        if m in seen:
            return 0
        seen.add(m)
        return 1 + sum(size(c, seen) for c in children.get(m, ()) if c in defined)
    rtl_mods = [m for p in by("rtl") for m in info[p]["mods"]]
    tops = sorted((m for m in rtl_mods if m not in instantiated), key=lambda m: -size(m))
    res["tops"] = [{"module": m, "instances_below": size(m) - 1, "file": R(defined[m][0])} for m in tops]

    # rtl_files: packages (import order) then RTL
    pkgs = by("package")
    order, placed = [], set()
    pkg_of = {n: p for p in pkgs for n in info[p]["pkgs"]}

    def place(p, stack=()):
        if p in placed or p in stack:
            return
        for imp in sorted(info[p]["imports"]):
            if imp in pkg_of and pkg_of[imp] != p:
                place(pkg_of[imp], stack + (p,))
        placed.add(p)
        order.append(p)
    for p in pkgs:
        place(p)
    rtl_list = [R(p) for p in order + by("rtl")]
    fl_rank = sorted(filelists, key=lambda p: (0 if re.search(r"rtl|design|top|src", os.path.basename(p), re.I) else 1, len(p)))
    sugg = {}
    skipped = ", ".join("%s %d" % (k, v) for k, v in sorted(stats.items()) if k.startswith("skip")) or "none"
    if fl_rank:
        sugg["rtl_files"] = {"value": ["-f " + R(fl_rank[0])], "confidence": "high",
                             "reasons": ["design filelist found: %s - referencing it keeps the list maintained by the design side" % R(fl_rank[0])],
                             "alternatives": [{"value": rtl_list, "note": "explicit list from the scan (%d files)" % len(rtl_list)}]
                             + [{"value": ["-f " + R(p)], "note": "other filelist"} for p in fl_rank[1:4]]}
    else:
        sugg["rtl_files"] = {"value": rtl_list, "confidence": "medium" if rtl_list else "low",
                             "reasons": ["%d package file(s) first (import order), then %d RTL file(s); skipped: %s"
                                         % (len(order), len(by("rtl")), skipped)],
                             "alternatives": []}

    # include dirs: where the `included headers actually are
    headers = {}
    for p in files:
        headers.setdefault(os.path.basename(p), []).append(p)
    inc_dirs, unresolved = [], set()
    for p, i in info.items():
        if i["cat"] in ("rtl", "package", "ip", "define", "header"):
            for inc in i["includes"]:
                hits = headers.get(os.path.basename(inc), [])
                if hits:
                    d = R(os.path.dirname(hits[0]))
                    sub = _posix(os.path.dirname(inc))
                    if sub and d.endswith(sub):
                        d = d[:-len(sub)].rstrip("/")
                    if d not in inc_dirs:
                        inc_dirs.append(d)
                else:
                    unresolved.add(inc)
    if unresolved:
        res["warnings"].append("`include not found in the scan: %s" % ", ".join(sorted(unresolved)[:20]))
    hdr_dirs = sorted({R(os.path.dirname(p)) for p in by("header")})
    sugg["include_dirs"] = {"value": sorted(inc_dirs), "confidence": "high" if inc_dirs else "medium",
                            "reasons": ["directories of the headers the sources `include"] if inc_dirs else ["no `include found"],
                            "alternatives": [{"value": hdr_dirs, "note": "every directory holding headers"}] if hdr_dirs else []}
    included = {os.path.basename(x) for i in info.values() for x in i["includes"]}
    defs = [R(p) for p in by("define") if os.path.basename(p) not in included]
    sugg["rtl_define_files"] = {"value": defs, "confidence": "medium",
                                "reasons": ["define-only files (only `define/`ifdef) that no source `includes"] if defs else ["no stand-alone macro file found"],
                                "alternatives": []}
    sugg["ip_files"] = {"value": [R(p) for p in by("ip")], "confidence": "medium",
                        "reasons": ["files under ip/vendor dirs or encrypted (.vp/.svp, `pragma protect)"], "alternatives": []}
    sugg["gate_files"] = {"value": [R(p) for p in by("gate")], "confidence": "medium",
                          "reasons": ["files under syn/netlist/gate dirs or *.vg / *netlist*"], "alternatives": []}
    sugg["std_libs"] = {"value": ["-v " + R(p) for p in by("lib")], "confidence": "low",
                        "reasons": ["`celldefine files under lib/stdcell dirs - check against the foundry kit"], "alternatives": []}
    sugg["rtl_tops"] = {"value": [t["module"] for t in res["tops"][:1]], "confidence": "medium" if res["tops"] else "low",
                        "reasons": ["module not instantiated by any other RTL module, largest hierarchy first"],
                        "alternatives": [{"value": [t["module"]], "note": "%d instances below (%s)" % (t["instances_below"], t["file"])}
                                         for t in res["tops"][1:6]]}
    # register table: CSVs with the RalGen columns, anywhere under the design root
    droot_abs = resolve(repo, droot)
    regs = []
    for p in sorted(set(csvs) | set(glob.glob(os.path.join(droot_abs, "**", "*.csv"), recursive=True))):
        try:
            with open(p, encoding="utf-8", errors="replace", newline="") as f:
                for row in csv.reader(f):
                    if any(c.strip() for c in row):
                        if all(c in row for c in REG_COLS):
                            regs.append(R(p))
                        break
        except (OSError, csv.Error):
            pass
    sugg["reg_table"] = {"value": regs[0] if regs else None,
                         "confidence": "high" if len(regs) == 1 else ("medium" if regs else "low"),
                         "reasons": ["CSV with the RalGen columns %s" % "/".join(REG_COLS)] if regs else ["no CSV with the RalGen columns found"],
                         "alternatives": [{"value": r, "note": "also matches"} for r in regs[1:5]]}
    # diff against what is recorded / written now
    vb = var_by_id(registry())
    for k, s in sugg.items():
        cur = a["answers"].get(k)
        if cur is None and k in vb and vb[k]["kind"] == "filelist_block":
            cur = current_value(vb[k], root)
        if isinstance(s["value"], list) and isinstance(cur, list):
            s["diff"] = {"added": [x for x in s["value"] if x not in cur], "removed": [x for x in cur if x not in s["value"]]}
        s["current"] = cur
    res["suggestions"] = sugg
    return res


# ----------------------------------------------------------------------- detect
def _python_candidates():
    seen, out = set(), []
    for c in (_which("python3"), _which("python"), "/opt/anaconda3/bin/python", "/usr/bin/python3"):
        if not c or c in seen or not os.path.exists(c):
            continue
        seen.add(c)
        rc, _ = _run([c, "-c", "import openpyxl"])
        out.append({"value": c, "note": "openpyxl ok" if rc == 0 else "no openpyxl"})
    return out


def _hdl_dirs(repo, maxdepth=3):
    out = []
    skip = {"verify", "sim", "deliver_bridge", ".git", ".claude", "docs", "tools"}
    for entry in sorted(os.listdir(repo)):
        top = os.path.join(repo, entry)
        if entry in skip or not os.path.isdir(top):
            continue
        n = 0
        for d, dirs, fs in os.walk(top):
            if d[len(top):].count(os.sep) >= maxdepth:
                dirs[:] = []
            n += sum(1 for f in fs if f.lower().endswith(SRC_EXT + HDR_EXT))
        if n:
            out.append({"value": entry, "note": "%d HDL files" % n})
    return out


def detect(root, stage=None):
    reg = registry()
    repo = repo_of(root)
    a = load_answers(root)
    scan = None
    out = {}
    for var in stage_vars(reg, stage):
        if var["kind"] in ("detect_only", "record_only"):
            cur = a["applied"].get(var["id"]) or (infer_from_rewrites(var, root) if var.get("rewrites") else None)
        else:
            cur = current_value(var, root)
        d = {"current": cur, "default": default_of(var, root, a), "candidates": []}
        how = var.get("detect", "")
        if how.startswith("env:"):
            v = os.environ.get(how[4:])
            d["candidates"] = [{"value": v, "note": "exists" if v and os.path.isdir(v) else "path missing"}] if v else []
        elif how.startswith("path:"):
            w = _which(how[5:])
            d["candidates"] = [{"value": w, "note": "on PATH"}] if w else []
        elif how == "python":
            d["candidates"] = _python_candidates()
        elif how == "design_root":
            d["candidates"] = _hdl_dirs(repo)
            if not any(c["value"] == DEFAULT_DESIGN_ROOT for c in d["candidates"]):
                d["candidates"].append({"value": DEFAULT_DESIGN_ROOT, "note": "framework placeholder"})
        elif how == "spec_dir":
            for c in ("verify/docs/spec", "docs/spec", "spec", "doc", "docs", design_root(root, a) + "/doc"):
                p = resolve(repo, c)
                if os.path.isdir(p):
                    n = sum(len(f) for _, _, f in os.walk(p))
                    d["candidates"].append({"value": c, "note": "%d files" % n})
            d["candidates"].append({"value": "none", "note": "pre-research mode"})
        elif how == "rtl_dir":
            dr = design_root(root, a)
            base = resolve(repo, dr)
            if os.path.isdir(base):
                d["candidates"].append({"value": dr, "note": "design root"})
                for sub in sorted(os.listdir(base)):
                    if os.path.isdir(os.path.join(base, sub)) and sub.lower() not in SKIP_DIRS:
                        d["candidates"].append({"value": repo_rel(repo, os.path.join(base, sub)), "note": ""})
        elif how.startswith("scan:"):
            scan = scan if scan is not None else scan_design(root)
            s = scan["suggestions"].get(how[5:])
            if s:
                d["candidates"] = [{"value": s["value"], "note": "scan (%s): %s" % (s["confidence"], "; ".join(s["reasons"]))}] + \
                                  [{"value": x["value"], "note": x["note"]} for x in s.get("alternatives", [])]
                if "diff" in s:
                    d["diff"] = s["diff"]
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
                a["answers"][k] = validate(vb[k], "\n".join(v) if isinstance(v, list) else str(v))
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
    print("recorded: %s" % ", ".join((["prefill:" + src] if src else []) + [p.split("=", 1)[0] for p in pairs]
                                     + ["defer:" + k for k in defers]))


def _state(v, a):
    if v["kind"] == "detect_only":
        return "check-only"
    if v["id"] in a["answers"]:
        return "answered"
    if v["id"] in a["deferred"]:
        return "deferred"
    return "pending"


def cmd_status(root, stage):
    a = load_answers(root)
    print("%-12s %-5s %-20s %-10s %-38s %s" % ("stage", "phase", "id", "state", "answer/default", "current"))
    for v in stage_vars(registry(), stage):
        cur = current_value(v, root) if v["kind"] not in ("detect_only", "record_only") else a["applied"].get(v["id"])
        ans = a["answers"].get(v["id"], default_of(v, root, a) or "")
        print("%-12s %-5s %-20s %-10s %-38s %s" % (v["stage"], v["phase"], v["id"], _state(v, a), str(ans)[:38], str(cur)[:60]))


# ------------------------------------------------------------------------ apply
def _apply_var(var, value, root, applied, dry, log):
    kind = var["kind"]
    if var.get("owner"):
        log.append("skip %s: owned by %s (check compares only)" % (var["id"], var["owner"]))
        return True
    if kind == "json_field":
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
        if not os.path.exists(path):
            log.append("WARN %s: not generated yet (run --guvc first) - %s not written" % (var["file"], var["id"]))
            return False
        text, nl = read_text(path)
        lines = text.split("\n")
        s, e = _block_bounds(lines, var["start"], var["end"])
        if s is None or e is None:
            log.append("WARN %s: markers '%s' missing - appended" % (var["file"], var["start"]))
            while lines and lines[-1] == "":
                lines.pop()
            lines += ["", var["start"], var["end"], ""]
            s, e = len(lines) - 3, len(lines) - 2
        body = [var["line"].replace("{p}", render_path(x)) for x in value]
        new = "\n".join(lines[:s + 1] + body + lines[e:])
        if new != text:
            log.append("%s: %d line(s) in the '%s' block" % (var["file"], len(body), var["start"].strip("/ -")))
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
    return True


def cmd_apply(root, stage, dry, force):
    a = load_answers(root)
    todo = [v for v in stage_vars(registry(), stage) if v["id"] in a["answers"]]
    if any(v["stage"] == "project" for v in todo) and "bootstrapped_from" not in a and not force:
        die("project-stage values rewrite identity tokens and are applied only in a bootstrapped repo "
            "(answers.json has no 'bootstrapped_from'). Use --stage verification here, or --force.")
    log = []
    for var in todo:
        value = a["answers"][var["id"]]
        if var.get("rewrites") and var["id"] not in a["applied"]:
            base = infer_from_rewrites(var, root)
            if base:
                a["applied"][var["id"]] = base
        ok = _apply_var(var, value, root, a["applied"], dry, log)
        if not dry and ok and var["kind"] != "detect_only" and not var.get("owner"):
            a["applied"][var["id"]] = value
    if not dry:
        save_answers(root, a)
    print(("planned changes (dry run):" if dry else "applied changes:") if log else "nothing to change")
    for l in log:
        print("  " + l)


# ------------------------------------------------------------------------ check
def _lint(root, a, top):
    repo = repo_of(root)
    verilator = _which("verilator")
    files = ["verify/tb_top/macro/rtl_define.f", "verify/tb_top/filelist/include.f",
             "verify/tb_top/filelist/ip_file_lst.f", "verify/tb_top/filelist/rtl_file_lst.f"]
    files = [f for f in files if os.path.isfile(os.path.join(repo, f))]
    tops = [top] if top else (a["answers"].get("rtl_tops") or [])
    args = ["--lint-only", "-Wno-fatal", "-Wno-lint", "-Wno-style"] + (["--top-module", tops[0]] if tops else [])
    for f in files:
        args += ["-f", "../../../" + f]
    cmd = "verilator " + " ".join(args)
    if not verilator:
        return [("WARN", "lint", "verilator not on PATH - run in <repo>/sim/_np_lint/l1 (depth 3): " + cmd)]
    wd = os.path.join(repo, "sim", "_np_lint", "l1")   # depth 3, like comp_<case>/
    os.makedirs(wd, exist_ok=True)
    rc, out = _run([verilator] + args, timeout=600, cwd=wd)
    shutil.rmtree(os.path.join(repo, "sim", "_np_lint"), ignore_errors=True)
    errs = [l for l in out.splitlines() if l.startswith("%Error")]
    if rc == 0 and not errs:
        return [("READY", "lint", "verilator --lint-only clean (top %s)" % (tops[0] if tops else "auto"))]
    return [("FAIL", "lint", e[:160]) for e in errs[:10]] or [("FAIL", "lint", "verilator exit %d" % rc)]


def cmd_check(root, stage, markdown, lint, top):
    reg = registry()
    a = load_answers(root)
    repo = repo_of(root)
    ans = a["answers"]
    res = []
    for v in stage_vars(reg, stage):
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
        if v["kind"] in ("record_only", "choice_rewrite"):
            if (v["kind"] == "choice_rewrite" or v.get("rewrites")) and a["applied"].get(i) != ans[i]:
                res.append(("FAIL", i, "answer %r not applied yet - run apply" % ans[i]))
                continue
        else:
            if v["kind"] == "filelist_block" and not os.path.exists(os.path.join(root, v["file"])):
                res.append(("PENDING", i, "%s not generated yet (--guvc), then apply" % v["file"]))
                continue
            cur = current_value(v, root)
            if cur != ans[i]:
                who = "the owner (%s) writes it" % v["owner"] if v.get("owner") else "run apply"
                res.append(("FAIL", i, "target holds %r, answer is %r - %s" % (cur, ans[i], who)))
                continue
        res.append(("READY", i, str(ans[i])[:80]))

    if stage in (None, "all", "project"):
        dr = ans.get("design_root")
        if dr and not os.path.isdir(resolve(repo, dr)):
            res.append(("WARN", "design_root", "%s does not exist yet - fine if the design lands later" % dr))
        py = ans.get("wsim_python")
        if py:
            if not os.path.exists(py):
                res.append(("WARN", "wsim_python", "%s not found on this machine" % py))
            elif _run([py, "-c", "import openpyxl"])[0] != 0:
                res.append(("WARN", "wsim_python", "%s has no openpyxl (RalGen needs it)" % py))
        # platform residue: text that still describes the other oEDA platform
        for v in stage_vars(reg, "project"):
            chosen = ans.get(v["id"]) or a["applied"].get(v["id"])
            for phrase in (v.get("residue") or {}).get(chosen or "", []):
                for pat in reg.get("residue_files", []):
                    for f in sorted(glob.glob(os.path.join(root, pat))):
                        for n, line in enumerate(read_text(f)[0].split("\n"), 1):
                            if phrase in line:
                                res.append(("WARN", "platform", "%s:%d still says '%s' (%s=%s)"
                                            % (repo_rel(root, f), n, phrase, v["id"], chosen)))
        # source-project residue: identity values and module names of the repo this one was bootstrapped from
        bf = a.get("bootstrapped_from") or {}
        scan = set()
        for pat in reg.get("residue_files", []) + [f for v in reg["vars"] for rw in v.get("rewrites") or [] for f in rw["files"]]:
            scan.update(glob.glob(os.path.join(root, pat)))
        texts = [(repo_rel(root, f), read_text(f)[0].split("\n")) for f in sorted(scan) if os.path.isfile(f)]
        seen = set()
        for i, old in sorted((bf.get("source_values") or {}).items()):
            v = var_by_id(reg).get(i)
            new = ans.get(i, a["applied"].get(i))
            if not v or not v.get("rewrites") or not isinstance(old, str) or not old or old == new:
                continue
            for rw in v["rewrites"]:
                needle = rw["pattern"].replace("{v}", old)
                for f, lines in texts:
                    for n, line in enumerate(lines, 1):
                        if needle in line and (f, n, needle) not in seen:
                            seen.add((f, n, needle))
                            res.append(("WARN", "source-value", "%s:%d still says '%s' (%s of the source project)" % (f, n, needle, i)))
        try:
            with open(os.path.join(root, "json", "module.json"), encoding="utf-8") as fh:
                cur_mods = set(json.load(fh).get("modules", {}))
        except (OSError, ValueError):
            cur_mods = set()
        # a source module that is a module (or the project name) of this project is no residue
        own = cur_mods | {str(x) for x in (ans.get("project_name"), a["applied"].get("project_name")) if x}
        rx = module_name_re([m for m in bf.get("source_modules") or [] if m not in own])
        if rx:
            for f, lines in texts:
                for n, line in enumerate(lines, 1):
                    hit = rx.search(line)
                    if hit:
                        res.append(("WARN", "source-module", "%s:%d names '%s', a module of the source project (arch R1)" % (f, n, hit.group(0))))
        if ans.get("lsf_enable") == "TRUE":
            for k in ("lsf_queue", "lsf_hosts_file"):
                if k in a["deferred"] or not ans.get(k):
                    res.append(("WARN", "lsf_enable", "LSF is on but %s is not set - wsim cannot dispatch" % k))
            hf = ans.get("lsf_hosts_file")
            if hf and not os.path.isfile(hf):
                res.append(("WARN", "lsf_hosts_file", "%s not found on this machine" % hf))
            if not _which("bsub"):
                res.append(("WARN", "lsf_enable", "bsub not on PATH on this machine"))
        bash = _which("bash")
        if bash:
            for s in ("script/sflow/wsim", "script/sflow/wsim_oeda", "script/sflow/flow_env.sh"):
                rc = subprocess.run([bash, "-n", _posix(os.path.join(root, s))],
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE).returncode
                res.append(("READY" if rc == 0 else "FAIL", "bash -n", s))

    if stage in (None, "all", "verification"):
        for k in ("rtl_files", "ip_files", "rtl_define_files", "gate_files", "gate_ip_files", "std_libs", "gpls_libs"):
            for item in ans.get(k, []):
                m = FLAG_RE.match(item)
                p = m.group(2) if m else item
                if not os.path.isfile(resolve(repo, p)):
                    res.append(("FAIL", k, "missing file %s" % p))
        for d in ans.get("include_dirs", []):
            if not os.path.isdir(resolve(repo, d)):
                res.append(("FAIL", "include_dirs", "missing dir %s" % d))
        rt = ans.get("reg_table")
        if rt and ans.get("top_enable_ral", "true") == "true" and not os.path.isfile(resolve(repo, rt)):
            res.append(("WARN", "reg_table", "CSV not present yet (%s) - RAL cases fail until it lands" % rt))
        try:
            with open(os.path.join(root, reg["config_file"]), encoding="utf-8") as f:
                cfg = json.load(f)
            if not cfg.get("enable_ral", True) and any(m.get("enable_ral", True) or m.get("adapter_type") for m in cfg.get("modules", [])):
                res.append(("FAIL", "config", "top-level enable_ral=false but a module keeps RAL/adapter"))
            res.append(("READY" if cfg.get("modules") else "PENDING", "modules",
                        "%d module(s) in the config" % len(cfg["modules"]) if cfg.get("modules")
                        else "no modules yet - spec2json proposes them, json2env runs --guvc"))
        except (OSError, ValueError) as e:
            res.append(("FAIL", "config", str(e)))
        if lint:
            res += _lint(root, a, top)

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


def cmd_scan(root, markdown):
    res = scan_design(root)
    if not markdown:
        print(json.dumps(res, indent=2, ensure_ascii=False))
        return
    print("scan root: `%s` (design root `%s`) - %s" % (res["rtl_dir"], res["design_root"],
          ", ".join("%s %d" % kv for kv in sorted(res["stats"].items())) or "no HDL files"))
    print("\n| Variable | Suggestion | Confidence | Why | vs current |\n|---|---|---|---|---|")
    for k, s in res["suggestions"].items():
        v = s["value"]
        shown = ("%d item(s): %s" % (len(v), ", ".join(v[:3]) + (" ..." if len(v) > 3 else ""))) if isinstance(v, list) else str(v)
        d = s.get("diff")
        dd = ("+%d / -%d" % (len(d["added"]), len(d["removed"]))) if d else ""
        print("| `%s` | %s | %s | %s | %s |" % (k, shown, s["confidence"], "; ".join(s["reasons"]), dd))
    if res["tops"]:
        print("\ntop candidates: " + ", ".join("%s (%d below)" % (t["module"], t["instances_below"]) for t in res["tops"][:6]))
    for w in res["warnings"]:
        print("WARN: " + w)


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


def _manifest(full=False):
    carry, reset, withs, excl, regen, state = [], [], {}, [], [], []
    for line in open(os.path.join(HERE, "manifest.txt"), encoding="utf-8"):
        line = "" if line.lstrip().startswith("#") else line.split("#", 1)[0].strip()
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
        elif parts[0] == "regen":
            regen.append(_glob_re(parts[1]))
        elif parts[0] == "state":
            state.append(_glob_re(parts[1]))
    if full:
        return carry, reset, withs, excl, regen, state
    return carry, reset, withs, excl


def classify(f, m=None):
    """Manifest class of a repo-relative file: exclude > reset > carry/with > regen > state."""
    carry, reset, withs, excl, regen, state = m or _manifest(full=True)
    if any(e.match(f) for e in excl):
        return "exclude"
    if f in {p for p, _ in reset}:
        return "reset"
    if any(p.match(f) for p in carry):
        return "carry"
    for flag, pats in withs.items():
        if any(p.match(f) for p in pats):
            return "with:" + flag
    if any(p.match(f) for p in regen):
        return "regen"
    if any(p.match(f) for p in state):
        return "state"
    return None


def module_name_re(mods):
    """Module names in an 'own-code' context: <mod>_<uvm-ish suffix> or a backticked bare name."""
    if not mods:
        return None
    alt = "|".join(re.escape(m) for m in sorted(mods, key=len, reverse=True))
    sfx = "smoke|test|seq|block|base|env|if|driver|monitor|scoreboard|sequencer|seqr|adapter|cfg|pkg|agent|coverage"
    return re.compile(r"\b(?:%s)_(?:%s)\w*|(?<!`)`(?:%s)`(?!`)" % (alt, sfx, alt))


def _doc_map_globs(ops_text):
    """First-column backticked paths of the ops §4 doc-map table, as fnmatch globs."""
    m = re.search(r"(?ms)^## 4\..*?(?=^## )", ops_text)
    out = []
    for line in (m.group(0) if m else "").split("\n"):
        if not line.startswith("|"):
            continue
        cell = line.split("|")[1]
        for p in re.findall(r"`([^`]+)`", cell):
            g = re.sub(r"<[^>]+>", "*", p)
            if g.startswith("verify/"):
                g = g[len("verify/"):]
            if g.endswith("/"):
                g += "*"
            out.append(g)
    return out


def audit(repo):
    """Framework self-audit: manifest coverage, module names in carried instruction text,
    doc-map coverage of carried .md files, registry coverage. Returns [(level, item, detail)]."""
    import fnmatch
    m = _manifest(full=True)
    res = []
    files = _source_files_of(repo)
    carried = []
    for f in files:
        c = classify(f, m)
        if c is None:
            res.append(("FAIL", "manifest", "unclassified file %s - add it to manifest.txt (carry/reset/regen/state/exclude)" % f))
        elif c in ("carry", "reset"):
            carried.append(f)
    verify = os.path.join(repo, "verify")
    # module names of this repo in carried instruction/doc text (arch R1)
    try:
        with open(os.path.join(verify, "json", "module.json"), encoding="utf-8") as fh:
            mods = list(json.load(fh).get("modules", {}))
    except (OSError, ValueError):
        mods = []
    rx = module_name_re(mods)
    text_files = [f for f in carried if f.endswith((".md", ".sh", ".json")) and classify(f, m) == "carry"]
    if rx:
        for f in text_files:
            for n, line in enumerate(read_text(os.path.join(repo, f))[0].split("\n"), 1):
                hit = rx.search(line)
                if hit:
                    res.append(("FAIL", "module-name", "%s:%d names a module (%s) - carried files stay module-agnostic (arch R1)" % (f, n, hit.group(0))))
    # every occurrence of a registered project value in carried text must sit in a file of its rewrite
    # (otherwise apply leaves the source project's value behind in the new one - arch R7)
    vtexts = {}
    for f in carried:
        if f.startswith("verify/") and classify(f, m) == "carry" and f.endswith((".md", ".py", ".sh", ".json", ".txt")):
            vtexts[f[len("verify/"):]] = read_text(os.path.join(repo, f))[0].split("\n")
    seen = set()
    for v in registry()["vars"]:
        if not v.get("rewrites"):
            continue
        cv = infer_from_rewrites(v, verify) if v["kind"] == "record_only" else current_value(v, verify)
        if not isinstance(cv, str) or not cv:
            continue
        for rw in v["rewrites"]:
            needle = rw["pattern"].replace("{v}", cv)
            for f, lines in vtexts.items():
                if f in rw["files"] or f.startswith("script/new_project/"):
                    continue
                for n, line in enumerate(lines, 1):
                    if needle in line and (f, n, needle) not in seen:
                        seen.add((f, n, needle))
                        res.append(("FAIL", "rewrite", "%s:%d holds '%s' but is not in the %s rewrite files of vars.json (arch R7)"
                                    % (f, n, needle, v["id"])))
    # doc-map coverage of carried .md files
    ops = os.path.join(verify, "docs", "ops", "multi_agent_ops.md")
    globs = _doc_map_globs(read_text(ops)[0]) if os.path.isfile(ops) else []
    for f in carried:
        if not f.endswith(".md"):
            continue
        rel = f[len("verify/"):] if f.startswith("verify/") else f
        if not any(fnmatch.fnmatch(rel, g) or fnmatch.fnmatch(f, g) for g in globs):
            res.append(("FAIL", "doc-map", "%s is carried but not in the ops section 4 doc map" % f))
    # registry coverage: flow_env variables and config top-level keys
    reg = registry()
    sh_vars = {v["var"] for v in reg["vars"] if v["kind"] == "sh_var"}
    fe = os.path.join(verify, reg["flow_env_file"])
    for var in re.findall(r"^(WSIM_\w+)=", read_text(fe)[0], re.M) if os.path.isfile(fe) else []:
        if var not in sh_vars:
            res.append(("FAIL", "registry", "%s in flow_env.sh is not registered in vars.json (arch R7)" % var))
    keys = {v["key"] for v in reg["vars"] if v["kind"] == "json_field"} | set(reg.get("fixed_config_keys", []))
    try:
        with open(os.path.join(verify, reg["config_file"]), encoding="utf-8") as fh:
            for k in json.load(fh):
                if k not in keys:
                    res.append(("FAIL", "registry", "config key %s is neither registered nor listed in fixed_config_keys (arch R7)" % k))
    except (OSError, ValueError):
        pass
    if not any(r[0] == "FAIL" for r in res):
        res.append(("READY", "audit", "%d files classified, %d carried, no module names, doc map and registry complete" % (len(files), len(carried))))
    return res


def cmd_audit(markdown):
    res = audit(SRC_REPO)
    if markdown:
        print("| Level | Item | Detail |\n|---|---|---|")
        for r in res:
            print("| %s | `%s` | %s |" % r)
    else:
        for r in res:
            print("%-8s %-12s %s" % r)
    fails = sum(1 for r in res if r[0] == "FAIL")
    print("\nsummary: FAIL %d" % fails)
    sys.exit(1 if fails else 0)


def _source_files_of(repo):
    # tracked files plus untracked-but-not-ignored ones (framework edits not committed yet)
    rc, so = _run(["git", "-C", repo, "ls-files", "--cached", "--others", "--exclude-standard"], timeout=60)
    if rc == 0 and so.strip():
        return sorted({l.strip() for l in so.splitlines() if l.strip() and os.path.isfile(os.path.join(repo, l.strip()))})
    files = []
    for d, _, fs in os.walk(repo):
        if ".git" in d.split(os.sep):
            continue
        files += [repo_rel(repo, os.path.join(d, f)) for f in fs]
    return files


def _source_files():
    return _source_files_of(SRC_REPO)


def _sections(text):
    parts = re.split(r"(?m)^(## .*)$", text)
    return parts[0], [(parts[i], parts[i + 1]) for i in range(1, len(parts), 2)]


def _reset(kind, src_text, ctx):
    if kind == "config":
        cfg = json.loads(src_text)
        cfg["modules"] = []
        return json.dumps(cfg, indent=2, ensure_ascii=False) + "\n"
    if kind == "flow_env":
        # site values belong to the old server: neutral values until /new-project sets them
        neutral = {"WSIM_REG_TABLE": "", "WSIM_PYTHON": "python3", "WSIM_LSF_ENABLE": "FALSE",
                   "WSIM_LSF_QUEUE": "", "WSIM_LSF_HOSTS_FILE": "", "WSIM_LSF_SUBMIT_HOSTS": "",
                   "WSIM_LSF_EXEC_HOST_REGEX": "", "WSIM_LSF_QUEUE_SED": "", "WSIM_DPO_DB": ""}
        out = src_text
        for k, v in neutral.items():
            out = re.sub(r"^%s=.*$" % k, lambda m, k=k, v=v: '%s="%s"' % (k, v), out, flags=re.M)
        return out
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
                out.append(head + "\n".join(l for l in body.split("\n") if not l.startswith("| G")))
            else:
                out.append(head + body)
        return "".join(out)
    if kind == "fw_env":
        pre, _ = _sections(src_text)
        return pre.rstrip("\n") + ("\n\n## %s Initialization\n- Change: environment bootstrapped from `%s` (commit %s) by "
                                   "`script/new_project/new_project.py bootstrap`; framework carried per `script/new_project/manifest.txt`, "
                                   "chip-specific state reset, `tb_top/` left to the first `--guvc`.\n- Reason: new chip project on this framework.\n"
                                   "- Impact: nothing generated yet - run `/new-project`, then the `/new-verification` intake.\n") % (TODAY, ctx["src"], ctx["sha"])
    if kind == "taskboard":
        hdr = []
        for l in src_text.split("\n"):
            hdr.append(l)
            if l.startswith("|---"):
                break
        rows = [
            "| %s | New-project setup (`/new-project`: identity, design root, tools, server settings, language) | global | leader | /new-project | in progress | bootstrapped from `%s` @ %s |" % (TODAY, ctx["src"], ctx["sha"]),
            "| %s | First real VCS case + one LSF dispatch on this server | global | user | — | pending | after `/new-project` and the first `--guvc`; confirms the flow_env.sh site section |" % TODAY,
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
        return json.dumps({"bootstrapped_from": {"repo": ctx["src"], "commit": ctx["sha"], "date": TODAY, "with": ctx["with"],
                                                 "source_values": dict(ctx["applied"]), "source_modules": ctx["modules"]},
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
    fails = [r for r in audit(SRC_REPO) if r[0] == "FAIL"]
    if fails:
        for r in fails:
            print("FAIL     %-12s %s" % r[1:], file=sys.stderr)
        die("the framework audit failed (%d item(s)) - fix the source repo first (`new_project.py audit`)" % len(fails))
    rc, sha = _run(["git", "-C", SRC_REPO, "rev-parse", "--short", "HEAD"])
    applied = {}
    for v in registry()["vars"]:
        if v.get("rewrites") or v["kind"] == "choice_rewrite":
            cv = infer_from_rewrites(v, SRC_VERIFY) if v["kind"] == "record_only" else current_value(v, SRC_VERIFY)
            if cv:
                applied[v["id"]] = cv
    try:
        with open(os.path.join(SRC_VERIFY, "json", "module.json"), encoding="utf-8") as fh:
            src_mods = sorted(json.load(fh).get("modules", {}))
    except (OSError, ValueError):
        src_mods = []
    ctx = {"src": _posix(SRC_REPO), "sha": sha.strip() if rc == 0 else "unknown", "with": with_flags,
           "applied": applied, "modules": src_mods}
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
    b.add_argument("--with", dest="withs", action="append", default=[], help="optional manifest group (a with:<flag> line in manifest.txt)")
    b.add_argument("--force", action="store_true")
    for name in ("detect", "status"):
        x = sub.add_parser(name)
        x.add_argument("--stage", choices=STAGES + ("all",), default="all")
    sc = sub.add_parser("scan")
    sc.add_argument("--markdown", action="store_true")
    s = sub.add_parser("set")
    s.add_argument("pairs", nargs="*")
    s.add_argument("--defer", action="append", default=[])
    s.add_argument("--from", dest="src", help="prefill from another project's answers.json")
    p = sub.add_parser("apply")
    p.add_argument("--stage", choices=STAGES + ("all",), default="all")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--force", action="store_true")
    c = sub.add_parser("check")
    c.add_argument("--stage", choices=STAGES + ("all",), default="all")
    c.add_argument("--markdown", action="store_true")
    c.add_argument("--lint", action="store_true", help="verilator --lint-only of the design file lists (verification stage)")
    c.add_argument("--top", help="top module for --lint (default: rtl_tops answer)")
    au = sub.add_parser("audit", help="framework self-audit (run in the framework repo before committing framework changes)")
    au.add_argument("--markdown", action="store_true")
    args = ap.parse_args()
    if not args.cmd:
        ap.print_help()
        sys.exit(2)
    root = os.path.abspath(args.root)
    if args.cmd == "bootstrap":
        cmd_bootstrap(args.dst, args.withs, args.force)
    elif args.cmd == "detect":
        print(json.dumps(detect(root, args.stage), indent=2, ensure_ascii=False))
    elif args.cmd == "scan":
        cmd_scan(root, args.markdown)
    elif args.cmd == "status":
        cmd_status(root, args.stage)
    elif args.cmd == "set":
        cmd_set(root, args.pairs, args.defer, args.src)
    elif args.cmd == "apply":
        cmd_apply(root, args.stage, args.dry_run, args.force)
    elif args.cmd == "check":
        cmd_check(root, args.stage, args.markdown, args.lint, args.top)
    elif args.cmd == "audit":
        cmd_audit(args.markdown)


if __name__ == "__main__":
    main()
