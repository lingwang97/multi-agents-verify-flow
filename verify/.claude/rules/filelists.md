---
paths:
  - "**/*.f"
---

# Filelist conventions

- Paths are relative to the scratch run dir and use the `../../../verify/...` prefix. The VCS `comp_<case>/` and `sim_*` scene dirs and the oEDA build dirs `sim/oeda_build/<tag>_<sig>/` sit three levels below the repo root; keep that depth assumption when editing `.f` files.
- Relative `+incdir+` and file paths resolve against the compile cwd — the reason for the depth-3 scratch layout.
- `tb_top/filelist/uvm.f` (system level) order: base packages `global_pkg` → `reg_mdl_pkg` → `ral_reg_model` → `base_uvc_pkg`, then each UVC's `uvc/<mod>/script/uvm.f`, then `tb_top_chip.f` and `top_pkg.sv`. SV package/include order matters — insert new files at the matching layer. `uvm.f` itself is template-pure (`.claude/rules/generated-assembly.md`).
- Block level uses `tb_top/filelist/uvm_blk_<mod>.f` + `tb_top_<mod>.f` instead (selected by `+<MOD>_BLOCK_TEST`); these are module-private and hand-maintained. Both flow scripts derive the filelist from the token (lower-cased module name), so a new block-level module only needs its `uvm_blk_<mod>.f`; a missing file stops with a clear error (Makefile `$(error)` / `wsim_oeda` `die`).
- `tb_top/filelist/*.f` also select RTL vs gate vs IP sources per sim level (`rtl_file_lst.f` lists the RTL). The source lists and `include.f` are user-maintained skeletons (file classes: `verify/CLAUDE.md` "Regenerating the environment"); their design content comes from the `/new-verification` design-input step (`new_project.py scan` → user confirms → `apply`); sub-agents do not edit them.
- `wsim_oeda` preprocesses the filelist into `sim/oeda_build/<tag>_<sig>/uvm_oeda.f` (linked from the case as `comp_<case>/build`) (`-f` expanded, `//` comments stripped, per-directory `+incdir` added) — check that file when an oEDA compile cannot find a source.
- Changing `tb_top/filelist/*.f` is a source-of-truth change (ops §1: change plan + user approval).
