# oEDA local flow - machine setup (Linux)

> Division of labor: day-to-day commands and the pass criterion are canonized in `verify/CLAUDE.md` (oEDA section), the Verilator/OPEN_EDA coding rules in `.claude/rules/oeda-verilator.md`; this file covers only how a Linux machine is set up for the oEDA flow. Record this machine's actual paths and versions below once the flow runs.

## Recommended toolchain

- **Verilator >= 5.054** (a recent OSS CAD Suite). Older releases reject some UVM/SystemVerilog forms - 5.040, for example, cannot parse `uvm_config_db #(<pkg>::<type>)::get/set` and rejects a function without a return type. The framework isolates the known cases under `OPEN_EDA` (`.claude/rules/oeda-verilator.md`); new code on an older release may hit more.
- **Accellera UVM-1.2** source tree. A simulator-bundled UVM can carry vendor code Verilator cannot parse; UVM 1.1d and IEEE 1800.2 differ in RAL, phasing and deprecated APIs.
- `/new-project` (P2) and `new_project.py check --stage project` report what this machine has against these versions; `wsim_oeda` prints a warning on every run when Verilator or UVM differs. Both are warnings - other versions still run.

## One-time setup

- Verilator: unpack the OSS CAD Suite and source its `environment` in the shell that runs the flow (`source <oss-cad-suite>/environment`); `verilator --version` must answer.
- UVM-1.2 library: `export UVM_HOME=<path>/uvm-1.2` (`wsim_oeda` default: `$HOME/tools/uvm-1.2`). Use a plain Accellera UVM-1.2 source tree - a simulator-bundled UVM can carry vendor code Verilator cannot parse.
- Python 3 with openpyxl for RalGen: `WSIM_PYTHON` in `script/sflow/flow_env.sh`, else `/usr/bin/python3` (the OSS CAD Suite python has no openpyxl).
- Waveforms: an FST viewer (Surfer or GTKWave).

## Pitfalls

- csh/tcsh login shells: `wsim_oeda` is a bash script and does not see variables set only in `~/.cshrc`. Export `UVM_HOME` and source the OSS CAD Suite `environment` where bash sees them (`~/.bashrc` / `~/.profile`), or in the shell before calling `./wsim_oeda`.
- The compile runs in `sim/uvm_scratch_oeda_<case>/comp_<case>/` (three levels below the repo root, matching the `.f` path depth); `obj_dir` is reused while the build key (tool version, project id, defines, flags, filelist, source fingerprint) is unchanged.

## This machine

- To be filled in: OSS CAD Suite path and Verilator version, `UVM_HOME`, `WSIM_PYTHON`, waveform viewer.
