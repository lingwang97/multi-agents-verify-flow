# Test Case Development Manual

## 1. Purpose & audience

This is a task-oriented guide for engineers writing a new test case in this `verify` UVM environment. It is **not** a UVM tutorial — it assumes you know UVM basics and want to know specifically what to do *in this repo*. For the overall architecture (naming conventions, `wsim` flow), read `CLAUDE.md` at the root of this tree first (filelist layering: `.claude/rules/filelists.md`); this manual only repeats what's needed inline. It is written for any module of the chip (`<mod>` below): which modules exist and how far each is customised is project state, kept in `docs/memory/arch_memory.md` §0 (open gaps: §9) and `docs/modules/<mod>.md`.

**Automating §3/§4:** this manual lives inside the `add-test-case` skill (`.claude/skills/add-test-case/`, next to `SKILL.md` and `add_test_case.py`) because the skill scaffolds the mechanical parts of §3 and §4 (the `test/`/`seq/` classes and the JSON entry) in one step, following the naming and inheritance rules below. Run `python3 .claude/skills/add-test-case/add_test_case.py --help` — you still fill in real stimulus (§3.4-3.6) by hand. Paths are relative to the verify root (`verify/`) unless stated otherwise.

## 2. The starting state: what a generated module looks like

`gen_uvm_env.py --guvc` generates every module's UVC from the same template (`script/gen_uvc.py`). Until someone customises it, a module is **template output**:

- **Interface** (`uvc/<mod>/src/<mod>_if.sv`) declares only `rst`, `clk`, `card_sel` and a generic `<mod>_ctrl[31:0]` bus; the `//add common interface signal here` comment is the extension point for real protocol signals.
- **Driver** only drives `card_sel` (`// begin your drv logic here.` marks where real driving goes) — nothing else on the interface is driven.
- **Scoreboard** checks nothing: `main_phase` prints a banner and waits, the monitor's write method just logs the received transaction.
- **Coverage** has two generic single-bin covergroups on the ctrl signal — no protocol-state bins, no crosses.
- **`seq/comm_<mod>_methods.sv`** (reusable per-module helper tasks, `` `include ``-d into `base_seq`'s class body — `CLAUDE.md` Architecture, "Test/sequence base") is an empty placeholder.
- **Tests and sequences**: `test/<mod>_test.sv` holds `<mod>_base_test` plus an inert `<mod>_smoke_test`; `seq/<mod>_seq.sv` holds `<mod>_base_seq` plus an empty `<mod>_smoke_seq`. A module generated with `has_tb_top: true` also gets the block-level pair `test/<mod>_block_base_test.sv` / `seq/<mod>_block_base_seq.sv` (with an inert `<mod>_smoke_block_test`), `tb_top/tb_top/tb_top_<mod>.sv` and `tb_top/filelist/uvm_blk_<mod>.f`.
- **JSON** (`json/case/<mod>.json`) starts with placeholder entries (`<mod>_smoke_test`, `<mod>_smoke_block_test`, `<mod>_random1_test`, `<mod>_random2_test`) using fake tokens (`+DEFINE1+DEFINE2+DEFINE3=100`, `+PLUSARGS1…`); most of their `UVM_TESTNAME`s have no class.

**Writing a test for a template module means filling in real content at every layer**, not just adding a JSON entry to something that already works end-to-end.

**Customising a UVC** - what a finished module typically has (patterns that worked in practice):

- **Interface**: the real protocol signals, plus the generated `checks_enable` / `coverage_enable` hooks.
- **Driver**: a small FSM per transfer; drive on the edge opposite to the DUT's sampling edge when the DUT uses blocking assignments, insert the idle cycles the protocol requires, and return a response (`item_done(rsp)`) when sequences need read data.
- **Monitor**: reconstructs complete transfers from the pins, forwards them to the scoreboard/coverage, and holds the oEDA-side procedural protocol checks (`` `ifdef OPEN_EDA ``) mirroring the SVA in `*_if_pc.sv`.
- **Scoreboard**: a real model of the expected behaviour (e.g. a shadow memory for a storage DUT), derived from the spec - never from the RTL.
- **Coverage**: bins on protocol state and data classes (boundaries, errors, wait states), crosses where they matter.
- **Sequences**: reusable helpers (`<mod>_write/<mod>_read/<mod>_idle`-style) in the block base seq or `comm_<mod>_methods.sv`; helpers that need read data call `get_response`.
- **JSON**: one entry per scenario with only the macros the case needs.

Record the module's DUT facts, quirks and case macros in `docs/modules/<mod>.md`.

## 3. Step-by-step: writing a new leaf test class

### 3.1 Decide block-level vs. system-level

- **System-level** (full chip): extend the generated `<mod>_base_test` / `<mod>_base_seq`.
- **Block-level** (single IP): the case's `VCS_MACRO_OPT` carries `+<MOD>_BLOCK_TEST`, which selects `tb_top/filelist/uvm_blk_<mod>.f` (both flows derive it from the define — `CLAUDE.md` "Block-level flow"). Extra compile defines for one case are appended: `+<MOD>_BLOCK_TEST+<EXTRA_DEFINE>`. Block level needs the module's block base pair (§2); which modules have it: arch_memory §0.

### 3.2 Pick a base to extend

**System-level:**
```systemverilog
// test/<mod>_test.sv
class <mod>_<function>_test extends <mod>_base_test;
  `uvm_component_utils(<mod>_<function>_test)
  function new(string name = "<mod>_<function>_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  task main_phase(uvm_phase phase);
    <mod>_<function>_seq seq;
    super.main_phase(phase);
    phase.raise_objection(this);
    seq = <mod>_<function>_seq::type_id::create("seq");
    seq.start(vseqr_h.<mod>_seqr_h);   // see §3.3 for the targets
    phase.drop_objection(this);
  endtask
endclass
```
```systemverilog
// seq/<mod>_seq.sv
class <mod>_<function>_seq extends <mod>_base_seq;
  `uvm_object_utils(<mod>_<function>_seq)
  function new(string name="<mod>_<function>_seq"); super.new(name); endfunction
  task body();
    super.body();
    // real stimulus goes here — see §3.4/§3.5
  endtask
endclass
```

**Block-level:** extend `<mod>_block_base_test` / `<mod>_block_base_seq` the same way and start on `<mod>_env_h.vseqr_h`. A module generated with `enable_ral: true` gets RAL wiring in its block base (shape below); with `enable_ral: false` the block base has no RAL.

```systemverilog
// test/<mod>_block_base_test.sv - build_phase
ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);
ral.configure(null, "");
ral.build();
ral.set_coverage(UVM_CVR_ALL);
ral.lock_model();
ral.reset();
ral.set_hdl_path_root("tb_top"); //need to be updated
uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(), "*", "ral", ral);
// connect_phase
ral.default_map.set_sequencer(<mod>_env_h.vseqr_h, <mod>_adapter_h);
ral.default_map.set_auto_predict(1);
```

The generated `reg2<bus>` adapter is a stub (bare field copy): write the real bus conversion before trusting a RAL access, and prove the path with one real `ral.<reg>.write()/read()`. Whether a module's adapter and RAL path are validated: arch_memory §9.

### 3.3 Start a sequence on the (virtual) sequencer

`top_virtual_sequencer` (`env/top_vseqr.sv`) exposes a `ral` handle plus one sub-sequencer per module (`<mod>_sequencer <mod>_seqr_h;`). Start a **chip-wide** sequence with `seq.start(vseqr_h)`; a sequence that drives one module's UVC with `seq.start(vseqr_h.<mod>_seqr_h)`. Block-level tests start on the module env's own sequencer, `<mod>_env_h.vseqr_h`.

### 3.4 Drive registers via RAL, once the model exists

`utils/reg/uvm_reg_macros.sv` defines shorthand macros for register access, e.g.:
```systemverilog
`define WR_REG(module,reg,value)  ral.``module``.reg_``reg``.wr(value)
`define RD_REG(module,reg,value)  ral.``module``.reg_``reg``.rd(value)
```
These assume every register handle is named `reg_<regname>` under a block named `<module>` — **this naming assumption is unconfirmed** against what `utils/reg/gen_reg_model.py` generates. The RAL model is generated at runtime (`ral/ral_reg_model.sv`, top class `ral_gen_main`) from the register-table CSV at `$WSIM_REG_TABLE`. Confirm the generated names before relying on the macros; plain `ral.<block>.<reg>.write(status, data, .parent(this));` calls always work. A module without registers (`enable_ral: false`) does not use RAL at all.

### 3.5 Fill in per-module helpers

Put reusable tasks (register read/write wrappers, wait-for-signal helpers, etc.) in `seq/comm_<mod>_methods.sv`. It is `` `include ``-d inside `base_seq`'s class body, so anything defined there becomes a member task of `base_seq` and every `<mod>_base_seq` subclass — no import needed. Block-level helpers can live in the module's block base seq instead; a helper that waits for the driver's response must call `get_response` when the driver does `item_done(rsp)`.

### 3.6 Wire the interface/driver/monitor/scoreboard/coverage for the real protocol

If your test exercises real protocol behaviour (not just register writes through RAL), add real signals. Follow `CLAUDE.md`'s UVC-pattern rule: a new interface signal is added in `*_if.sv`, sampled in the monitor and covered in `*_coverage.sv`. The scoreboard needs a real check replacing the generated stub (§2) before a passing run means anything (§5). Property checks are dual-tracked (SVA in `*_if_pc.sv` for VCS, procedural equivalents in the monitor/scoreboard for oEDA — `.claude/rules/oeda-verilator.md`).

## 4. Registering the test in JSON (not in SV)

Test cases are **not** enumerated in SV — they're JSON entries in `json/case/<mod>.json`, turned into a `.list` line by `tb_top/scripts/testjson2lst.py` (source `script/sflow/testjson2lst.py`).

### 4.1 Required fields

Every test entry must have exactly these 9 keys (`testStruct` in `testjson2lst.py`):

| Key | Meaning |
|---|---|
| `stage1` | `"true"`/`"false"` — included in a `-stage1` regression run |
| `stage2` | `"true"`/`"false"` — included in a `-stage2` regression run |
| `smoke` | `"true"`/`"false"` — included in a `-smoke` run |
| `full` | `"true"`/`"false"` — included in a `-full` run |
| `codecoverage` | `"true"` appends `cm=1` to the `.list` line |
| `iteration` | how many times the test repeats (with different random seeds) |
| `UVM_TESTNAME` | the actual `+UVM_TESTNAME=` — **must match a real class name** |
| `VCS_MACRO_OPT` | compile-time `+define+`s specific to this test |
| `VCS_PLUSARGS_OPT` | runtime `+plusargs` — `""` is valid, but the **key must be present** (read unconditionally; a missing key raises `KeyError`) |

Only the literal string `"true"` counts for the regression groups. Running a single case by name (`wsim -c <key>`) bypasses this filter.

### 4.2 JSON key vs. `UVM_TESTNAME` — these can differ

The dict **key** (e.g. `"<mod>_random1_test"`) is the label you pass to `wsim -c <key>`; the `UVM_TESTNAME` **value** is the class actually run. Two keys can point at the same class with different `iteration` / `VCS_MACRO_OPT` — that is how one test class gets several regression entries with different knobs.

### 4.3 Don't copy the placeholders

The generated entries (§2) use fake tokens and point at classes that may not exist. When you add a real test, use only the macros/plusargs the case really needs, and make sure `UVM_TESTNAME` matches the class you wrote in §3.

## 5. Running and debugging

From the repo-root `sim/` (full option lists: `CLAUDE.md` Commands and oEDA sections):

```bash
./wsim_oeda -c <key> -seed 1 [-covrpt]    # local oEDA run (Verilator; no functional coverage)
./wsim -c <key>                           # VCS run
./wsim -c <key> -fsdb                     # + waveform (forces iteration=1)
./wsim -c <key> -seed 12345               # fixed seed for debugging a failure
./wsim -m <mod>                           # all tests of a module
./wsim -smoke | -stage1 | -stage2 | -full # regression groups
```

Pass/fail is decided by grepping `UVM_ERROR`/`UVM_FATAL` counts in `sim.log`; results roll up into `result.txt`, and a rerun command for a VCS failure lands in `fail_wave.txt`.

**Caveat**: on a template module (§2) the scoreboard compares nothing, so zero `UVM_ERROR`/`UVM_FATAL` does **not** mean the test verified anything. Don't call a test done until its scoreboard (§3.6) has a real check.

## 6. Definition of done for a leaf test

Before calling a new test case finished, confirm:

- [ ] Any new protocol signals are added to `*_if.sv`, sampled in the monitor, and covered in `*_coverage.sv`.
- [ ] The driver drives real protocol behaviour, not just `card_sel`.
- [ ] The scoreboard has a real check (not the generated stub).
- [ ] Coverage has meaningful bins/crosses beyond the generic single-range bin.
- [ ] The sequence calls `.start()` on the correct (virtual) sequencer (§3.3).
- [ ] The JSON entry uses real macros/plusargs (not the placeholder tokens) and `UVM_TESTNAME` matches an actual class.
- [ ] The case runs with zero `UVM_ERROR`/`UVM_FATAL` **and** you've confirmed the scoreboard actually exercised the intended behaviour.
