#!/usr/bin/env python3
"""conv_report - two-flow convergence report (oEDA vs VCS).

Scans the repo-root sim/ scratch trees and prints, per case:
  case | oEDA result | oEDA coverage report | VCS result | VCS coverage

Usage (from anywhere; paths resolved relative to this script):
  python3 conv_report.py                 # all cases found in either tree
  python3 conv_report.py --case apb      # substring filter on case name
  python3 conv_report.py -o conv.txt     # also write sim/conv_report.txt

Read-only. Exit 0 always (a report, not a checker).
"""
import argparse
import glob
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))  # verify/.claude/skills/conv-report
REPO = os.path.normpath(os.path.join(HERE, '..', '..', '..', '..'))
SIM = os.path.join(REPO, 'sim')
OEDA_PREFIX = 'uvm_scratch_oeda_'
LEGACY_PREFIX = 'uvm_scratch_local_'
VCS_PREFIX = 'uvm_scratch_'


def read_results(scratch):
    """last result per case line from result.txt -> {'case': 'PASS'|'FAIL'|...}"""
    out = {}
    f = os.path.join(scratch, 'result.txt')
    if not os.path.isfile(f):
        return out
    for line in open(f, encoding='utf-8', errors='replace'):
        parts = line.split()
        if len(parts) >= 2:
            out[parts[0]] = parts[1]
    return out


def scan():
    oeda, vcs = {}, {}
    for d in glob.glob(os.path.join(SIM, OEDA_PREFIX + '*')):
        case = os.path.basename(d)[len(OEDA_PREFIX):]
        oeda[case] = d
    for d in glob.glob(os.path.join(SIM, VCS_PREFIX + '*')):
        base = os.path.basename(d)
        if base.startswith(OEDA_PREFIX) or base.startswith(LEGACY_PREFIX):
            continue
        case = base[len(VCS_PREFIX):]
        vcs[case] = d
    return oeda, vcs


def cov_mark(scratch, flow):
    if not scratch:
        return '-'
    if flow == 'oEDA':
        return 'yes' if glob.glob(os.path.join(scratch, 'comp_*', 'cov_report')) else 'no'
    # VCS code-coverage dir naming varies; mark present/absent generically
    marks = glob.glob(os.path.join(scratch, '*', '*.cm')) + \
            glob.glob(os.path.join(scratch, 'simv.cm')) + \
            glob.glob(os.path.join(scratch, '*', 'cm'))
    return 'yes' if marks else '?'


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--case', default='', help='substring filter on case name')
    ap.add_argument('-o', '--output', default=None,
                    help='also write the report to this file (default: stdout only)')
    args = ap.parse_args()

    oeda_dirs, vcs_dirs = scan()
    oeda_res = {c: read_results(d) for c, d in oeda_dirs.items()}
    vcs_res = {c: read_results(d) for c, d in vcs_dirs.items()}

    cases = sorted(set(oeda_dirs) | set(vcs_dirs))
    if args.case:
        cases = [c for c in cases if args.case in c]

    head = '%-42s %-8s %-8s %-8s %-8s' % ('case', 'oEDA', 'oEDA-cov', 'VCS', 'VCS-cov')
    lines = [head, '-' * len(head)]
    for c in cases:
        o = oeda_res.get(c, {})
        v = vcs_res.get(c, {})
        lines.append('%-42s %-8s %-8s %-8s %-8s' % (
            c[:42],
            o.get(c, '-') if o else '-',
            cov_mark(oeda_dirs.get(c), 'oEDA'),
            v.get(c, '-') if v else '-',
            cov_mark(vcs_dirs.get(c), 'VCS'),
        ))
    report = '\n'.join(lines) + '\n'
    print(report, end='')

    done = [c for c in cases
            if oeda_res.get(c, {}).get(c) == 'PASS' and vcs_res.get(c, {}).get(c) == 'PASS']
    print('summary: %d case(s), %d converged (PASS on both flows)' % (len(cases), len(done)))
    if args.output:
        out = args.output if os.path.isabs(args.output) else os.path.join(SIM, args.output)
        with open(out, 'w', encoding='utf-8') as f:
            f.write(report)
        print('written:', out)
    return 0


if __name__ == '__main__':
    sys.exit(main())
