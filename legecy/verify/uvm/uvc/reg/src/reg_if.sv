interface  reg_if ();

   import uvm_pkg::*;
   import global_pkg::*;
   import reg_addr::*;   
   string       report_id = "cal_adc_if";
    
    //rst_field rst_fds[$];
    uvm_reg_field field_with_reset[string];
    bit [31:0] NUM;

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE[" reg_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE[" reg_if"];

   initial begin
      NUM = 0;
      IF_CHECKS_ENABLE["reg_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["reg_if"] = 1'b1;   //initially on
   end
   


/* rst logic */
logic               mid_rst_n;
logic               ri_rst_n;
logic               rst_n_l;
logic               pin_ri;
logic               tp_sel;

//------------------------------------------------------------
// reg module por reset event
// used in reg_monitor,  etc.
//------------------------------------------------------------
event               reg_rstpor_done;

/*apb interface*/
//------------------------------------------------------------
//mid_apb_decoder
logic             clk; //mid_clk
logic             psel            ; //APB bus 
logic             penable         ; //APB bus 
logic             pwrite          ; //APB bus 
logic      [31:0] paddr           ; //APB bus 
logic      [31:0] pwdata          ; //APB bus 
logic      [31:0] prdata          ; //APB bus 

logic             pready          ; //APB bus 
//xclk_apb_decoder
logic         xclk;
logic         xclk_psel     ;
logic         xclk_penable  ;
logic         xclk_pwrite   ;
logic  [31:0] xclk_paddr    ;
logic  [31:0] xclk_pwdata   ;
logic [31:0]  xclk_prdata   ;

logic         xclk_pready   ;

//std_apb_decoder
logic             std_psel            ; //APB bus 
logic             std_penable         ; //APB bus 
logic             std_pwrite          ; //APB bus 
logic      [31:0] std_paddr           ; //APB bus 
logic      [31:0] std_pwdata          ; //APB bus 
logic      [31:0] std_prdata          ; //APB bus 
logic             std_pready          ; //APB bus 
//------------------------------------------------------------



//------------------------------------------------------------
//W1T signals
//------------------------------------------------------------ 
logic [31:0]    reg_cfg                 ;
logic           reg_core_rd_clr         ;      
logic           reg_nonce_update        ;      
logic           reg_glbsetvld               ;      
logic           reg_spdlog_reset            ;      
logic           reg_ft_bitmap_clr       ;
logic           reg_cfg_spdgo           ;
logic           reg_cfg_rstfifo         ;
logic           reg_ftst                ;    

logic           reg_ntime_half_work     ;      
logic           reg_lfb_clear           ;  
logic           reg_glbselfcal_en       ;  
logic           reg_gbp_vld             ;  
logic           reg_glb_thsr_rq         ;  
logic           reg_self_aging_start    ;  

logic           reg_pll0_autoreset_pre  ;      
logic           reg_pll1_autoreset_pre  ;      
logic           reg_pll2_autoreset_pre  ;      
logic           reg_pll3_autoreset_pre  ;      
logic           reg_divcnt_ctrl_slice_divcnt_clr        ;      
logic [31:0]    reg_efuse_ctrl              ;
logic [1:0]     reg_prog_mode               ;

logic           reg_uart_softrst        ;

logic           reg_mx2_sft_rst         ;

logic           reg_ro_cg_en    ;
logic           lvro_clk        ;
logic           reg_div_num     ;
int             ro_div_num  = (reg_div_num == 1)?4:((reg_div_num == 2)?8:((reg_div_num == 4)?16:1));  //lvro_clk freq = xclk freq / ro_div_num
logic           is_reg_roctrl0_0;
logic           is_reg_roctrl1_0;
logic           is_reg_roctrl0_1;
logic           is_reg_roctrl1_1;
logic           reg_lvro_rst0_0 ;
logic           reg_lvro_rst1_0 ;
logic           reg_lvro_rst0_1 ;
logic           reg_lvro_rst1_1 ;


//rfu W1T SIG
logic           reg_work_eco_w1t1       ;
logic           reg_speed_eco_w1t1           ;
logic           reg_mx2_bridge_eco_w1t1      ;
logic           reg_cpm_eco_w1t1             ;
logic           reg_rst_eco_w1t1             ;
logic           reg_lvro_eco_w1t1            ;

logic           reg_comm_interface_eco_w1t1  ;

logic           reg_work_eco_w1t2       ;
logic           reg_speed_eco_w1t2           ;
logic           reg_mx2_bridge_eco_w1t2      ;
logic           reg_cpm_eco_w1t2             ;
logic           reg_rst_eco_w1t2             ;
logic           reg_lvro_eco_w1t2            ;

logic           reg_comm_interface_eco_w1t2  ;

logic           reg_work_eco_w1t1_buf       ;
logic           reg_speed_eco_w1t1_buf           ;
logic           reg_mx2_bridge_eco_w1t1_buf      ;
logic           reg_cpm_eco_w1t1_buf             ;
logic           reg_rst_eco_w1t1_buf             ;
logic           reg_lvro_eco_w1t1_buf            ;

logic           reg_comm_interface_eco_w1t1_buf  ;

logic           reg_work_eco_w1t2_buf       ;
logic           reg_speed_eco_w1t2_buf           ;
logic           reg_mx2_bridge_eco_w1t2_buf      ;
logic           reg_cpm_eco_w1t2_buf             ;
logic           reg_rst_eco_w1t2_buf             ;
logic           reg_lvro_eco_w1t2_buf            ;

logic           reg_comm_interface_eco_w1t2_buf  ;




//------------------------------------------------------------
//RC signals
//------------------------------------------------------------
logic           thsr_rdy            ;
logic           reg_thsr_skip       ;
logic           mode                ;

logic           reg_freq_sum_rdy    ;   //RC
logic           reg_hashrate_sum_rdy    ; //RC
logic           reg_self_aging_ave_done ; //RC
logic           reg_tvsenr_rdy          ; //RC       


// uart shadow registe, xclk -> sync pll
// 1, REG_UART_PLLDIV_MODE
// 2, REG_UART_PLLDIV_INT
// 3, REG_UART_PLLDIV_FRC
// 4, REG_UART***
//-------------------------------------------------------------------
logic        reg_uart_cfg_update      ;

logic        REG_UART_PLLDIV_MODE          ;
logic [15:0] REG_UART_PLLDIV_INT           ;
logic [15:0] REG_UART_PLLDIV_FRC           ;

logic [39:0]  REG_UART_HEADER_INDICATOR    ;
logic         REG_UART_CHECK_MODE_SEL      ;
logic [ 4:0]  REG_UART_FSM_TO_CNT_MAX_SHIFT;
logic [ 4:0]  REG_UART_RX_TO_CNT_MAX_SHIFT ;
logic         REG_UART_NONCE_RETURN_EN     ;
logic [ 6:0]  REG_UART_NONCE_CNT_MAX       ;
logic         REG_UART_TIMED_RETURN_EN     ;
logic         REG_UART_FC_DISABLE          ;
logic         REG_UART_PLL_MODE            ;
logic [31:0]  REG_UART_TIMED_RETURN_CNT_MAX;
logic         REG_UART_PLL_DO_SHAPING_EN   ;
logic         REG_UART_PLL_FB_SHAPING_EN   ;
logic [ 1:0]  REG_UART_PLL_DO_SHAPING_MODE ;
logic [ 1:0]  REG_UART_PLL_FB_SHAPING_MODE ;

logic [ 3:0]  REG_UART_RX_BUSY_CNT_MAX     ;
logic [ 5:0]  REG_UART_RDFSM_WAIT_CNT_MAX  ;
logic         REG_UART_SOFTRST            ;


logic        REG_UART_PLLDIV_MODE_pll        ;
logic [15:0] REG_UART_PLLDIV_INT_pll         ;
logic [15:0] REG_UART_PLLDIV_FRC_pll         ;

logic [39:0]  REG_UART_HEADER_INDICATOR_p    ;
logic         REG_UART_CHECK_MODE_SEL_p      ;
logic [ 4:0]  REG_UART_FSM_TO_CNT_MAX_SHIFT_p;
logic [ 4:0]  REG_UART_RX_TO_CNT_MAX_SHIFT_p ;
logic         REG_UART_NONCE_RETURN_EN_p     ;
logic [ 6:0]  REG_UART_NONCE_CNT_MAX_p       ;
logic         REG_UART_TIMED_RETURN_EN_p     ;
logic         REG_UART_FC_DISABLE_p          ;
logic         REG_UART_PLL_MODE_p            ;
logic [31:0]  REG_UART_TIMED_RETURN_CNT_MAX_p;
logic         REG_UART_PLL_DO_SHAPING_EN_p   ;
logic         REG_UART_PLL_FB_SHAPING_EN_p   ;
logic [ 1:0]  REG_UART_PLL_DO_SHAPING_MODE_p ;
logic [ 1:0]  REG_UART_PLL_FB_SHAPING_MODE_p ;


logic [ 3:0]  REG_UART_RX_BUSY_CNT_MAX_p     ;
logic [ 5:0]  REG_UART_RDFSM_WAIT_CNT_MAX_p  ;
logic         REG_UART_SOFTRST_p             ;




//------------------------------------------------------------
// shadow reg 
//------------------------------------------------------------
logic              is_REG_Core_wr_data    ;
logic              REG_Core_regrw         ;
logic  [7:0]       REG_Core_rw_addr       ;
logic  [7:0]       REG_Core_rw_coreid     ;
logic  [31:0]      work_pwdata            ;

logic  [7:0]       REG_Mask               ;                   // Read from REG_Core_wr_data
logic  [7:0]       REG_Clk_dbg_sel        ;            // Read from REG_Core_wr_data
logic  [1:0]       REG_selfclk_sel        ;            // Read from REG_Core_wr_data
logic              REG_core_selfcal_en    ;        // Read from REG_Core_wr_data
logic  [7:0]       REG_core_selfcal_id    ;        // Read from REG_Core_wr_data
logic              REG_selfvec_sel        ;            // Read from REG_Core_wr_data
logic  [8:0]       REG_selfclk_minstage   ;       // Read from REG_Core_wr_data
logic  [8:0]       REG_selfclk_maxstage   ;       // Read from REG_Core_wr_data
logic  [9:0]       REG_selfclk_cfg        ;            // Read from REG_Core_wr_data

logic              is_REG_SELFCLK_SEL     ;
logic              is_REG_selfclk_cfg     ;
logic  [7:0]       is_REG_selfclk_cfg_id  ;

//------------------------------------------------------------
/*
wand SDA;
wand SCL;

logic sda_master;
assign SDA = (sda_master === 0) ? 1'b0:1'bz ;

//-------------------------------------------------------------------
// sslog <- adaptive_log, or selfcal_log
//-------------------------------------------------------------------
logic         ss_adaptive_en  ;
logic         ss_selfcal_en   ;
bit enable_pullup_resistor;
assign (weak1, weak0) SDA = enable_pullup_resistor ? 1:0 ;


initial begin
  #100;
  sda_master = 1'b0;
  enable_pullup_resistor = 0;
  $display($sformatf("[I2C] @%t sda_master = %b, SDA = (%V) %b",$realtime, sda_master, SDA, SDA));
  #200;
  sda_master = 1'b1;
  enable_pullup_resistor = 1;
  $display($sformatf("[I2C] @%t sda_master = %b, SDA = (%V) %b",$realtime, sda_master, SDA, SDA));

end
*/

initial begin
  #50ns;
  `ifdef PLSIM
    @(negedge mid_rst_n);
  `else 
    @(posedge mid_rst_n);
  `endif
  -> reg_rstpor_done;
end

//------------------------------------------------------------
//
`ifdef PL_SIM
  initial begin
  `ifdef USE_JAMLINK_DRV
    $asserton(0, tb_top.reg_pif);
  `elsif USE_UART_DRV
    $asserton(0, tb_top.reg_pif);
  `else 
    $assertoff(0, tb_top.reg_pif);
  `endif
  end
`endif

   logic rst;
   logic card_sel;



    `include "../../../verify/uvm/uvc/reg/src/reg_if_pc.sv"  

endinterface :  reg_if
