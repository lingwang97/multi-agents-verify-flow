# fw_env_memory (json2env_agent)

Environment framework build & update log. Entry format: date / change / reason / impact.
The current environment state (module table, generation rules) lives in `arch_memory.md` §0; the generation-rules canon is `verify/CLAUDE.md` ("Regenerating the environment"). Per R6: framework changes are logged **here** — arch's Last-updated chain records only rule/doc changes.

## 2026-11-17 Initialization
- Change: multi-agent flow deployed; this memory created. No environment change.
- Reason: flow deployment (`docs/ops/multi_agent_ops.md`).
- Impact: none.

## Framework-change history (migrated from arch_memory.md on 2026-11-19; pre-multi-agent records, dates taken from the arch changelog)

- ≤2026-11-11 Template lifts into `gen_uvm_env.py`: OPEN_EDA guards (`top_pkg`, `tb_top_*`, `dump_wave`, `vif_declare`), `TB_TOP=tb_top`, clk/rst generation in both tb_top templates.
- ≤2026-11-11 `hdl/rtl/soc_stub.sv` removed — the system flow has no DUT until the SoC RTL lands; VCS Makefile gained the `block_env` branch (`uvm_blk_<mod>.f` selection).
- 2026-11-11 `enable_ral` config knob added (chip-global + per-module) with its generator-enforced rules.
- 2026-11-11 oEDA rename: `wsim_local` → `wsim_oeda`; scratch `uvm_scratch_oeda_<case>/`; isolation define `+define+OPEN_EDA`; old `_local` on-disk artifacts kept as-is.
- 2026-11-12 Width macros derived from the register table: RalGen (`gen_reg_model.py`) writes `verify/ral/ral_reg_width`; the old `chip_define.sv` + CORE_NUM parsing removed.
