# modules/apb_master — apb_master / apb_v3_sram verification knowledge base

> **Cross-agent canon of current facts** for this module: DUT details, quirks, instantiation parameters, case macros, config rationale. Per-agent process logs live in `docs/memory/dev|debug/<mod>.md` (append-only); stable facts distilled from a log are **promoted** here per arch_memory R6 with the log entry marked "promoted" — do not copy canon into logs.
> Full verification findings and results: `docs/apb_v3_sram_verify_report.md`.

- **DUT:** `hdl/rtl/apb_v3_sram.v` (APB3 slave SRAM, listed in `tb_top/filelist/rtl_file_lst.f`); tb top `tb_top/tb_top/tb_top_apb_master.sv` generates clock/reset and instantiates the DUT. Instantiate with `.MEM_BLOCK_SIZE(32)` — default 8 breaks `wr_data2mem` (ignores `PADDR`). Reset must be asserted from t=0 (memory only initialised in the reset branch).
- **Cases:** `+APB_MASTER_BLOCK_TEST` in `VCS_MACRO_OPT`; the wait-state case adds `+APB_SRAM_EN_WAIT` (DUT `EN_WAIT_DELAY_FUNC=1`). Run e.g. `./wsim_oeda -c apb_master_rw_rand_block_test -seed 1 -covrpt`.
- **DUT quirks that shaped the UVC:** early PREADY in SETUP; one-phase lag after each transfer (driver inserts ≥1 idle cycle); `wait_cyc_limit` randomised once at t=0; out-of-range reads keep stale PRDATA with PSLVERR=1. Driver/monitor sample on **negedge** (DUT uses blocking assigns on posedge).
- **Sequence helpers** live in `seq/apb_master_block_base_seq.sv` (`apb_write`/`apb_read`/`apb_idle`); every helper must `get_response` because the driver does `item_done(rsp)`.
- The apb_master DUT has no registers: `enable_ral: false`, `adapter_type: ""` (the former stub adapter was deleted).
