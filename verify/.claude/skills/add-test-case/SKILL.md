---
name: add-test-case
description: Scaffold a new UVM test case (test class + sequence class + JSON case entry) for a module in this verify environment. Use when asked to create, add, generate, or scaffold a test case, system-level or block-level, for reg/apb_master/ro/uart/efuse.
---

# Add Test Case

Generates a new leaf test case for one module (`reg`, `apb_master`, `ro`, `uart`, `efuse`) in `verify`, synchronizing all three places a test case lives: the `test/` class, the `seq/` class, and the `json/case/<module>.json` entry — following this repo's inheritance rules and naming convention. Read `test_case_dev_manual.md` (in this skill directory) first if you haven't worked in this tree before; this skill automates exactly the mechanical steps that manual describes in its §3/§4.

Paths below are relative to `verify/` (the "verify root").

## Run this — the driver

```bash
python3 .claude/skills/add-test-case/add_test_case.py \
  --module <reg|apb_master|ro|uart|efuse> \
  --function <short_scenario_name> \
  --level <system|block> \
  [--stage1 true|false] [--stage2 true|false] [--smoke true|false] [--full true|false] \
  [--iteration N] [--codecoverage true|false] \
  [--macro-opt "+EXTRA_DEFINE"] [--plusargs-opt "+EXTRA_PLUSARG"]
```

Examples:

```bash
# system-level
python3 .claude/skills/add-test-case/add_test_case.py \
  --module ro --function toggle_check --level system --stage1 true --smoke true

# block-level (efuse and apb_master have a working block base — see Gotchas)
python3 .claude/skills/add-test-case/add_test_case.py \
  --module efuse --function burn_and_read --level block --stage2 true --iteration 4

# block-level, apb_master: --function carries the "_block" suffix to match the
# existing apb_master_<fp>_block_test naming (class = apb_master_<function>_test)
python3 .claude/skills/add-test-case/add_test_case.py \
  --module apb_master --function back2back_block --level block --stage1 true
```

Block-level flavours that need an extra compile define (e.g. apb_master's wait test needs `+APB_SRAM_EN_WAIT`) pass it with `--macro-opt "+APB_SRAM_EN_WAIT"`; the script prepends `+<MODULE>_BLOCK_TEST` itself, giving `+APB_MASTER_BLOCK_TEST+APB_SRAM_EN_WAIT`.

This creates, per the naming rule `<module>_<function>_test` / `<module>_<function>_seq`:

- **System level**: appends `<module>_<function>_test extends <module>_base_test` into `test/<module>_test.sv`, and `<module>_<function>_seq extends <module>_base_seq` into `seq/<module>_seq.sv`. The test's `main_phase` starts the sequence on `vseqr_h.<module>_seqr_h` (the module's own sub-sequencer on `top_virtual_sequencer`).
- **Block level**: appends `<module>_<function>_test extends <module>_block_base_test` into `test/<module>_block_base_test.sv`, and the seq analog into `seq/<module>_block_base_seq.sv`. The test starts the sequence on `<module>_env_h.vseqr_h` (the module env's own sequencer).
- Either way: a new entry keyed `"<module>_<function>_test"` is added to `json/case/<module>.json`'s `"tests"` object, with `UVM_TESTNAME` set to that same class name (so `wsim -c <module>_<function>_test -uvm` runs it directly), and — for block level — `VCS_MACRO_OPT` auto-prefixed with `+<MODULE>_BLOCK_TEST`.

The script refuses (clear error, no partial edits) if: the module name is invalid, `--function` isn't a valid identifier fragment, the class name already exists in the target file, the JSON key already exists, or — for block level — the module has no working block base yet (see Gotchas).

## After running

The generated seq's `body()` is a `// TODO: real stimulus...` stub. Fill it in (apb_master's block seqs show real stimulus via `apb_write`/`apb_read`/`apb_idle`), then:

```bash
# from the repo-root sim/, locally inside WSL (oEDA; block-level cases):
./wsim_oeda -c <module>_<function>_test -seed 1
# on the Linux VCS server (sign-off):
./wsim -c <module>_<function>_test -uvm
```

A clean run (no `UVM_ERROR`/`UVM_FATAL`) doesn't yet mean much until the scoreboard has a real check — see `test_case_dev_manual.md` §5's caveat.

## Gotchas

- **Block-level works for `efuse` and `apb_master` today.** Each has a complete block base pair (`test/<mod>_block_base_test.sv` / `seq/<mod>_block_base_seq.sv`) and a `tb_top/filelist/uvm_blk_<mod>.f`; the VCS Makefile (`script/sflow/Makefile`) and the local `script/sflow/wsim_oeda` derive that filelist from the `<MOD>_BLOCK_TEST` define, so no per-module flow-script branch is needed and a missing filelist stops with a clear error. `uart`, `reg` and `ro` have no block filelist and no block base pair. The script detects missing base-class files and refuses with this explanation rather than guessing; it does not touch the Makefile or `wsim_oeda`.
- **apb_master naming:** existing apb_master block tests are named `apb_master_<fp>_block_test`, so pass `--function <fp>_block` to keep the `_block_` infix (the script itself builds `<module>_<function>_test`). apb_master block seqs get stimulus via the `apb_write/apb_read/apb_idle` helpers in `apb_master_block_base_seq`; the generated `body()` TODO stub must be filled in with those.
- **`stage1`/`stage2` default to mutually exclusive**, matching every existing entry in the JSON files (smoke tests are `stage1`-only, regression tests are `stage2`-only). If you only pass one, the script infers the other rather than leaving both `"true"`. Pass both explicitly if you genuinely want a test in both groups.
- **The target `json/case/<module>.json` gets fully re-serialized** (via Python's `json` module, 4-space indent) when a new entry is added, not surgically patched — the JSON stays valid and semantically identical, but the file's original slightly-irregular tab/space formatting is normalized. This is expected, not a bug.
- **Duplicate-safe, not idempotent-safe.** Running the same `--module`/`--function`/`--level` twice fails on the second run (class/key already exists) rather than silently overwriting — this is intentional.
- **No new files are created for leaf classes** — the script always appends into the existing per-module file, because that's the exact filename already `` `include``-d by `env/top_pkg.sv` (system tests), `seq/soc_sequence_lib.sv` (system seqs), or the fixed path in a block `.f` filelist (block level). Creating a *new* file per test case would additionally require editing those manifests — out of scope for "add a test case."

## Adding a new module (keep this skill in sync)

Whenever a module is added to (or removed from) the environment — `script/uvm_env_config_template.json`, `json/module.json`, `gen_uvm_env.py --guvc` — update **all** of the following in the same change:

1. `MODULES` list in `add_test_case.py`.
2. Every module enumeration in this SKILL.md: the frontmatter `description`, the intro sentence, the `--module <...>` usage line, the Gotchas block-level support list, and the Troubleshooting table row.
3. Check whether the module has a working block base pair + `tb_top/filelist/uvm_blk_<mod>.f` (the flow scripts derive the filelist from `<MOD>_BLOCK_TEST`); if so list it under the block-level Gotcha, otherwise add it to the "not supported" list.
4. Run the script with the new module once (e.g. a throwaway `--function`) or at least confirm `--module <new>` is accepted, then revert any scratch test it generated.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `ERROR: Block-level base classes for module '<mod>' don't exist yet` | Requested `--level block` for `uart`/`reg`/`ro` | Only `efuse` and `apb_master` are supported at block level today. See Gotchas. To add support for another module, someone needs to author `test/<mod>_block_base_test.sv` + `seq/<mod>_block_base_seq.sv` (mirroring apb_master's/efuse's) and add `tb_top/filelist/uvm_blk_<mod>.f` (the flow scripts pick it up from `<MOD>_BLOCK_TEST` automatically) — that's a bigger task than this skill's scope. |
| `ERROR: Class <name> already exists in <file>` | Re-ran with the same `--module`/`--function`/`--level` | Pick a different `--function`, or hand-edit if you meant to modify the existing test. |
| `ERROR: Test key <name> already exists in <json file>` | Same as above, JSON side | Same fix. |
| `ERROR: --function must be an identifier fragment...` | `--function` had spaces, hyphens, or started with a digit | Use `snake_case`, e.g. `write_read`, not `write-read` or `2nd_pass`. |
