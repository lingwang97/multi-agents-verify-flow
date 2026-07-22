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
`ifdef PLL0_POR_FREQ_300M
parameter RICLK = 3;//when RI = 1, then set pll0 = 200ns
`else
parameter RICLK = 5;//when RI = 1, then set pll0 = 200ns
`endif
parameter RICLK_MODE0 = 5;//when RI = 1, then set pll0 = 200ns
parameter MODE_I = 0;
parameter MODE_W = 2;//fifo address
integer TOTAL_CORE_NUM = `DESIGN_CORE_NUM;
logic [7:0] GC_DESIGN_CORE_NUM_8BIT = `DESIGN_CORE_NUM;

`define DATA_TP_LEN                  259


`define SLICE_START(x) `SLICE``x``_START
`define SLICE_CORE_NUMS(x)   `SLICE``x``_CORE_NUM

localparam int slice_start[`SLICE_NUM] = '{
    `SLICE_START(0),
    `SLICE_START(1),
    `SLICE_START(2),
    `SLICE_START(3),
    `SLICE_START(4),
    `SLICE_START(5),
    `SLICE_START(6),
    `SLICE_START(7)

};
localparam int slice_core_num[`SLICE_NUM] = '{
    `SLICE_CORE_NUMS(0),
    `SLICE_CORE_NUMS(1),
    `SLICE_CORE_NUMS(2),
    `SLICE_CORE_NUMS(3),
    `SLICE_CORE_NUMS(4),
    `SLICE_CORE_NUMS(5),
    `SLICE_CORE_NUMS(6),
    `SLICE_CORE_NUMS(7)

};

parameter int slice_end[`SLICE_NUM] = '{
    `SLICE_START(0)+`SLICE_CORE_NUMS(0)-1,
    `SLICE_START(1)+`SLICE_CORE_NUMS(1)-1,
    `SLICE_START(2)+`SLICE_CORE_NUMS(2)-1,
    `SLICE_START(3)+`SLICE_CORE_NUMS(3)-1,
    `SLICE_START(4)+`SLICE_CORE_NUMS(4)-1,
    `SLICE_START(5)+`SLICE_CORE_NUMS(5)-1,
    `SLICE_START(6)+`SLICE_CORE_NUMS(6)-1,
    `SLICE_START(7)+`SLICE_CORE_NUMS(7)-1

};

//////////////////////////////////////////////////////////////////////////////////////


endpackage : global_pkg
