`ifndef PL_SIM
`ifdef USE_RAL_MODEL

//SIG: target signal
//DATA_IDX:signal index,current code fit in sing-bit singal,so make DATA_IDX==0 default.
//bit_num:current singal's bit postion in REG
//
`define reg_mid_W1T_macro(RST_SOURCE, ADDR, SIG, DATA_IDX = 0) \
  property  SIG``_``DATA_IDX``_W1T(bit [31:0] bit_num); \
    logic data; \
    `define RST_SOURCE  \
    `ifndef NORST \
    disable iff(!RST_SOURCE)  \
    `endif  \
    `undef RST_SOURCE \
    @(negedge clk) \
    `define SIG``_``DATA_IDX  \
    `ifdef SIG``_0  \
      ((paddr === ADDR) && $fell(pwrite) && pwdata[bit_num] && $rose(penable), data =SIG  ) |=> (data == !SIG  ) ##1 (data == SIG);  \
    `else \
      ((paddr === ADDR) && $fell(pwrite) && pwdata[bit_num] && $rose(penable), data =SIG[DATA_IDX]  ) |=> (data == !SIG[DATA_IDX]  ) ##1 (data == SIG[DATA_IDX]);  \
    `endif  \
    `undef SIG``_``DATA_IDX  \
  endproperty  
//*/

`define reg_xclk_W1T_macro(RST_SOURCE, ADDR, SIG, DATA_IDX = 0) \
  property  SIG``_``DATA_IDX``_W1T(bit [31:0] bit_num); \
    logic data; \
    `define RST_SOURCE  \
    `ifndef NORST \
    disable iff(!RST_SOURCE)  \
    `endif  \
    `undef RST_SOURCE \
    @(negedge xclk) \
    `define SIG``_``DATA_IDX  \
    `ifdef SIG``_0  \
      ((xclk_paddr === ADDR) && $fell(xclk_pwrite) && xclk_pwdata[bit_num] && $rose(xclk_penable), data = SIG) |=> (data == !SIG ) ##1 (data == SIG);  \
    `else \
      ((xclk_paddr === ADDR) && $fell(xclk_pwrite) && xclk_pwdata[bit_num] && $rose(xclk_penable), data = SIG[DATA_IDX]) |=> (data == !SIG[DATA_IDX] ) ##1 (data == SIG[DATA_IDX]);  \
    `endif  \
    `undef SIG``_``DATA_IDX  \
  endproperty  

`define reg_lvro_W1T_macro(RST_SOURCE, ADDR, IS_REG, SIG) \
  property  SIG``_0_W1T(bit [31:0] bit_num ); \
    logic data; \
    `define RST_SOURCE  \
    `ifndef NORST \
    disable iff(!RST_SOURCE || reg_ro_cg_en)  \
    `else \
    disable iff(reg_ro_cg_en)  \
    `endif  \
    `undef RST_SOURCE \
    @(negedge xclk) (xclk_paddr === ADDR) && $fell(xclk_pwrite) && xclk_pwdata[bit_num] && $rose(xclk_penable) |=> @(negedge lvro_clk) ##[35:50]  ($rose(IS_REG), data = SIG) ##1 (data == !SIG ) ##1 (data == SIG);  \
  endproperty



//             __    __    __    __    __    
// clk       _|  |__|  |__|  |__|  |__|  |__ 
//                   ___________
// psel            _|           |__________
//                   _____
// pwrite          _|     |__________
//                         _____
// penable         _______|     |________
//                    ____x_____
// paddr           __/          \_____
//                         _____
// pwdata[bit_num] _______|     |________


//-------------------------------------------------------------------------------
// -------------------------------------------------------------------------------
// NOTE: mid_clk domain
//
// No.1 check work.reg_core_rd_addr.core_rd_clr,                  bit [31] 
// No.2 check Work.reg_nonce_update.reg_nonce_update,             bit [31] 
// No.3 check work.reg_cfg.reg_cfg_rstfifo,                       bit [31] 
// No.4 check work.reg_spdsyc_cfg.reg_cfg_spdgo,                  bit [31] 
// No.5 check Work.reg_ft.reg_ftst,                               bit [31] 
// No.6 check Work.reg_ftdbg.reg_ft_bitmap_clr,                   bit [31] 
// No.7 check speed.reg_ss_ctrl.reg_glbsetvld,                        bit [ 3] 
// No.8 check speed.reg_reg_spdlog_reset.reg_spdlog_reset,                bit [ 0] 
// No.9 check speed.reg_selfcal_ctrl.reg_glbselfcal_en,           bit [ 1] 
// No.10 check speed.reg_gbp_ctrl.gbp_vld,                        bit [ 1] 
// No.11 check speed.reg_selfcnt_ctrl.reg_glb_thsr_rq,            bit [ 0] 
// No.12 check speed.reg_selfvec_aging_ctrl.reg_self_aging_start, bit [31] 
// No.13 check speed.reg_lfb_ctrl.lfb_clear,                      bit [ 1] 
// -------------------------------------------------------------------------------
`reg_mid_W1T_macro(mid_rst_n,   REG_CORE_RD_ADDR_ADDR        , reg_core_rd_clr     , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_NONCE_UPDATE_ADDR        , reg_nonce_update    , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_CFG_ADDR                 , reg_cfg_rstfifo     , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_SPDSYC_CFG_ADDR          , reg_cfg_spdgo       , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_FT_ADDR                  , reg_ftst            , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_FTDBG_ADDR               , reg_ft_bitmap_clr   , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_SS_CTRL_ADDR             , reg_glbsetvld       , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_SPDLOG_RESET_ADDR        , reg_spdlog_reset    , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_GBP_CTRL_ADDR            , reg_gbp_vld         , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_SELFCNT_CTRL_ADDR        , reg_glb_thsr_rq     , 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_SELFVEC_AGING_CTRL_ADDR  , reg_self_aging_start, 0 )
`reg_mid_W1T_macro(mid_rst_n,   REG_LFB_CTRL_ADDR            , reg_lfb_clear       , 0 )
//

chk_reg_core_rd_clr_0_W1T:
assert property(reg_core_rd_clr_0_W1T(31)) else `uvm_error("[ASSERT ERR]","Work.reg_core_rd_addr.reg_core_rd_clr W1T not match!")
chk_reg_nonce_update_0_W1T:
assert property(reg_nonce_update_0_W1T(31)) else `uvm_error("[ASSERT ERR]","Work.reg_nonce_update.reg_nonce_update W1T not match!")
chk_reg_cfg_rstfifo_0_W1T:
assert property(reg_cfg_rstfifo_0_W1T(31)) else `uvm_error("[ASSERT ERR]","work.reg_cfg.reg_cfg_rstfifo W1T not match!")
chk_reg_cfg_spdgo_0_W1T:
assert property(reg_cfg_spdgo_0_W1T(31)) else `uvm_error("[ASSERT ERR]","Work.reg_spdsyc_cfg.reg_cfg_spdgo W1T not match!")
chk_reg_ftst_0_W1T:
assert property(reg_ftst_0_W1T(31)) else `uvm_error("[ASSERT ERR]","Work.reg_ft.reg_ftst W1T not match!")
chk_reg_ft_bitmap_clr_0_W1T:
assert property(reg_ft_bitmap_clr_0_W1T(31)) else `uvm_error("[ASSERT ERR]","Work.reg_ftdbg.reg_ft_bitmap_clr W1T not match!")
chk_reg_glbsetvld_0_W1T:
assert property(reg_glbsetvld_0_W1T(3))   else `uvm_error("[ASSERT ERR]","speed.reg_ss_ctrl.reg_glbsetvld W1T not match!")
chk_reg_spdlog_reset_0_W1T:
assert property(reg_spdlog_reset_0_W1T(0)) else `uvm_error("[ASSERT ERR]","speed.reg_reg_spdlog_reset.reg_spdlog_reset W1T not match!")
chk_reg_gbp_vld_0_W1T:
assert property(reg_gbp_vld_0_W1T(1)) else `uvm_error("[ASSERT ERR]","speed.reg_gbp_ctrl.reg_gbp_vld W1T not match!")
chk_reg_glb_thsr_rq_0_W1T:
assert property(reg_glb_thsr_rq_0_W1T(0)) else `uvm_error("[ASSERT ERR]","speed.reg_selfcnt_ctrl.reg_glb_thsr_rq W1T not match!")
chk_reg_self_aging_start_0_W1T:
assert property(reg_self_aging_start_0_W1T(31)) else `uvm_error("[ASSERT ERR]","speed.reg_selfvec_aging_ctrl.reg_self_aging_start W1T not match!")
assert property(reg_lfb_clear_0_W1T(1)) else `uvm_error("[ASSERT ERR]","speed.reg_lfb_ctrl.lfb_clear W1T not match!")


cov_reg_core_rd_clr_0_W1T: cover property(reg_core_rd_clr_0_W1T(31));
cov_reg_nonce_update_0_W1T: cover property(reg_nonce_update_0_W1T(31));
cov_reg_cfg_rstfifo_0_W1T: cover property(reg_cfg_rstfifo_0_W1T(31));
cov_reg_cfg_spdgo_0_W1T: cover property(reg_cfg_spdgo_0_W1T(31));
cov_reg_ftst_0_W1T: cover property(reg_ftst_0_W1T(31));
cov_reg_ft_bitmap_clr_0_W1T: cover property(reg_ft_bitmap_clr_0_W1T(31));
cov_reg_glbsetvld_0_W1T: cover property(reg_glbsetvld_0_W1T(3));
cov_reg_spdlog_reset_0_W1T: cover property(reg_spdlog_reset_0_W1T(0));
cov_reg_gbp_vld_0_W1T: cover property(reg_gbp_vld_0_W1T(1));
cov_reg_glb_thsr_rq_0_W1T:  cover property(reg_glb_thsr_rq_0_W1T(0));
cov_reg_self_aging_start_0_W1T: cover property(reg_self_aging_start_0_W1T(31));
cov_reg_lfb_clear_0_W1T: cover property(reg_lfb_clear_0_W1T(1));


// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------
// NOTE: xclk domain
// 
// No.1   Cpm.REG_PLL0L1.REG_PLL0_AUTORESET_PRE,    bit[0] 
// No.2   Cpm.REG_PLL1L1.REG_PLL1_AUTORESET_PRE,    bit[0] 
// No.3   Cpm.REG_PLL2L1.REG_PLL2_AUTORESET_PRE,   bit[0] 
// No.4   Cpm.REG_PLL3L1.REG_PLL3_AUTORESET_PRE,   bit[0] 
// No.5   Cpm.REG_DIVCNT_CTRL.reg_divcnt_ctrl_slice_divcnt_clr, bit[0] 
// No.7   comm.REG_UART_CFG3.REG_UART_SOFTRST   bit[0] 
// No.8   comm.REG_mx2_rst.REG_mx2_sft_rst      bit[0] 
//
// No.9   lvro_inst.REG_roctrl0_0.REG_lvro_rst0_0    bit[8] 
// No.10  lvro_inst.REG_roctrl1_0.REG_lvro_rst1_0    bit[8] 
// No.11  lvro_inst.REG_roctrl0_1.REG_lvro_rst0_1    bit[8] 
// No.12  lvro_inst.REG_roctrl1_1.REG_lvro_rst1_1    bit[8] 

// -------------------------------------------------------------------------------
//`reg_xclk_W1T_macro(ri_rst_n,   REG_PLL0L1_ADDR       ,   reg_pll0_autoreset_pre    , 0 )
//`reg_xclk_W1T_macro(ri_rst_n,   REG_PLL1L1_ADDR       ,   reg_pll1_autoreset_pre    , 0 )
//`reg_xclk_W1T_macro(ri_rst_n,   REG_PLL2L1_ADDR       ,   reg_pll2_autoreset_pre    , 0 )
//`reg_xclk_W1T_macro(ri_rst_n,   REG_PLL3L1_ADDR       ,   reg_pll3_autoreset_pre    , 0 )
`reg_xclk_W1T_macro(ri_rst_n,   REG_DIVCNT_CTRL_ADDR  ,   reg_divcnt_ctrl_slice_divcnt_clr      , 0 )
`reg_xclk_W1T_macro(ri_rst_n,   REG_UART_CFG3_ADDR    ,   reg_uart_softrst      , 0 )
`reg_xclk_W1T_macro(ri_rst_n,   REG_MX2_RST_ADDR      ,   reg_mx2_sft_rst       , 0 )

`reg_lvro_W1T_macro(rst_n_l,   REG_ROCTRL0_0_ADDR    , is_reg_roctrl0_0,  reg_lvro_rst0_0 )
`reg_lvro_W1T_macro(rst_n_l,   REG_ROCTRL1_0_ADDR    , is_reg_roctrl1_0,  reg_lvro_rst1_0 )
`reg_lvro_W1T_macro(rst_n_l,   REG_ROCTRL0_1_ADDR    , is_reg_roctrl0_1,  reg_lvro_rst0_1 )
`reg_lvro_W1T_macro(rst_n_l,   REG_ROCTRL1_1_ADDR    , is_reg_roctrl1_1,  reg_lvro_rst1_1 )




//chk_reg_pll0_autoreset_pre_0_W1T:
//assert property(reg_pll0_autoreset_pre_0_W1T(0))  else `uvm_error("[ASSERT ERR]","cpm.reg_pll0l1.reg_pll0_autoreset_pre W1T not match!")
//chk_reg_pll1_autoreset_pre_0_W1T:
//assert property(reg_pll1_autoreset_pre_0_W1T(0))  else `uvm_error("[ASSERT ERR]","cpm.reg_pll1l1.reg_pll1_autoreset_pre W1T not match!")
//chk_reg_pll2_autoreset_pre_0_W1T:
//assert property(reg_pll2_autoreset_pre_0_W1T(0))  else `uvm_error("[ASSERT ERR]","cpm.reg_pll2l1.reg_pll2_autoreset_pre W1T not match!")
//chk_reg_pll3_autoreset_pre_0_W1T:
//assert property(reg_pll3_autoreset_pre_0_W1T(0))  else `uvm_error("[ASSERT ERR]","cpm.reg_pll3l1.reg_pll3_autoreset_pre W1T not match!")
chk_reg_divcnt_ctrl_slice_divcnt_clr_0_0_W1T:
assert property(reg_divcnt_ctrl_slice_divcnt_clr_0_W1T(0))  else `uvm_error("[ASSERT ERR]","Cpm.REG_DIVCNT_CTRL.reg_divcnt_ctrl_slice_divcnt_clr[0] W1T not match!")
chk_uart_softrst_0_W1T:
assert property(reg_uart_softrst_0_W1T(0))  else `uvm_error("[ASSERT ERR]","comm.reg_uart_cfg3.reg_uart_softrst W1T not match!")
chk_mx2_sft_rst_0_W1T:
assert property(reg_mx2_sft_rst_0_W1T(0))  else `uvm_error("[ASSERT ERR]","rst.reg_mx2_rst.reg_mx2_sft_rst W1T not match!")

//chk_reg_lvro_rst0_0_0_W1T:
//assert property(reg_lvro_rst0_0_0_W1T(8))  else `uvm_error("[ASSERT ERR]","lvro_inst.reg_roctrl0_0.reg_lvro_rst0_0 W1T not match!")
//chk_reg_lvro_rst1_0_0_W1T:
//assert property(reg_lvro_rst1_0_0_W1T(8))  else `uvm_error("[ASSERT ERR]","lvro_inst.reg_roctrl1_0.reg_lvro_rst1_0 W1T not match!")
//chk_reg_lvro_rst0_1_0_W1T:
//assert property(reg_lvro_rst0_1_0_W1T(8))  else `uvm_error("[ASSERT ERR]","lvro_inst.reg_roctrl0_1.reg_lvro_rst0_1 W1T not match!")
//chk_reg_lvro_rst1_1_0_W1T:
//assert property(reg_lvro_rst1_1_0_W1T(8))  else `uvm_error("[ASSERT ERR]","lvro_inst.reg_roctrl1_1.reg_lvro_rst1_1 W1T not match!")


//cov_reg_pll0_autoreset_pre_0_W1T: cover property(reg_pll0_autoreset_pre_0_W1T(0));
//cov_reg_pll1_autoreset_pre_0_W1T: cover property(reg_pll1_autoreset_pre_0_W1T(0));
//cov_reg_pll2_autoreset_pre_0_W1T: cover property(reg_pll2_autoreset_pre_0_W1T(0));
//cov_reg_pll3_autoreset_pre_0_W1T: cover property(reg_pll3_autoreset_pre_0_W1T(0));
cov_reg_divcnt_ctrl_slice_divcnt_clr_0_0_W1T: cover property(reg_divcnt_ctrl_slice_divcnt_clr_0_W1T(0));
cov_reg_uart_softrst_0_W1T: cover property(reg_uart_softrst_0_W1T(0));
cov_reg_mx2_sft_rst_0_W1T:  cover property(reg_mx2_sft_rst_0_W1T(0));
cov_reg_lvro_rst0_0_0_W1T:  cover property(reg_lvro_rst0_0_0_W1T(8));
cov_reg_lvro_rst1_0_0_W1T:  cover property(reg_lvro_rst1_0_0_W1T(8));
cov_reg_lvro_rst0_1_0_W1T:  cover property(reg_lvro_rst0_1_0_W1T(8));
cov_reg_lvro_rst1_1_0_W1T:  cover property(reg_lvro_rst1_1_0_W1T(8));




//No.16 check EFUSE.reg_efuse_ctrl, bit [3:0], [6] 
// FIX ME about W1T for efuse reg
// property reg_efuse_ctrl_W1T(bit [6:0] bit_num);
//   logic data;
//   disable iff( pin_ri || (!pin_ri && reg_prog_mode[1]))
//   //disable iff(pin_ri)
//   @(negedge xclk) 
//   ((xclk_paddr === REG_EFUSE_CTRL_ADDR) && $fell(xclk_pwrite) && xclk_pwdata[bit_num] && $rose(xclk_penable), data = reg_efuse_ctrl[bit_num]) |=> (reg_efuse_ctrl[bit_num] == !data) ##1 (reg_efuse_ctrl[bit_num] == data);
// endproperty


// chk_reg_efuse_ctrl_0_W1T:
// assert property(reg_efuse_ctrl_W1T(0))  else `uvm_error("[ASSERT ERR]","EFUSE.reg_efuse_ctrl[0] W1T not match!")
// chk_reg_efuse_ctrl_1_W1T:
// assert property(reg_efuse_ctrl_W1T(1))  else `uvm_error("[ASSERT ERR]","EFUSE.reg_efuse_ctrl[1] W1T not match!")
// chk_reg_efuse_ctrl_2_W1T:
// assert property(reg_efuse_ctrl_W1T(2))  else `uvm_error("[ASSERT ERR]","EFUSE.reg_efuse_ctrl[2] W1T not match!")
// chk_reg_efuse_ctrl_3_W1T:
// assert property(reg_efuse_ctrl_W1T(3))  else `uvm_error("[ASSERT ERR]","EFUSE.reg_efuse_ctrl[3] W1T not match!")
// chk_reg_efuse_ctrl_6_W1T:
// assert property(reg_efuse_ctrl_W1T(6))  else `uvm_error("[ASSERT ERR]","EFUSE.reg_efuse_ctrl[6] W1T not match!")

// cov_reg_efuse_ctrl_0_W1T: cover property(reg_efuse_ctrl_W1T(0));
// cov_reg_efuse_ctrl_1_W1T: cover property(reg_efuse_ctrl_W1T(1));
// cov_reg_efuse_ctrl_2_W1T: cover property(reg_efuse_ctrl_W1T(2));
// cov_reg_efuse_ctrl_3_W1T: cover property(reg_efuse_ctrl_W1T(3));
// cov_reg_efuse_ctrl_6_W1T: cover property(reg_efuse_ctrl_W1T(6));




// ------------------------------------------
// ECO spare W1T
// 1,   reg_work_eco_w1t1        [30], [31]
// 2,   reg_mx2_bridge_eco_w1t1       [30], [31]
// 3,   reg_speed_eco_w1t1            [30], [31]
// 4,   reg_cpm_eco_w1t1              [30], [31]
// 5,   reg_lvro_eco_w1t1             [30], [31]
// 7,   reg_comm_interface_eco_w1t1   [30], [31]
// 8,   reg_rst_eco_w1t1           [30], [31]
// ---------------------------,--------------
`reg_mid_W1T_macro(NORST,   REG_WORK_CTRL_RFU_ADDR       ,  reg_work_eco_w1t1            , 0)
`reg_mid_W1T_macro(NORST,   REG_WORK_CTRL_RFU_ADDR       ,  reg_work_eco_w1t2            , 0)
`reg_mid_W1T_macro(NORST,   REG_MX2_BRIDGE_RFU_ADDR      ,  reg_mx2_bridge_eco_w1t1      , 0)
`reg_mid_W1T_macro(NORST,   REG_MX2_BRIDGE_RFU_ADDR      ,  reg_mx2_bridge_eco_w1t2      , 0)
`reg_mid_W1T_macro(NORST,   REG_SPEED_RFU_ADDR           ,  reg_speed_eco_w1t1           , 0)
`reg_mid_W1T_macro(NORST,   REG_SPEED_RFU_ADDR           ,  reg_speed_eco_w1t2           , 0)

`reg_xclk_W1T_macro(NORST,  REG_CPM_RFU_ADDR            ,  reg_cpm_eco_w1t1             , 0)
`reg_xclk_W1T_macro(NORST,  REG_CPM_RFU_ADDR            ,  reg_cpm_eco_w1t2             , 0)
`reg_xclk_W1T_macro(NORST,  REG_LVRO_RFU_ADDR           ,  reg_lvro_eco_w1t1            , 0)
`reg_xclk_W1T_macro(NORST,  REG_LVRO_RFU_ADDR           ,  reg_lvro_eco_w1t2            , 0)

`reg_xclk_W1T_macro(NORST,  REG_COMM_INTERFACE_RFU_ADDR ,  reg_comm_interface_eco_w1t1  , 0)
`reg_xclk_W1T_macro(NORST,  REG_COMM_INTERFACE_RFU_ADDR ,  reg_comm_interface_eco_w1t2  , 0)
`reg_xclk_W1T_macro(NORST,  REG_RST_RFU_ADDR            ,  reg_rst_eco_w1t1             , 0)
`reg_xclk_W1T_macro(NORST,  REG_RST_RFU_ADDR            ,  reg_rst_eco_w1t2             , 0)

chk_reg_work_eco_w1t1_0_W1T:
assert property(reg_work_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","work.reg_work_eco_w1t1 W1T not match!")
chk_reg_work_eco_w1t2_0_W1T:
assert property(reg_work_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","work.reg_work_eco_w1t2 W1T not match!")
chk_reg_mx2_bridge_eco_w1t1_0_W1T:
assert property(reg_mx2_bridge_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","work.reg_mx2_bridge_eco_w1t1 W1T not match!")
chk_reg_mx2_bridge_eco_w1t2_0_W1T:
assert property(reg_mx2_bridge_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","work.reg_mx2_bridge_eco_w1t2 W1T not match!")
chk_reg_speed_eco_w1t1_0_W1T:
assert property(reg_speed_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","speed.reg_speed_eco_w1t1 W1T not match!")
chk_reg_speed_eco_w1t2_0_W1T:
assert property(reg_speed_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","speed.reg_speed_eco_w1t2 W1T not match!")

chk_reg_cpm_eco_w1t1_0_W1T:
assert property(reg_cpm_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","cpm.reg_cpm_eco_w1t1 W1T not match!")
chk_reg_cpm_eco_w1t2_0_W1T:
assert property(reg_cpm_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","cpm.reg_cpm_eco_w1t2 W1T not match!")
//chk_reg_lvro_eco_w1t1_0_W1T:
//assert property(reg_lvro_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","ro.reg_lvro_eco_w1t1 W1T not match!")
//chk_reg_lvro_eco_w1t2_0_W1T:
//assert property(reg_lvro_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","ro.reg_lvro_eco_w1t2 W1T not match!")

chk_reg_comm_interface_eco_w1t1_0_W1T:
assert property(reg_comm_interface_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","comm.reg_comm_interface_eco_w1t1 W1T not match!")
chk_reg_comm_interface_eco_w1t2_0_W1T:
assert property(reg_comm_interface_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","comm.reg_comm_interface_eco_w1t2 W1T not match!")
chk_reg_rst_eco_w1t1_0_W1T:
assert property(reg_rst_eco_w1t1_0_W1T(30))  else `uvm_error("[ASSERT ERR]","rst.reg_rst_eco_w1t1 W1T not match!")
chk_reg_rst_eco_w1t2_0_W1T:
assert property(reg_rst_eco_w1t2_0_W1T(31))  else `uvm_error("[ASSERT ERR]","rst.reg_rst_eco_w1t2 W1T not match!")



cov_reg_work_eco_w1t1_0_W1T      : cover property(reg_work_eco_w1t1_0_W1T(30))     ;
cov_reg_work_eco_w1t2_0_W1T      : cover property(reg_work_eco_w1t2_0_W1T(31))     ;
cov_reg_mx2_bridge_eco_w1t1_0_W1T     : cover property(reg_mx2_bridge_eco_w1t1_0_W1T(30))    ;
cov_reg_mx2_bridge_eco_w1t2_0_W1T     : cover property(reg_mx2_bridge_eco_w1t2_0_W1T(31))    ;
cov_reg_speed_eco_w1t1_0_W1T          : cover property(reg_speed_eco_w1t1_0_W1T(30))         ;
cov_reg_speed_eco_w1t2_0_W1T          : cover property(reg_speed_eco_w1t2_0_W1T(31))         ;
cov_reg_cpm_eco_w1t1_0_W1T            : cover property(reg_cpm_eco_w1t1_0_W1T(30))           ;
cov_reg_cpm_eco_w1t2_0_W1T            : cover property(reg_cpm_eco_w1t2_0_W1T(31))           ;
cov_reg_lvro_eco_w1t1_0_W1T           : cover property(reg_lvro_eco_w1t1_0_W1T(30))          ;
cov_reg_lvro_eco_w1t2_0_W1T           : cover property(reg_lvro_eco_w1t2_0_W1T(31))          ;

cov_reg_comm_interface_eco_w1t1_0_W1T : cover property(reg_comm_interface_eco_w1t1_0_W1T(30));
cov_reg_comm_interface_eco_w1t2_0_W1T : cover property(reg_comm_interface_eco_w1t2_0_W1T(31));
cov_reg_rst_eco_w1t1_0_W1T            : cover property(reg_rst_eco_w1t1_0_W1T(30))        ;
cov_reg_rst_eco_w1t2_0_W1T            : cover property(reg_rst_eco_w1t2_0_W1T(31))        ;

// ------------------------------------------
// ECO spare W1T, ECO_BUF 
// 1,   reg_work_eco_w1t1        [30], [31]
// 2,   reg_mx2_bridge_eco_w1t1       [30], [31]
// 3,   reg_speed_eco_w1t1            [30], [31]
// 4,   reg_cpm_eco_w1t1              [30], [31]
// 5,   reg_lvro_eco_w1t1             [30], [31]

// 7,   reg_comm_interface_eco_w1t1   [30], [31]
// 8,   reg_rst_eco_w1t1           [30], [31]
// ---------------------------,--------------
`reg_mid_W1T_macro(NORST,   REG_WORK_CTRL_RFU_ADDR       ,  reg_work_eco_w1t1_buf            , 0)
`reg_mid_W1T_macro(NORST,   REG_WORK_CTRL_RFU_ADDR       ,  reg_work_eco_w1t2_buf            , 0)
`reg_mid_W1T_macro(NORST,   REG_MX2_BRIDGE_RFU_ADDR      ,  reg_mx2_bridge_eco_w1t1_buf      , 0)
`reg_mid_W1T_macro(NORST,   REG_MX2_BRIDGE_RFU_ADDR      ,  reg_mx2_bridge_eco_w1t2_buf      , 0)
`reg_mid_W1T_macro(NORST,   REG_SPEED_RFU_ADDR           ,  reg_speed_eco_w1t1_buf           , 0)
`reg_mid_W1T_macro(NORST,   REG_SPEED_RFU_ADDR           ,  reg_speed_eco_w1t2_buf           , 0)

`reg_xclk_W1T_macro(NORST,  REG_CPM_RFU_ADDR            ,  reg_cpm_eco_w1t1_buf             , 0)
`reg_xclk_W1T_macro(NORST,  REG_CPM_RFU_ADDR            ,  reg_cpm_eco_w1t2_buf             , 0)
`reg_xclk_W1T_macro(NORST,  REG_LVRO_RFU_ADDR           ,  reg_lvro_eco_w1t1_buf            , 0)
`reg_xclk_W1T_macro(NORST,  REG_LVRO_RFU_ADDR           ,  reg_lvro_eco_w1t2_buf            , 0)

`reg_xclk_W1T_macro(NORST,  REG_COMM_INTERFACE_RFU_ADDR ,  reg_comm_interface_eco_w1t1_buf  , 0)
`reg_xclk_W1T_macro(NORST,  REG_COMM_INTERFACE_RFU_ADDR ,  reg_comm_interface_eco_w1t2_buf  , 0)
`reg_xclk_W1T_macro(NORST,  REG_RST_RFU_ADDR            ,  reg_rst_eco_w1t1_buf             , 0)
`reg_xclk_W1T_macro(NORST,  REG_RST_RFU_ADDR            ,  reg_rst_eco_w1t2_buf             , 0)
chk_reg_work_eco_w1t1_buf_0_W1T:
assert property(reg_work_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","work.reg_work_eco_w1t1_buf W1T not match!")
chk_reg_work_eco_w1t2_buf_0_W1T:
assert property(reg_work_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","work.reg_work_eco_w1t2_buf W1T not match!")
chk_reg_mx2_bridge_eco_w1t1_buf_0_W1T:
assert property(reg_mx2_bridge_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","work.reg_mx2_bridge_eco_w1t1_buf W1T not match!")
chk_reg_mx2_bridge_eco_w1t2_buf_0_W1T:
assert property(reg_mx2_bridge_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","work.reg_mx2_bridge_eco_w1t2_buf W1T not match!")
chk_reg_speed_eco_w1t1_buf_0_W1T:
assert property(reg_speed_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","speed.reg_speed_eco_w1t1_buf W1T not match!")
chk_reg_speed_eco_w1t2_buf_0_W1T:
assert property(reg_speed_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","speed.reg_speed_eco_w1t2_buf W1T not match!")

chk_reg_cpm_eco_w1t1_buf_0_W1T:
assert property(reg_cpm_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","cpm.reg_cpm_eco_w1t1_buf W1T not match!")
chk_reg_cpm_eco_w1t2_buf_0_W1T:
assert property(reg_cpm_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","cpm.reg_cpm_eco_w1t2_buf W1T not match!")
//chk_reg_lvro_eco_w1t1_buf_0_W1T:
//assert property(reg_lvro_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","ro.reg_lvro_eco_w1t1_buf W1T not match!")
//chk_reg_lvro_eco_w1t2_buf_0_W1T:
//assert property(reg_lvro_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","ro.reg_lvro_eco_w1t2_buf W1T not match!")

chk_reg_comm_interface_eco_w1t1_buf_0_W1T:
assert property(reg_comm_interface_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","comm.reg_comm_interface_eco_w1t1_buf W1T not match!")
chk_reg_comm_interface_eco_w1t2_buf_0_W1T:
assert property(reg_comm_interface_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","comm.reg_comm_interface_eco_w1t2_buf W1T not match!")
chk_reg_rst_eco_w1t1_buf_0_W1T:
assert property(reg_rst_eco_w1t1_buf_0_W1T(30))  else `uvm_error("[ASSERT ERR]","rst.reg_rst_eco_w1t1_buf W1T not match!")
chk_reg_rst_eco_w1t2_buf_0_W1T:
assert property(reg_rst_eco_w1t2_buf_0_W1T(31))  else `uvm_error("[ASSERT ERR]","rst.reg_rst_eco_w1t2_buf W1T not match!")
cov_reg_work_eco_w1t1_buf_0_W1T      : cover property(reg_work_eco_w1t1_buf_0_W1T(30))     ;
cov_reg_work_eco_w1t2_buf_0_W1T      : cover property(reg_work_eco_w1t2_buf_0_W1T(31))     ;
cov_reg_mx2_bridge_eco_w1t1_buf_0_W1T     : cover property(reg_mx2_bridge_eco_w1t1_buf_0_W1T(30))    ;
cov_reg_mx2_bridge_eco_w1t2_buf_0_W1T     : cover property(reg_mx2_bridge_eco_w1t2_buf_0_W1T(31))    ;
cov_reg_speed_eco_w1t1_buf_0_W1T          : cover property(reg_speed_eco_w1t1_buf_0_W1T(30))         ;
cov_reg_speed_eco_w1t2_buf_0_W1T          : cover property(reg_speed_eco_w1t2_buf_0_W1T(31))         ;
cov_reg_cpm_eco_w1t1_buf_0_W1T            : cover property(reg_cpm_eco_w1t1_buf_0_W1T(30))           ;
cov_reg_cpm_eco_w1t2_buf_0_W1T            : cover property(reg_cpm_eco_w1t2_buf_0_W1T(31))           ;
cov_reg_lvro_eco_w1t1_buf_0_W1T           : cover property(reg_lvro_eco_w1t1_buf_0_W1T(30))          ;
cov_reg_lvro_eco_w1t2_buf_0_W1T           : cover property(reg_lvro_eco_w1t2_buf_0_W1T(31))          ;

cov_reg_comm_interface_eco_w1t1_buf_0_W1T : cover property(reg_comm_interface_eco_w1t1_buf_0_W1T(30));
cov_reg_comm_interface_eco_w1t2_buf_0_W1T : cover property(reg_comm_interface_eco_w1t2_buf_0_W1T(31));
cov_reg_rst_eco_w1t1_buf_0_W1T            : cover property(reg_rst_eco_w1t1_buf_0_W1T(30))        ;
cov_reg_rst_eco_w1t2_buf_0_W1T            : cover property(reg_rst_eco_w1t2_buf_0_W1T(31))        ;



// -------------------------------------------------------------------------------
// RC
// -------------------------------------------------------------------------------
//No.1 check speed.reg_freq_sum.reg_freq_sum_rdy                        bit[31]
property reg_freq_sum_rdy_RC;
  disable iff(!mid_rst_n || (thsr_rdy && !reg_thsr_skip ))
  @(negedge clk) 
  ((paddr === REG_FREQ_SUM_ADDR) && $rose(penable) && ($past(pwrite , 1) == 0) ) |=>  (reg_freq_sum_rdy == 0) ;
endproperty

chk_reg_freq_sum_rdy_RC:
    assert property(reg_freq_sum_rdy_RC)  
    else `uvm_error("[ASSERT ERR]","speed.reg_freq_sum.reg_freq_sum_rdy RC not match!")
cov_reg_freq_sum_rdy_RC:  cover property(reg_freq_sum_rdy_RC);


//No.2 check speed.reg_hashrate_sum.reg_hashrate_sum_rdy                bit[31]
property reg_hashrate_sum_rdy_RC;
  disable iff(!mid_rst_n || (thsr_rdy && mode ))
  @(negedge clk) 
  ((paddr === REG_HASHRATE_SUM_ADDR) && $rose(penable) && ($past(pwrite , 1) == 0) ) |=>  (reg_hashrate_sum_rdy == 0) ;
endproperty

chk_reg_hashrate_sum_rdy_RC:  
    assert property(reg_hashrate_sum_rdy_RC)  
    else `uvm_error("[ASSERT ERR]","speed.reg_hashrate_sum.reg_hashrate_sum_rdy RC not match!")
cov_reg_hashrate_sum_rdy_RC:  cover property(reg_hashrate_sum_rdy_RC);


//No.3 check speed.reg_selfvec_aging_hashrate.reg_self_aging_ave_done   bit[31]
property reg_self_aging_ave_done_RC;
  disable iff(!mid_rst_n )
  @(negedge clk) 
  ((paddr === REG_SELFVEC_AGING_HASHRATE_ADDR) && $rose(penable) && ($past(pwrite , 1) == 0) ) |=>  (reg_self_aging_ave_done == 0) ;
endproperty

chk_reg_self_aging_ave_done_RC:
    assert property(reg_self_aging_ave_done_RC)  
    else `uvm_error("[ASSERT ERR]","speed.reg_selfvec_aging_hashrate.reg_self_aging_ave_done RC not match!")
cov_reg_self_aging_ave_done_RC:   cover property(reg_self_aging_ave_done_RC);



//No.4 check pvt.reg_tvsenr.reg_tvsenr_rdy                            bit[24]
property reg_tvsenr_rdy_RC;
  @(negedge xclk) 
  ((xclk_paddr === REG_TVSENR_ADDR) && $rose(xclk_penable) && ($past(xclk_pwrite , 1) == 0) ) |=>  (reg_tvsenr_rdy == 0) ;
endproperty

chk_reg_tvsenr_rdy_RC:
    assert property(reg_tvsenr_rdy_RC)  
    else `uvm_error("[ASSERT ERR]","pvt.reg_tvsenr.reg_tvsenr_rdy RC not match!")
cov_reg_tvsenr_rdy_RC:    cover property(reg_tvsenr_rdy_RC);
`endif    //
`endif