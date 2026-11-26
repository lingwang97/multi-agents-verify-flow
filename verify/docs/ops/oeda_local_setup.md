# oEDA local flow - machine setup (Linux)

> Division of labor: day-to-day commands and the pass criterion are canonized in `verify/CLAUDE.md` (oEDA section), the Verilator/OPEN_EDA coding rules in `.claude/rules/oeda-verilator.md`; this file covers only how a Linux machine is set up for the oEDA flow. Record this machine's actual paths and versions below once the flow runs.

## One-time setup

- Verilator: unpack the OSS CAD Suite and source its `environment` in the shell that runs the flow (`source <oss-cad-suite>/environment`); `verilator --version` must answer.
- UVM-1.2 library: `export UVM_HOME=<path>/uvm-1.2` (`wsim_oeda` default: `$HOME/tools/uvm-1.2`). Use a plain Accellera UVM-1.2 source tree - a simulator-bundled UVM can carry vendor code Verilator cannot parse.
- Python 3 with openpyxl for RalGen: `WSIM_PYTHON` in `script/sflow/flow_env.sh`, else `/usr/bin/python3` (the OSS CAD Suite python has no openpyxl).
- Waveforms: an FST viewer (Surfer or GTKWave).

## Pitfalls

- csh/tcsh login shells: `wsim_oeda` is a bash script and does not see variables set only in `~/.cshrc`. Export `UVM_HOME` and source the OSS CAD Suite `environment` where bash sees them (`~/.bashrc` / `~/.profile`), or in the shell before calling `./wsim_oeda`.
- The compile runs in `sim/uvm_scratch_oeda_<case>/comp_<case>/` (three levels below the repo root, matching the `.f` path depth); `obj_dir` is reused while the build key (tool version, defines, flags, filelist, source fingerprint) is unchanged.

## This machine

- To be filled in: OSS CAD Suite path and Verilator version, `UVM_HOME`, `WSIM_PYTHON`, waveform viewer.
