`define HDLREF_OneSliceAllMx2CoreBus2Bus(C_ID,S_ID,OFST,SL2,SL1,RTLN,NL_L,NL_R,MSB,LSB)\
  `define THIS_S_ID_``S_ID\
  `ifdef PL_SIM\
    `ifdef THIS_S_ID_0\
      `ifndef NetList__MX2Core \
        `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE0_END,`GLS_SLICE0_START)\
      `else \
        `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,20,`GLS_SLICE0_START)\
        //`HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE0_END,`GLS_MAX_LONG_MX2CORE_R)\
      `endif  \
    `elsif THIS_S_ID_1\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE1_END,`GLS_SLICE1_START)\
    `elsif THIS_S_ID_2\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE2_END,`GLS_SLICE2_START)\
    `elsif THIS_S_ID_3\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE3_END,`GLS_SLICE3_START)\
    `elsif THIS_S_ID_4\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE4_END,`GLS_SLICE4_START)\
    `elsif THIS_S_ID_5\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE5_END,`GLS_SLICE5_START)\
    `elsif THIS_S_ID_6\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2_,__mx2.``RTLN,`GLS_SLICE6_END,`GLS_SLICE6_START)\	  
    `endif\
  `undef THIS_S_ID_``S_ID \
  `else /*RTL*/ \
    `ifdef THIS_S_ID_0\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE0_END,`GLS_SLICE0_START)\
    `elsif THIS_S_ID_1\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE1_END,`GLS_SLICE1_START)\
    `elsif THIS_S_ID_2\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE2_END,`GLS_SLICE2_START)\
    `elsif THIS_S_ID_3\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE3_END,`GLS_SLICE3_START)\
    `elsif THIS_S_ID_4\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE4_END,`GLS_SLICE4_START)\
    `elsif THIS_S_ID_5\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE5_END,`GLS_SLICE5_START)\
    `elsif THIS_S_ID_6\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE6_END,`GLS_SLICE6_START)\
    `endif\
  `endif\
  `undef THIS_S_ID_``S_ID

`define HDLREF_OneMx2Core2ChBus2Bus(C_ID,S_ID,OFST,SL2,SL1,RTLN,NL_L,NL_R,MSB,LSB)\
  `define THIS_S_ID_``S_ID\
  `ifdef PL_SIM\
    `ifdef THIS_S_ID_0\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE0_RW_CORE_END,`GLS_SLICE0_RW_CORE_START )\
    `elsif THIS_S_ID_1\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_A_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE0_LW_CORE_END,`GLS_SLICE0_LW_CORE_START)\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_B_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE1_RW_CORE_END,`GLS_SLICE1_RW_CORE_START)\	  
    `elsif THIS_S_ID_2\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_A_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE1_LW_CORE_END,`GLS_SLICE1_LW_CORE_START)\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_B_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE2_RW_CORE_END,`GLS_SLICE2_RW_CORE_START)\	  
    `elsif THIS_S_ID_3\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_A_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE2_LW_CORE_END,`GLS_SLICE2_LW_CORE_START)\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_B_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE3_RW_CORE_END,`GLS_SLICE3_RW_CORE_START)\	  
    `elsif THIS_S_ID_4\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_A_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE3_LW_CORE_END,`GLS_SLICE3_LW_CORE_START)\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_B_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE4_RW_CORE_END,`GLS_SLICE4_RW_CORE_START)\	  
    `elsif THIS_S_ID_5\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_A_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE4_LW_CORE_END,`GLS_SLICE4_LW_CORE_START)\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_B_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE5_RW_CORE_END,`GLS_SLICE5_RW_CORE_START)\
    `elsif THIS_S_ID_6\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_A_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE5_LW_CORE_END,`GLS_SLICE5_LW_CORE_START)\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_B_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE6_RW_CORE_END,`GLS_SLICE6_RW_CORE_START)\
    `elsif THIS_S_ID_7\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.ch``S_ID``.G_SLICE_TAIL_WRAPPER_,__mx2_clkgen.``RTLN,`GLS_SLICE6_LW_CORE_END,`GLS_SLICE6_LW_CORE_START)\
    `endif\
  `undef THIS_S_ID_``S_ID \
  `else /*RTL*/ \
    `ifdef THIS_S_ID_0\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE0_END,`GLS_SLICE0_START)\
    `elsif THIS_S_ID_1\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE1_END,`GLS_SLICE1_START)\
    `elsif THIS_S_ID_2\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE2_END,`GLS_SLICE2_START)\
    `elsif THIS_S_ID_3\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE3_END,`GLS_SLICE3_START)\
    `elsif THIS_S_ID_4\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE4_END,`GLS_SLICE4_START)\
    `elsif THIS_S_ID_5\
      `HDL_OpWireBus(SL2,SL1``tb_top.C[C_ID].btnode.btc.slice``S_ID``.G_MX2[,].mx2.``RTLN,`GLS_SLICE5_END,`GLS_SLICE5_START)\
    `endif\
  `endif\
  `undef THIS_S_ID_``S_ID