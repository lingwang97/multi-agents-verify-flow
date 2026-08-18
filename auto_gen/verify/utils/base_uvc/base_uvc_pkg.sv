package base_uvc_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;

`include "base_env.sv"                // Base env: all env extend from this , print PASS/FAIL message at end of test
`include "base_monitor.sv"            // Base mon: all monitors extend from this
`include "base_scoreboard.sv"         // Base sb : all sb extend from this
`include "base_agent.sv"

endpackage : base_uvc_pkg
