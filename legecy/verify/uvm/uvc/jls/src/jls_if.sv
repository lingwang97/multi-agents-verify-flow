interface jls_if ();

   import uvm_pkg::*;
   import global_pkg::*;
   import reg_addr::*;   
   string       report_id = "jls_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["jls_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["jls_if"];

   initial begin
      IF_CHECKS_ENABLE["jls_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["jls_if"] = 1'b1;   //initially on
   end


   logic  tp_sel;
   logic wait_flag;
   logic ci_rst_n;
  
    //apb mid_clk bus
	logic [31:0]	paddr;
	logic			   psel;//
	logic			   penable;//
	logic			   pwrite;//
	logic [31:0]	pwdata;
	logic			   pready;
	logic [31:0]	prdata;
	logic [1:0]    apb_state_cur;
	
    //apb xclk bus
	logic [31:0]	xclk_paddr;
	logic			   xclk_psel;
	logic			   xclk_penable;
	logic			   xclk_pwrite;
	logic [31:0]	xclk_pwdata;
	logic			   xclk_pready;
	logic [31:0]	xclk_prdata;
	logic [1:0]    xclk_apb_state_cur;

   //standard apb bus 
   logic [31:0]	std_paddr;
	logic			   std_psel;
	logic			   std_penable;
	logic			   std_pwrite;
	logic [31:0]	std_pwdata;
	logic			   std_pready;
	logic [31:0]	std_prdata;
   logic [1:0]    std_apb_state_cur;


    logic            xclk         ;
    logic            pin_ci       ;
    logic            xclk_J       ;//wuqiang add
    logic            pin_ci_J     ;//wuqiang add
    logic            pin_di       ;
    logic           pin_do       ;
    logic           fb_do        ;
    logic            ci_rst_f_n   ;
    logic [8:0]    len_fifo        ;

    logic            rst_n_mid        ;
    logic            rst_n_xclk        ;

    logic 			mid_rst_f_n;
    logic   [6:0]    z_NonceBufCnt;


    logic  [31:0]   work_paddr   ;
    logic           work_psel    ;
    logic           work_penable ;
    logic           work_pwrite  ;
    logic  [31:0]   work_pwdata  ;
    logic            work_pready  ;
    logic   [31:0]   work_prdata  ;

    logic  [31:0]   speed_paddr  ;
    logic           speed_psel   ;
    logic           speed_penable;
    logic           speed_pwrite ;
    logic  [31:0]   speed_pwdata ;
    logic            speed_pready ;
    logic   [31:0]   speed_prdata ;

    logic  [31:0]   rst_paddr  ;
    logic           rst_psel   ;
    logic           rst_penable;
    logic           rst_pwrite ;
    logic  [31:0]   rst_pwdata ;
    logic            rst_pready ;
    logic   [31:0]   rst_prdata ;

    logic  [31:0]   cpm_paddr    ;
    logic           cpm_psel     ;
    logic           cpm_penable  ;
    logic           cpm_pwrite   ;
    logic  [31:0]   cpm_pwdata   ;
    logic            cpm_pready   ;
    logic   [31:0]   cpm_prdata   ;

    logic  [31:0]   pvt_paddr    ;
    logic           pvt_psel     ;
    logic           pvt_penable  ;
    logic           pvt_pwrite   ;
    logic  [31:0]   pvt_pwdata   ;
    logic            pvt_pready   ;
    logic   [31:0]   pvt_prdata   ;

    logic  [31:0]   efuse_paddr  ;
    logic           efuse_psel   ;
    logic           efuse_penable;
    logic           efuse_pwrite ;
    logic  [31:0]   efuse_pwdata ;
    logic            efuse_pready ;
    logic   [31:0]   efuse_prdata ;

    logic  [31:0]   lvro_paddr     ;
    logic           lvro_psel      ;
    logic           lvro_penable   ;
    logic           lvro_pwrite    ;
    logic  [31:0]   lvro_pwdata    ;
    logic            lvro_pready    ;
    logic   [31:0]   lvro_prdata    ;

    logic  [31:0]   lvro_master_paddr     ;
    logic           lvro_master_psel      ;
    logic           lvro_master_penable   ;
    logic           lvro_master_pwrite    ;
    logic  [31:0]   lvro_master_pwdata    ;
    logic            lvro_master_pready    ;
    logic   [31:0]   lvro_master_prdata    ;
    
    
    logic           pready_out   ;

    logic           z_dbg_w_req  ;
    logic           z_dbg_r_req ;

	//CHIP_ID 
	logic   [9:0]	chip_id;
	//fsm
	logic 	[2:0]	cur_state;
  logic   [2:0] nxt_state;
  logic [5:0] ci_cnt;//
  logic  cycle41_di_state;//
  logic  len_ecc_en;//
  logic  t_pkg_start;//
  logic  mid_fsm_psel;
  logic  mid_fsm_penable;
  logic  mid_fsm_pwrite;
  logic  mid_fsm_rdata_ready;
  logic  x_fsm_psel;
  logic  x_fsm_penable;
  logic  x_fsm_pwrite;
  logic  x_fsm_rdata_ready;

   logic  std_fsm_psel;
   logic  std_fsm_penable;
   logic  std_fsm_pwrite;
   logic  std_fsm_rdata_ready;
   logic ri_rst_f_n;
  
initial   begin
		wait_flag = 0;
		repeat(50) @(posedge pin_ci_J);
		wait_flag = 1;

end

   // logic uart_xclk;
   // logic uart_mid_clk;
   // logic uart_pll_clk;

   logic clk;
   logic clk_J;//wuqiang add
   logic rst;
   logic card_sel;
   logic [31:0] correct_data;
   logic [31:0] ecc_datain;
   logic [6:0] ecc_chkin;
//   logic ri_rst_f_n;
   //CDC check interface
   //cdc_pkg_mid_rd
   logic bus_read_ci2mid;
   logic rd_req_mid;
   //cdc_pkg_wr
   logic bus_write_ci2mid;
   logic wr_req_mid;
   //cdc_pkg_xclk_rd
   logic bus_read_ci2xclk;
   logic rd_req_xclk;
   //cdc_pkg_wr
   logic bus_write_ci2xclk;
   logic wr_req_xclk;

   //cdc_pkg_xclk_rd
   logic bus_read_ci2std;
   logic rd_req_std;
   //cdc_pkg_wr
   logic bus_write_ci2std;
   logic wr_req_std;

   //cdc_myaddr_vld
   logic myaddr_vld_ci;
   logic myaddr_vld_xclk;
   //cdc_pkg_ecc0
   logic t_z_ecc0;
   logic t_ecc0;
   //cdc_pkg_ecc1
   logic t_z_ecc1;
   logic t_ecc1;
   //cdc_pkg_ecc2
   logic t_z_ecc2;
   logic t_ecc2;
   //cdc_apb_rdata_vld
   logic apb_rdata_ready;
   logic apb_rdata_vld_ci;
   //cdc_xclk_apb_rdata_vld
   logic xclk_apb_rdata_ready;
   logic xclk_apb_rdata_ready_ci;
  
   logic std_apb_rdata_ready;
   logic std_apb_rdata_ready_ci;

   //cdc_nb_cnt_vld
   logic nb_cnt_vld;
   logic nb_cnt_vld_ci;
   logic ack_fail;
   
	logic [31:0]	paddr_a;
	logic			psel_a;//
	logic			penable_a;//
	logic			pwrite_a;//
	logic [31:0]	pwdata_a;
	logic			pready_a;
	logic [31:0]	prdata_a;
  logic clk_a;

	logic [31:0]	xclk_paddr_a;
	logic			xclk_psel_a;
	logic			xclk_penable_a;
	logic			xclk_pwrite_a;
	logic [31:0]	xclk_pwdata_a;
	logic			xclk_pready_a;
	logic [31:0]	xclk_prdata_a;
  logic xclk_a;
 
 
 `include "../../../verify/uvm/uvc/jls/src/jls_if_pc.sv"  



endinterface : jls_if
