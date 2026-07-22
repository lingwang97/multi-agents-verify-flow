
`ifndef MDL_EFUSE

`define WAIT_FLAG tb_top.jls_pif.wait_flag

`ifndef RANDOM_REG_CHECK

property ip_pgm_load_mutex ;
    @(posedge xclk) (`WAIT_FLAG) |-> (!((!ip_PGENB) & ip_LOAD)) ;
endproperty
chk_ip_pgm_load_mutex:
assert property(ip_pgm_load_mutex) else `uvm_error("ASSERT ERROR","ip_PGENB and ip_LOAD is enabled in the same time!");
cov_ip_pgm_load_mutex:
cover property(ip_pgm_load_mutex);

property ip_pd_ps ;
    @(posedge xclk) (`WAIT_FLAG) |-> (!(ip_PS & ip_PD)) ;
endproperty
chk_ip_pd_ps:
assert property(ip_pd_ps) else `uvm_error("ASSERT ERROR","ip_PS and ip_PD is enabled in the same time!");
cov_ip_pd_ps:
cover property(ip_pd_ps);

property ip_ps_state ;
    @(posedge xclk) (`WAIT_FLAG) |-> ((ip_PS & (!ip_PGENB)) || (ip_LOAD & (!ip_PS))||((!$isunknown(ip_PS))&&(ip_PGENB&(!ip_LOAD))));
endproperty
chk_ip_ps_state:
assert property(ip_ps_state) else `uvm_error("ASSERT ERROR","ip_PS status cant meet being low except pgm!");
cov_ip_ps_state:
cover property(ip_ps_state);


property ip_strobe_protect ;
    @(posedge xclk) (`WAIT_FLAG  && (ip_STROBE)) |-> ((!ip_PGENB)||ip_LOAD) ;
endproperty
chk_ip_strobe_protect:
assert property(ip_strobe_protect) else `uvm_error("ASSERT ERROR","ip_STROBE is actived when wr/rd is disabled!");
cov_ip_strobe_protect:
cover property(ip_strobe_protect);

// property ip_doutq_rst ;
//     @(posedge xclk) (`WAIT_FLAG && ip_CSB) |-> (ip_Q==32'd0) ;
// endproperty
// chk_ip_doutq_rst:
// assert property(ip_doutq_rst) else `uvm_error("ASSERT ERROR","ip_Q rst status dont meet be zero when ip_CSB diable!");
// cov_ip_doutq_rst:
// cover property(ip_doutq_rst);

// property ip_rf_rst ;
//     @(posedge xclk) (`WAIT_FLAG && (ip_CSB||ip_RSB||ip_TRCS)) |-> (ip_RF==32'd0) ;
// endproperty
// chk_ip_rf_rst:
// assert property(ip_rf_rst) else `uvm_error("ASSERT ERROR","ip_RF rst status dont meet be zero when ip_CSB is diabled or ip_RSB/ip_TRCS is enabled!");
// cov_ip_rf_rst:
// cover property(ip_rf_rst);



`endif

`endif