# leader taskboard

Scheduling board maintained by the leader (main session); updated on every dispatch/recall.

| Date | Task | Module/Scope | Owner/Agent | Invocation | Status | Notes / Trigger |
|---|---|---|---|---|---|---|
| 2026-11-17 | Multi-agent flow deployment | global | leader | — | done | see `docs/ops/multi_agent_ops.md` |
| 2026-11-18 | Linux migration: VCS flow deployment | global | user | — | blocked (awaiting user migration) | **the user notifies the leader when migration completes**; the leader then verifies `file_manage.sh` deployables and site-specific items (site python, LSF queue names — see `.claude/rules/flow-scripts.md`), plus a server-side check of `wsim` RalGen with `WSIM_REG_TABLE` (skip when the CSV is absent / mtime regeneration — only `bash -n` checked locally, 2026-11-23); **review the site section of `verify/script/sflow/flow_env.sh`** (`WSIM_PYTHON`, `WSIM_LSF_QUEUE`, `WSIM_LSF_HOSTS_FILE`, `WSIM_DPO_DB`, and the LSF policy `WSIM_LSF_ENABLE` / `WSIM_LSF_SUBMIT_HOSTS` / `WSIM_LSF_EXEC_HOST_REGEX` / `WSIM_LSF_QUEUE_SED` — parameterized 2026-11-23, values unchanged) against the new server, then run one real VCS case + one LSF dispatch |
| 2026-11-18 | oEDA runtime environment update | global | leader+json2env | leader dispatch | blocked (depends on previous) | assess the oEDA deployment shape on Linux (server-native Verilator vs keeping local WSL), `file_manage` deploy, scratch/obj_dir path assumption review |
| 2026-11-18 | oEDA↔VCS closed-loop handshake update | global | leader+debug_agent | leader dispatch | blocked (depends on the two above) | redefine result return/trigger (`sim/vcs_results/` vs direct server read) and conv-report input paths; afterwards revise `docs/ops/multi_agent_ops.md` §3 |
| 2026-11-25 | Framework made generic (soc environment → local test fixture, identity chip/000) | global | leader | — | done | fixture usage: arch §0; snapshot tag `soc-pid003-snapshot` |
