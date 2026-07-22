`include "gls_macro_base_inc.sv"

`define HDL_OpPerWire(OPT,MSB,LSB,VAL) \
  `define LRH_DEF0__LSB_``LSB \
  `LH_ID_RH_``MSB``(OPT,VAL) \
  `undef LRH_DEF0__LSB_``LSB

`define HDL_OpWireBus(OPT,MID,VAL,MSB,LSB) \
  `define LRH_DEF1__LSB_``LSB\
  `define LRH_DEF1__MSB_``MSB\
  `ifdef LRH_DEF1__LSB_0\
    `ifdef LRH_DEF1__MSB_0\
      `LH_ID_MH_ID_RH(OPT,,MID,,VAL)\
    `else\
      `LH_ID_MH_ID_RH_``MSB``(OPT,MID,VAL)\
    `endif\
  `else\
    `LH_ID_MH_ID_RH_``MSB``(OPT,MID,VAL)\
  `endif\
  `undef LRH_DEF1__LSB_``LSB\
  `undef LRH_DEF1__MSB_``MSB

  //used for core netlist only connection
  `define HDL_OneSliceMx2NetlistTailBus2Bus(C_ID,S_ID,SL2,SL1,SR1) \
    `ifdef NetList__MX2Core_Tile_L \
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2_,__mx2.mx2_tail_``SR1``,3 ,3 ) \
    `endif \
    `ifdef NetList__MX2Core_Tile_M \
      `HDL_OpWireBus(SL2,+7``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2_,__mx2.mx2_tail_``SR1``,3 ,3 ) \
    `endif \ 
    `ifdef NetList__MX2Core_Tile_H \
      `HDL_OpWireBus(SL2,+14``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2_,__mx2.mx2_tail_``SR1``,3 ,3 ) \
    `endif

  //used for kick out core netlist used connection
  `define HDL_OneSliceMx2NonNetlistTailBus2Bus(C_ID,SL1,SR1,SR2) \
    `ifdef NetList__MX2Core \
      `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice0.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,20,`GLS_SLICE0_START) \
      //`HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice0.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE0_END,11) \
    `else \
      `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice0.G_MX2_,__mx2.mx2_tail.``SR1,SR2,`GLS_SLICE0_END,`GLS_SLICE0_START) \
    `endif \
    `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice1.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE1_END,`GLS_SLICE1_START) \
    `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice2.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE2_END,`GLS_SLICE2_START) \
    `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice3.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE3_END,`GLS_SLICE3_START) \
    `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice4.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE4_END,`GLS_SLICE4_START) \
    `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice5.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE5_END,`GLS_SLICE5_START) \
    `HDL_OpWireBus(SL1`` tb_top.C[C_ID].btnode.btc.slice6.G_MX2_,__mx2.mx2_tail.``SR1``,SR2,`GLS_SLICE6_END,`GLS_SLICE6_START)

  `define HDL_OneSliceMx2NetlistHeadBus2Bus(C_ID,S_ID,SL2,SL1,SR1) \
    `ifdef NetList__MX2Core_Tile_L \
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2_,__mx2.mx2_head_``SR1``,3 ,3 ) \
    `endif \
    `ifdef NetList__MX2Core_Tile_M \
      `HDL_OpWireBus(SL2,+7``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2_,__mx2.mx2_head_``SR1``,3 ,3 ) \
    `endif \ 
    `ifdef NetList__MX2Core_Tile_H \
      `HDL_OpWireBus(SL2,+14``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2_,__mx2.mx2_head_``SR1``,3 ,3 ) \
    `endif

  `define HDL_OneSliceMx2NonNetlistHeadBus2Bus(C_ID,S_ID,SL2,SL1,SR1) \
    `ifdef NetList__MX2Core_Tile_L \
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2_,__mx2.mx2_head.``SR1,2 ,0 ) \
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2_,__mx2.mx2_head.``SR1,6 ,4 ) \
    `endif \
    `ifdef NetList__MX2Core_Tile_M \
     `HDL_OpWireBus(SL2,+7``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2_,__mx2.mx2_head.``SR1,2 ,0 ) \
     `HDL_OpWireBus(SL2,+7``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2_,__mx2.mx2_head.``SR1,6 ,4 ) \
    `endif \
    `ifdef NetList__MX2Core_Tile_H \
     `HDL_OpWireBus(SL2,+14``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2_,__mx2.mx2_head.``SR1,2 ,0 ) \
     `HDL_OpWireBus(SL2,+14``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2_,__mx2.mx2_head.``SR1,6 ,4 ) \
    `endif

  `define HDL_OneSliceMx2HeadBus2Bus(C_ID,S_ID,SL2,SL1,SR1) \
     `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2_,__mx2.mx2_head.``SR1,6 ,0 ) \
     `HDL_OpWireBus(SL2,+7``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2_,__mx2.mx2_head.``SR1,6 ,0 ) \
     `HDL_OpWireBus(SL2,+14``SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2_,__mx2.mx2_head.``SR1,6 ,0 )

`define GLS_INIT_REG(HDL,VAL) \
 initial begin \
    reg val; \
    #1000ns; \
   //  @(posedge tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.spd2core.REG_Cfg_SpdGo);\
   @(posedge tb_top.C[0].btnode.btc.sys_ctrl.crg.mid_rst_n);\
    #200ns; \
    if(HDL``.D === 1'bx) val = VAL ; else val = HDL``.D ; \
    force HDL``.D=val; force HDL``.CK=0; #1ns; force HDL``.CK=1; #20ns ; force HDL``.CK=0; release HDL``.CK; release HDL``.D; \
 end

`define GLS_INIT_WORK_DATA_BUF_REG(C_ID,HDL,VAL)\
initial begin \
   reg val; \
   #1000ns; \
   //  @(posedge tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.spd2core.REG_Cfg_SpdGo);\
   @(posedge tb_top.C[C_ID].btnode.btc.sys_ctrl.crg.mid_rst_n);\
   #200ns; \
   if(HDL``.D === 1'bx) val = VAL ; else val = HDL``.D ; \
   force HDL``.D=val; force HDL``.CK=0; #1ns; force HDL``.CK=1; #20ns ; force HDL``.CK=0; release HDL``.CK; release HDL``.D; \
   force HDL``.D=val; #100ns; release HDL``.D; \
end

`define GLS_INIT_REG_IN_RST(C_ID,HDL,VAL) \
 initial begin \
    reg val; \
    #1000ns; \
    @(negedge tb_top.C[C_ID].btnode.btc.sys_ctrl.crg.mid_rst_n);\
    if(HDL``.D === 1'bx) val = VAL ; else val = HDL``.D ; \
    force HDL``.D=val; force HDL``.CK=0; #1ns; force HDL``.CK=1; #20ns ; force HDL``.CK=0; \
    repeat(2)@(negedge tb_top.C[0].btnode.btc.sys_ctrl.crg.mid_clk); \
    release HDL``.CK; release HDL``.D; \
 end

`include "gls_slice_chip_define.sv"

//`ifdef NetList__0p5
`define RO_SLICE_TOP      tb_top.C[0].btnode.btc.slice1.ro_core_ctrl
`define MX2_CORE_GATE_PATH     tb_top.C[0].btnode.btc.slice2.slice2_tile_h.G_MX2_3__mx2
`define MX2_CORE_GATE_PATH_M   tb_top.C[0].btnode.btc.slice2.slice2_tile_m.G_MX2_3__mx2
`define MX2_CORE_GATE_PATH_L   tb_top.C[0].btnode.btc.slice2.slice2_tile_l.G_MX2_3__mx2

`define S0MX2TINY(C_ID) tb_top.C[C_ID].btnode.btc.slice0.G_MX2_TINY_177__mx2_tiny
`define S4MX2TINY(C_ID) tb_top.C[C_ID].btnode.btc.slice4.G_MX2_TINY_178__mx2_tiny

`define HDL_OpSlice2Mx2NonNetlistTailPerInst(C_ID,OP,SIG) \
  `ifdef NetList__MX2Core \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice0.G_MX2_,20,0,__mx2.mx2_tail.``SIG) \
  //`HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice0.G_MX2_,`GLS_SLICE0_END,11,__mx2.mx2_tail.``SIG) \
  `else \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice0.G_MX2_,`GLS_SLICE0_END,`GLS_SLICE0_START,__mx2.mx2_tail.``SIG) \
  `endif \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice1.G_MX2_,`GLS_SLICE1_END,`GLS_SLICE1_START,__mx2.mx2_tail.``SIG) \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice2.G_MX2_,`GLS_SLICE2_END,`GLS_SLICE2_START,__mx2.mx2_tail.``SIG) \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice3.G_MX2_,`GLS_SLICE3_END,`GLS_SLICE3_START,__mx2.mx2_tail.``SIG) \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice4.G_MX2_,`GLS_SLICE4_END,`GLS_SLICE4_START,__mx2.mx2_tail.``SIG) \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice5.G_MX2_,`GLS_SLICE5_END,`GLS_SLICE5_START,__mx2.mx2_tail.``SIG) \
  `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice6.G_MX2_,`GLS_SLICE6_END,`GLS_SLICE6_START,__mx2.mx2_tail.``SIG) \

`define HDL_OpOneSliceMx2TailPerInst(C_ID,S_ID,OP,SIG) \
  `ifdef PL_SIM\
     `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2_,6,0,__mx2.mx2_tail.``SIG) \
     `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2_,6,0,__mx2.mx2_tail.``SIG) \
     `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2_,6,0,__mx2.mx2_tail.``SIG) \
  `else\
     `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_l.G_MX2[,6,0,].mx2.mx2_tail.``SIG) \
     `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_m.G_MX2[,6,0,].mx2.mx2_tail.``SIG) \
     `HDL_OpPerWire(OP`` tb_top.C[C_ID].btnode.btc.slice``S_ID``.slice``S_ID``_tile_h.G_MX2[,6,0,].mx2.mx2_tail.``SIG) \
  `endif

`ifdef PL_SIM
  `define BTNODE_SPEED_CORE_LH btnode.btc.sys_ctrl.speed.G_
  `define SPEED_CORE_RH __speed_core
  `define ChClkGenL _
  `define ChClkGenR __
  `define MX2_HEAD_RX mx2_head_mx2_rx_
  `define MX2_HEAD_TX mx2_head_mx2_tx_
  `define MX2_TAIL_RX mx2_tail_mx2_rx_
  `define MX2_TAIL_TX mx2_tail_mx2_tx_
  `define mx2_tail_selfclk_top_U_SELFCLK mx2_tail_selfclk_top_U_SELFCLK_
  `define mx2_tail_selfclk_top mx2_tail_selfclk_top_
  `define mx2_head_sha256_reg  mx2_head_sha256_reg_
  `define mx2_head_mx2_rx mx2_head_mx2_rx_
`else
  `define BTNODE_SPEED_CORE_LH btnode.btc.sys_ctrl.speed.G[
  `define SPEED_CORE_RH ].speed_core
  `define ChClkGenL [
  `define ChClkGenR ].
  `define MX2_HEAD_RX mx2_head.mx2_rx.
  `define MX2_HEAD_TX mx2_head.mx2_tx.
  `define MX2_TAIL_RX mx2_tail.mx2_rx.
  `define MX2_TAIL_TX mx2_tail.mx2_tx.
  `define mx2_tail_selfclk_top_U_SELFCLK mx2_tail.selfclk_top.U_SELFCLK.
  `define mx2_tail_selfclk_top mx2_tail.selfclk_top.
  `define mx2_head_sha256_reg  mx2_head.sha256_reg.
  `define mx2_head_mx2_rx mx2_head.mx2_rx.
`endif

`define C0_SPEED_CORE_LH tb_top.C[0].```BTNODE_SPEED_CORE_LH
`define SYS_CTRL_G_SPEED_CORE(CHIP_ID,CORE_ID) tb_top.C[CHIP_ID].```BTNODE_SPEED_CORE_LH``CORE_ID```SPEED_CORE_RH

`include "gls_macro_mxcore_inc.sv"
`include "gls_macro_hdlref_inc.sv"
`include "/filesets/project/SG/siruichang/btc/a3195b/core/man2c_new/new_mx2/rtl/rtl_BE/ctrl/ctrl_top/core_define.vh"
