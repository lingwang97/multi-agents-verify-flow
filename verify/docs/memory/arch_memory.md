# arch_memory

Project state for this verify tree: the architecture/module table (in a chip project this section holds the chip's module table), the system bring-up checklist and the open development gaps. Read before structural changes and append project state here - not policy: framework rules live in the carried rule files (`.claude/rules/maintenance.md`, `two-flow.md` and the other canons of the ops §4 doc map) and history lives in the logs. Renumbering rule: `.claude/rules/maintenance.md` R6. Last updated 2026-11-27. Change history: `git log -- docs/memory/arch_memory.md` (framework changes: `docs/memory/fw_env_memory.md`).

**TOC**: §0 architecture state → §1 system bring-up checklist → §2 open development gaps.

---

## 0. Current architecture state

This repository is the **framework**: `script/uvm_env_config_template.json` lists no modules, and nothing generated (`uvc/ env/ test/ seq/ intf/ json/ tb_top/ utils/`, `sim/`) or chip-specific (`hdl/`, `docs/modules/`, module logs and feature lists) is committed. A chip project gets its modules through `/new-verification` (spec2json → json2env) after `bootstrap.sh` and `/new-project`; there this section holds the chip's module table.

- **Local test fixture** (framework development only, never committed): a five-module environment kept on disk and excluded through `.git/info/exclude` (pattern list there) - `apb_master` (fully customised UVC, DUT `hdl/rtl/apb_v3_sram.v`, `enable_ral: false`, block level), `efuse` (template, block level, RAL), `reg`/`ro`/`uart` (templates). Config: `verify/local/uvm_env_config.json`. Regenerate from `script/` with `python gen_uvm_env.py -c ../local/uvm_env_config.json --guvc`, deploy with `file_manage.sh`; the framework smoke is `./wsim_oeda -c apb_master_smoke_block_test -seed 1` (block cases of RAL modules also need a register-table CSV). A fresh clone has no fixture: restore it from tag `soc-pid003-snapshot` (`git checkout soc-pid003-snapshot -- verify/uvc verify/env verify/test verify/seq verify/intf verify/json verify/tb_top hdl`, then `git reset -q` on the same paths so they stay untracked; the old config is `git show soc-pid003-snapshot:verify/script/uvm_env_config_template.json`, with `project_name` set to the framework's), then regenerate.
- Module source of truth (in a project): `script/uvm_env_config_template.json` and `json/module.json`. Config-knob semantics and the generator-enforced rules are canonized in `verify/CLAUDE.md` ("Regenerating the environment"). RalGen gating is canonized in `.claude/rules/ral.md`. Caveat: the VCS Makefile `init_reg_cfg` (+vcs+initreg+...) is NOT gated - backdoor register init depends on the chip model, handle manually if top-level enable_ral is ever set false.

---

## 1. System-level bring-up checklist (once the chip RTL lands; do not start early)

1. The chip RTL lands under the design root and is listed in `tb_top/filelist/rtl_file_lst.f` through the `/new-verification` design-input step (stage 2b) (the generated system top `tb_top_<project>.sv` has clk/rst from the template; DUT instantiation is hand work, not generatable).
2. The real register-table CSV is provided at the `WSIM_REG_TABLE` location (`verify/script/sflow/flow_env.sh`; the location is asked in the `/new-verification` register-table step and written through `new_project.py set/apply`; placing the file is the user's action) -> triggers RalGen real model AND the derived-width validation (width derivation: `.claude/rules/ral.md` - check `verify/ral/ral_reg_width` covers the real widest register, especially sliced registers).
3. `tb_top/config/Makefile.initreg.cfg` is referenced by the VCS Makefile but is not generated - create it when register init is first needed.
4. Chip DUT instance in `tb_top_<project>.sv`, its wiring to the UVC interfaces in `intf/<mod>_if_conn.sv` / `top_if_conn.sv` (included through `tb_top/component/if_conn.sv`; same `dut_*` net convention as the block level, `.claude/rules/uvm-architecture.md` "Interface connection") - hand work per DUT.
5. System smoke stimuli: the generated `<mod>_smoke_test` classes are inert; fill their bodies (add-test-case skill covers scaffolding).
6. Replace the fake tokens (`+DEFINE1...`) of the generated case JSONs when real system cases are added.

## 2. Open development gaps

Confirmed gaps of the generated environment that a developer hits when writing tests. IDs are stable - a closed gap leaves its number unused. **Lifecycle:** when a gap closes, delete its row here, log the fix in `docs/memory/fw_env_memory.md` (state lives here, history there), and, for G3, remove the RAL-macro-naming caveat in `test_case_dev_manual.md` §3.4 (the manual describes the generated skeleton generically; the other gaps have no caveat there). Placeholder JSON tokens are tracked in §1 item 6.

| ID | Gap | Where | Done looks like |
|---|---|---|---|
| G3 | `reg_<name>` handle-naming assumption unconfirmed | `utils/reg/uvm_reg_macros.sv:15-25` assumes handles named `reg_<regname>`; nothing has used the macros yet | One real register access confirms the names (or generator/macros adjusted) |
| G4 | Generated adapters are unvalidated stubs | every `reg2<bus>` adapter does a bare `we`/`addr`/`data` copy ("Please complete the conversion logic of the bus...") | The adapter written/validated against the real protocol semantics |
| G5 | `comm_<mod>_methods.sv` is generated empty | placeholder comments only | Populated as real tests are written |
| G6 | Generated `UVM_TESTNAME`s mostly have no leaf class | the `<mod>_smoke_test` / `<mod>_smoke_block_test` classes are inert; `<mod>_random_test` etc. have no class | Leaf classes written (add-test-case skill), JSON updated |
| G8 | Generated block-base RAL wiring never exercised | `<mod>_block_base_test/_seq` wire `ral`/adapter/sequencer, but no `ral.<reg>.write()/read()` has gone through them | One register access through this path succeeds |
| G9 | Placeholder system-level RAL hierarchy path | the `gen_uvm_env.py` top_env template sets `ral.set_hdl_path_root("tb_top.C[0].btnode.btc")` - not the chip's hierarchy; harmless while no system-level RAL model exists | Updated to the real hierarchy before any backdoor register access in the revived system flow |
