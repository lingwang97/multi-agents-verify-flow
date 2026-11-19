# oEDA local flow environment manual (WSL2 + Verilator, machine-specific)

> Split out of `arch_memory.md` §2 on 2026-11-18 (R6 doc governance: machine setup is an ops manual, not project knowledge).
> Division of labor: day-to-day commands and the project coding constraints (Verilator/OPEN_EDA rules, pass criterion) are canonized in `verify/CLAUDE.md` (oEDA / OPEN_EDA sections); this file covers only how this machine is set up and driven.

## One-time setup (machine-specific)

- One-time: right-click-run `C:\Users\wangling\tools\wsl-setup\enable_wsl2.bat` as administrator (VirtualMachinePlatform; one UAC + one reboot), then import the distro: `"C:\Program Files\WSL\wsl.exe" --import Ubuntu-24.04 C:\Users\wangling\wsl\Ubuntu-24.04 C:\Users\wangling\tools\wsl-setup\ubuntu-24.04-wsl-rootfs.tar.gz --version 2` (WSL 2.7.14 MSI already installed).
- Inside WSL add `source ~/tools/oss-cad-suite/environment` and `export UVM_HOME=$HOME/tools/uvm-1.2` to `~/.bashrc` (automated by `C:\Users\wangling\tools\wsl-setup\bootstrap_ubuntu.sh`).
- Waveforms: native-Windows Surfer `C:\Users\wangling\tools\surfer\surfer.exe` (FST/VCD) opening `\\wsl.localhost\Ubuntu-24.04\...` paths (SourceForge-hosted GTKWave is unreachable on this network).

## Windows-side invocation pitfalls

- **Use the full path** `"/c/Program Files/WSL/wsl.exe" -d Ubuntu-24.04 -- ...` (the `system32` shim lacks the inbox kernel; symptom: exit 127 and garbled UTF-16 error).
- **Git Bash quoting:** `wsl ... bash -c '...$c...'` loses `$c` (expanded to empty on the Windows side → `wsim_oeda -c  -seed 1` "invalid option"). Put multi-command runs in a script file and call it with `MSYS_NO_PATHCONV=1` so `/mnt/c/...` is not rewritten.
