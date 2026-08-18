---
name: add-test-case
description: Scaffold a new UVM test case (test class + sequence class + JSON case entry) for a module in this auto_gen/verify environment. Use when asked to create, add, generate, or scaffold a test case, system-level or block-level, for reg/jls/ro/uart/efuse.
---

# Add Test Case

Generates a new leaf test case for one module (`reg`, `jls`, `ro`, `uart`, `efuse`) in `auto_gen/verify`, synchronizing all three places a test case lives: the `test/` class, the `seq/` class, and the `json/case/<module>.json` entry — following this repo's inheritance rules and naming convention. Read `docs/test_case_dev_manual.md` first if you haven't worked in this tree before; this skill automates exactly the mechanical steps that manual describes in its §3/§4.

Paths below are relative to `auto_gen/verify/` (the "verify root").

## Run this — the driver

```bash
python3 .claude/skills/add-test-case/add_test_case.py \
  --module <reg|jls|ro|uart|efuse> \
  --function <short_scenario_name> \
  --level <system|block> \
  [--stage1 true|false] [--stage2 true|false] [--smoke true|false] [--full true|false] \
  [--iteration N] [--codecoverage true|false] \
  [--macro-opt "+EXTRA_DEFINE"] [--plusargs-opt "+EXTRA_PLUSARG"]
```

Examples actually run and verified in this session:

```bash
# system-level
python3 .claude/skills/add-test-case/add_test_case.py \
  --module ro --function toggle_check --level system --stage1 true --smoke true

# block-level (only efuse has a working block base today — see Gotchas)
python3 .claude/skills/add-test-case/add_test_case.py \
  --module efuse --function burn_and_read --level block --stage2 true --iteration 4
```

This creates, per the naming rule `<module>_<function>_test` / `<module>_<function>_seq`:

- **System level**: appends `<module>_<function>_test extends <module>_base_test` into `test/<module>_test.sv`, and `<module>_<function>_seq extends <module>_base_seq` into `seq/<module>_seq.sv`. The test's `main_phase` starts the sequence on `vseqr_h.<module>_seqr_h` (the module's own sub-sequencer on `top_virtual_sequencer`).
- **Block level**: appends `<module>_<function>_test extends <module>_block_base_test` into `test/<module>_block_base_test.sv`, and the seq analog into `seq/<module>_block_base_seq.sv`. The test starts the sequence on `<module>_env_h.vseqr_h` (the module env's own sequencer).
- Either way: a new entry keyed `"<module>_<function>_test"` is added to `json/case/<module>.json`'s `"tests"` object, with `UVM_TESTNAME` set to that same class name (so `wsim -c <module>_<function>_test -uvm` runs it directly), and — for block level — `VCS_MACRO_OPT` auto-prefixed with `+<MODULE>_BLOCK_TEST`.

The script refuses (clear error, no partial edits) if: the module name is invalid, `--function` isn't a valid identifier fragment, the class name already exists in the target file, the JSON key already exists, or — for block level — the module has no working block base yet (see Gotchas).

## After running

The generated seq's `body()` is a `// TODO: real stimulus...` stub — same as every other leaf sequence in this repo today. Fill it in, then:

```bash
# from sim/
./wsim -c <module>_<function>_test -uvm
```

A clean run (no `UVM_ERROR`/`UVM_FATAL`) doesn't yet mean much until the scoreboard has a real check — see `docs/test_case_dev_manual.md` §5's caveat.

## Gotchas

- **Block-level only works for `efuse` today.** `test/efuse_block_base_test.sv` / `seq/efuse_block_base_seq.sv` are the only complete, Makefile-wired block base pair. `jls` and `uart` have block *filelists* (`tb_top/filelist/uvm_blk_jls.f`, `uvm_blk_uart.f`) that reference `jls_block_base_test.sv`/`uart_block_base_test.sv` and their seq counterparts — but those files don't exist yet, **and** `tb_top/scripts/Makefile`'s block-env filelist selection only special-cases `EFUSE_BLOCK_TEST` (confirmed by reading the Makefile — no `JLS_BLOCK_TEST`/`UART_BLOCK_TEST` branch exists), so even creating the missing files wouldn't get picked up without also editing the Makefile. `reg`/`ro` have no block filelist at all. The script detects the missing base-class files and refuses with this explanation rather than guessing; it does not touch the Makefile.
- **`stage1`/`stage2` default to mutually exclusive**, matching every existing entry in the JSON files (smoke tests are `stage1`-only, regression tests are `stage2`-only). If you only pass one, the script infers the other rather than leaving both `"true"`. Pass both explicitly if you genuinely want a test in both groups.
- **The target `json/case/<module>.json` gets fully re-serialized** (via Python's `json` module, 4-space indent) when a new entry is added, not surgically patched — the JSON stays valid and semantically identical, but the file's original slightly-irregular tab/space formatting is normalized. This is expected, not a bug.
- **Duplicate-safe, not idempotent-safe.** Running the same `--module`/`--function`/`--level` twice fails on the second run (class/key already exists) rather than silently overwriting — this is intentional.
- **No new files are created for leaf classes** — the script always appends into the existing per-module file, because that's the exact filename already `` `include``-d by `env/top_pkg.sv` (system tests), `seq/soc_sequence_lib.sv` (system seqs), or the fixed path in a block `.f` filelist (block level). Creating a *new* file per test case would additionally require editing those manifests — out of scope for "add a test case."

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `ERROR: Block-level base classes for module '<mod>' don't exist yet` | Requested `--level block` for `jls`/`uart`/`reg`/`ro` | Only `efuse` is supported at block level today. See Gotchas. To add support for another module, someone needs to author `test/<mod>_block_base_test.sv` + `seq/<mod>_block_base_seq.sv` (mirroring efuse's) and wire the Makefile — that's a bigger task than this skill's scope. |
| `ERROR: Class <name> already exists in <file>` | Re-ran with the same `--module`/`--function`/`--level` | Pick a different `--function`, or hand-edit if you meant to modify the existing test. |
| `ERROR: Test key <name> already exists in <json file>` | Same as above, JSON side | Same fix. |
| `ERROR: --function must be an identifier fragment...` | `--function` had spaces, hyphens, or started with a digit | Use `snake_case`, e.g. `write_read`, not `write-read` or `2nd_pass`. |
