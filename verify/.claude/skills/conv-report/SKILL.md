---
name: conv-report
description: Generate the two-flow convergence report (oEDA vs VCS) for the verify environment - which cases passed on which flow and where coverage was collected. Use when asked for a convergence/closed-loop status, a two-flow comparison, or before sign-off of test cases.
---

# Convergence Report (oEDA vs VCS)

Read-only report over the repo-root `sim/` scratch trees. No simulation is run.

## Run it

```bash
${CLAUDE_SKILL_DIR}/conv_report.py                  # all cases
${CLAUDE_SKILL_DIR}/conv_report.py --case <mod>     # substring filter
${CLAUDE_SKILL_DIR}/conv_report.py -o conv_report.txt   # + write sim/conv_report.txt
```

The script resolves the repo-root `sim/` from its own location, so it runs from any cwd on any host (paths are plain filesystem, no simulator needed).

## Output columns

| Column | Meaning |
|---|---|
| `case` | case key of `json/case/<mod>.json` |
| `oEDA` | status of the case's last oEDA run (`sim/uvm_scratch_oeda_<case>/result.txt`) |
| `oEDA-cov` | `yes` if a `-covrpt` annotated `cov_report/` exists (line/toggle coverage) |
| `VCS` | status of the case in the newest `wsim` invocation dir that ran it (`sim/uvm_scratch_<case\|mod\|group>_<timestamp>_.../result.txt`; run names `<case>_<prefix>_iter<N>` are mapped back to the case) |
| `VCS-cov` | `yes` if that invocation has `comp_<case>/simv.vdb` (`-cm`) |

A status over several iterations is PASS only when every iteration passed, otherwise the first non-PASS status (`FAIL`, `compile_error`, `sim_setup_error`); `-` = the flow has not run the case.

A case is **converged** only when it shows PASS in both `oEDA` and `VCS` columns;
the summary line counts those. Remember the sign-off rules in
`verify/docs/memory/arch_memory.md` section 5: functional-coverage closure
(`-fm`) is a separate VCS step and is NOT represented in this report.

## Notes

- The report never fails (exit 0); empty columns mean that flow has not run the case.
