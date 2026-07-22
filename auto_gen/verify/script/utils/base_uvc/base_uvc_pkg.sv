package base_uvc_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
import reg_addr::*;

`include "base_env.sv"            // Base env: print PASS/FAIL message at end of test
`include "base_mon.sv"            // Base mon: all monitors extend from this
`include "base_sb.sv"             // Base sb : all monitors extend from this
//`include "base_drv.sv"
`include "base_agent.sv"

endpackage : base_uvc_pkg
