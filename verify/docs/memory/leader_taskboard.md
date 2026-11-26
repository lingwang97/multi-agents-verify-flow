# leader taskboard

Scheduling board maintained by the leader (main session); updated on every dispatch/recall.

| Date | Task | Module/Scope | Owner/Agent | Invocation | Status | Notes / Trigger |
|---|---|---|---|---|---|---|
| 2026-11-17 | Multi-agent flow deployment | global | leader | — | done | see `docs/ops/multi_agent_ops.md` |
| 2026-11-18 | Linux VCS flow validation | global | user | — | in progress (on uart_test) | the framework carries neutral site values; each project sets its own through `/new-project` P3. Confirm on the uart_test server: one real VCS case + one LSF dispatch, and the F3 root cause (scene-dir links - send `ls -la comp_<case>/` and the scene dir if the new link check fires) |
| 2026-11-18 | oEDA runtime environment update | global | leader+json2env | leader dispatch | done | user decision 2026-11-26: oEDA runs natively on Linux only; WSL support and descriptions removed |
| 2026-11-18 | oEDA↔VCS closed-loop handshake update | global | leader+debug_agent | leader dispatch | done | user decision 2026-11-26: debug_agent runs VCS per the ops §3 tiers (max 3 concurrent runs); conv-report reads `sim/` directly |
| 2026-11-25 | Framework made generic (soc environment → local test fixture, identity chip/000) | global | leader | — | done | fixture usage: arch §0; snapshot tag `soc-pid003-snapshot` |
