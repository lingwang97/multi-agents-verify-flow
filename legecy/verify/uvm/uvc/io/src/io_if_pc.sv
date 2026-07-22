`ifndef IO_ASSERTION_OFF


//            ______________________            CI posedge
// __________/
//           |- 100ps -|
//                      ____________________    CI_dly posedge, delay 100ps to CI
// ____________________/
// _______________
//                \______________________       CO negedge, occus between CI posedge and CI_dly posedge

//CI INV ASSERTION
property ci_inv_dsel0_sel0_pos;
  @(posedge CI_CKO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n) |-> CO_CKI_s === 1;
endproperty
assert_ci_inv_dsel0_sel0_pos: assert property(ci_inv_dsel0_sel0_pos) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel0_pos failed!");
cover_ci_inv_dsel0_sel0_pos: cover property(ci_inv_dsel0_sel0_pos);

property ci_inv_dsel0_sel0_pos_dly;
  @(posedge CI_CKO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n) |-> CO_CKI_s === 0;
endproperty
assert_ci_inv_dsel0_sel0_pos_dly: assert property(ci_inv_dsel0_sel0_pos_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel0_pos_dly failed!");
cover_ci_inv_dsel0_sel0_pos_dly: cover property(ci_inv_dsel0_sel0_pos_dly);

property ci_inv_dsel0_sel0_neg;
  @(negedge CI_CKO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n) |-> CO_CKI_s === 0;
endproperty
assert_ci_inv_dsel0_sel0_neg: assert property(ci_inv_dsel0_sel0_neg) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel0_neg failed!");
cover_ci_inv_dsel0_sel0_neg: cover property(ci_inv_dsel0_sel0_neg);

property ci_inv_dsel0_sel0_neg_dly;
  @(negedge CI_CKO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n) |-> CO_CKI_s === 1;
endproperty
assert_ci_inv_dsel0_sel0_neg_dly: assert property(ci_inv_dsel0_sel0_neg_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel0_neg_dly failed!");
cover_ci_inv_dsel0_sel0_neg_dly: cover property(ci_inv_dsel0_sel0_neg_dly);


property ci_inv_dsel0_sel1_pos;
  @(posedge CI_CKO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n) |-> CO_CKI_s === 1;
endproperty
assert_ci_inv_dsel0_sel1_pos: assert property(ci_inv_dsel0_sel1_pos) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel1_pos failed!");
cover_ci_inv_dsel0_sel1_pos: cover property(ci_inv_dsel0_sel1_pos);

property ci_inv_dsel0_sel1_pos_dly;
  @(posedge CI_CKO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n) |-> 
`ifndef FPGA_SYN  
  CO_CKI_s === 1'bz;
`else  
  CO_CKI_s === 1'b0;
`endif
endproperty
assert_ci_inv_dsel0_sel1_pos_dly: assert property(ci_inv_dsel0_sel1_pos_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel1_pos_dly failed!");
cover_ci_inv_dsel0_sel1_pos_dly: cover property(ci_inv_dsel0_sel1_pos_dly);

property ci_inv_dsel0_sel1_neg;
  @(negedge CI_CKO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n) |-> 
`ifndef FPGA_SYN  
  CO_CKI_s === 1'bz;
`else  
  CO_CKI_s === 1'b0;
`endif  
endproperty
assert_ci_inv_dsel0_sel1_neg: assert property(ci_inv_dsel0_sel1_neg) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel1_neg failed!");
cover_ci_inv_dsel0_sel1_neg: cover property(ci_inv_dsel0_sel1_neg);

property ci_inv_dsel0_sel1_neg_dly;
  @(negedge CI_CKO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n) |-> CO_CKI_s === 1;
endproperty
assert_ci_inv_dsel0_sel1_neg_dly: assert property(ci_inv_dsel0_sel1_neg_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel0_sel1_neg_dly failed!");
cover_ci_inv_dsel0_sel1_neg_dly: cover property(ci_inv_dsel0_sel1_neg_dly);


property ci_inv_dsel1_sel0_pos;
  @(posedge CKO_CI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n) |-> CKI_CO_n === 1;
endproperty
assert_ci_inv_dsel1_sel0_pos: assert property(ci_inv_dsel1_sel0_pos) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel0_pos failed!");
cover_ci_inv_dsel1_sel0_pos: cover property(ci_inv_dsel1_sel0_pos);

property ci_inv_dsel1_sel0_pos_dly;
  @(posedge CKO_CI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n) |-> CKI_CO_n === 0;
endproperty
assert_ci_inv_dsel1_sel0_pos_dly: assert property(ci_inv_dsel1_sel0_pos_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel0_pos_dly failed!");
cover_ci_inv_dsel1_sel0_pos_dly: cover property(ci_inv_dsel1_sel0_pos_dly);

property ci_inv_dsel1_sel0_neg;
  @(negedge CKO_CI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n) |-> CKI_CO_n === 0;
endproperty
assert_ci_inv_dsel1_sel0_neg: assert property(ci_inv_dsel1_sel0_neg) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel0_neg failed!");
cover_ci_inv_dsel1_sel0_neg: cover property(ci_inv_dsel1_sel0_neg);

property ci_inv_dsel1_sel0_neg_dly;
  @(negedge CKO_CI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n) |-> CKI_CO_n === 1;
endproperty
assert_ci_inv_dsel1_sel0_neg_dly: assert property(ci_inv_dsel1_sel0_neg_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel0_neg_dly failed!");
cover_ci_inv_dsel1_sel0_neg_dly: cover property(ci_inv_dsel1_sel0_neg_dly);


property ci_inv_dsel1_sel1_pos;
  @(posedge CKO_CI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n) |-> CKI_CO_n === 1;
endproperty
assert_ci_inv_dsel1_sel1_pos: assert property(ci_inv_dsel1_sel1_pos) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel1_pos failed!");
cover_ci_inv_dsel1_sel1_pos: cover property(ci_inv_dsel1_sel1_pos);

property ci_inv_dsel1_sel1_pos_dly;
  @(posedge CKO_CI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n) |-> 
`ifndef FPGA_SYN  
  CKI_CO_n === 1'bz;
`else  
  CKI_CO_n === 1'b0;
`endif   
endproperty
assert_ci_inv_dsel1_sel1_pos_dly: assert property(ci_inv_dsel1_sel1_pos_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel1_pos_dly failed!");
cover_ci_inv_dsel1_sel1_pos_dly: cover property(ci_inv_dsel1_sel1_pos_dly);

property ci_inv_dsel1_sel1_neg;
  @(negedge CKO_CI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n) |->
`ifndef FPGA_SYN  
  CKI_CO_n === 1'bz;
`else  
  CKI_CO_n === 1'b0;
`endif  
endproperty
assert_ci_inv_dsel1_sel1_neg: assert property(ci_inv_dsel1_sel1_neg) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel1_neg failed!");
cover_ci_inv_dsel1_sel1_neg: cover property(ci_inv_dsel1_sel1_neg);

property ci_inv_dsel1_sel1_neg_dly;
  @(negedge CKO_CI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n) |-> CKI_CO_n === 1;
endproperty
assert_ci_inv_dsel1_sel1_neg_dly: assert property(ci_inv_dsel1_sel1_neg_dly) else `uvm_error("[ASSERT ERR]","assert_ci_inv_dsel1_sel1_neg_dly failed!");
cover_ci_inv_dsel1_sel1_neg_dly: cover property(ci_inv_dsel1_sel1_neg_dly);


//CKI INV ASSERTION
property cki_inv_dsel0_sel0_pos;
  @(posedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CKO_CI_s === 1;
endproperty
assert_cki_inv_dsel0_sel0_pos: assert property(cki_inv_dsel0_sel0_pos) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel0_pos failed!");
cover_cki_inv_dsel0_sel0_pos: cover property(cki_inv_dsel0_sel0_pos);

property cki_inv_dsel0_sel0_pos_dly;
  @(posedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CKO_CI_s === 0;
endproperty
assert_cki_inv_dsel0_sel0_pos_dly: assert property(cki_inv_dsel0_sel0_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel0_pos_dly failed!");
cover_cki_inv_dsel0_sel0_pos_dly: cover property(cki_inv_dsel0_sel0_pos_dly);

property cki_inv_dsel0_sel0_neg;
  @(negedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CKO_CI_s === 0;
endproperty
assert_cki_inv_dsel0_sel0_neg: assert property(cki_inv_dsel0_sel0_neg) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel0_neg failed!");
cover_cki_inv_dsel0_sel0_neg: cover property(cki_inv_dsel0_sel0_neg);

property cki_inv_dsel0_sel0_neg_dly;
  @(negedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CKO_CI_s === 1;
endproperty
assert_cki_inv_dsel0_sel0_neg_dly: assert property(cki_inv_dsel0_sel0_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel0_neg_dly failed!");
cover_cki_inv_dsel0_sel0_neg_dly: cover property(cki_inv_dsel0_sel0_neg_dly);


property cki_inv_dsel0_sel1_pos;
  @(posedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> CKO_CI_s === 1;
endproperty
assert_cki_inv_dsel0_sel1_pos: assert property(cki_inv_dsel0_sel1_pos) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel1_pos failed!");
cover_cki_inv_dsel0_sel1_pos: cover property(cki_inv_dsel0_sel1_pos);

property cki_inv_dsel0_sel1_pos_dly;
  @(posedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> 
`ifndef FPGA_SYN  
  CKO_CI_s === 1'bz;
`else  
  CKO_CI_s === 1'b0;
`endif
endproperty
assert_cki_inv_dsel0_sel1_pos_dly: assert property(cki_inv_dsel0_sel1_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel1_pos_dly failed!");
cover_cki_inv_dsel0_sel1_pos_dly: cover property(cki_inv_dsel0_sel1_pos_dly);

property cki_inv_dsel0_sel1_neg;
  @(negedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> 
`ifndef FPGA_SYN  
  CKO_CI_s === 1'bz;
`else  
  CKO_CI_s === 1'b0;
`endif  
endproperty
assert_cki_inv_dsel0_sel1_neg: assert property(cki_inv_dsel0_sel1_neg) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel1_neg failed!");
cover_cki_inv_dsel0_sel1_neg: cover property(cki_inv_dsel0_sel1_neg);

property cki_inv_dsel0_sel1_neg_dly;
  @(negedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> CKO_CI_s === 1;
endproperty
assert_cki_inv_dsel0_sel1_neg_dly: assert property(cki_inv_dsel0_sel1_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel0_sel1_neg_dly failed!");
cover_cki_inv_dsel0_sel1_neg_dly: cover property(cki_inv_dsel0_sel1_neg_dly);


property cki_inv_dsel1_sel0_pos;
  @(posedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CI_CKO_n === 1;
endproperty
assert_cki_inv_dsel1_sel0_pos: assert property(cki_inv_dsel1_sel0_pos) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel0_pos failed!");
cover_cki_inv_dsel1_sel0_pos: cover property(cki_inv_dsel1_sel0_pos);

property cki_inv_dsel1_sel0_pos_dly;
  @(posedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CI_CKO_n === 0;
endproperty
assert_cki_inv_dsel1_sel0_pos_dly: assert property(cki_inv_dsel1_sel0_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel0_pos_dly failed!");
cover_cki_inv_dsel1_sel0_pos_dly: cover property(cki_inv_dsel1_sel0_pos_dly);

property cki_inv_dsel1_sel0_neg;
  @(negedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CI_CKO_n === 0;
endproperty
assert_cki_inv_dsel1_sel0_neg: assert property(cki_inv_dsel1_sel0_neg) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel0_neg failed!");
cover_cki_inv_dsel1_sel0_neg: cover property(cki_inv_dsel1_sel0_neg);

property cki_inv_dsel1_sel0_neg_dly;
  @(negedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && !REG_cko_inv) |-> CI_CKO_n === 1;
endproperty
assert_cki_inv_dsel1_sel0_neg_dly: assert property(cki_inv_dsel1_sel0_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel0_neg_dly failed!");
cover_cki_inv_dsel1_sel0_neg_dly: cover property(cki_inv_dsel1_sel0_neg_dly);


property cki_inv_dsel1_sel1_pos;
  @(posedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> CI_CKO_n === 1;
endproperty
assert_cki_inv_dsel1_sel1_pos: assert property(cki_inv_dsel1_sel1_pos) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel1_pos failed!");
cover_cki_inv_dsel1_sel1_pos: cover property(cki_inv_dsel1_sel1_pos);

property cki_inv_dsel1_sel1_pos_dly;
  @(posedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> 
`ifndef FPGA_SYN  
  CI_CKO_n === 1'bz;
`else  
  CI_CKO_n === 1'b0;
`endif   
endproperty
assert_cki_inv_dsel1_sel1_pos_dly: assert property(cki_inv_dsel1_sel1_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel1_pos_dly failed!");
cover_cki_inv_dsel1_sel1_pos_dly: cover property(cki_inv_dsel1_sel1_pos_dly);

property cki_inv_dsel1_sel1_neg;
  @(negedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && !REG_cko_inv) |->
`ifndef FPGA_SYN  
  CI_CKO_n === 1'bz;
`else  
  CI_CKO_n === 1'b0;
`endif  
endproperty
assert_cki_inv_dsel1_sel1_neg: assert property(cki_inv_dsel1_sel1_neg) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel1_neg failed!");
cover_cki_inv_dsel1_sel1_neg: cover property(cki_inv_dsel1_sel1_neg);

property cki_inv_dsel1_sel1_neg_dly;
  @(negedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && !REG_cko_inv) |-> CI_CKO_n === 1;
endproperty
assert_cki_inv_dsel1_sel1_neg_dly: assert property(cki_inv_dsel1_sel1_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_inv_dsel1_sel1_neg_dly failed!");
cover_cki_inv_dsel1_sel1_neg_dly: cover property(cki_inv_dsel1_sel1_neg_dly);


//CKI INV DIS ASSERTION
property cki_disinv_dsel0_sel0_pos;
  @(posedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CKO_CI_s === 0;
endproperty
assert_cki_disinv_dsel0_sel0_pos: assert property(cki_disinv_dsel0_sel0_pos) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel0_pos failed!");
cover_cki_disinv_dsel0_sel0_pos: cover property(cki_disinv_dsel0_sel0_pos);

property cki_disinv_dsel0_sel0_pos_dly;
  @(posedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CKO_CI_s === 1;
endproperty
assert_cki_disinv_dsel0_sel0_pos_dly: assert property(cki_disinv_dsel0_sel0_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel0_pos_dly failed!");
cover_cki_disinv_dsel0_sel0_pos_dly: cover property(cki_disinv_dsel0_sel0_pos_dly);

property cki_disinv_dsel0_sel0_neg;
  @(negedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CKO_CI_s === 1;
endproperty
assert_cki_disinv_dsel0_sel0_neg: assert property(cki_disinv_dsel0_sel0_neg) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel0_neg failed!");
cover_cki_disinv_dsel0_sel0_neg: cover property(cki_disinv_dsel0_sel0_neg);

property cki_disinv_dsel0_sel0_neg_dly;
  @(negedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CKO_CI_s === 0;
endproperty
assert_cki_disinv_dsel0_sel0_neg_dly: assert property(cki_disinv_dsel0_sel0_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel0_neg_dly failed!");
cover_cki_disinv_dsel0_sel0_neg_dly: cover property(cki_disinv_dsel0_sel0_neg_dly);


property cki_disinv_dsel0_sel1_pos;
  @(posedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && REG_cko_inv) |-> 
`ifndef FPGA_SYN  
  CKO_CI_s === 1'bz;
`else  
  CKO_CI_s === 1'b0;
`endif  
endproperty
assert_cki_disinv_dsel0_sel1_pos: assert property(cki_disinv_dsel0_sel1_pos) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel1_pos failed!");
cover_cki_disinv_dsel0_sel1_pos: cover property(cki_disinv_dsel0_sel1_pos);

property cki_disinv_dsel0_sel1_pos_dly;
  @(posedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && REG_cko_inv) |-> CKO_CI_s === 1'b1;
endproperty
assert_cki_disinv_dsel0_sel1_pos_dly: assert property(cki_disinv_dsel0_sel1_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel1_pos_dly failed!");
cover_cki_disinv_dsel0_sel1_pos_dly: cover property(cki_disinv_dsel0_sel1_pos_dly);

property cki_disinv_dsel0_sel1_neg;
  @(negedge CKI_CO_n) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && REG_cko_inv) |-> CKO_CI_s === 1'b1;
endproperty
assert_cki_disinv_dsel0_sel1_neg: assert property(cki_disinv_dsel0_sel1_neg) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel1_neg failed!");
cover_cki_disinv_dsel0_sel1_neg: cover property(cki_disinv_dsel0_sel1_neg);

roperty cki_disinv_dsel0_sel1_neg_dly;
  @(negedge CKI_CO_n_dly) disable iff(!io_assert_gate)
  (!pin_dsel_n && pin_sel_n && REG_cko_inv) |->
`ifndef FPGA_SYN  
  CKO_CI_s === 1'bz;
`else  
  CKO_CI_s === 1'b0;
`endif  
endproperty
assert_cki_disinv_dsel0_sel1_neg_dly: assert property(cki_disinv_dsel0_sel1_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel0_sel1_neg_dly failed!");
cover_cki_disinv_dsel0_sel1_neg_dly: cover property(cki_disinv_dsel0_sel1_neg_dly);


property cki_disinv_dsel1_sel0_pos;
  @(posedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CI_CKO_n === 0;
endproperty
assert_cki_disinv_dsel1_sel0_pos: assert property(cki_disinv_dsel1_sel0_pos) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel0_pos failed!");
cover_cki_disinv_dsel1_sel0_pos: cover property(cki_disinv_dsel1_sel0_pos);

property cki_disinv_dsel1_sel0_pos_dly;
  @(posedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CI_CKO_n === 1;
endproperty
assert_cki_disinv_dsel1_sel0_pos_dly: assert property(cki_disinv_dsel1_sel0_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel0_pos_dly failed!");
cover_cki_disinv_dsel1_sel0_pos_dly: cover property(cki_disinv_dsel1_sel0_pos_dly);

property cki_disinv_dsel1_sel0_neg;
  @(negedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CI_CKO_n === 1;
endproperty
assert_cki_disinv_dsel1_sel0_neg: assert property(cki_disinv_dsel1_sel0_neg) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel0_neg failed!");
cover_cki_disinv_dsel1_sel0_neg: cover property(cki_disinv_dsel1_sel0_neg);

property cki_disinv_dsel1_sel0_neg_dly;
  @(negedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && !pin_sel_n && REG_cko_inv) |-> CI_CKO_n === 0;
endproperty
assert_cki_disinv_dsel1_sel0_neg_dly: assert property(cki_disinv_dsel1_sel0_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel0_neg_dly failed!");
cover_cki_disinv_dsel1_sel0_neg_dly: cover property(cki_disinv_dsel1_sel0_neg_dly);


property cki_disinv_dsel1_sel1_pos;
  @(posedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && REG_cko_inv) |->
`ifndef FPGA_SYN  
  CI_CKO_n === 1'bz;
`else  
  CI_CKO_n === 1'b0;
`endif  
endproperty
assert_cki_disinv_dsel1_sel1_pos: assert property(cki_disinv_dsel1_sel1_pos) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel1_pos failed!");
cover_cki_disinv_dsel1_sel1_pos: cover property(cki_disinv_dsel1_sel1_pos);

property cki_disinv_dsel1_sel1_pos_dly;
  @(posedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && REG_cko_inv) |-> CI_CKO_n === 1'b1;
endproperty
assert_cki_disinv_dsel1_sel1_pos_dly: assert property(cki_disinv_dsel1_sel1_pos_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel1_pos_dly failed!");
cover_cki_disinv_dsel1_sel1_pos_dly: cover property(cki_disinv_dsel1_sel1_pos_dly);

property cki_disinv_dsel1_sel1_neg;
  @(negedge CO_CKI_s) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && REG_cko_inv) |-> CI_CKO_n === 1'b1;
endproperty
assert_cki_disinv_dsel1_sel1_neg: assert property(cki_disinv_dsel1_sel1_neg) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel1_neg failed!");
cover_cki_disinv_dsel1_sel1_neg: cover property(cki_disinv_dsel1_sel1_neg);

property cki_disinv_dsel1_sel1_neg_dly;
  @(negedge CO_CKI_s_dly) disable iff(!io_assert_gate)
  (pin_dsel_n && pin_sel_n && REG_cko_inv) |-> 
`ifndef FPGA_SYN  
  CI_CKO_n === 1'bz;
`else  
  CI_CKO_n === 1'b0;
`endif  
endproperty
assert_cki_disinv_dsel1_sel1_neg_dly: assert property(cki_disinv_dsel1_sel1_neg_dly) else `uvm_error("[ASSERT ERR]","assert_cki_disinv_dsel1_sel1_neg_dly failed!");
cover_cki_disinv_dsel1_sel1_neg_dly: cover property(cki_disinv_dsel1_sel1_neg_dly);


`endif
