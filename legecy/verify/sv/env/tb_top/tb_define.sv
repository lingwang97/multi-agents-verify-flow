//----------------------------------------------------------------------------------------
// entry macro
//----------------------------------------------------------------------------------------
`define INCLUDE_FILE(NAME,NAME2) \
    `include "NAME``_``NAME2"
`define TB_TOP                  tb_top

`define BTC(n)                  `TB_TOP.C[n].btnode.btc
`define BTC0                    `BTC(0)

`ifndef PL_SIM
`define ERROR_MAX_NUM           20
`else 
`define ERROR_MAX_NUM           200
`endif

`define TOP_CLK4

`define XCLK_FREQ           24

`define PLL_DEFAULT_FREQ        24

`define PLL0_POR_FREQ           200

//<translate_macro_start>

//skip so much 
`ifndef PL_SIM
    //with RO_TEST defined, which is not define ARM_UD_MODEL, will raise tons of timing violation, fix define temprorary
    `ifndef RO_TEST
        `define ARM_UD_MODEL  // for library cell fast mode simulation without violation
    `endif
`endif

`define MX2_VER
`ifdef OSC_48M
    `define XCLK_P_NS 20.832
`else
    `define XCLK_P_NS 41.666
`endif

`include "gls_macro_define.sv"
