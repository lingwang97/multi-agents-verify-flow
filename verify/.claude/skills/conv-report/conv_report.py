#!/usr/bin/env python3
"""conv_report - two-flow convergence report (oEDA vs VCS).

Scans the repo-root sim/ scratch trees and prints, per case:
  case | oEDA result | oEDA coverage report | VCS result | VCS coverage

Usage (from anywhere; paths resolved relative to this script):
  python3 conv_report.py                 # all cases found in either tree
  python3 conv_report.py --case apb      # substring filter on case name
  python3 conv_report.py -o conv.txt     # also write sim/conv_report.txt

Where the results come from:
  oEDA  sim/uvm_scratch_oeda_<case>/result.txt (one dir per case, newest run only)
  VCS   sim/uvm_scratch_<case|mod|group>_<timestamp>_..._<level>/result.txt (one
        dir per wsim invocation; -tag / -nopostfix change the suffix). Its lines
        name a run "<case>_<prefix>_iter<N>" (prefix: empty for -c, the module
        for -m, the group for -smoke/-stage*/-full) and are mapped back to the
        case keys of verify/json/case/*.json. The newest invocation that ran a
        case wins.
A case's status over its iterations: PASS only when every iteration passed,
otherwise the first non-PASS status (FAIL, compile_error, sim_setup_error).

Read-only. Exit 0 always (a report, not a checker).
"""
import argparse
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))  # verify/.claude/skills/conv-report
REPO = os.path.normpath(os.path.join(HERE, '..', '..', '..', '..'))
SIM = os.path.join(REPO, 'sim')
VERIFY = os.path.join(REPO, 'verify')
OEDA_PREFIX = 'uvm_scratch_oeda_'
LEGACY_PREFIX = 'uvm_scratch_local_'
VCS_PREFIX = 'uvm_scratch_'
GROUPS = ('smoke', 'stage1', 'stage2', 'full')


def known_names():
    """case keys and module names from the case JSON database (may be empty)"""
    cases, modules = set(), set()
    try:
        with open(os.path.join(VERIFY, 'json', 'module.json'), encoding='utf-8') as f:
            mods = json.load(f).get('modules', {})
    except (OSError, ValueError):
        mods = {}
    for mod, rel in mods.items():
        modules.add(mod)
        try:
            with open(os.path.join(VERIFY, 'json', rel), encoding='utf-8') as f:
                cases.update(json.load(f).get('tests', {}).keys())
        except (OSError, ValueError):
            pass
    return cases, modules


def merge_status(statuses):
    """PASS only when every run passed; otherwise the first non-PASS status"""
    for s in statuses:
        if s != 'PASS':
            return s
    return 'PASS' if statuses else None


def read_lines(path):
    """[(name, status)] from a result.txt, skipping the pass-rate line"""
    out = []
    try:
        lines = open(path, encoding='utf-8', errors='replace').readlines()
    except OSError:
        return out
    for line in lines:
        parts = line.split()
        if len(parts) >= 2 and parts[0] != 'pass':
            out.append((parts[0], parts[1]))
    return out


def vcs_case_name(run_name, cases, prefixes):
    """'<case>_<prefix>_iter<N>' -> '<case>' (prefix empty for a -c run)"""
    base = re.sub(r'_iter\d+$', '', run_name)
    if base.endswith('_'):
        return base[:-1]
    if base in cases:
        return base
    for p in sorted(prefixes, key=len, reverse=True):
        if base.endswith('_' + p) and (not cases or base[:-len(p) - 1] in cases):
            return base[:-len(p) - 1]
    return base


def scan_oeda():
    """case -> (status, scratch dir)"""
    res = {}
    for d in glob.glob(os.path.join(SIM, OEDA_PREFIX + '*')):
        case = os.path.basename(d)[len(OEDA_PREFIX):]
        st = merge_status([s for n, s in read_lines(os.path.join(d, 'result.txt')) if n == case])
        if st:
            res[case] = (st, d)
    return res


def scan_vcs(cases, modules):
    """case -> (status, invocation dir) from the newest wsim invocation that ran it"""
    prefixes = set(modules) | set(GROUPS)
    best = {}   # case -> (mtime, statuses, dir)
    for d in glob.glob(os.path.join(SIM, VCS_PREFIX + '*')):
        base = os.path.basename(d)
        if base.startswith(OEDA_PREFIX) or base.startswith(LEGACY_PREFIX):
            continue
        f = os.path.join(d, 'result.txt')
        if not os.path.isfile(f):
            continue
        mtime = os.path.getmtime(f)
        runs = {}
        for name, st in read_lines(f):
            runs.setdefault(vcs_case_name(name, cases, prefixes), []).append(st)
        for case, sts in runs.items():
            if case not in best or mtime > best[case][0]:
                best[case] = (mtime, sts, d)
    return {c: (merge_status(sts), d) for c, (m, sts, d) in best.items()}


def cov_mark(case, scratch, flow):
    if not scratch:
        return '-'
    if flow == 'oEDA':
        return 'yes' if glob.glob(os.path.join(scratch, 'comp_*', 'cov_report')) else 'no'
    # wsim -cm writes the coverage database into comp_<case>/simv.vdb of the invocation dir
    return 'yes' if os.path.isdir(os.path.join(scratch, 'comp_' + case, 'simv.vdb')) else 'no'


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--case', default='', help='substring filter on case name')
    ap.add_argument('-o', '--output', default=None,
                    help='also write the report to this file (default: stdout only)')
    args = ap.parse_args()

    known_cases, modules = known_names()
    oeda = scan_oeda()
    vcs = scan_vcs(known_cases, modules)

    cases = sorted(set(oeda) | set(vcs))
    if args.case:
        cases = [c for c in cases if args.case in c]

    width = max([42] + [len(c) for c in cases])
    head = '%-*s %-15s %-8s %-15s %-8s' % (width, 'case', 'oEDA', 'oEDA-cov', 'VCS', 'VCS-cov')
    lines = [head, '-' * len(head)]
    for c in cases:
        o_st, o_dir = oeda.get(c, ('-', None))
        v_st, v_dir = vcs.get(c, ('-', None))
        lines.append('%-*s %-15s %-8s %-15s %-8s' % (
            width, c, o_st, cov_mark(c, o_dir, 'oEDA'), v_st, cov_mark(c, v_dir, 'VCS')))
    report = '\n'.join(lines) + '\n'
    print(report, end='')

    both = [c for c in cases if oeda.get(c, ('',))[0] == 'PASS' and vcs.get(c, ('',))[0] == 'PASS']
    o_pass = sum(1 for c in cases if oeda.get(c, ('',))[0] == 'PASS')
    v_pass = sum(1 for c in cases if vcs.get(c, ('',))[0] == 'PASS')
    summary = ('summary: %d case(s); oEDA PASS %d/%d run, VCS PASS %d/%d run; '
               '%d converged (PASS on both flows)' % (
                   len(cases), o_pass, sum(1 for c in cases if c in oeda),
                   v_pass, sum(1 for c in cases if c in vcs), len(both)))
    print(summary)
    if args.output:
        out = args.output if os.path.isabs(args.output) else os.path.join(SIM, args.output)
        with open(out, 'w', encoding='utf-8') as f:
            f.write(report + summary + '\n')
        print('written:', out)
    return 0


if __name__ == '__main__':
    sys.exit(main())
