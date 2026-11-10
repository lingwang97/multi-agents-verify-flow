# apb_v3_sram RTL 验证开发报告

| 项目 | 内容 |
|---|---|
| DUT | `hdl/rtl/apb_v3_sram.v`（APB v3 slave SRAM，Farshad 2018，MIT） |
| 分支 | `verify_ai_flow_cc_open_eda` |
| 验证环境 | 块级 UVM（UVM-1.2），`verify/uvc/apb_master/` |
| 仿真工具 | Verilator 5.053（开源 EDA 本地流，WSL2 + Ubuntu 24.04）；VCS 金标准流脚本已同步支持 |
| 运行入口 | `sim/wsim_local -c <case> -seed 1 [-covrpt]` |
| 报告日期 | 2026-09-28 |

---

## 1. 概述

本报告覆盖 apb_v3_sram 的块级验证开发全过程：tb 顶层与 filelist 更新、apb_master UVC 组件补全、RTL 验证 feature point（FP）分解、6 个块级测试用例开发与仿真、以及验证结论。全部用例在开源 EDA 环境（Verilator + UVM-1.2）下运行。

**结论摘要**：在参数覆盖配置（`MEM_BLOCK_SIZE=32`，见 §7.1）下，DUT 的复位、读写、越界错误、边界地址、等待周期等特性功能正确，全部验证点通过（见 §5）。同时发现若干 DUT 设计/代码缺陷与 quirk（见 §7），供设计侧评审。

## 2. DUT 特性分析

### 2.1 端口与参数

端口：标准 APB v3 slave —— `PRESETn`（低有效）、`PCLK`、`PSEL`、`PENABLE`、`PWRITE`、`PADDR[31:0]`、`PWDATA[31:0]`、`PRDATA[31:0]`、`PREADY`、`PSLVERR`。无 APB4 信号（无 PPROT/PSTRB）。

参数（tb 例化取值）：

| 参数 | 默认值 | tb 取值 | 说明 |
|---|---|---|---|
| ADDR_BUS_WIDTH | 32 | 32 | PADDR 位宽 |
| DATA_BUS_WIDTH | 32 | 32 | 数据位宽 |
| MEMSIZE | 64 | 64 | 存储深度（条目数） |
| MEM_BLOCK_SIZE | 8 | **32（覆盖）** | 单条目位宽，须与 DATA_BUS_WIDTH 一致（§7.1） |
| RESET_VAL | 0 | 0 | 复位填充值 |
| EN_WAIT_DELAY_FUNC | 0 | 0/1（编译期） | 等待周期使能（+APB_SRAM_EN_WAIT） |
| MIN/MAX_RAND_WAIT_CYC | 0/1 | 0/1 | 等待周期范围 |

### 2.2 行为模型

单一 `always @(posedge PCLK or PRESETn)` 进程，按 PSEL/PENABLE 组合分支：

- **复位**：PREADY=0、PSLVERR=0、PRDATA=0，memory 全部填 RESET_VAL。注意 memory 仅有这一条初始化路径，复位必须从 t=0 拉低 PRESETn。
- **IDLE**（!PSEL && !PENABLE）：PREADY=0、PSLVERR=0。
- **SETUP**（PSEL && !PENABLE）：EN_WAIT=0 时 **PREADY 提前一拍拉高**（quirk，见 §7.3）；EN_WAIT=1 时 PREADY=0。
- **ACCESS**（PSEL && PENABLE）：EN_WAIT=1 时先等待 `wait_cyc_limit` 拍再 PREADY=1；写：PADDR<MEMSIZE 写入且 PSLVERR=0，否则 PSLVERR=1（不写入）；读：PADDR<MEMSIZE 返回 `memory[PADDR]`，否则 PSLVERR=1 且 **PRDATA 保持陈旧值**；传输完成后下一拍 PREADY=0。
- **单进程相位滞后**：ACCESS 评估后进程挂起在内部 `@(posedge PCLK)`，恢复时丢失一次触发 —— 每次传输后 DUT 响应滞后一拍（§7.4）。driver 因此在每笔传输间插入 ≥1 个 IDLE 周期。

## 3. 验证环境架构

```
tb_top (verify/tb_top/tb_top/tb_top_apb_master.sv)
 ├── 时钟产生（10ns）/ 复位产生（t=0 拉高 20 拍，PRESETn=~rst）
 ├── apb_master_pif()（apb_master_if，含 APB v3 全套信号）
 ├── apb_v3_sram 例化（MEM_BLOCK_SIZE=32 覆盖；EN_WAIT 由 +define 切换）
 └── uvm_config_db 发布 vif
apb_master_env
 ├── apb_master_agent（active）
 │    ├── apb_master_driver    —— APB v3 master FSM，negedge 驱动/采样（IDLE→SETUP→ACCESS→等 PREADY）
 │    ├── apb_master_monitor   —— negedge 事务重建（SETUP 锁存、wait_cycles 统计）+ 过程式协议检查
 │    ├── apb_master_sequencer
 │    └── apb_master_scoreboard —— shadow memory 参考模型 + PSLVERR/PRDATA 陈旧值检查
 └── apb_master_coverage       —— APB 传输/数据 covergroup（VCS 侧收集）
```

- 序列基类 `apb_master_block_base_seq` 提供 `apb_write / apb_read / apb_idle` 复用激励 helper（响应经 `get_response` 消费）。
- 测试基类 `apb_master_block_base_test`：RAL 构建（stub adapter，本 DUT 无寄存器，运行期不发起寄存器操作）、cfg 随机化、完整 runtime phases。
- **driver/monitor 采用 negedge** 的原因：DUT 在 posedge 内用阻塞赋值更新 PRDATA/PSLVERR，posedge 采样存在竞争。
- 协议检查（monitor，所有用例常开，`checks_enable` 可关）：PENABLE 无 SETUP 前导、ACCESS 期间 PADDR/PWRITE/PWDATA 稳定、PSLVERR 仅在 ACCESS 且不早于 PREADY、PREADY 二值性、IDLE 静默（连续 2 拍后 PREADY/PSLVERR 必须为 0）。SETUP 早期 PREADY 与 DUT 相位滞后属于容忍项，不判错。
- filelist：`uvm_blk_apb_master.f`（块级编译集，含 DUT RTL）；`wsim_local` 按 case JSON 中 `+APB_MASTER_BLOCK_TEST` 宏自动选择（VCS Makefile 同步增加该分支）。

## 4. Feature Point 分解与映射

| FP | 特性点 | 检查手段 | 覆盖用例 |
|---|---|---|---|
| FP1 | 复位行为：PREADY/PSLVERR/PRDATA 清零，memory 全部为 RESET_VAL | 64 地址全量回读逐笔比对 + scoreboard 模型 | apb_master_reset_block_test |
| FP2 | 在界写（PADDR<64）正确写入、PSLVERR=0 | scoreboard 随后读回比对 | smoke / rw_rand / boundary |
| FP3 | 在界读返回已写数据、PSLVERR=0 | scoreboard `rdata === model[addr]` | 同上 |
| FP4 | 随机读写数据完整性 | 100 笔随机激励 × 5 seed，scoreboard shadow model 逐笔比对 | apb_master_rw_rand_block_test |
| FP5 | 越界（PADDR≥64）：PSLVERR=1、写不生效、读 PRDATA 陈旧 | 越界写后回读锚点地址；scoreboard 维护 `prdata_shadow` 校验陈旧值 | apb_master_error_block_test |
| FP6 | IDLE 态 PREADY/PSLVERR=0 | monitor IDLE 静默检查（所有用例常开） | 全部用例 |
| FP7 | EN_WAIT_DELAY_FUNC=1 等待周期：master 保持 ACCESS 至 PREADY | +APB_SRAM_EN_WAIT 专项编译，10 组写读回读；wait_cycles 进覆盖统计（不判错，§7.5） | apb_master_wait_block_test（3 iter） |
| FP8 | APB 协议合规（相位顺序、控制稳定性、PSLVERR 时序） | monitor 过程式协议检查（所有用例常开） | 全部用例 |
| FP9 | 边界地址 0/1/62/63（在界）与 64（首个错误地址） | 定向边界读写 | apb_master_boundary_block_test；rw_rand 首两笔固定 0/63 |
| FP10 | 连续传输吞吐/相位滞后行为 | driver 固定插入 1 拍 IDLE；吞吐与相位滞后记录于 §7.4（不注入零间隔激励） | 分析覆盖 |

## 5. 仿真执行结果

运行命令：`./wsim_local -c <case> -seed 1 [-covrpt]`；PASS 判据 = simv 退出码 0 且 sim.log 中 `UVM_ERROR :0` / `UVM_FATAL :0`。

| 用例 | iteration / seed | EN_WAIT | 结果 | scoreboard 检查 |
|---|---|---|---|---|
| apb_master_smoke_block_test | 1 iter，seed 1 | 0 | **PASS** | 6 笔传输 |
| apb_master_reset_block_test | 1 iter，seed 1 | 0 | **PASS** | 64 笔全地址回读 |
| apb_master_rw_rand_block_test | 5 iter，seed 1–5 | 0 | **PASS ×5** | 100 笔/iter（共 500 笔，含越界读比率随机的在界读写） |
| apb_master_error_block_test | 1 iter，seed 1 | 0 | **PASS** | 10 笔（5 越界写 + 2 越界读 + 锚点写读校验） |
| apb_master_boundary_block_test | 1 iter，seed 1 | 0 | **PASS** | 10 笔（0/1/62/63 在界 + 64 越界） |
| apb_master_wait_block_test | 3 iter，seed 1–3 | 1 | **PASS ×3** | 20 笔/iter |

全部 iteration 的 sim.log 均 `UVM_ERROR :0` / `UVM_WARNING :0` / `UVM_FATAL :0`。

**等待周期实测**：DUT 在 t=0 会 `$display` 出一次性抽取的 `wait_cyc_limit`，wait 用例 3 个 iteration 实测值为 **0 / 0 / 1** —— 等待为 0 拍与 1 拍两种行为均被真实激励覆盖（§7.5）。

（执行记录：`sim/uvm_scratch_local_<case>/result.txt` 与 `run_iterN/sim.log`）

## 6. 覆盖率

### 6.1 代码覆盖率（Verilator `--coverage` + `-covrpt`，apb_v3_sram.v 注记）

wsim_local 打印的汇总数字（line 27.2% 等）为全部编译代码（TB+UVC+DUT）的混合值，不能反映 DUT 本身；下表为对注记文件 `cov_report/apb_v3_sram.v` 逐行统计的 **DUT 专属覆盖**：

| 用例配置 | DUT 注记行覆盖 | 零覆盖行解释 |
|---|---|---|
| reset（EN_WAIT=0，纯读） | 11/39 | 无写激励 → `wr_data2mem` 全部、PWDATA/PWRITE/PRDATA/PSLVERR 端口翻转、`PSLVERR=1` 两分支、EN_WAIT=1 等待分支 |
| rw_rand（EN_WAIT=0，5 seed 随机读写） | 39/53（73.6%） | `state` 死声明(§7.6)、拆分写缺陷分支(§7.1)、等待分支（编译期 EN_WAIT=0 不可达）、`PSLVERR=1` 两分支（无越界激励） |
| error / boundary（EN_WAIT=0，含越界激励） | 49/58（84.5%） | `state` 死声明、拆分写缺陷分支、等待分支（编译期不可达） |
| wait（EN_WAIT=1，3 iter） | 43/55（78.2%） | `state` 死声明、拆分写缺陷分支、EN_WAIT=0 SETUP 分支（编译期不可达）、`PSLVERR=1` 两分支（无越界激励） |

**合并结论**：5 个用例取并集后，DUT **全部可执行行为行均已覆盖**。持续零覆盖仅两类：`reg [1:0] state` 死声明（从未被赋值/读取，§7.6）与 `wr_data2mem` 的 DATA_BUS_WIDTH≠MEM_BLOCK_SIZE 拆分写分支（已知缺陷路径，有意不注入激励，§7.1）。EN_WAIT 两侧分支分别由 EN_WAIT=0 / EN_WAIT=1 两种编译配置覆盖（编译期常量，单一配置下对侧分支不可达）。翻转覆盖以 error 用例最高（全局 toggle 67.8%），rw_rand 次之（62.9%）。

### 6.2 功能覆盖率

covergroup（`cg_apb_transfer`：地址分段×读写 cross、PSLVERR、等待拍数；`cg_data`：数据型态）随 UVC 交付，但 **Verilator 不采集 covergroup 覆盖率**，需在 VCS 金标准流上用 `-fm` 收敛。开源环境下的"验证点全覆盖"以 §4 FP→用例映射 + §5 全 PASS + §6.1 DUT 代码覆盖共同证明。

## 7. DUT 问题发现（供设计评审）

1. **【缺陷】`wr_data2mem` 在 DATA_BUS_WIDTH≠MEM_BLOCK_SIZE 时写错地址**（apb_v3_sram.v L90-107）：按 32/8=4 拍拆字节写入 `memory[0..3]`，完全忽略 PADDR —— 任意地址写都会覆写 memory[0..3]，按地址回读必然失配。本次验证以 `.MEM_BLOCK_SIZE(32)` 覆盖绕开（该配置走 `memory[PADDR]` 正确路径）；**默认参数配置不可用于功能正确的读写**，建议修复或约束参数组合。
2. **【缺陷倾向】`always @(posedge PCLK or PRESETn)` 对 PRESETn 任意沿敏感**：缺少 `negedge` 关键字，复位释放沿（上升沿）也会触发进程评估一次（当前评估分支内 `!PRESETn` 判 0，行为无害，但为不良编码习惯）。
3. **【quirk】SETUP 期 PREADY 提前拉高**（EN_WAIT=0）：合规 master 仅在 ACCESS 采样 PREADY，故功能无害；但不符合 APB 协议时序图，协议检查器需显式容忍。
4. **【quirk】单进程结构导致每次传输后相位滞后一拍**：ACCESS 评估后进程挂起在内部 `@(posedge PCLK)`，恢复消耗下一 posedge 且丢失一次分支评估。实测影响：传输后紧接的 SETUP 评估延迟一拍，master 侧表现为该笔传输延迟增加；**零间隔背靠背传输依赖此滞后行为才能工作**（本环境 driver 固定插 1 拍 IDLE 规避）。
5. **【quirk】`wait_cyc_limit` 仅在 t=0 随机一次**（initial 块内 `$urandom_range`）：参数名暗示每笔传输随机延迟，实际全程固定（0 或 1）。wait 测试 3 个 iteration（seed 1–3）实测抽取值为 0 / 0 / 1，两种取值的行为均已覆盖。
6. **【死代码】IDLE/SETUP/ACCESS/WAIT 状态机变量（L52-62）声明后从未使用**；与实际分支逻辑无关，易误导读者。
7. **【提示】越界读 PRDATA 保持陈旧值**：符合"错误读不更新 PRDATA"的常见约定，但 spec 未定义；scoreboard 按陈旧值语义检查通过。

## 8. 运行复现方法

```bash
# Windows 宿主机（本机 system32 wsl shim 缺 inbox 内核，需用 MSI 版全路径）
"C:\Program Files\WSL\wsl.exe" -d Ubuntu-24.04 -- bash -c \
  'source ~/tools/oss-cad-suite/environment; export UVM_HOME=$HOME/tools/uvm-1.2; \
   cd /mnt/c/Users/wangling/pro_cc/projecd_id/sim && ./wsim_local -c apb_master_smoke_block_test -seed 1 -covrpt'
# 产物：sim/uvm_scratch_local_<case>/comp_<case>/run_iterN/{sim.log,wave.fst,coverage.dat}
# 代码覆盖注记：.../cov_report/；结果汇总：<scratch>/result.txt
```

脚本改动后需先 `bash verify/script/file_manage.sh` 重新部署（`script/` 为源）。

## 9. 局限与后续工作

- Verilator 不采集功能覆盖率：`apb_master_coverage` 的 covergroup 需在 VCS 流（`./wsim -m apb_master -fm`）上收敛；covergroup bin 已按 FP 分解预置。
- 零间隔背靠背传输未注入激励（DUT 相位滞后行为下可工作但无裕量），以分析覆盖；如设计侧修复相位滞后，应补 b2b 定向用例。
- 协议检查为 monitor 过程式实现（Verilator 不支持 SVA 并发断言）；VCS 流上可增补 `apb_master_if_pc.sv` 中的并发 assertion。
- 系统级流（tb_top_soc/uvm.f）当前无 DUT/时钟（本轮范围外）；jls→apb_master 迁移的系统级部分待后续集成验证。
- 代码覆盖中 DUT 的 `reset_ram` 复位分支、IDLE 分支等已由 FP1/FP6 覆盖；`wr_data2mem` 的 4 拍拆分支（默认参数路径）为已知缺陷路径，未注入激励（见 §7.1）。
