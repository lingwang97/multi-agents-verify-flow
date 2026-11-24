---
paths:
  - "**/*.f"
---

# Filelist conventions

- Paths are relative to the scratch run dir and use the `../../../verify/...` prefix. Both `comp_<case>/` (VCS and oEDA) and the `sim_*` scene dirs sit three levels below the repo root; keep that depth assumption when editing `.f` files.
- Relative `+incdir+` and file paths resolve against the compile cwd — the reason for the depth-3 scratch layout.
- `tb_top/filelist/uvm.f` (system level) order: base packages `global_pkg` → `reg_mdl_pkg` → `ral_reg_model` → `base_uvc_pkg`, then each UVC's `uvc/<mod>/script/uvm.f`, then `tb_top_soc.f` and `top_pkg.sv`. SV package/include order matters — insert new files at the matching layer. `uvm.f` itself is template-pure (`.claude/rules/generated-assembly.md`).
- Block level uses `tb_top/filelist/uvm_blk_<mod>.f` + `tb_top_<mod>.f` instead (selected by `+<MOD>_BLOCK_TEST`); these are module-private and hand-maintained.
- `tb_top/filelist/*.f` also select RTL vs gate vs IP sources per sim level (`rtl_file_lst.f` lists the RTL). The source lists (`rtl_file_lst.f`, `ip_file_lst.f`, `gate_file_lst.f`, `gate_ip_file_lst.f`, `lib_lst.f`, `gpls_lib_lst.f`) and `include.f` are user-maintained: `--guvc` writes their skeleton once and never overwrites them, so edit them directly.
- `wsim_oeda` preprocesses the filelist into `comp_<case>/uvm_oeda.f` (`-f` expanded, `//` comments stripped, per-directory `+incdir` added) — check that file when an oEDA compile cannot find a source.
- Changing `tb_top/filelist/*.f` is a source-of-truth change (ops §1: change plan + user approval).
