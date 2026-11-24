---
paths:
  - "env/top_env.sv"
  - "env/top_vseqr.sv"
  - "env/top_pkg.sv"
  - "env/top_if.sv"
  - "env/top_if_pc.sv"
  - "json/module.json"
  - "test/base_test.sv"
  - "seq/base_seq.sv"
  - "seq/soc_sequence_lib.sv"
  - "tb_top/filelist/uvm.f"
  - "tb_top/tb_top/tb_top_soc.sv"
  - "tb_top/macro/tb_define.sv"
  - "tb_top/component/*.sv"
  - "script/gen_uvm_env.py"
---

# Generated assembly files: never hand-edit

The files matched here are **template-pure**: `gen_uvm_env.py --guvc` rewrites them on every run (canon: `verify/CLAUDE.md` "Regenerating the environment").

- Do not hand-edit them — the next regeneration silently drops the change. Lift the change into the matching template in `script/gen_uvm_env.py`, regenerate, then check `git diff` + one smoke run (`./wsim_oeda -c apb_master_smoke_block_test`).
- When a generated file already carries a needed fix (e.g. the `OPEN_EDA` guards in `top_pkg`, `tb_top_*`, `dump_wave`, `vif_declare`), fix the template and the generated file together, otherwise a regeneration drops the oEDA support.
- Templates are Python strings: an SV escape such as `"\n"` must be written `\\n` in the template, or the generated file gets a raw line break inside a string literal (Verilator: syntax error).
- Commit (or be ready to `git checkout --`) before regenerating.
- Module-private files (`uvc/<mod>/`, `<mod>_seq/test.sv`, `<mod>_block_base_*`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, …) are the opposite: generated once, then hand-extended. So are the user-maintained skeletons (`tb_top/filelist/` source lists (`rtl_file_lst.f`, `ip_file_lst.f`, `gate_file_lst.f`, `gate_ip_file_lst.f`, `lib_lst.f`, `gpls_lib_lst.f`, `include.f`), `tb_top/macro/rtl_define.f` and `tb_top/config/*.cfg`).
