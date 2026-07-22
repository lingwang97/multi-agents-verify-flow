interface efuse_if ();

   import uvm_pkg::*;
   import global_pkg::*;
   import reg_addr::*;   
   string       report_id = "cal_adc_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["efuse_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["efuse_if"];

   initial begin
      IF_CHECKS_ENABLE["efuse_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["efuse_if"] = 1'b1;   //initially on
   end
  
   logic			   xclk;
   logic			   xclk_gated;
   logic 		   pin_ri;
   logic             psel           ; //APB bus 
   logic      [31:0] paddr          ; //APB bus 
   logic             penable        ; //APB bus 
   logic             pready_in      ; //APB bus 
   logic             pwrite         ; //APB bus 
   logic      [31:0] pwdata         ; //APB bus 
   logic             pready_out     ; //APB bus 
   logic      [31:0] prdata         ; //APB bus 

   logic      [31:0] paddr_1r        ;
   logic             pwrite_1r       ;
//===============efuse ip interfaec===================
   logic [31:0] ip_Q                  ;
   logic [3:0]  ip_RF                 ;
   logic        ip_CSB                ;
   logic        ip_STROBE             ;
   logic        ip_LOAD               ;
   logic        ip_PGENB              ;
   logic        ip_PS                 ;
   logic        ip_MR                 ;
   logic        ip_PD                 ;
   logic        ip_RWL                ;
   logic        ip_RSB                ;
   logic [9:0]  ip_A                  ;
   logic [1:0]  ip_AT                 ;
   logic        ip_TRCS               ;

//===============reg  signal=====================

  logic [31:0] reg_strobe_timer       ;
  logic        reg_strobe_timer_we    ;

//===============internal  signal================


//===============external  signal================

   logic             strobe_cnt_en   ;
   logic             strobe_init_en  ;
   logic      [31:0] strobe_cnt      ;


   logic          mid_clk;
   logic          mid_pin_ri         ; //RI reset
   logic          rst;
   logic          card_sel;

   logic        ip_Q_and              ;
   assign ip_Q_and = &ip_Q;
   `include "../../../verify/uvm/uvc/efuse/src/efuse_if_pc.sv"  


endinterface : efuse_if
