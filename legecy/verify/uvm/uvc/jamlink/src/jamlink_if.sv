interface jamlink_if ();

   import uvm_pkg::*;
   import global_pkg::*;
import reg_addr::*;   
   string       report_id = "cal_adc_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["jamlink_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["jamlink_if"];

   initial begin
      IF_CHECKS_ENABLE["jamlink_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["jamlink_if"] = 1'b1;   //initially on
   end
   //jlm_wb
	logic [15:0] r_reg_setflush;
	logic [15:0] r_reg_difrst ;
	logic [15:0] r_reg_dofrst ;
	logic [15:0] r_reg_setrst ;
	logic [31:0] reg_ecc0;
	logic [31:0] reg_ecc1;
	logic [31:0] reg_ecc2;
	//
	logic do_fifo_empty;
	//input interface
	logic jlm_stb_i; 
	logic jlm_we_i;  
	logic [5:0] jlm_adr_i; 
	logic [31:0] jlm_dat_i; 
	logic [31:0] jlm_dat_o;


   logic init_mode;


   	logic clk;
   	logic rst;
   	logic card_sel;
  //------------------------------------------------------------------

  //-----------------------------------------------------------------
	//logic [8:0] len_fifo;
	logic [6:0] noncebufcnt;
   `include "../../../verify/uvm/uvc/jamlink/src/jamlink_if_pc.sv"  


endinterface : jamlink_if
