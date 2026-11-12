---
name: conv-report
description: Generate the two-flow convergence report (oEDA vs VCS) for the verify environment - which cases passed on which flow and where coverage was collected. Use when asked for a convergence/closed-loop status, a two-flow comparison, or before sign-off of test cases.
---

# Convergence Report (oEDA vs VCS)

Read-only report over the repo-root `sim/` scratch trees. No simulation is run.

## Run it

```bash
python3 verify/.claude/skills/conv-report/conv_report.py                  # all cases
python3 verify/.claude/skills/conv-report/conv_report.py --case apb       # substring filter
python3 verify/.claude/skills/conv-report/conv_report.py -o conv_report.txt   # + write sim/conv_report.txt
```

The script resolves the repo-root `sim/` from its own location, so it runs from any cwd, on Linux servers and inside WSL (paths are plain filesystem, no simulator needed).

## Output columns

| Column | Meaning |
|---|---|
| `case` | case name (scratch suffix after `uvm_scratch_` / `uvm_scratch_oeda_`) |
| `oEDA` | last line for this case in the oEDA tree's `result.txt` (PASS/FAIL/-) |
| `oEDA-cov` | `yes` if a `-covrpt` annotated `cov_report/` exists (line/toggle coverage) |
| `VCS` | last line for this case in the VCS tree's `result.txt` |
| `VCS-cov` | `yes`/`?`/`-` for VCS coverage artifacts (naming varies by `-cm` invocation) |

A case is **converged** only when it shows PASS in both `oEDA` and `VCS` columns;
the summary line counts those. Remember the sign-off rules in
`verify/docs/memory/arch_memory.md` section 5: functional-coverage closure
(`-fm`) is a separate VCS step and is NOT represented in this report.

## Notes

- Old `uvm_scratch_local_*` directories (pre-rename artifacts) are ignored.
- The report never fails (exit 0); empty columns mean that flow has not run the case.
