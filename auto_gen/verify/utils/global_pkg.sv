package global_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "global_enum.svh"

string report_id = "global_pkg";



//////////////////////////////////////////////////////////////////////////////////////
bit MON_CHECKS_ENABLE[string];   //Enables/Disables checking in monitor
bit MON_COVERAGE_ENABLE[string]; //Enables/Disables coverage in monitor
bit IF_CHECKS_ENABLE[string];    //Enables/Disables protocol checking in uvc interface
bit IF_COVERAGE_ENABLE[string];  //Enables/Disables coverage in uvc interface
bit SB_CHECKS_ENABLE[string];   //Enables/Disables checking in scoreboard

// Define global parameter Here





endpackage : global_pkg

