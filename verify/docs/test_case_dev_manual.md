# Test Case Development Manual

## 1. Purpose & audience

This is a task-oriented guide for engineers writing a new test case in the `auto_gen/verify` UVM environment for the `soc` project. It is **not** a UVM tutorial — it assumes you know UVM basics and want to know specifically what to do *in this repo*. For the overall architecture (filelist layering, naming conventions, `wsim` flow), read `CLAUDE.md` at the root of this tree first; this manual only repeats what's needed inline.

**Automating §3/§4:** `.claude/skills/add-test-case/` scaffolds the mechanical parts of §3 and §4 (the `test/`/`seq/` classes and the JSON entry) in one step, following the exact naming and inheritance rules below. Run `python3 .claude/skills/add-test-case/add_test_case.py --help` — you'll still need to fill in real stimulus (§3.4-3.6) by hand.

## 2. The starting state: what "generated scaffold" actually means here

Before you start, understand exactly where this repo currently stands. Every one of the five UVCs (`reg`, `jls`, `ro`, `uart`, `efuse`) is still **unmodified `gen_uvc.py` template output** — no hand customization has been done anywhere yet. Concretely:

- **Interfaces** (`uvc/<mod>/src/<mod>_if.sv`) only declare `rst`, `clk`, `card_sel`, and a generic `<mod>_ctrl[31:0]` bus. E.g. `uvc/efuse/src/efuse_if.sv:10-13`. Line 20, `//add common interface signal here`, is the extension point for real protocol signals.
- **Drivers** only drive `card_sel`. E.g. `uvc/efuse/src/efuse_driver.sv:41` literally says `// begin your drv logic here.`, and lines 43-44 only do `@(posedge vif.clk); vif.card_sel <= req.card_sel;` — nothing else on the interface is ever driven.
- **Scoreboards** don't check anything. E.g. `uvc/efuse/src/efuse_scoreboard.sv:28-32` — `main_phase` prints a banner and waits `#1000ns`; `write_main_efuse_monitor` (lines 34-36) just logs the received transaction via `uvm_info`, no comparison against an expected value.
- **Coverage** has only two generic single-bin covergroups per module (`cg_<mod>_ctrl`, `cg_<mod>_ctrl_by_if`), each a full-range `[0:31]` bin on the generic ctrl signal — no protocol-state bins, no cross coverage.
- **`comm_<mod>_methods.sv`** (meant to hold reusable per-module helper tasks, `` `include``-d directly into `base_seq`'s class body — see `CLAUDE.md` line 58) are **completely empty** in all five modules. E.g. `seq/comm_efuse_methods.sv` is 6 lines, all comments.
- **Leaf test/sequence classes don't exist.** `test/<mod>_test.sv` only defines `<mod>_base_test` (e.g. `test/efuse_test.sv:4-26`) whose `build_phase`/`main_phase` just call `super.*()`. `seq/<mod>_seq.sv` only defines `<mod>_base_seq` (e.g. `seq/efuse_seq.sv:7-35`) whose `body()` is empty aside from a `// build your common cfg or init operation here` comment. There is no `<mod>_smoke_test`, no `<mod>_random_test`, etc. anywhere in `test/`.
- This pattern is identical across reg/jls/ro/uart/efuse — nothing stands out as a finished worked example among the five UVCs themselves.

**The one partially-real pattern in the repo** is `test/efuse_block_base_test.sv` + `seq/efuse_block_base_seq.sv` — a standalone pair (not derived from `base_test`/`base_seq`) for block-level (single-IP) testing that shows genuine RAL wiring. Even this has never actually exercised a register read/write — see §3.2 and §7 gap #8.

Given all this, **writing a new test case here means filling in real content at every layer**, not just adding a JSON entry to something that already works end-to-end. Section 7 lists the specific blockers you're likely to hit first.

## 3. Step-by-step: writing a new leaf test class

### 3.1 Decide block-level vs. system-level

- **System-level** (full-chip): extend the generated `<mod>_base_test` / `<mod>_base_seq`.
- **Block-level** (single IP, register-driven): use the `+define+<MOD>_BLOCK_TEST` macro (per `CLAUDE.md` line 69) which selects the `uvm_blk_*.f` filelists and different register-init config in the Makefile. `json/case/efuse.json`'s `efuse_smoke_block_test` entry shows the concrete convention: `"VCS_MACRO_OPT":"+EFUSE_BLOCK_TEST+DEFINE1+DEFINE2+DEFINE3=100"`.

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

**Block-level (RAL-driven, single IP)** — currently only `efuse` has this pair; for reg/jls/ro/uart you'd author an analogous `<mod>_block_base_test`/`<mod>_block_base_seq` by copying `efuse_block_base_test.sv`/`efuse_block_base_seq.sv` and adjusting module names. The pattern to follow, quoted from the existing efuse version:

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

The **only** place in the codebase showing the call shape is a commented-out template in the generated `base_test`:
```systemverilog
// test/base_test.sv, inside configure_phase (~line 198-204)
//init_normal_seq init_seq;
phase.raise_objection(this);
//init_seq = init_normal_seq::type_id::create("init_seq");
//init_seq.start(vseqr_h);
phase.drop_objection(this);
```
No real, uncommented `.start()` call exists anywhere in `test/` or `seq/` today — you'll be the first.

`top_virtual_sequencer` (`env/top_vseqr.sv:4-24`) exposes a `ral` handle plus one sub-sequencer per module:
```systemverilog
reg_sequencer   reg_seqr_h;
jls_sequencer   jls_seqr_h;
ro_sequencer    ro_seqr_h;
uart_sequencer  uart_seqr_h;
efuse_sequencer efuse_seqr_h;
```
Start a **chip-wide** sequence with `seq.start(vseqr_h)`; start a sequence that only needs to drive one module's UVC with `seq.start(vseqr_h.<mod>_seqr_h)` (e.g. `vseqr_h.efuse_seqr_h`).

### 3.4 Drive registers via RAL, once the model exists

`utils/reg/uvm_reg_macro.sv:15-25` defines shorthand macros for register access, e.g.:
```systemverilog
`define WR_REG(module,reg,value)  ral.``module``.reg_``reg``.wr(value)
`define RD_REG(module,reg,value)  ral.``module``.reg_``reg``.rd(value)
```
These assume every register handle is named literally `reg_<regname>` under a block named `<module>` — **this naming assumption is unconfirmed** against what `utils/reg/gen_reg_model.py` actually generates, since no RAL model exists in this checkout yet (see §7 gaps #1-3). Confirm the real generated names before relying on these macros; you may need plain `ral.<block>.<reg>.write(status, data, .parent(this));` calls instead.

### 3.5 Fill in per-module helpers

Put reusable tasks (register read/write wrappers, wait-for-signal helpers, etc.) in `seq/comm_<mod>_methods.sv`. Because this file is `` `include``-d directly inside `base_seq`'s class body (`CLAUDE.md` line 58), anything you define there becomes a callable member task of `base_seq` and every `<mod>_base_seq` subclass — no separate import needed. Today all five of these files (plus an apparently-unused `seq/comm_cpft_methods.sv`) are empty placeholders.

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

Every one of the 5 modules' `json/case/<module>.json` currently has 4 entries following an identical, copy-pasted placeholder pattern (`<mod>_smoke_test`, `<mod>_smoke_block_test`, `<mod>_random1_test`, `<mod>_random2_test`), all using the same fake tokens: `+DEFINE1+DEFINE2+DEFINE3=100`, `+PLUSARGS1+PLUSARG2`, `+DEFINE4`. **None of the 15 `UVM_TESTNAME` values across all 5 files correspond to a class that exists in `test/` yet.** When you add a real test, replace the placeholder tokens with your real macros/plusargs, and make sure `UVM_TESTNAME` matches the class you wrote in §3.

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

**Important caveat**: because no scoreboard in this repo has a real check yet (§2), a clean `UVM_ERROR`/`UVM_FATAL` count of zero does **not** mean your test verified anything — it may simply mean nothing was ever compared. Don't treat a passing `wsim` run as "done" until your scoreboard (§3.6) has a real assertion in it.

This only runs on Linux with VCS/Verdi/LSF — not on a Windows dev box.

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
| 1 | RAL model not generated yet | `verify/ral/ral_reg_model.sv` and its source `hdl/common/reg_table/reg_table_reg_list.csv` don't exist in this checkout | Any code referencing `RAL_PKG::ral_gen_main` (including `efuse_block_base_test.sv:11,73`) won't compile until `wsim`'s `RalGen` step runs `utils/reg/gen_reg_model.py` against a real CSV | The CSV exists and `wsim` has generated `ral/ral_reg_model.sv` at least once |
| 2 | Include filename mismatch | `utils/reg/reg_mdl_pkg.sv:10` does `` `include "uvm_reg_macros.svh"`` but the actual file on disk is `utils/reg/uvm_reg_macro.sv` (no trailing "s", `.sv` not `.svh`) | Compile failure the moment `reg_mdl_pkg` is compiled with this include active | Filename or include path fixed so it resolves |
| 3 | `reg_<name>` handle-naming assumption unconfirmed | `utils/reg/uvm_reg_macro.sv:15-25` assumes register handles are named `reg_<regname>` | The `` `WR_REG``/`` `RD_REG`` etc. macros may not match what `gen_reg_model.py` actually emits | Confirmed (or the generator/macros adjusted) against a real generated model |
| 4 | Adapters incomplete/unvalidated | Only `jls`, `uart`, `efuse` have a `reg2<bus>_adapter.sv`; `reg` and `ro` have none. All 3 existing ones are identical generic stubs (`uvc/efuse/src/efuse_reg2apb_adapter.sv:11,26`: "Please complete the conversion logic of the bus...") doing a bare `we`/`addr`/`data` copy | RAL front-door access through `reg`/`ro` isn't possible yet; the 3 existing adapters are unvalidated against real bus timing | `reg`/`ro` adapters written; all adapters validated against real protocol semantics |
| 5 | `comm_<mod>_methods.sv` empty | All 5 (plus an apparently-unused `seq/comm_cpft_methods.sv`) are placeholder comments only | No reusable per-module sequence helpers exist yet | Populated as real tests are written; delete `comm_cpft_methods.sv` if truly unused |
| 6 | Most `UVM_TESTNAME` values still have no leaf class | Of the 15+ entries across `json/case/*.json`, only `ro_toggle_check_test` (system) and `efuse_burn_and_read_test` (block) currently have a matching class (generated via `.claude/skills/add-test-case/` as this manual's first worked examples) — the rest (`<mod>_smoke_test`, `<mod>_random_test`, etc.) still don't | Still the core work this manual exists to guide, for everything except those two | Leaf classes written per §3 (or via the skill), JSON updated per §4 |
| 7 | ~~No real `.start()` call exists anywhere~~ Resolved | `ro_toggle_check_test`/`efuse_burn_and_read_test` (see #6) now call `.start()` for real — `seq.start(vseqr_h.ro_seqr_h)` and `seq.start(efuse_env_h.vseqr_h)` respectively | — | Done — these are now the reference examples §3.3 points at |
| 8 | `efuse_block_base_test/_seq` RAL wiring never exercised | Build/connect phases create and wire `ral`/adapter/sequencer, but no `ral.<reg>.write()/read()` call exists anywhere in the repo | Treat this pattern as "wiring example only," not proof the path works end-to-end | A real register access through this path succeeds |
| 9 | JSON case files are placeholder scaffolding | All 5 modules' `json/case/*.json` use identical fake tokens (`DEFINE1/2/3=100`, `PLUSARGS1/PLUSARG2`, `DEFINE4`) across all 4 pre-existing entries each | Copying these tokens into a new entry propagates meaningless macros | Real, module-specific macros/plusargs in place per §4.3 |
| 10 | `jls`/`uart` block-level is wired halfway | `tb_top/filelist/uvm_blk_jls.f` and `uvm_blk_uart.f` already reference `seq/jls_block_base_seq.sv`/`test/jls_block_base_test.sv` and the `uart` equivalents — but those files don't exist (only `efuse`'s pair does), **and** `tb_top/scripts/Makefile`'s block-env filelist selection only special-cases `EFUSE_BLOCK_TEST` (no `JLS_BLOCK_TEST`/`UART_BLOCK_TEST` branch) | Block-level testing only works for `efuse` today; `reg`/`ro` have no block filelist at all | `jls`/`uart` block-base files authored (mirroring efuse's) and the Makefile's block-env branch extended to select their filelists |
