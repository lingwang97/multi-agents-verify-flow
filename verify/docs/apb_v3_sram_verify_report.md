# apb_v3_sram RTL Verification Development Report

> Note (2026-11-19): this is the translated English version of the original Chinese report (2026-09-28). `wsim_local` is the historical name of what is now `wsim_oeda` (see arch_memory §5); on-disk `_local` artifacts were kept as-is.

| Item | Content |
|---|---|
| DUT | `hdl/rtl/apb_v3_sram.v` (APB v3 slave SRAM, Farshad 2018, MIT) |
| Branch | `verify_ai_flow_cc_open_eda` |
| Verification environment | block-level UVM (UVM-1.2), `verify/uvc/apb_master/` |
| Simulation tool | Verilator 5.053 (open-source EDA local flow, WSL2 + Ubuntu 24.04); the VCS golden-reference flow scripts support it in sync |
| Run entry | `sim/wsim_local -c <case> -seed 1 [-covrpt]` |
| Report date | 2026-09-28 |

---

## 1. Overview

This report covers the whole block-level verification development of apb_v3_sram: tb top and filelist updates, completion of the apb_master UVC components, RTL verification feature-point (FP) decomposition, development and simulation of 6 block-level test cases, and the verification conclusions. All cases ran in the open-source EDA environment (Verilator + UVM-1.2).

**Conclusion summary**: under the parameter-override configuration (`MEM_BLOCK_SIZE=32`, see §7.1), the DUT's reset, read/write, out-of-range error, boundary-address and wait-cycle behaviors are functionally correct; all verification points pass (§5). Several DUT design/code defects and quirks were also found (§7) for design-side review.

## 2. DUT behavior analysis

### 2.1 Ports and parameters

Ports: standard APB v3 slave — `PRESETn` (active low), `PCLK`, `PSEL`, `PENABLE`, `PWRITE`, `PADDR[31:0]`, `PWDATA[31:0]`, `PRDATA[31:0]`, `PREADY`, `PSLVERR`. No APB4 signals (no PPROT/PSTRB).

Parameters (values used by the tb instantiation):

| Parameter | Default | tb value | Notes |
|---|---|---|---|
| ADDR_BUS_WIDTH | 32 | 32 | PADDR width |
| DATA_BUS_WIDTH | 32 | 32 | data width |
| MEMSIZE | 64 | 64 | memory depth (entries) |
| MEM_BLOCK_SIZE | 8 | **32 (override)** | per-entry width; must equal DATA_BUS_WIDTH (§7.1) |
| RESET_VAL | 0 | 0 | reset fill value |
| EN_WAIT_DELAY_FUNC | 0 | 0/1 (compile time) | wait-cycle enable (+APB_SRAM_EN_WAIT) |
| MIN/MAX_RAND_WAIT_CYC | 0/1 | 0/1 | wait-cycle range |

### 2.2 Behavioral model

A single `always @(posedge PCLK or PRESETn)` process, branching on the PSEL/PENABLE combination:

- **Reset**: PREADY=0, PSLVERR=0, PRDATA=0, memory entirely filled with RESET_VAL. Note this is the only initialization path of the memory — PRESETn must be asserted low from t=0.
- **IDLE** (!PSEL && !PENABLE): PREADY=0, PSLVERR=0.
- **SETUP** (PSEL && !PENABLE): with EN_WAIT=0, **PREADY asserts one cycle early** (quirk, §7.3); with EN_WAIT=1, PREADY=0.
- **ACCESS** (PSEL && PENABLE): with EN_WAIT=1, waits `wait_cyc_limit` cycles before PREADY=1; write: PADDR<MEMSIZE writes with PSLVERR=0, otherwise PSLVERR=1 (no write); read: PADDR<MEMSIZE returns `memory[PADDR]`, otherwise PSLVERR=1 and **PRDATA keeps its stale value**; one cycle after the transfer completes, PREADY=0.
- **Single-process phase lag**: after evaluating ACCESS the process suspends on an internal `@(posedge PCLK)` and misses one trigger when resumed — the DUT response lags one cycle after every transfer (§7.4). The driver therefore inserts ≥1 IDLE cycle between transfers.

## 3. Verification environment architecture

```
tb_top (verify/tb_top/tb_top/tb_top_apb_master.sv)
 ├── clock gen (10ns) / reset gen (deasserted at t=0 for 20 cycles, PRESETn=~rst)
 ├── apb_master_pif() (apb_master_if, full APB v3 signal set)
 ├── apb_v3_sram instantiation (MEM_BLOCK_SIZE=32 override; EN_WAIT switched by +define)
 └── uvm_config_db publishes the vif
apb_master_env
 ├── apb_master_agent (active)
 │    ├── apb_master_driver    — APB v3 master FSM, drives/samples on negedge (IDLE→SETUP→ACCESS→wait PREADY)
 │    ├── apb_master_monitor   — negedge transaction rebuild (SETUP latching, wait_cycles count) + procedural protocol checks
 │    ├── apb_master_sequencer
 │    └── apb_master_scoreboard — shadow-memory reference model + PSLVERR/stale-PRDATA checks
 └── apb_master_coverage       — APB transfer/data covergroups (collected on VCS)
```

- Sequence base `apb_master_block_base_seq` provides the reusable stimulus helpers `apb_write / apb_read / apb_idle` (responses consumed via `get_response`).
- Test base `apb_master_block_base_test`: RAL build (stub adapter — this DUT has no registers, no register operations at runtime), cfg randomization, full runtime phases.
- **Why driver/monitor use negedge**: the DUT updates PRDATA/PSLVERR with blocking assignments inside posedge — posedge sampling would race.
- Protocol checks (monitor, always on for all cases, can be disabled via `checks_enable`): PENABLE without SETUP lead-in, PADDR/PWRITE/PWDATA stability during ACCESS, PSLVERR only in ACCESS and no earlier than PREADY, PREADY two-valuedness, IDLE quiescence (PREADY/PSLVERR must be 0 after 2 consecutive cycles). The early-SETUP PREADY and the DUT phase lag are tolerated items, not errors.
- Filelist: `uvm_blk_apb_master.f` (block-level compile set, includes the DUT RTL); `wsim_local` selects it automatically from the `+APB_MASTER_BLOCK_TEST` macro in the case JSON (the VCS Makefile gained the same branch).

## 4. Feature-point decomposition and mapping

| FP | Feature point | Check method | Covering case |
|---|---|---|---|
| FP1 | Reset behavior: PREADY/PSLVERR/PRDATA cleared, memory fully RESET_VAL | full 64-address read-back compared item by item + scoreboard model | apb_master_reset_block_test |
| FP2 | In-range write (PADDR<64) writes correctly, PSLVERR=0 | scoreboard write-then-read-back compare | smoke / rw_rand / boundary |
| FP3 | In-range read returns written data, PSLVERR=0 | scoreboard `rdata === model[addr]` | same as above |
| FP4 | Random r/w data integrity | 100 random stimuli × 5 seeds, scoreboard shadow model compares item by item | apb_master_rw_rand_block_test |
| FP5 | Out-of-range (PADDR≥64): PSLVERR=1, write has no effect, read PRDATA stale | read back an anchor address after an out-of-range write; scoreboard keeps `prdata_shadow` to check staleness | apb_master_error_block_test |
| FP6 | IDLE-state PREADY/PSLVERR=0 | monitor IDLE-quiescence check (always on) | all cases |
| FP7 | EN_WAIT_DELAY_FUNC=1 wait cycles: master holds ACCESS until PREADY | dedicated `+APB_SRAM_EN_WAIT` compile, 10 write-read pairs; wait_cycles counted into coverage statistics (not an error, §7.5) | apb_master_wait_block_test (3 iters) |
| FP8 | APB protocol compliance (phase ordering, control stability, PSLVERR timing) | monitor procedural protocol checks (always on) | all cases |
| FP9 | Boundary addresses 0/1/62/63 (in range) and 64 (first error address) | directed boundary r/w | apb_master_boundary_block_test; rw_rand pins 0/63 on its first two items |
| FP10 | Back-to-back transfer throughput / phase-lag behavior | driver always inserts 1 IDLE cycle; throughput and phase lag recorded in §7.4 (no zero-gap stimulus injected) | analysis-covered |

## 5. Simulation results

Run command: `./wsim_local -c <case> -seed 1 [-covrpt]`; PASS = simv exit code 0 and `UVM_ERROR :0` / `UVM_FATAL :0` in sim.log.

| Case | iteration / seed | EN_WAIT | Result | Scoreboard checks |
|---|---|---|---|---|
| apb_master_smoke_block_test | 1 iter, seed 1 | 0 | **PASS** | 6 transfers |
| apb_master_reset_block_test | 1 iter, seed 1 | 0 | **PASS** | 64 full-address read-backs |
| apb_master_rw_rand_block_test | 5 iters, seeds 1–5 | 0 | **PASS ×5** | 100 items/iter (500 total; in-range r/w with a random share of out-of-range reads) |
| apb_master_error_block_test | 1 iter, seed 1 | 0 | **PASS** | 10 items (5 out-of-range writes + 2 out-of-range reads + anchor write-read checks) |
| apb_master_boundary_block_test | 1 iter, seed 1 | 0 | **PASS** | 10 items (0/1/62/63 in range + 64 out of range) |
| apb_master_wait_block_test | 3 iters, seeds 1–3 | 1 | **PASS ×3** | 20 items/iter |

All iterations show `UVM_ERROR :0` / `UVM_WARNING :0` / `UVM_FATAL :0` in sim.log.

**Measured wait cycles**: the DUT `$display`s the one-time-drawn `wait_cyc_limit` at t=0; the 3 wait-case iterations measured **0 / 0 / 1** — both the 0-cycle and 1-cycle wait behaviors were exercised by real stimulus (§7.5).

(Execution records: `sim/uvm_scratch_local_<case>/result.txt` and `run_iterN/sim.log`)

## 6. Coverage

### 6.1 Code coverage (Verilator `--coverage` + `-covrpt`, annotated on apb_v3_sram.v)

The summary numbers printed by wsim_local (line 27.2% etc.) mix all compiled code (TB+UVC+DUT) and do not reflect the DUT itself; the table below is the **DUT-only coverage** counted line by line from the annotated file `cov_report/apb_v3_sram.v`:

| Case configuration | DUT annotated-line coverage | Explanation of zero-covered lines |
|---|---|---|
| reset (EN_WAIT=0, reads only) | 11/39 | no write stimulus → all of `wr_data2mem`, PWDATA/PWRITE/PRDATA/PSLVERR port toggles, both `PSLVERR=1` branches, the EN_WAIT=1 wait branch |
| rw_rand (EN_WAIT=0, 5-seed random r/w) | 39/53 (73.6%) | dead `state` declaration (§7.6), split-write defect branch (§7.1), wait branch (unreachable with compile-time EN_WAIT=0), both `PSLVERR=1` branches (no out-of-range stimulus) |
| error / boundary (EN_WAIT=0, includes out-of-range stimulus) | 49/58 (84.5%) | dead `state` declaration, split-write defect branch, wait branch (compile-time unreachable) |
| wait (EN_WAIT=1, 3 iters) | 43/55 (78.2%) | dead `state` declaration, split-write defect branch, EN_WAIT=0 SETUP branch (compile-time unreachable), both `PSLVERR=1` branches (no out-of-range stimulus) |

**Combined conclusion**: across the union of the 5 cases, **all executable behavior lines of the DUT are covered**. Permanently zero-covered lines are only two kinds: the dead `reg [1:0] state` declaration (never assigned/read, §7.6) and the `wr_data2mem` DATA_BUS_WIDTH≠MEM_BLOCK_SIZE split-write branch (known defect path, deliberately not stimulated, §7.1). The two EN_WAIT branches are covered by the EN_WAIT=0 / EN_WAIT=1 compile configurations respectively (compile-time constants — the opposite branch is unreachable in a single configuration). Toggle coverage is highest for the error case (global toggle 67.8%), then rw_rand (62.9%).

### 6.2 Functional coverage

The covergroups (`cg_apb_transfer`: address bucket × r/w cross, PSLVERR, wait cycles; `cg_data`: data patterns) ship with the UVC, but **Verilator does not collect covergroup coverage** — they must be converged on the VCS golden flow with `-fm`. In the open-source environment, "all verification points covered" is jointly evidenced by the §4 FP→case mapping + §5 all-PASS + §6.1 DUT code coverage.

## 7. DUT issues found (for design review)

1. **[Defect] `wr_data2mem` writes the wrong address when DATA_BUS_WIDTH≠MEM_BLOCK_SIZE** (apb_v3_sram.v L90-107): it splits the write into 32/8=4 byte cycles writing `memory[0..3]`, completely ignoring PADDR — a write to any address overwrites memory[0..3], and read-back by address necessarily mismatches. This verification bypassed it with the `.MEM_BLOCK_SIZE(32)` override (that configuration takes the correct `memory[PADDR]` path); **the default parameter configuration cannot perform functionally correct reads/writes** — recommend fixing it or constraining the parameter combination.
2. **[Defect-leaning] `always @(posedge PCLK or PRESETn)` is sensitive to any PRESETn edge**: the `negedge` keyword is missing, so the reset-release (rising) edge also triggers one process evaluation (harmless today since the evaluation branch tests `!PRESETn`, but bad coding practice).
3. **[Quirk] PREADY asserts early during SETUP** (EN_WAIT=0): functionally harmless because a compliant master samples PREADY only in ACCESS, but it does not match the APB protocol timing diagram — the protocol checker must tolerate it explicitly.
4. **[Quirk] single-process structure causes a one-cycle phase lag after every transfer**: after evaluating ACCESS the process suspends on an internal `@(posedge PCLK)`; resuming consumes the next posedge and misses one branch evaluation. Measured effect: the SETUP evaluation right after a transfer is delayed one cycle, seen on the master side as extra latency for that transfer; **zero-gap back-to-back transfers only work because of this lag** (this environment's driver always inserts 1 IDLE cycle to avoid relying on it).
5. **[Quirk] `wait_cyc_limit` is randomized only once at t=0** (`$urandom_range` in an initial block): the parameter name suggests a per-transfer random delay, but it is fixed for the whole run (0 or 1). The 3 wait-test iterations (seeds 1–3) drew 0 / 0 / 1 — both values' behaviors are covered.
6. **[Dead code] the IDLE/SETUP/ACCESS/WAIT state variables (L52-62) are declared but never used**; unrelated to the actual branching logic, misleading to readers.
7. **[Note] out-of-range reads keep PRDATA stale**: matches the common "failed reads do not update PRDATA" convention, but the spec does not define it; the scoreboard checks against the stale-value semantics and passes.

## 8. How to reproduce

```bash
# Windows host (the inbox system32 wsl shim lacks the kernel; use the full MSI-installed path)
"C:\Program Files\WSL\wsl.exe" -d Ubuntu-24.04 -- bash -c \
  'source ~/tools/oss-cad-suite/environment; export UVM_HOME=$HOME/tools/uvm-1.2; \
   cd /mnt/c/Users/wangling/pro_cc/projecd_id/sim && ./wsim_local -c apb_master_smoke_block_test -seed 1 -covrpt'
# Artifacts: sim/uvm_scratch_local_<case>/comp_<case>/run_iterN/{sim.log,wave.fst,coverage.dat}
# Code-coverage annotations: .../cov_report/; result summary: <scratch>/result.txt
```

After script changes, redeploy first with `bash verify/script/file_manage.sh` (`script/` is the source).

## 9. Limitations and follow-up

- Verilator does not collect functional coverage: the `apb_master_coverage` covergroups must be converged on the VCS flow (`./wsim -m apb_master -fm`); covergroup bins were pre-populated per the FP decomposition.
- Zero-gap back-to-back transfers were not stimulated (they would work under the DUT phase-lag behavior but without margin) — covered by analysis; if the design side fixes the phase lag, add a b2b directed case.
- Protocol checks are procedural in the monitor (Verilator does not support SVA concurrent assertions); concurrent assertions in `apb_master_if_pc.sv` can be added on the VCS flow.
- The system-level flow (tb_top_soc/uvm.f) currently has no DUT/clock (out of scope for this round); the system-level part of the jls→apb_master migration awaits later integration verification.
- In DUT code coverage, the `reset_ram` reset branch and the IDLE branch are covered by FP1/FP6; the 4-cycle split branch of `wr_data2mem` (default-parameter path) is a known defect path and was not stimulated (§7.1).
