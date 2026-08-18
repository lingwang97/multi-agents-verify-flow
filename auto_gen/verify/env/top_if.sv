interface top_if ();

  import uvm_pkg::*;
  import global_pkg::*;
  //import reg_addr::*;      //USE YOUR REG DEFINE PKG IF YOU HAS ONE
  string report_id = "top_if";
    
  logic checks_enable;      
  logic coverage_enable;    
  logic rst;
  logic clk;
  logic card_sel;
  logic[31:0] top_ctrl;

  initial begin
      IF_CHECKS_ENABLE["top_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["top_if"] = 1'b1;   //initially on
      checks_enable   = 1'b1;                   //initially on
      coverage_enable = 1'b1;                   //initially on
  end

  //Real-time update of the flag signal in specific test scenarios
  always@(IF_CHECKS_ENABLE["top_if"]) checks_enable = IF_CHECKS_ENABLE["top_if"];
  always@(IF_COVERAGE_ENABLE["top_if"]) coverage_enable = IF_COVERAGE_ENABLE["top_if"];
  //add common interface signal here

 `include "top_if_pc.sv" //maybe need to update
endinterface : top_if
