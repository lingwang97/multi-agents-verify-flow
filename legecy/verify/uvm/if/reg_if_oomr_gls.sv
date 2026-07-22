
`define SYS_CTRL    `BTC0.sys_ctrl
`define REG         `BTC0.sys_ctrl.u_top_reg_cfg
`define JLS2APB     `BTC0.sys_ctrl.comm_interface.mid_apb_decoder
`define XCLK_APB    `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder
`define STD_APB     `BTC0.sys_ctrl.comm_interface.std_apb_decoder
`define WORK_CTRL   `BTC0.sys_ctrl.work_ctrl
`define SPEED       `BTC0.sys_ctrl.speed
`define RST         `BTC0.sys_ctrl.crg
`define CPM         `BTC0.sys_ctrl.crg
`define PVT         `BTC0.evt_top.u_pvt_top
`define EFUSE       `BTC0.evt_top.u_efuse
`define LVRO_MST_REG    `BTC0.sys_ctrl.lvro_master_ctrl.lvro_master_regfile
`define COMM_REG    `BTC0.sys_ctrl.comm_interface.comm_interface_regfile



`HDLREF_wire_assign(reg_pif.mid_rst_n ,   `REG.mid_rst_n    ,   0 ,  0)  ; 
`HDLREF_wire_assign(reg_pif.ri_rst_n  ,   `RST.ri_rst_n     ,   0 ,  0)  ; 
`HDLREF_wire_assign(reg_pif.rst_n_l   ,   `RST.ro_rst_n     ,   0 ,  0)  ; 
`HDLREF_wire_assign(reg_pif.pin_ri    ,   `EFUSE.pin_ri     ,   0 ,  0)  ;
`HDLREF_reg_assign( reg_pif.tp_sel    ,   `COMM_IF.tp_sel   ,   0 ,  0)  ;

  `HDLREF_wire_assign(reg_pif.clk         , `COMM_IF.mid_clk    ,   0 ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk        , `COMM_IF.xclk     ,   0 ,   0)  ;
//-------------------------------------------------------------------
//mid_apb_decoder
`ifndef USE_JAMLINK_DRV
`ifndef USE_UART_DRV
  `HDLREF_wire_assign(reg_pif.psel    ,   jls_pif.psel   ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.paddr   ,   jls_pif.paddr  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.penable ,   jls_pif.penable,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pwrite  ,   jls_pif.pwrite ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pwdata  ,   jls_pif.pwdata ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pready   ,  jls_pif.pready ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.prdata   ,  jls_pif.prdata ,   31  ,   0)  ;
  
  `HDLREF_wire_assign(reg_pif.xclk_pwdata ,   jls_pif.pwdata  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_paddr  ,   jls_pif.paddr   ,   31  ,   0)  ;
  
  `HDLREF_wire_assign(reg_pif.xclk_psel   ,   jls_pif.xclk_psel    ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_penable,   jls_pif.xclk_penable ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pwrite ,   jls_pif.xclk_pwrite  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pready  ,  jls_pif.xclk_pready  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_prdata  ,  jls_pif.xclk_prdata  ,   31  ,   0)  ;
`else  
  `HDLREF_wire_assign(reg_pif.psel    , `JLS2APB.psel   ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.paddr   , `JLS2APB.paddr  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.penable , `JLS2APB.penable,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pwrite  , `JLS2APB.pwrite ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pwdata  , `JLS2APB.pwdata ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pready   , `JLS2APB.pready ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.prdata   , `JLS2APB.prdata ,   31  ,   0)  ;
  
  
  `HDLREF_wire_assign(reg_pif.xclk_psel   ,   `XCLK_APB.psel    ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_paddr  ,   `XCLK_APB.paddr   ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_penable,   `XCLK_APB.penable ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pwrite ,   `XCLK_APB.pwrite  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pwdata ,   `XCLK_APB.pwdata  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pready  ,   `XCLK_APB.pready  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_prdata  ,   `XCLK_APB.prdata  ,   31  ,   0)  ;
  
  `HDLREF_wire_assign(reg_pif.std_psel   ,   `STD_APB.psel    ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_paddr  ,   `STD_APB.paddr   ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_penable,   `STD_APB.penable ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_pwrite ,   `STD_APB.pwrite  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_pwdata ,   `STD_APB.pwdata  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_pready  ,  `STD_APB.pready  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_prdata  ,  `STD_APB.prdata  ,   31  ,   0)  ;
`endif
`else

  `HDLREF_wire_assign(reg_pif.psel    , `JLS2APB.psel   ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.paddr   , `JLS2APB.paddr  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.penable , `JLS2APB.penable,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pwrite  , `JLS2APB.pwrite ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pwdata  , `JLS2APB.pwdata ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.pready   , `JLS2APB.pready ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.prdata   , `JLS2APB.prdata ,   31  ,   0)  ;
  
  
  `HDLREF_wire_assign(reg_pif.xclk_psel   ,   `XCLK_APB.psel    ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_paddr  ,   `XCLK_APB.paddr   ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_penable,   `XCLK_APB.penable ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pwrite ,   `XCLK_APB.pwrite  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pwdata ,   `XCLK_APB.pwdata  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_pready  ,   `XCLK_APB.pready  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.xclk_prdata  ,   `XCLK_APB.prdata  ,   31  ,   0)  ;
  
  `HDLREF_wire_assign(reg_pif.std_psel   ,   `STD_APB.psel    ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_paddr  ,   `STD_APB.paddr   ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_penable,   `STD_APB.penable ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_pwrite ,   `STD_APB.pwrite  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_pwdata ,   `STD_APB.pwdata  ,   31  ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_pready  ,  `STD_APB.pready  ,   0   ,   0)  ;
  `HDLREF_wire_assign(reg_pif.std_prdata  ,  `STD_APB.prdata  ,   31  ,   0)  ;
`endif


//-------------------------------------------------------------------



//-------------------------------------------------------------------
// W1T reg_field
// assign reg_pif.reg_cfg[9]       =   `REG.REG_Cfg_FTSt  ;

`HDLREF_reg_assign(reg_pif.reg_core_rd_clr      ,   `REG.REG_Core_rd_clr      ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_nonce_update     ,   `REG.REG_Nonce_Update     ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_cfg_rstfifo      ,   `REG.REG_Cfg_RstFifo      ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_glbsetvld        ,   `REG.REG_GlbSetVld        ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_spdlog_reset     ,   `REG.REG_SpdLog_reset     ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_ft_bitmap_clr    ,   `REG.work_regfile.REG_ft_bitmap_clr    ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_cfg_spdgo        ,   `REG.REG_Cfg_SpdGo        ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_ftst             ,   `REG.REG_FTSt             ,     0,  0)  ;

`HDLREF_reg_assign(reg_pif.reg_ntime_half_work  ,   `REG.REG_ntime_half_work  ,     0,  0)  ;

//selfclk
//`ifdef PL_SIM
`HDLREF_reg_assign(reg_pif.reg_lfb_clear       ,         `REG.REG_lfb_clear         ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_glb_thsr_rq     ,         `REG.REG_glb_thsr_rq       ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_self_aging_start,         `REG.REG_self_aging_start  ,     0,  0)  ;


`HDLREF_reg_assign(reg_pif.reg_pll0_autoreset_pre ,   `CPM.crg_regfile.REG_PLL0_AUTORESET_PRE,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_pll1_autoreset_pre ,   `CPM.crg_regfile.REG_PLL1_AUTORESET_PRE,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_pll2_autoreset_pre ,   `CPM.crg_regfile.REG_PLL2_AUTORESET_PRE,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_pll3_autoreset_pre ,   `CPM.crg_regfile.REG_PLL3_AUTORESET_PRE,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_divcnt_ctrl_slice_divcnt_clr ,   `CPM.crg_regfile.REG_DIVCNT_CTRL_SLICE_DIVCNT_CLR,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_gbp_vld        ,   `REG.REG_gbp_vld          ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_uart_softrst   ,   `COMM_IF.REG_UART_SOFTRST ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_mx2_sft_rst    ,   `CPM.REG_mx2_sft_rst      ,     0,  0)  ;

`HDLREF_reg_assign(reg_pif.reg_ro_cg_en      , `REG.work_regfile.REG_Ro_CG_en     , 0,  0)  ;


//rfu W1T SIG, regfile 
assign reg_pif.reg_work_eco_w1t1           = `REG.work_regfile.REG_work_eco_w1t1         ;
assign reg_pif.reg_work_eco_w1t2           = `REG.work_regfile.REG_work_eco_w1t2         ;
assign reg_pif.reg_mx2_bridge_eco_w1t1     = `REG.work_regfile.REG_mx2_bridge_eco_w1t1   ;
assign reg_pif.reg_mx2_bridge_eco_w1t2     = `REG.work_regfile.REG_mx2_bridge_eco_w1t2   ;
assign reg_pif.reg_speed_eco_w1t1          = `REG.speed_regfile.REG_speed_eco_w1t1       ;
assign reg_pif.reg_speed_eco_w1t2          = `REG.speed_regfile.REG_speed_eco_w1t2       ;
assign reg_pif.reg_cpm_eco_w1t1            = `CPM.crg_regfile.REG_cpm_eco_w1t1           ;
assign reg_pif.reg_cpm_eco_w1t2            = `CPM.crg_regfile.REG_cpm_eco_w1t2           ;

//assign reg_pif.reg_lvro_eco_w1t1           = `LVRO_MST_REG.REG_lvro_eco_w1t1             ;
//assign reg_pif.reg_lvro_eco_w1t2           = `LVRO_MST_REG.REG_lvro_eco_w1t2             ;

assign reg_pif.reg_comm_interface_eco_w1t1 = `COMM_REG.REG_comm_interface_eco_w1t1       ;
assign reg_pif.reg_comm_interface_eco_w1t2 = `COMM_REG.REG_comm_interface_eco_w1t2       ;
assign reg_pif.reg_rst_eco_w1t1            = `CPM.crg_regfile.REG_rst_eco_w1t1           ;  
assign reg_pif.reg_rst_eco_w1t2            = `CPM.crg_regfile.REG_rst_eco_w1t2           ;  


//rfu W1T SIG, buf
assign reg_pif.reg_work_eco_w1t1_buf           = `SYS_CTRL.work_ctrl.eco_work_eco_w1t1.Y         ;
assign reg_pif.reg_work_eco_w1t2_buf           = `SYS_CTRL.work_ctrl.eco_work_eco_w1t2.Y         ;
assign reg_pif.reg_mx2_bridge_eco_w1t1_buf     = `SYS_CTRL.mx2_bridge.GEN_MX2_BRIDGE_ECO_BUF_H[30].eco_mx2_bridge_buf_H.Y   ;
assign reg_pif.reg_mx2_bridge_eco_w1t2_buf     = `SYS_CTRL.mx2_bridge.GEN_MX2_BRIDGE_ECO_BUF_H[31].eco_mx2_bridge_buf_H.Y   ;
assign reg_pif.reg_speed_eco_w1t1_buf          = `SYS_CTRL.speed.GEN_SPEED_ECO_BUF_H[30].eco_speed_buf_h.Y       ;
assign reg_pif.reg_speed_eco_w1t2_buf          = `SYS_CTRL.speed.GEN_SPEED_ECO_BUF_H[31].eco_speed_buf_h.Y       ;
assign reg_pif.reg_cpm_eco_w1t1_buf            = `SYS_CTRL.crg.GEN_CPM_ECO_BUF_H[30].eco_cpm_buf_h.Y       ;
assign reg_pif.reg_cpm_eco_w1t2_buf            = `SYS_CTRL.crg.GEN_CPM_ECO_BUF_H[31].eco_cpm_buf_h.Y       ;

//assign reg_pif.reg_lvro_eco_w1t1_buf         = `SYS_CTRL.lvro_master_ctrl.eco_lvro_buf_w1t1.Y     ;
//assign reg_pif.reg_lvro_eco_w1t2_buf         = `SYS_CTRL.lvro_master_ctrl.eco_lvro_buf_w1t2.Y     ;

assign reg_pif.reg_comm_interface_eco_w1t1_buf = `SYS_CTRL.comm_interface.GEN_COMMON_INTERFACE_ECO_BUF_H[30].eco_comm_interface_buf_h.Y  ;
assign reg_pif.reg_comm_interface_eco_w1t2_buf = `SYS_CTRL.comm_interface.GEN_COMMON_INTERFACE_ECO_BUF_H[31].eco_comm_interface_buf_h.Y  ;
assign reg_pif.reg_rst_eco_w1t1_buf            = `SYS_CTRL.crg.u_crg_rst.GEN_RI_RST_BUF_H[30].eco_rst_buf_h.Y       ;
assign reg_pif.reg_rst_eco_w1t2_buf            = `SYS_CTRL.crg.u_crg_rst.GEN_RI_RST_BUF_H[31].eco_rst_buf_h.Y       ;  


//-------------------------------------------------------------------
// RC assertion
//-------------------------------------------------------------------
`HDLREF_reg_assign(reg_pif.reg_thsr_skip    ,   `SPEED.self_inst.self_aging_inst.self_thsrcnt_inst.REG_thsr_skip ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.thsr_rdy         ,   `SPEED.self_inst.self_aging_inst.self_thsrcnt_inst.thsr_rdy   ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.mode             ,   `SPEED.self_inst.self_aging_inst.self_thsrcnt_inst.mode       ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_freq_sum_rdy ,   `SPEED.REG_freq_sum_rdy ,     0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_self_aging_ave_done  ,   `SPEED.self_inst.self_aging_inst.REG_self_aging_done  , 0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_hashrate_sum_rdy     ,   `SPEED.REG_hashrate_sum_rdy               , 0,  0)  ;
`HDLREF_reg_assign(reg_pif.reg_tvsenr_rdy           ,   `PVT.REG_tvsenR_rdy                       , 0,  0)  ;

//-------------------------------------------------------------------

//-------------------------------------------------------------------
// uart shadow registe, xclk -> sync pll
// 1, REG_UART_PLLDIV_MODE
// 2, REG_UART_PLLDIV_INT
// 3, REG_UART_PLLDIV_FRC
//-------------------------------------------------------------------
`HDLREF_wire_assign(reg_pif.reg_uart_cfg_update  ,   `UART_TOP.reg_uart_cfg_update  ,   0,   0)  ;

`HDLREF_reg_assign(reg_pif.REG_UART_PLLDIV_MODE         , `UART_TOP.REG_UART_PLLDIV_MODE          ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLLDIV_INT          , `UART_TOP.REG_UART_PLLDIV_INT           ,  15,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLLDIV_FRC          , `UART_TOP.REG_UART_PLLDIV_FRC           ,  15,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_HEADER_INDICATOR    , `UART_TOP.REG_UART_HEADER_INDICATOR     ,  39,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_CHECK_MODE_SEL      , `UART_TOP.REG_UART_CHECK_MODE_SEL       ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_FSM_TO_CNT_MAX_SHIFT, `UART_TOP.REG_UART_FSM_TO_CNT_MAX_SHIFT ,   4,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_RX_TO_CNT_MAX_SHIFT , `UART_TOP.REG_UART_RX_TO_CNT_MAX_SHIFT  ,   4,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_NONCE_RETURN_EN     , `UART_TOP.REG_UART_NONCE_RETURN_EN      ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_NONCE_CNT_MAX       , `UART_TOP.REG_UART_NONCE_CNT_MAX        ,   6,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_TIMED_RETURN_EN     , `UART_TOP.REG_UART_TIMED_RETURN_EN      ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_FC_DISABLE          , `UART_TOP.REG_UART_FC_DISABLE           ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLL_MODE            , `UART_TOP.REG_UART_PLL_MODE             ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_TIMED_RETURN_CNT_MAX, `UART_TOP.REG_UART_TIMED_RETURN_CNT_MAX ,  31,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLL_DO_SHAPING_EN   , `UART_TOP.REG_UART_PLL_DO_SHAPING_EN    ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLL_FB_SHAPING_EN   , `UART_TOP.REG_UART_PLL_FB_SHAPING_EN    ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLL_DO_SHAPING_MODE , `UART_TOP.REG_UART_PLL_DO_SHAPING_MODE  ,   1,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLL_FB_SHAPING_MODE , `UART_TOP.REG_UART_PLL_FB_SHAPING_MODE  ,   1,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_RX_BUSY_CNT_MAX     , `UART_TOP.REG_UART_RX_BUSY_CNT_MAX      ,   3,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_RDFSM_WAIT_CNT_MAX  , `UART_TOP.REG_UART_RDFSM_WAIT_CNT_MAX   ,   5,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_SOFTRST             , `UART_TOP.REG_UART_SOFTRST              ,   0,  0)  ;


`HDLREF_reg_assign(reg_pif.REG_UART_PLLDIV_MODE_pll       , `UART_TOP.REG_UART_PLLDIV_MODE_pll        ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLLDIV_INT_pll        , `UART_TOP.REG_UART_PLLDIV_INT_pll         ,  15,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLLDIV_FRC_pll        , `UART_TOP.REG_UART_PLLDIV_FRC_pll         ,  15,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_HEADER_INDICATOR_p    , `UART_TOP.REG_UART_HEADER_INDICATOR_p     ,  39,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_CHECK_MODE_SEL_p      , `UART_TOP.REG_UART_CHECK_MODE_SEL_p       ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_FSM_TO_CNT_MAX_SHIFT_p, `UART_TOP.REG_UART_FSM_TO_CNT_MAX_SHIFT_p ,   4,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_RX_TO_CNT_MAX_SHIFT_p , `UART_TOP.REG_UART_RX_TO_CNT_MAX_SHIFT_p  ,   4,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_NONCE_RETURN_EN_p     , `UART_TOP.REG_UART_NONCE_RETURN_EN_p      ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_NONCE_CNT_MAX_p       , `UART_TOP.REG_UART_NONCE_CNT_MAX_p        ,   6,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_TIMED_RETURN_EN_p     , `UART_TOP.REG_UART_TIMED_RETURN_EN_p      ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_FC_DISABLE_p          , `UART_TOP.REG_UART_FC_DISABLE_p           ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_PLL_MODE_p            , `UART_TOP.REG_UART_PLL_MODE_p             ,   0,  0)  ;
`HDLREF_reg_assign(reg_pif.REG_UART_TIMED_RETURN_CNT_MAX_p, `UART_TOP.REG_UART_TIMED_RETURN_CNT_MAX_p ,  31,  0)  ;
