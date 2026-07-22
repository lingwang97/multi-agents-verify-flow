`ifndef PL_SIM
    `define IO_DLY  0.1ns  //should larger than cki and ci delay.
`else
    `define IO_DLY  5ns  //should larger than cki and ci delay.
`endif

assign io_pif.clk = `BTC0.io_pad_n.xclk;

assign io_pif.pin_ci_n = `BTC0.io_pad_n.pin_ci;
assign io_pif.pad_ri_n = `BTC0.io_pad_n.pad_ri;
assign io_pif.pin_to_n = `BTC0.io_pad_n.pin_to;
assign io_pif.z_DataOut_n = `BTC0.io_pad_n.z_DataOut;
assign io_pif.pin_sel_n = `BTC0.io_pad_n.pin_sel;
assign io_pif.pin_dsel_n = `BTC0.io_pad_n.pin_dsel;
assign io_pif.pin_di_fback_n = `BTC0.io_pad_n.pin_di_fback;
assign io_pif.pin_di_n = `BTC0.io_pad_n.pin_di;
//assign io_pif.io_cfg_n = `BTC0.io_pad_n.io_cfg;
assign io_pif.SEL_n = `BTC0.io_pad_n.SEL;
assign io_pif.TO_n = `BTC0.io_pad_n.TO;
assign io_pif.CKI_CO_n = `BTC0.io_pad_n.CKI_CO;
assign #`IO_DLY io_pif.CKI_CO_n_dly = `BTC0.io_pad_n.CKI_CO;
assign io_pif.CI_CKO_n = `BTC0.io_pad_n.CI_CKO;
assign #`IO_DLY io_pif.CI_CKO_n_dly = `BTC0.io_pad_n.CI_CKO;
assign io_pif.RI_DO_n = `BTC0.io_pad_n.RI_DO;
assign io_pif.DI_RO_n = `BTC0.io_pad_n.DI_RO;
assign io_pif.FBDO_FBDI_n = `BTC0.io_pad_n.FBDO_FBDI;
assign io_pif.DSEL_n = `BTC0.io_pad_n.DSEL;
assign io_pif.CKI_CO_C_n = `BTC0.io_pad_n.CKI_CO_C;
assign io_pif.CI_CKO_C_n = `BTC0.io_pad_n.CI_CKO_C;
assign io_pif.DI_RO_C_n = `BTC0.io_pad_n.DI_RO_C;
assign io_pif.RI_DO_C_n = `BTC0.io_pad_n.RI_DO_C;
assign io_pif.FBDO_FBDI_C_n = `BTC0.io_pad_n.FBDO_FBDI_C;

assign io_pif.REG_fb_sel = `BTC0.sys_ctrl.comm_interface.REG_fb_sel;
assign io_pif.REG_cko_inv = `BTC0.sys_ctrl.comm_interface.REG_cko_inv_nen;
assign io_pif.REG_io_n_cfg = `BTC0.sys_ctrl.comm_interface.REG_io_n_cfg;
assign io_pif.REG_io_s_cfg = `BTC0.sys_ctrl.comm_interface.REG_io_s_cfg;

assign io_pif.xclk_s = `BTC0.io_pad_s.xclk;
assign io_pif.pin_ci_s = `BTC0.io_pad_s.pin_ci;
assign io_pif.pad_ri_s = `BTC0.io_pad_s.pad_ri;
assign io_pif.z_DataOut_s = `BTC0.io_pad_s.z_DataOut;
assign io_pif.pin_sel_s = `BTC0.io_pad_s.pin_sel;
assign io_pif.pin_dsel_s = `BTC0.io_pad_s.pin_dsel;
assign io_pif.pin_di_fback_s = `BTC0.io_pad_s.pin_di_fback;
assign io_pif.pin_di_s = `BTC0.io_pad_s.pin_di;
//assign io_pif.io_cfg_s = `BTC0.io_pad_s.io_cfg;
assign io_pif.CO_CKI_C_s = `BTC0.io_pad_s.CO_CKI_C;
assign io_pif.CKO_CI_C_s = `BTC0.io_pad_s.CKO_CI_C;
assign io_pif.RO_DI_C_s = `BTC0.io_pad_s.RO_DI_C;
assign io_pif.DO_RI_C_s = `BTC0.io_pad_s.DO_RI_C;
assign io_pif.FBDI_FBDO_C_s = `BTC0.io_pad_s.FBDI_FBDO_C;
assign io_pif.CKO_CI_s = `BTC0.io_pad_s.CKO_CI;
assign #`IO_DLY io_pif.CKO_CI_s_dly = `BTC0.io_pad_s.CKO_CI;
assign io_pif.CO_CKI_s = `BTC0.io_pad_s.CO_CKI;
assign #`IO_DLY io_pif.CO_CKI_s_dly = `BTC0.io_pad_s.CO_CKI;
assign io_pif.RO_DI_s = `BTC0.io_pad_s.RO_DI;
assign io_pif.DO_RI_s = `BTC0.io_pad_s.DO_RI;
assign io_pif.FBDI_FBDO_s = `BTC0.io_pad_s.FBDI_FBDO;

assign io_pif.from_io_n_pin_tpsel = `BTC0.sys_ctrl.from_io_n_pin_tpsel;

`ifndef FPGA_SYN
assign io_pif.cps_io_to = `BTC0.TO;
//assign io_pif.xclk_div = `BTC0.sys_ctrl.crg.cpm_div.clk_out;
`endif
assign io_pif.mx2_tx_testo = `BTC0.sys_ctrl.mx2_tx_testo;
assign io_pif.my_round_start = `BTC0.sys_ctrl.work_ctrl.my_round_start;
assign io_pif.z_NonceFlip = `BTC0.sys_ctrl.crg.z_NonceFlip;
assign io_pif.z_dbg_spdbusy = `BTC0.sys_ctrl.crg.z_dbg_spdbusy;
assign io_pif.z_dbg_w_req = `BTC0.sys_ctrl.crg.z_dbg_w_req;
assign io_pif.z_dbg_r_req = `BTC0.sys_ctrl.crg.z_dbg_r_req;
assign io_pif.raw_core_vld = `BTC0.sys_ctrl.crg.raw_core_vld;

assign io_pif.pin_tpsel = `BTC0.io_pad_n.pin_tpsel;
assign io_pif.DO_f_jlm = `BTC0.io_pad_n.DO_f_jlm;
assign io_pif.uart_do = `BTC0.sys_ctrl.comm_interface.uart_do;
assign io_pif.slice_gnt = `BTC0.sys_ctrl.mx2_bridge.slice_gnt;
assign io_pif.mx2_rx = `BTC0.sys_ctrl.mx2_rx;
assign io_pif.mx2_ry = `BTC0.sys_ctrl.mx2_ry;
assign io_pif.mx2_ru = `BTC0.sys_ctrl.mx2_ru;
assign io_pif.mx2_rv = `BTC0.sys_ctrl.mx2_rv;

assign io_pif.data_ready = `BTC0.sys_ctrl.rx_top_data_ready_muxo;
assign io_pif.header_pass = `BTC0.sys_ctrl.comm_interface.header_pass;
assign io_pif.header_fail = `BTC0.sys_ctrl.comm_interface.header_fail;
assign io_pif.chk_pass = `BTC0.sys_ctrl.comm_interface.chk_pass;
assign io_pif.chk_fail = `BTC0.sys_ctrl.comm_interface.chk_fail;
assign io_pif.vld_work = `BTC0.sys_ctrl.work_ctrl.gen_mid.vld_Work;
//assign io_pif.selfcal_itrp_update = `BTC0.sys_ctrl.work_ctrl.core2top.selfcal_itrp_update;
assign io_pif.uart_wr_cmd_valid = `BTC0.sys_ctrl.comm_interface.uart_top.uart_wr_cmd_valid;
assign io_pif.uart_rd_cmd_valid = `BTC0.sys_ctrl.comm_interface.uart_top.uart_rd_cmd_valid;
assign io_pif.uart_wr_rsp_valid = `BTC0.sys_ctrl.comm_interface.uart_top.uart_wr_rsp_valid;
assign io_pif.uart_rd_rsp_valid = `BTC0.sys_ctrl.comm_interface.uart_top.uart_rd_rsp_valid;



assign io_pif.to_cpm_uart_pll_baudclk = `BTC0.sys_ctrl.comm_interface.uart_top.uart_pll_baudclk;
assign io_pif.REG_FT_Ftdone = `BTC0.sys_ctrl.work_ctrl.ft.REG_FT_Ftdone;
assign io_pif.self_aging_wr_done = `BTC0.sys_ctrl.speed.self_inst.self_aging_inst.self_aging_wr_done;
//assign io_pif.burn_off_tmp = `BTC0.sys_ctrl.crg.to_cpm_efuse_burn_off_tmp;
//assign io_pif.to_cpm_efuse_cs = `BTC0.sys_ctrl.crg.to_cpm_efuse_cs;
assign io_pif.sort_done = `BTC0.sys_ctrl.crg.to_cpm_sort_done;
assign io_pif.current_reg_need_insert = `BTC0.sys_ctrl.crg.to_cpm_current_reg_need_insert;
 

assign io_pif.to_io_s_xclk = `BTC0.sys_ctrl.to_io_s_xclk;
assign io_pif.xclk = `BTC0.sys_ctrl.xclk;   
assign io_pif.sysctrl_xclk_delay = `BTC0.sys_ctrl.xclk;
assign io_pif.reg_cko_inv = `BTC0.sys_ctrl.comm_interface.REG_cko_inv_nen;
assign io_pif.real_cki = tb_top.real_cki;

`ifndef FPGA_SYN   
assign io_pif.pad_to_ie = `BTC0.io_pad_n.pad_TO.IE;
assign io_pif.pad_to_oen = `BTC0.io_pad_n.pad_TO.OE;
assign io_pif.pad_sel_ie = `BTC0.io_pad_n.pad_SEL.IE;
assign io_pif.pad_sel_oen = `BTC0.io_pad_n.pad_SEL.OE;
assign io_pif.pad_dsel_ie = `BTC0.io_pad_n.pad_DSEL.IE;
assign io_pif.pad_dsel_oen = `BTC0.io_pad_n.pad_DSEL.OE;
assign io_pif.pad_tpsel_ie = `BTC0.io_pad_n.pad_TPSEL.IE;
assign io_pif.pad_tpsel_oen = `BTC0.io_pad_n.pad_TPSEL.OE;
`else
assign io_pif.pad_to_ie = `BTC0.io_pad_n.pad_TO.IE;
assign io_pif.pad_to_oen = `BTC0.io_pad_n.pad_TO.OE;
assign io_pif.pad_sel_ie = `BTC0.io_pad_n.pad_SEL.IE;
assign io_pif.pad_sel_oen = `BTC0.io_pad_n.pad_SEL.OE;
assign io_pif.pad_dsel_ie = `BTC0.io_pad_n.pad_DSEL.IE;
assign io_pif.pad_dsel_oen = `BTC0.io_pad_n.pad_DSEL.OE;
`endif


generate for(genvar i = 0 ; i < `CHIP_NUM; i = i+1) begin
`ifdef FUNC_IO_FB_SEL
    assign io_pif.chips_io_fb_sel[i] = tb_top.C[i].btnode.btc.sys_ctrl.REG_fb_sel;
`else
    assign io_pif.chips_io_fb_sel[i] = 0;
`endif
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i = i+1) begin
    assign io_pif.TPSEL_n[i] = tb_top.C[i].btnode.btc.io_pad_n.TPSEL;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.cps_sysc_to_io_n_xclk_chips[i] = tb_top.C[i].btnode.btc.sys_ctrl.to_io_n_xclk;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.fb_btc[i] = tb_top.C[i].btnode.btc.sys_ctrl.REG_fb_sel;
end
endgenerate

//btc signals
generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.SEL[i] = tb_top.C[i].btnode.SEL;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.DSEL[i] = tb_top.C[i].btnode.DSEL;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.FBDI_FBDO[i] = tb_top.C[i].btnode.FBDI_FBDO;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.FBDO_FBDI[i] = tb_top.C[i].btnode.FBDO_FBDI;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.CKI_CO[i] = tb_top.C[i].btnode.CKI_CO;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.CKO_CI[i] = tb_top.C[i].btnode.CKO_CI;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.CI_CKO[i] = tb_top.C[i].btnode.CI_CKO;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.CO_CKI[i] = tb_top.C[i].btnode.CO_CKI;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.RI_DO[i] = tb_top.C[i].btnode.RI_DO;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.RO_DI[i] = tb_top.C[i].btnode.RO_DI;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.DI_RO[i] = tb_top.C[i].btnode.DI_RO;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign io_pif.DO_RI[i] = tb_top.C[i].btnode.DO_RI;
end
endgenerate


initial begin
  io_pif.io_assert_gate = 0;
  `ifndef FPGA_SYN
    #10ns;
  `else
    #125ns;
  `endif
  io_pif.io_assert_gate = 1;
end
