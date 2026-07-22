
//assign mc_pif.rst = tb_top.rst;
`define JLM 	tb_top.jlm
`define WB  	`JLM.jlm_wb

`ifdef USE_RAL_MODEL
`ifdef USE_JAMLINK_DRV
	initial begin
		/*
		force `JLM.JLM_STB_I  = jamlink_pif.jlm_stb_i;
		force `JLM.JLM_WE_I  = jamlink_pif.jlm_we_i;
		force `JLM.JLM_ADR_I  = jamlink_pif.jlm_adr_i;
		force `JLM.JLM_DAT_I  = jamlink_pif.jlm_dat_i;
		*/
		force tb_top.API_STB_I  = jamlink_pif.jlm_stb_i;
		force tb_top.API_WE_I  = jamlink_pif.jlm_we_i;
		force tb_top.API_ADR_I  = jamlink_pif.jlm_adr_i;
		force tb_top.API_DAT_I  = jamlink_pif.jlm_dat_i;
		

    //force tb_top.jlm_ci  = jamlink_pif.jlm_ci;
    //force tb_top.JLM_CO  = jamlink_pif.jlm_co;

	end
`endif
`endif
initial begin
	jamlink_pif.init_mode = 1'b0;
end

assign jamlink_pif.jlm_dat_o   = `JLM.JLM_DAT_O;
assign jamlink_pif.noncebufcnt = `BTC0.sys_ctrl.comm_interface.jls_top.jls_fsm.z_NonceBufCnt_ci;
//assign jamlink_pif.len_fifo    = `BTC0.sys_ctrl.comm_interface.len_fifo[8:0];
//alias jlm_wb signals
assign jamlink_pif.r_reg_setflush = `WB.r_REG_SetFlush;
assign jamlink_pif.r_reg_difrst = `WB.r_REG_DiFRst ;
assign jamlink_pif.r_reg_dofrst = `WB.r_REG_DoFRst ;
assign jamlink_pif.r_reg_setrst = `WB.r_REG_SetRst ;
assign jamlink_pif.reg_ecc0= `WB.REG_ECC0 ;
assign jamlink_pif.reg_ecc1 = `WB.REG_ECC1 ;
assign jamlink_pif.reg_ecc2 = `WB.REG_ECC2 ;
assign jamlink_pif.clk = `JLM.clk;

assign jamlink_pif.do_fifo_empty = `JLM.do_fifo.empty;
//assign jamlink_pif.xclk = `BTC0.sys_ctrl.comm_interface.xclk;