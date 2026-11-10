interface apb_master_if ();

  import uvm_pkg::*;
  import global_pkg::*;
  //import reg_addr::*;      //USE YOUR REG DEFINE PKG IF YOU HAS ONE
  string report_id = "apb_master_if";
    
  logic checks_enable;
  logic coverage_enable;
  logic rst;
  logic clk;
  logic card_sel;
  logic[31:0] apb_master_ctrl;

  // APB v3 protocol signals (rst is active-high here; DUT PRESETn = ~rst)
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;
  logic pslverr;

  initial begin
      IF_CHECKS_ENABLE["apb_master_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["apb_master_if"] = 1'b1;   //initially on
      checks_enable   = 1'b1;                   //initially on
      coverage_enable = 1'b1;                   //initially on
  end

  //Real-time update of the flag signal in specific test scenarios
  always@(IF_CHECKS_ENABLE["apb_master_if"]) checks_enable = IF_CHECKS_ENABLE["apb_master_if"];
  always@(IF_COVERAGE_ENABLE["apb_master_if"]) coverage_enable = IF_COVERAGE_ENABLE["apb_master_if"];



  //add common interface signal here

 `include "apb_master_if_pc.sv" //maybe need to update
endinterface : apb_master_if
