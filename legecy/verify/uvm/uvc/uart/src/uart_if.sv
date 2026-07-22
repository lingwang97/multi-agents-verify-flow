interface uart_if ();

   import uvm_pkg::*;
   import global_pkg::*;
import reg_addr::*;
   string       report_id = "cal_adc_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["uart_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["uart_if"];

   initial begin
      IF_CHECKS_ENABLE["uart_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["uart_if"] = 1'b1;   //initially on
   end

// --------------------------------------
// clk
// ---------------------------------------
    logic   xclk        ;
    logic   uart_clk    ;
    logic   uart_clk16  ;

    logic        pll_clk    ;
    logic        xclk_gated ;
    logic        pclk_gated ;
    logic        pclk       ;

 //for clkdiv_frc
    logic [15:0] divfrc_cnt;
//for filt test
    logic        rx_din_sampled;
    logic [7:0]  rx_pll_cnt;
    logic [3:0]  sampled_high_cnt;
    logic [3:0]  sampled_low_cnt;
    logic        rx_pll_clk;
    logic        REG_UART_RX_PLL_FILT_SEL;

// --------------------------------------
// data inout
// ---------------------------------------
    real    uart_divisor;
    real    uart_freq   ;

    logic        uart_fsm_rst_n      ;      //this real uart_fsm_rst_n signal will be random "high" at time0, and toggle unexpected assertion error ,
    logic        rst_n      ;               //so rst_n signal start as "0 and postpone 2xclk assign to uart_fsm_rst_n

    logic        RX         ;
    logic        DI   = 1   ;            //DI


// ---------------------------------------------------------------------
// crc check
// ---------------------------------------------------------------------
    logic [31:0]  check_datain      ;
    logic [ 7:0]  check_chkout      ;
    logic [ 3:0]  uart_fsm_x_state  ;
    logic [ 3:0]  uart_fsm_p_state  ;



    logic [9:0]  uart_chipid;

    logic [39:0] DI_X_rx_dout       ;
    logic [39:0] DI_P_rx_dout       ;
    logic [39:0] FBDO_X_tx_din      ;
    logic [39:0] FBDO_P_tx_din      ;

    logic [39:0] DI_rx_dout   ;
    logic [39:0] FBDI_rx_dout ;
    logic        DO     ;            //DO
    logic        FBDI   ;          //FBDI
    logic        CTS_n  ;         //CI
    logic        RTS_n  ;         //CO
    logic        FBDO   ;          //FBDO

    logic [31:0] noncebuf_data_o [`CHIP_NUM-1:0][25:0];

    int fake_pll_freq     ;

    int targetchipid = `CHIP_NUM-1;

// --------------------------------------
// uart status
// ---------------------------------------
    logic [ 6:0] noncebufcnt  ;
    logic [39:0] HEADER       ;

    logic [7:0] REG_UART_FREQ_RATIO    ;

    logic        REG_UART_CHECK_MODE_SEL          ;
    logic [ 4:0] REG_UART_RX_TO_CNT_MAX_SHIFT     ;
    logic [ 4:0] REG_UART_FSM_TO_CNT_MAX_SHIFT    ;
    logic [39:0] REG_UART_HEADER_INDICATOR        ;
    logic [ 7:0] REG_UART_CHIPID        ;
    logic        REG_UART_CHIPLAST      ;
    logic        header_fail            ;
    logic        header_pass            ;
    logic        chk_fail               ;
    logic        chk_pass               ;

    logic         DI_rx_start_err     ;
    logic         DI_rx_start_glitch  ;

    logic        REG_UART_XCLK_DO_SHAPING_EN               ;
    logic        REG_UART_XCLK_FB_SHAPING_EN               ;
    logic [1:0]  REG_UART_XCLK_DO_SHAPING_MODE               ;
    logic [1:0]  REG_UART_XCLK_FB_SHAPING_MODE               ;

    logic        uart_fc_disable        ;
    logic        uart_softrst           ;
    logic        uart_softrst_p           ;
    logic [2:0]  uart_rd_fsm_state       ;
    logic [2:0]  uart_pll_rd_fsm_state   ;
    logic [`CHIP_NUM-1:0][2:0]  uart_state_a   ;
    logic        uart_state_a_idle             ;

    logic        di_rx_busy     ;
    logic        fbdo_tx_busy   ;
    logic        fbdo_tx_pll_busy[`CHIP_NUM-1:0];

    logic        fbdo_tx_busy_a[7:0] ;
    logic        di_rx_busy_a[7:0] ;
    logic [2:0]  uart_rd_fsm_state_a[`CHIP_NUM-1:0] ;




// --------------------------------------
// uart pll mode
// ---------------------------------------
    logic        uart_pll_mode    ;
    logic        uart_plldiv_mode ;
    logic [15:0] uart_plldiv_int  ;
    logic [15:0] uart_plldiv_frc  ;
    logic        REG_UART_PLL_DO_SHAPING_EN     ;
    logic        REG_UART_PLL_FB_SHAPING_EN     ;

    logic [ 1:0] REG_UART_PLL_FB_SHAPING_MODE;
    logic [ 1:0] REG_UART_PLL_DO_SHAPING_MODE;


    logic         pll0_lock_flag                ;   //pll0 lock flag
    logic         REG_UART_PLL_MODE             ;
    // pll clk domain
    logic        REG_UART_PLLDIV_MODE_pll        ;
    logic [15:0] REG_UART_PLLDIV_INT_pll         ;
    logic [15:0] REG_UART_PLLDIV_FRC_pll         ;
    // pclk domain
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
    logic         REG_UART_PLL_DO_SHAPING_EN_p         ;
    logic         REG_UART_PLL_FB_SHAPING_EN_p         ;

    logic [ 1:0]  REG_UART_PLL_DO_SHAPING_MODE_p    ;
    logic [ 1:0]  REG_UART_PLL_FB_SHAPING_MODE_p    ;








    logic        clk_for_cov ;


// --------------------------------------
// uart scoreboard
// ---------------------------------------
      logic         DI_X_rx_valid         ;
      logic         DI_P_rx_valid         ;
      logic         FBDI_X_rx_valid       ;
      logic         FBDI_P_rx_valid       ;

      logic         DI_X_rx_busy         ;
      logic         DI_P_rx_busy         ;
      logic         FBDI_X_rx_busy       ;
      logic         FBDI_P_rx_busy       ;

      logic         DI_fsm_timeout_flag   ;
      logic         DI_rx_timeout_flag    ;

      //logic [7:0]   chipaddr;
      logic [9:0]   chipaddr;

      logic [1:0]   mode    ;
      logic [1:0]   cmd_mode_fsm_pll    ;
      logic [8:0]   tranlen ;

      logic [6:0]   nonce_cnt      ;
      logic         nonce_valid    ;
      logic [6:0]   REG_UART_NONCE_CNT_MAX  ;
      logic         REG_UART_NONCE_RETURN_EN;
      logic [11:0]  cmd_addr          ;

      logic         reg_nonce_update  ;
      logic         work_nonce_update ;

      logic [39:0]  FBDO_fifo_wdata   ;
      logic [ 2:0]  uart2apb_parser_state   ;
      logic [ 1:0]  uart2std_apb_cur_stat   ;
      logic         uart_std_apb_trans_wvalid;
      logic         uart_std_apb_trans_rvalid;



      logic         std_psel            ; //STD APB bus
      logic         std_penable         ; //STD APB bus
      logic         std_pwrite          ; //STD APB bus
      logic [31:0]  std_paddr           ; //STD APB bus
      logic [31:0]  std_pwdata          ; //STD APB bus
      logic [31:0]  std_prdata          ; //STD APB bus
      logic         std_pready          ; //STD APB bus




//////////////////////////////////////////////////////////////////////////////////////////
// uart err detect assertion
//////////////////////////////////////////////////////////////////////////////////////////
      logic [ 7:0]  REG_UART_FSM_TIMEOUT[`CHIP_NUM-1:0]     ;
      logic [11:0]  REG_UART_DIRX_TIMEOUT[`CHIP_NUM-1:0]    ;
      logic [11:0]  REG_UART_FBDIRX_TIMEOUT[`CHIP_NUM-1:0]  ;
      logic [31:0]  REG_UART_CHKFAIL[`CHIP_NUM-1:0]         ;
      logic [23:0]  REG_UART_DIRX_START_ERR[`CHIP_NUM-1:0]  ;
      logic [ 7:0]  REG_UART_FBDIRX_START_ERR[`CHIP_NUM-1:0];
      logic [23:0]  REG_UART_DIRX_GLITCH[`CHIP_NUM-1:0]     ;
      logic [ 7:0]  REG_UART_FBDIRX_GLITCH[`CHIP_NUM-1:0]   ;






      logic                   uart_softrst_mc_flag    ;
      logic [`CHIP_NUM-1:0]   uart_softrst_mc         ;

//////////////////////////////////////////////////////////////////////////////////////////
// di_rx_pll_fifo & di_rx_x_fifo
//////////////////////////////////////////////////////////////////////////////////////////
      logic                   DI_P_rx_wfull           ;
      logic                   DI_pll_s2p_winc         ;
      logic                   DI_P_rx_rempty          ;
      logic                   DI_pll_rinc             ;
      logic                   DI_X_rx_wfull           ;
      logic                   DI_x_s2p_winc           ;
      logic                   DI_X_rx_rempty          ;
      logic                   DI_x_rinc               ;
//////////////////////////////////////////////////////////////////////////////////////////
// uart_fc,
//////////////////////////////////////////////////////////////////////////////////////////
      logic [ 5:0]  REG_UART_RDFSM_WAIT_CNT_MAX[`CHIP_NUM]        ;
      logic [ 3:0]  REG_UART_RX_BUSY_CNT_MAX[`CHIP_NUM]          ;
      logic [ 5:0]  REG_UART_RDFSM_WAIT_CNT_MAX_p[`CHIP_NUM]     ;
      logic [ 3:0]  REG_UART_RX_BUSY_CNT_MAX_p[`CHIP_NUM]        ;

      logic [ 2:0]  uart_rd_fsm_state_x_a[`CHIP_NUM]    ;
      logic [ 2:0]  uart_rd_fsm_state_p_a[`CHIP_NUM];

      logic         DI_P_rx_din;
      logic         DI_X_rx_din;
      logic         FBDI_P_rx_din;
      logic         FBDI_X_rx_din;

      logic         FBDI_RX_X_rx_busy_n ;
      logic [ 3:0]  FBDI_RX_X_state;
      logic         FBDI_RX_PLL_rx_busy_n ;
      logic [ 3:0]  FBDI_RX_PLL_state;

      logic         DI_RX_X_rx_busy_n ;
      logic [ 3:0]  DI_RX_X_state;
      logic         DI_RX_PLL_rx_busy_n ;
      logic [ 3:0]  DI_RX_PLL_state;





  //------------------------------------------------------------------
  //-----------------------------------------------------------------
    wire [`CHIP_NUM - 1:0] uart_xclk;
    wire [`CHIP_NUM - 1:0] uart_di;
    wire [`CHIP_NUM - 1:0] uart_fbdo;

    logic            uart_xclk_for_gate;
    logic            uart_mid_clk_for_gate;
    logic            uart_pll_clk_for_gate;
    logic            tpsel;
  //------------------------------------------------------------------
  //-----------------------------------------------------------------

   event uart_rst_done;
   event uart_rx_timeout;

   initial begin
     rst_n = 0;
     #1ps;
     repeat (2) @(posedge xclk);
     assign rst_n = uart_fsm_rst_n;
   end




   initial begin
    `ifdef STUB_FAKE_PLL_FREQ
        force fake_pll_freq = `STUB_FAKE_PLL_FREQ;
    `else
        force fake_pll_freq = 500;
    `endif
       #200;
       @(posedge rst_n);
       -> uart_rst_done;
   end


         `ifdef PL_SIM
         `ifdef USE_UART_DRV
         `ifdef UART_SIM_SPEEDUP
		 generate for(genvar i = 0; i < `CHIP_NUM; i++)
         always @(negedge uart_fsm_rst_n) begin
                 #1;
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO[7:0]",i), 8'd4);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_7___REG_UART_FREQ_RATIO_reg_6___REG_UART_FREQ_RATIO_reg_4___REG_UART_FREQ_RATIO_reg_0_.Q3",i), 1'b0);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_5___REG_UART_FREQ_RATIO_reg_3___REG_UART_FREQ_RATIO_reg_2___REG_UART_FREQ_RATIO_reg_1_.Q3",i), 1'b0);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_5___REG_UART_FREQ_RATIO_reg_3___REG_UART_FREQ_RATIO_reg_2___REG_UART_FREQ_RATIO_reg_1_.Q2",i), 1'b1);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_5___REG_UART_FREQ_RATIO_reg_3___REG_UART_FREQ_RATIO_reg_2___REG_UART_FREQ_RATIO_reg_1_.Q1",i), 1'b0);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_7___REG_UART_FREQ_RATIO_reg_6___REG_UART_FREQ_RATIO_reg_4___REG_UART_FREQ_RATIO_reg_0_.Q2",i), 1'b0);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_5___REG_UART_FREQ_RATIO_reg_3___REG_UART_FREQ_RATIO_reg_2___REG_UART_FREQ_RATIO_reg_1_.Q0",i), 1'b0);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_7___REG_UART_FREQ_RATIO_reg_6___REG_UART_FREQ_RATIO_reg_4___REG_UART_FREQ_RATIO_reg_0_.Q1",i), 1'b0);
                 //uvm_hdl_deposit($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm.REG_UART_FREQ_RATIO_reg_7___REG_UART_FREQ_RATIO_reg_6___REG_UART_FREQ_RATIO_reg_4___REG_UART_FREQ_RATIO_reg_0_.Q0",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_0_.Q",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_1_.Q",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_2_.Q",i), 1'b1);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_3_.Q",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_4_.Q",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_5_.Q",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_6_.Q",i), 1'b0);
                 uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.REG_UART_FREQ_RATIO_reg_7_.Q",i), 1'b0);
		 end
		 endgenerate

         `endif
         `endif
         `endif



        logic clk;
        logic rst;
        logic card_sel;

//////////////////////////////////////////////////////////////////////////////////////////
// assertion, a3196s_for_regfile
//////////////////////////////////////////////////////////////////////////////////////////
logic         reg_uart_cfg_update;
logic         xclk_psel     ;
logic         xclk_penable  ;
logic         xclk_pwrite   ;
logic  [31:0] xclk_paddr    ;





//////////////////////////////////////////////////////////////////////////////////////////
// assertion control
//////////////////////////////////////////////////////////////////////////////////////////
`ifndef RI_RST_FORCE //Jerry add 2023/8/23
  `ifdef PL_SIM
  initial begin
    $assertoff(0, tb_top.uart_pif);
    //#100ns;
    wait(uart_rst_done.triggered);
    $asserton(0, tb_top.uart_pif);
    forever begin
      wait(rst_n == 1);
      $assertoff(0, tb_top.uart_pif);
      wait(rst_n == 0);
      $assertoff(0, tb_top.uart_pif);
    end
  end
  `else
  initial begin
    forever begin
      wait(rst_n == 0);
      $assertoff(0, tb_top.uart_pif);
      wait(rst_n == 1);
      $asserton(0, tb_top.uart_pif);
    end
  end
  `endif

`endif //RI_RST_FORCE
`ifdef USE_UART_DRV
    `include "../../../verify/uvm/uvc/uart/src/uart_if_pc.sv"
`endif

endinterface : uart_if
