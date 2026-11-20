# Test Case Development Manual

## 1. Purpose & audience

This is a task-oriented guide for engineers writing a new test case in the `verify` UVM environment for the `soc` project. It is **not** a UVM tutorial — it assumes you know UVM basics and want to know specifically what to do *in this repo*. For the overall architecture (filelist layering, naming conventions, `wsim` flow), read `CLAUDE.md` at the root of this tree first; this manual only repeats what's needed inline.

**Automating §3/§4:** this manual lives inside the `add-test-case` skill (`.claude/skills/add-test-case/`, next to `SKILL.md` and `add_test_case.py`) because the skill scaffolds the mechanical parts of §3 and §4 (the `test/`/`seq/` classes and the JSON entry) in one step, following the exact naming and inheritance rules below. Run `python3 .claude/skills/add-test-case/add_test_case.py --help` — you'll still need to fill in real stimulus (§3.4-3.6) by hand. Paths in this manual are relative to the verify root (`verify/`) unless stated otherwise. When a module is added or removed, keep this manual in sync with the skill (see `docs/memory/arch_memory.md` R1/R2).

## 2. The starting state: what "generated scaffold" actually means here

Before you start, understand exactly where this repo currently stands. Four of the five UVCs (`reg`, `ro`, `uart`, `efuse`) are still **unmodified `gen_uvc.py` template output**; the fifth, **`apb_master`** (UVC for the `apb_v3_sram` DUT, replaced the former `jls`), is fully customised and is the worked reference — see the end of this section. For the four template UVCs the following holds:

- **Interfaces** (`uvc/<mod>/src/<mod>_if.sv`) only declare `rst`, `clk`, `card_sel`, and a generic `<mod>_ctrl[31:0]` bus. E.g. `uvc/efuse/src/efuse_if.sv:10-13`. Line 20, `//add common interface signal here`, is the extension point for real protocol signals.
- **Drivers** only drive `card_sel`. E.g. `uvc/efuse/src/efuse_driver.sv:41` literally says `// begin your drv logic here.`, and lines 43-44 only do `@(posedge vif.clk); vif.card_sel <= req.card_sel;` — nothing else on the interface is ever driven.
- **Scoreboards** don't check anything. E.g. `uvc/efuse/src/efuse_scoreboard.sv:28-32` — `main_phase` prints a banner and waits `#1000ns`; `write_main_efuse_monitor` (lines 34-36) just logs the received transaction via `uvm_info`, no comparison against an expected value.
- **Coverage** has only two generic single-bin covergroups per module (`cg_<mod>_ctrl`, `cg_<mod>_ctrl_by_if`), each a full-range `[0:31]` bin on the generic ctrl signal — no protocol-state bins, no cross coverage.
- **`comm_<mod>_methods.sv`** (meant to hold reusable per-module helper tasks, `` `include``-d directly into `base_seq`'s class body — see `CLAUDE.md` line 58) are **completely empty** in all five modules. E.g. `seq/comm_efuse_methods.sv` is 6 lines, all comments.
- **Leaf test/sequence classes don't exist.** `test/<mod>_test.sv` only defines `<mod>_base_test` (e.g. `test/efuse_test.sv:4-26`) whose `build_phase`/`main_phase` just call `super.*()`. `seq/<mod>_seq.sv` only defines `<mod>_base_seq` (e.g. `seq/efuse_seq.sv:7-35`) whose `body()` is empty aside from a `// build your common cfg or init operation here` comment. There is no `<mod>_smoke_test`, no `<mod>_random_test`, etc. anywhere in `test/`.
- This pattern is identical across reg/ro/uart/efuse.

**The finished worked example is `apb_master`** (block level, DUT `hdl/rtl/apb_v3_sram.v`): a real interface (`apb_master_if.sv` with the APB3 signals), a negedge FSM driver, a monitor that reconstructs transfers and runs procedural protocol checks, a shadow-memory scoreboard, real coverage bins, sequence helpers `apb_write/apb_read/apb_idle` in `seq/apb_master_block_base_seq.sv`, six leaf tests (`apb_master_{smoke,reset,rw_rand,error,boundary,wait}_block_test`) and real JSON entries; results were reported in the 2026-09-28 campaign report (removed from the tree, in git history). Copy its structure when customising another UVC.

**The other partially-real pattern** is `test/efuse_block_base_test.sv` + `seq/efuse_block_base_seq.sv` — a standalone pair (not derived from `base_test`/`base_seq`) for block-level (single-IP) testing that shows genuine RAL wiring (apb_master's block base follows the same pair shape). Neither has exercised a real register read/write — see §3.2 and §7 gap #8.

Given all this, **writing a new test case here means filling in real content at every layer**, not just adding a JSON entry to something that already works end-to-end. Section 7 lists the specific blockers you're likely to hit first.

## 3. Step-by-step: writing a new leaf test class

### 3.1 Decide block-level vs. system-level

- **System-level** (full-chip): extend the generated `<mod>_base_test` / `<mod>_base_seq`.
- **Block-level** (single IP): use the `+define+<MOD>_BLOCK_TEST` macro (see `CLAUDE.md` Conventions) which selects the `uvm_blk_<mod>.f` filelist (the VCS Makefile and `wsim_oeda` both derive it from the define, no per-module branch). `json/case/apb_master.json` shows the real convention: `"VCS_MACRO_OPT":"+APB_MASTER_BLOCK_TEST"`, plus extra defines appended when a case needs a different compile (`+APB_MASTER_BLOCK_TEST+APB_SRAM_EN_WAIT`). Block-level support exists for `efuse` and `apb_master` only.

### 3.2 Pick a base to extend

**System-level:**
```systemverilog
// test/<mod>_test.sv
class <mod>_smoke_test extends <mod>_base_test;
  `uvm_component_utils(<mod>_smoke_test)
  function new(string name = "<mod>_smoke_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  task main_phase(uvm_phase phase);
    <mod>_smoke_seq seq;
    super.main_phase(phase);
    phase.raise_objection(this);
    seq = <mod>_smoke_seq::type_id::create("seq");
    seq.start(vseqr_h);          // see §3.3 for what vseqr_h can target
    phase.drop_objection(this);
  endtask
endclass
```
```systemverilog
// seq/<mod>_seq.sv
class <mod>_smoke_seq extends <mod>_base_seq;
  `uvm_object_utils(<mod>_smoke_seq)
  function new(string name="<mod>_smoke_seq"); super.new(name); endfunction
  task body();
    super.body();
    // real stimulus goes here — see §3.4/§3.5
  endtask
endclass
```

**Block-level (single IP)** — `efuse` and `apb_master` have this pair; for reg/ro/uart you'd author an analogous `<mod>_block_base_test`/`<mod>_block_base_seq` by copying `apb_master_block_base_test.sv`/`apb_master_block_base_seq.sv` (or efuse's) and adjusting module names, then add `tb_top/filelist/uvm_blk_<mod>.f` and a `tb_top/tb_top/tb_top_<mod>.sv` (the Makefile and `wsim_oeda` pick the filelist up from the `<MOD>_BLOCK_TEST` define automatically). The RAL wiring in the existing pairs, quoted from the efuse version:

```systemverilog
// test/efuse_block_base_test.sv:72-81 (build_phase)
ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);
ral.configure(null, "");
ral.build();
ral.set_coverage(UVM_CVR_ALL);
ral.lock_model();
ral.reset();
ral.set_hdl_path_root("tb_top"); //need to be updated
uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(), "*", "ral", ral);
```
```systemverilog
// test/efuse_block_base_test.sv:86-92 (connect_phase)
ral.default_map.set_sequencer(efuse_env_h.vseqr_h, efuse_adapter_h);
ral.default_map.set_auto_predict(1);
```

**Flag before you rely on this**: this wiring is plumbed but has never actually been exercised by a real `ral.<reg>.write()/read()` call anywhere in the repo (see §7 gap #8) — treat it as an unproven starting point, not a validated reference.

### 3.3 Start a sequence on the (virtual) sequencer

Real, uncommented block-level `.start()` calls: `seq.start(apb_master_env_h.vseqr_h)` in every `apb_master_*_block_test` (`test/apb_master_block_base_test.sv`) and the efuse smoke block test. System-level calls go on `vseqr_h` (the generated `base_test` also carries a commented-out template inside `configure_phase`).

`top_virtual_sequencer` (`env/top_vseqr.sv`) exposes a `ral` handle plus one sub-sequencer per module:
```systemverilog
reg_sequencer        reg_seqr_h;
apb_master_sequencer apb_master_seqr_h;
ro_sequencer         ro_seqr_h;
uart_sequencer       uart_seqr_h;
efuse_sequencer      efuse_seqr_h;
```
Start a **chip-wide** sequence with `seq.start(vseqr_h)`; start a sequence that only needs to drive one module's UVC with `seq.start(vseqr_h.<mod>_seqr_h)` (e.g. `vseqr_h.apb_master_seqr_h`).

### 3.4 Drive registers via RAL, once the model exists

`utils/reg/uvm_reg_macros.sv:15-25` defines shorthand macros for register access, e.g.:
```systemverilog
`define WR_REG(module,reg,value)  ral.``module``.reg_``reg``.wr(value)
`define RD_REG(module,reg,value)  ral.``module``.reg_``reg``.rd(value)
```
These assume every register handle is named literally `reg_<regname>` under a block named `<module>` — **this naming assumption is unconfirmed** against what `utils/reg/gen_reg_model.py` actually generates: the RAL model is now generated at runtime (`ral/ral_reg_model.sv`, top class `ral_gen_main` with a single `soc_reg` block of the placeholder CSV), and no sequence calls these macros yet (see §7 gap #3). Confirm the real generated names before relying on them; you may need plain `ral.<block>.<reg>.write(status, data, .parent(this));` calls instead. Note the `apb_master` block tests do not use RAL at all (the DUT has no registers).

### 3.5 Fill in per-module helpers

Put reusable tasks (register read/write wrappers, wait-for-signal helpers, etc.) in `seq/comm_<mod>_methods.sv`. Because this file is `` `include``-d directly inside `base_seq`'s class body (`CLAUDE.md` line 58), anything you define there becomes a callable member task of `base_seq` and every `<mod>_base_seq` subclass — no separate import needed. Today the `comm_<mod>_methods.sv` files are empty placeholders; `apb_master` keeps its reusable helpers (`apb_write/apb_read/apb_idle`) directly in `seq/apb_master_block_base_seq.sv` instead.

### 3.6 Wire the interface/driver/monitor/scoreboard/coverage for the real protocol

If your test needs to exercise real protocol behavior (not just register writes through RAL), you'll need to add real signals. Follow `CLAUDE.md`'s rule (line 54): a new interface signal must be added in `*_if.sv`, sampled in the monitor, and covered in `*_coverage.sv`. The scoreboard needs a real check replacing the banner/`#1000ns` stub (§2) before a passing run means anything (see §6's caveat).

## 4. Registering the test in JSON (not in SV)

Test cases are **not** enumerated in SV — they're JSON entries in `json/case/<module>.json`, turned into a `.list` line by `tb_top/scripts/testjson2lst.py` (source `script/sflow/testjson2lst.py`).

### 4.1 Required fields

Every test entry must have exactly these 9 keys (per `testStruct` in `testjson2lst.py:37-47`):

| Key | Meaning |
|---|---|
| `stage1` | `"true"`/`"false"` — included in a `-stage1` regression run |
| `stage2` | `"true"`/`"false"` — included in a `-stage2` regression run |
| `smoke` | `"true"`/`"false"` — included in a `-smoke` run |
| `full` | `"true"`/`"false"` — included in a `-full` run |
| `codecoverage` | `"true"` appends `cm=1` to the `.list` line |
| `iteration` | how many times the test repeats (with different random seeds) |
| `UVM_TESTNAME` | the actual `+UVM_TESTNAME=` passed to VCS — **must match a real class name** |
| `VCS_MACRO_OPT` | compile-time `+define+`s specific to this test |
| `VCS_PLUSARGS_OPT` | runtime `+plusargs` — `""` is valid, but the **key must be present** (its value is read unconditionally by `testjson2lst.py:198/226`; a missing key raises `KeyError`) |

Only literal string `"true"` counts — `"stage1":"true"` is required for a test to appear in a `-stage1` run (`testjson2lst.py:155`: `if not (tests[key][regression_type] == "true"): continue`). Running a single case by name (`wsim -c <name>`) bypasses this filter entirely and always works regardless of the stage flags.

### 4.2 JSON key vs. `UVM_TESTNAME` — these can differ

The dict **key** (e.g. `"efuse_random1_test"`) is the label you pass to `wsim -c <key>`; the `UVM_TESTNAME` **value** is what's actually instantiated by VCS. `json/case/efuse.json:30-52` shows this concretely: `efuse_random1_test` and `efuse_random2_test` are two different JSON keys, both with `"UVM_TESTNAME":"efuse_random_test"`, differing only in `iteration` (6 vs. 10) and `VCS_MACRO_OPT` — i.e. this is how you register multiple regression entries against one test class with different knobs.

### 4.3 What's already in the JSON today — don't copy the placeholders

`reg`, `ro`, `uart` and `efuse` still carry 4 copy-pasted placeholder entries each (`<mod>_smoke_test`, `<mod>_smoke_block_test`, `<mod>_random1_test`, `<mod>_random2_test`) using fake tokens (`+DEFINE1+DEFINE2+DEFINE3=100`, `+PLUSARGS1+PLUSARG2`, `+DEFINE4`); most of their `UVM_TESTNAME` values have no class in `test/`. `apb_master.json` is the cleaned reference: real `UVM_TESTNAME`s, empty `VCS_PLUSARGS_OPT`, and only the macros the case really needs. When you add a real test, don't copy the placeholder tokens, and make sure `UVM_TESTNAME` matches the class you wrote in §3.

## 5. Running and debugging

From `sim/` (see `CLAUDE.md`'s Commands section for the full option list):

```bash
./wsim -c <your_test_key> -uvm            # run your new case
./wsim -c <your_test_key> -uvm -fsdb      # + waveform (forces iteration=1)
./wsim -c <your_test_key> -seed 12345     # fixed seed for debugging a failure
./wsim -m <module>                        # run all tests for that module
./wsim -smoke | -stage1 | -stage2 | -full # regression groups
./wsim -gui                               # Verdi GUI
```

Pass/fail is decided by grepping `UVM_ERROR`/`UVM_FATAL` counts in `sim.log`; results roll up into `result.txt`, and a re-run command for any failure lands in `fail_wave.txt`.

**Important caveat**: apart from `apb_master`, no scoreboard in this repo has a real check yet (§2), so for `reg`/`ro`/`uart`/`efuse` a clean `UVM_ERROR`/`UVM_FATAL` count of zero does **not** mean your test verified anything — it may simply mean nothing was ever compared. Don't treat a passing run as "done" until your scoreboard (§3.6) has a real assertion in it.

`wsim` only runs on Linux with VCS/Verdi/LSF. On the Windows box use the open-source flow instead (WSL2 + Verilator, see `CLAUDE.md` "Local open-source sim"): from the repo-root `sim/`, `./wsim_oeda -c <your_test_key> -seed 1 [-covrpt]` (single case; invoke WSL by full path from Windows, see `docs/ops/oeda_local_setup.md`). It does not collect covergroup functional coverage.

## 6. Definition of done for a leaf test

Before calling a new test case finished, confirm:

- [ ] Any new protocol signals are added to `*_if.sv`, sampled in the monitor, and covered in `*_coverage.sv`.
- [ ] The driver drives real protocol behavior, not just `card_sel`.
- [ ] The scoreboard has a real check (not the generated banner/`#1000ns` stub).
- [ ] Coverage has meaningful bins/crosses beyond the generic single-range bin.
- [ ] The sequence calls `.start()` on the correct (virtual) sequencer (§3.3).
- [ ] The JSON entry uses real macros/plusargs (not the placeholder tokens) and `UVM_TESTNAME` matches an actual class.
- [ ] `wsim -c <key> -uvm` produces zero `UVM_ERROR`/`UVM_FATAL` **and** you've confirmed the scoreboard actually exercised the intended behavior (not just a clean log by default).

## 7. Known gaps to fix first

These are current, confirmed blockers/bugs in this checkout — check this list before you get surprised mid-development.

| # | Gap | Where | Impact | Done looks like |
|---|---|---|---|---|
| 1 | ~~RAL model not generated yet~~ Resolved | `verify/ral/ral_reg_model.sv` is now generated by `wsim`/`wsim_oeda`'s `RalGen` step from `hdl/common/reg_table/reg_table_reg_list.csv` (a placeholder CSV with one `soc_reg` block) | — | Done — replace the placeholder CSV with the real reg table when the SoC database lands |
| 2 | ~~Include filename mismatch~~ Resolved | `utils/reg/reg_mdl_pkg.sv` now includes `uvm_reg_macros.sv`, which exists in `utils/reg/` | — | Done |
| 3 | `reg_<name>` handle-naming assumption unconfirmed | `utils/reg/uvm_reg_macros.sv:15-25` assumes register handles are named `reg_<regname>`; no sequence uses the macros yet, and the generated model is `ral_gen_main` → `soc_reg` block | The `` `WR_REG``/`` `RD_REG`` etc. macros may not match what `gen_reg_model.py` actually emits | Confirmed (or generator/macros adjusted) by one real register access |
| 4 | Adapters incomplete/unvalidated | `apb_master`, `uart`, `efuse` have a `reg2<bus>_adapter.sv`; `reg` and `ro` have none. All existing ones are generic stubs doing a bare `we`/`addr`/`data` copy (`uvc/efuse/src/efuse_reg2apb_adapter.sv`: "Please complete the conversion logic of the bus..."; apb_master has none because the DUT has no registers (`enable_ral: false`, `adapter_type: ""` in `script/uvm_env_config_template.json`) | RAL front-door access through any UVC isn't validated against real bus timing | `reg`/`ro` adapters written; adapters validated against real protocol semantics |
| 5 | `comm_<mod>_methods.sv` empty | All are placeholder comments only (apb_master keeps helpers in `apb_master_block_base_seq.sv`) | No reusable per-module sequence helpers in the `comm_*` files | Populated as real tests are written |
| 6 | Most `UVM_TESTNAME` values still have no leaf class | Only the `apb_master` entries have real leaf classes (6 block tests + the system smoke test); `ro_smoke_test` and `efuse_smoke_block_test` exist but are inert; the other placeholder entries (`<mod>_random_test`, etc.) have no class | Still the core work this manual exists to guide for `reg`/`ro`/`uart`/`efuse` | Leaf classes written per §3 (or via the skill), JSON updated per §4 |
| 7 | ~~No real `.start()` call exists anywhere~~ Resolved | All `apb_master_*_block_test` classes call `seq.start(apb_master_env_h.vseqr_h)` for real | — | Done — the reference examples §3.3 points at |
| 8 | `efuse_block_base_test/_seq` RAL wiring never exercised | Build/connect phases create and wire `ral`/adapter/sequencer, but no `ral.<reg>.write()/read()` call exists anywhere in the repo | Treat this pattern as "wiring example only," not proof the path works end-to-end | A real register access through this path succeeds |
| 9 | JSON case files are placeholder scaffolding (except apb_master) | `reg`/`ro`/`uart`/`efuse` `json/case/*.json` use fake tokens (`DEFINE1/2/3=100`, `PLUSARGS1/PLUSARG2`, `DEFINE4`) | Copying these tokens into a new entry propagates meaningless macros | Real, module-specific macros/plusargs in place per §4.3 |
| 10 | `uart` (and `reg`/`ro`) have no block-level support | No `tb_top/filelist/uvm_blk_<mod>.f`, no `<mod>_block_base_test/_seq`, (the flow scripts derive the filelist from `<MOD>_BLOCK_TEST`, so these are the only missing pieces) | Block-level testing only works for `efuse` and `apb_master` | Block-base files, `tb_top_<mod>.sv` and `uvm_blk_<mod>.f` authored (mirroring apb_master's) |
