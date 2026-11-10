# Code Review：jls → apb_master 替换 + wsim_local 本地流程

- 分支：verify_ai_flow_cc_open_eda
- 审查日期：2026-11-09
- 审查范围：当前工作区 diff（含未跟踪文件）
- 审查角度：Conventions（CLAUDE.md 规范）、Efficiency（效率）、Simplification（冗余/死代码）、Altitude（根因深度）、Reuse（复用）
- 结论：共 13 条发现。jls → apb_master 替换本身符合仓库规范（命名、filelist 路径与分层、script/ 为唯一源、JSON 规则）。主要问题有两类：
  1. 重新生成后，wsim_local 依赖的 Verilator 支持被整体抹掉。
  2. block 级流程（adapter、Makefile 分支、filelist 接线）整体不通。

  多数问题的根因在 `verify/script/gen_uvm_env.py` 和 `verify/script/sflow/Makefile`，不在生成出的文件里。只改生成物，下次重新生成会再次破坏。

---

## 一、正确性（Correctness）

### 1. VERILATOR 支持被删除，wsim_local 无法编译 [CONFIRMED]

- 文件：`verify/tb_top/tb_top/tb_top_soc.sv`（第 50/62 行），另涉及 `dump_wave.sv`、`top_pkg.sv`、`vif_declare.sv`
- 问题：工作区 diff 删除了新增 `wsim_local` 所依赖的全部 `ifdef VERILATOR` 分支：
  - `program sdf_annotate` 不再被 guard，Verilator 不支持 program 块。
  - `dump_wave.sv` 的 FST 分支被删除。
  - `top_pkg.sv` 去掉了 `uvm_pkg.sv` 的 include guard。
  - `vif_declare.sv` 退回为分开的 initial 块。
  - clk/rst 生成与 stub DUT 被删除。
  - 但 `wsim_local:212` 仍传 `+define+VERILATOR`。
- 后果：`./wsim_local -c reg_smoke_test` 无法编译。即使编译通过，也没有 `$dumpfile/$dumpvars`，不会产生 wave.fst。
- 根因：`gen_uvm_env.py`（3028 行）里没有任何 VERILATOR/FST 相关模板。HEAD 中的 Verilator 修复是手改生成文件，重新生成就被抹掉。
- 建议：把（对 VCS 安全的）VERILATOR ifdef 写进生成器的模板字符串（`get_top_pkg_template` 约 1404 行、`get_vif_declare` 约 1637 行、`get_dump` 约 1852 行、`get_tb_top`/`get_tb_top_blk` 约 1660/1800 行），保持 script/ 为唯一源。

### 2. block base test 引用了不存在的 adapter [CONFIRMED]

- 文件：`verify/test/apb_master_block_base_test.sv`（第 12/61/96 行）
- 问题：引用 `apb_master_pkg::apb_master_reg2apb_adapter`，但配置里 `enable_adapter:false`，生成器不会生成该类（`uvc/apb_master/src/` 无该文件，`apb_master_pkg.sv` 无 include）。
- 后果：所有 apb_master block 用例（如 `apb_master_smoke_block_test`）编译报未定义类型。
- 根因：`gen_uvm_env.py` 的 `get_block_base_test_template()`（约 860/909/944 行）写死 adapter 声明/创建/`set_sequencer`，生成门限（约 2777 行）只判断 `has_tb_top`，不判断 `enable_adapter`。以后任何 `has_tb_top:true, enable_adapter:false` 的模块都会继承同一问题。
- 建议：让模板里的 adapter 接线按 `enable_adapter` 条件生成。

### 3. Makefile 没有 APB_MASTER_BLOCK_TEST 分支 [CONFIRMED]

- 文件：`verify/script/sflow/Makefile`（第 474-484 行，另有部署副本 `verify/tb_top/scripts/Makefile`）
- 问题：block filelist 选择只有 `EFUSE_BLOCK_TEST → uvm_blk_efuse.f`，其余走 else，`uvm_file_lst` 为空。新增的 `uvm_blk_apb_master.f`、`tb_top_apb_master.f`、`tb_top_apb_master.sv` 没有任何流程引用。
- 后果：`./wsim -c apb_master_smoke_block_test` 的 VCS 编译没有任何 UVM 源文件，立即失败。
- 建议：从 `VCS_MACRO_OPT` 中提取 `*_BLOCK_TEST` token，小写后映射到 `uvm_blk_$(mod).f`（CLAUDE.md 的命名约定使其可机械推导），今后新增模块不再需要改 Makefile。

### 4. wsim_local 没有 block 路径 [CONFIRMED]

- 文件：`verify/script/sflow/wsim_local`（第 281-287 行；部署副本 `sim/wsim_local`）
- 问题：硬编码 system 级 filelist（`ip_file_lst.f/include.f/lib_lst.f/rtl_file_lst.f/uvm.f`），没有 `uvm_blk_*` 选择与 BLOCK_TEST 处理。
- 后果：`./wsim_local -c apb_master_smoke_block_test` 会用 system 环境加 `+define+APB_MASTER_BLOCK_TEST` 编译，最后以 UVM_TESTNAME 未知报错，而不是明确提示不支持。
- 建议：wsim 与 wsim_local 共用一个"case → (defines, filelists)"解析器。

### 5. wsim_local 的 case 解析器与 testjson2lst.py 已出现分歧 [CONFIRMED]

- 文件：`verify/script/sflow/wsim_local`（第 99-140 行，内嵌 Python heredoc）
- 问题：重新实现了 `testjson2lst.py` 已有的功能（`wsim:708` 用的就是后者），且已分歧：
  - 缺少 `+UVM_REG_DATA_WIDTH=1408+UVM_HDL_MAX_WIDTH=1408` 的宏注入（`testjson2lst.py:276-278`）。
  - 不处理 case JSON 的 `exclude` 键（`testjson2lst.py:188-189/221-222`）。
- 后果：RAL 模型中 `uvm_reg_data_t` 在本地流程为 64 位，在 VCS 下为 1408 位，对位宽敏感的寄存器两套流程结果可能不同。今后的 `exclude` 条目只对 VCS 生效。
- 建议：改为调用 `testjson2lst.py`，解析其单行 `.list` 输出（参考 `wsim` 的做法）。

### 6. apb_master.json 的 random 用例指向不存在的测试类 [CONFIRMED]

- 文件：`verify/json/case/apb_master.json`（第 38 行）
- 问题：两条 random 用例（iteration 6 和 10，`stage2:true, full:true, codecoverage:true`）使用 `+UVM_TESTNAME=apb_master_random_test`，全仓库没有该类。此问题从已删除的 `jls.json` 原样继承。
- 后果：`-stage2`/`-full` 回归会排入 16 个必然失败的 run，或被永久计为失败。
- 建议：删除这两条，或补上真实的 `apb_master_random_test`。

### 7. apb_v3_sram.v 未被任何地方使用 [CONFIRMED]

- 文件：`hdl/rtl/apb_v3_sram.v`（第 25 行起）
- 问题：未被任何 filelist 编译，也未被任何模块实例化。`rtl_file_lst.f` 在删除 `soc_stub.sv` 后不含任何 RTL，`tb_top_apb_master.sv` 的 DUT 区域也是空的。
- 后果：本地仿真没有 DUT；100 多行 RTL 随 diff 提交但没有任何构建或仿真路径，容易悄悄腐烂。
- 建议：加入 `rtl_file_lst.f` 并在 `tb_top_apb_master.sv` 中实例化，或删除。

---

## 二、文档过期（Stale docs）

均为 `verify/CLAUDE.md`：

### 8. 第 7 行仍列出 jls 模块 [CONFIRMED]

文档写"per-module UVCs (`reg`, `jls`, `ro`, `uart`, `efuse`)"，而 diff 已删除整个 jls UVC（`uvc/jls/**`、`seq/jls_seq.sv`、`seq/comm_jls_methods.sv`、`test/jls_test.sv`、`intf/jls_if_conn*.sv`、`json/case/jls.json`），并在 `module.json` 中换成 `apb_master`。Claude Code 读到该文档会把 jls 当作存在的模块，且不知道 apb_master。

### 9. 第 49-51 行引用已删除的 soc_stub 和 VERILATOR 差异 [CONFIRMED]

文档引用已删除的 `hdl/rtl/soc_stub.sv`，并描述 `sdf_annotate` guard、FST 分支、单 initial 赋值 vif 等 VERILATOR 差异，而这些代码已被 diff 移除。注意：第 1 条修复（恢复 guard）后，这条文档的描述基本重新成立；需要同步的是 stub 文件的指向。

---

## 三、效率（Efficiency，均在 `verify/script/sflow/wsim_local`）

### 10. 每次运行全量重编 [PLAUSIBLE]

第 273 行 `rm -rf "$sim_dir"` 每次删除 `obj_dir`。seed 只是运行时 plusarg，同一 case 连续运行会重编逐字节相同的约 2529 个 TU 的 Verilator 二进制，而仿真本身只需几秒。
建议：把 `obj_dir` 放在稳定目录，用 verilator 版本 + 命令行 + `uvm_vlt.f` 内容的哈希作 key，让 Verilator/make 增量构建。

### 11. 构建目录在 WSL 的 /mnt/c（9p）上 [PLAUSIBLE]

第 75 行 `sim_dir` 和第 277 行 `scratch_dir` 位于 9p 挂载。2529 个 TU 的读写与链接、FST 和 `coverage.dat` 写入都要承受 9p 的元数据延迟，已知会让构建慢数倍。
建议：把 scratch 默认放到 WSL 原生文件系统（如 `~/.cache/<project>/` 或遵循 `TMPDIR`），仅把 wave.fst、sim.log、coverage.dat、result.txt 拷回 `sim/`。

### 12. --coverage 始终开启 [PLAUSIBLE]

第 221 行无条件传 `--coverage`，而 `coverage.dat` 只在 `-covrpt` 时使用（第 296-299 行）。toggle coverage 会增大生成代码与仿真开销。常用的波形调试循环白白付出代价，"cheap at this scale"的注释在真实 hdl/ 进来后不再成立。
建议：用 `[ "$OPTS_COVRPT" == "TRUE" ]` 控制。

---

## 四、冗余/死代码（Simplification）

### 13. 未使用变量与 WSIM_LOCAL_COV 失效 [CONFIRMED]

`wsim_local:35` 的 `currentPwd=$(pwd)` 全文未使用。`OPTS_COV_TYPE="${WSIM_LOCAL_COV:-addr}"` 只通过 `RalGen` 按 mtime 触发的重新生成生效；若 `verify/ral/ral_reg_model.sv` 已是最新，设置 `WSIM_LOCAL_COV=none`（文档中"covergroup 编译卡住"时的退路）不会重新生成，编译仍然失败。
建议：删除变量；COV 覆盖项变更时强制重新生成 RAL，或去掉该覆盖项。

---

## 已核查并确认无问题（未列为发现）

- 命名与 guard：`__APB_MASTER_PKG__SV__`、config-db key `apb_master_vif`/`apb_master_cfg` 等一致。
- script/ 为唯一源：`verify/script/utils/dpi_func.c` 与 `verify/utils/dpi_func.c`、`verify/script/sflow/` 与 `sim/` 下 wsim/wsim_local/project_name 逐字节一致；`tb_top/scripts/Makefile` 与 `script/sflow/Makefile` 同步。
- filelist 路径与分层：`../../../verify/` 前缀、`uvm.f` 顺序、`uvm_blk_apb_master.f` 结构与 efuse 一致。
- 属于生成器模板惯例、不作为本次改动问题的项：`apb_master_env.sv` 中先建后覆盖的 `vseqr_h`、空的 `apb_master_if_conn*.sv`、`apb_master_block_base_seq.sv` 中未使用的 `rand data/_printer/status`、`monitor_trans` 与 `collect_coverage` 的双 forever 循环、`recording_detail UVM_FULL` 与 `uvm_config_db set(null,"*")`、sim/ 与 script/sflow/ 的 wsim_local 双份（部署约定）。
- 无遗留 jls 引用（代码层面）。

---

## 修复优先级建议

1. 先修生成器（`gen_uvm_env.py`）：补 VERILATOR 模板分支（#1）、让 block test 的 adapter 接线跟随 `enable_adapter`（#2），再重新生成。
2. 修 Makefile 的 block filelist 推导（#3）；让 wsim_local 复用 `testjson2lst.py`（#4、#5）。
3. 补/删 random 用例（#6）；接线或删除 `apb_v3_sram.v`（#7）。
4. 同步 `verify/CLAUDE.md`（#8、#9）。
5. wsim_local 的效率项（#10-#12）与杂项（#13）。
