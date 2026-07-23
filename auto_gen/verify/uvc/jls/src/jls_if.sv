interface jls_if ();

  import uvm_pkg::*;
  import global_pkg::*;
  //import reg_addr::*;      //USE YOUR REG DEFINE PKG IF YOU HAS ONE
  string report_id = "jls_if";
    
  logic checks_enable;      //always@(*) checks_enable    = IF_CHECKS_ENABLE["jls_if"];
  logic coverage_enable;    //always@(*) coverage_enable  = IF_COVERAGE_ENABLE["jls_if"];
  logic rst;
  logic clk;
  logic card_sel;
  logic[31:0] jls_ctrl;

  initial begin
      IF_CHECKS_ENABLE["jls_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["jls_if"] = 1'b1;   //initially on
  end

  //add common interface signal here

 `include "jls_if_pc.sv" //maybe need to update
endinterface : jls_if
