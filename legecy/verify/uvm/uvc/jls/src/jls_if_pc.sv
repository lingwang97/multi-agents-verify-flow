`define BUS_READ_CI bus_read_ci
`define RD_REG_XCLK rd_req_xclk
`define BUS_WRITE_CI bus_write_ci
`define WR_REQ_XCLK wr_req_xclk
`define MYADDR_VLD_CI myaddr_vld_ci
`define MYADDR_VLD_XCLK myaddr_vld_xclk
`define T_Z_ECC0 t_z_ecc0
`define T_ECC0 t_ecc0
`define T_Z_ECC1 t_z_ecc1
`define T_ECC1 t_ecc1
`define T_Z_ECC2 t_z_ecc2
`define T_ECC2 t_ecc2
`define APB_RDATA_READY apb_rdata_ready
`define APB_RDATA_VLD_CI apb_rdata_vld_ci
`define DELAY_XLCK ##[1:7]
`define DELAY_MID ##[1:50]

localparam JlS_FSM_IDLE = 3'b000;
localparam JlS_FSM_CMD	= 3'b001;
localparam JlS_FSM_ADDR = 3'b010;
localparam JlS_FSM_NOP  = 3'b011;
localparam JlS_FSM_INIT = 3'b100;
localparam JlS_FSM_WR   = 3'b101;
localparam JlS_FSM_LEN  = 3'b110;
localparam JlS_FSM_RD   = 3'b111;

localparam APB_BUS_IDLE = 2'b00;
localparam APB_BUS_WSETUP = 2'b01;
localparam APB_BUS_RSETUP = 2'b10;
localparam APB_BUS_ENABLE = 2'b11;

`ifdef  USE_JAMLINK_DRV
`ifndef  RANDOM_REG_CHECK
	//check1  cdc_pkg_mid_rd
	property CDC_PKG_MID_RD;
		@(posedge pin_ci) (wait_flag) |-> ($rose(bus_read_ci2mid) && ci_rst_f_n) |-> @(posedge clk) `DELAY_MID (rd_req_mid == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_MID_RD:
	assert property(CDC_PKG_MID_RD) else `uvm_error("[ASSERT ERR]","CDC_PKG_MID_RD not match!")
	cov_CDC_PKG_MID_RD:
	cover property(CDC_PKG_MID_RD);
	
	//check2  cdc_pkg_mid_wr
	property CDC_PKG_MID_WR;
		@(posedge pin_ci) (wait_flag) |-> ($rose(bus_write_ci2mid) && ci_rst_f_n) |-> @(posedge clk) `DELAY_MID (wr_req_mid == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_MID_WR:
	assert property(CDC_PKG_MID_WR) else `uvm_error("[ASSERT ERR]","CDC_PKG_MID_WR not match!")
	cov_CDC_PKG_MID_WR:
	cover property(CDC_PKG_MID_WR);
	
	//check3 cdc_pkg_xclk_rd
	property CDC_PKG_XCLK_RD;
		@(posedge pin_ci) (wait_flag) |-> ($rose(bus_read_ci2xclk) && ci_rst_f_n) |=> @(posedge xclk) `DELAY_XLCK (rd_req_xclk == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_XCLK_RD:
	assert property(CDC_PKG_XCLK_RD) else `uvm_error("[ASSERT ERR]","CDC_PKG_XCLK_RD not match!")
	cov_CDC_PKG_XCLK_RD:
	cover property(CDC_PKG_XCLK_RD);
	
	//check4  cdc_pkg_xclk_wr
	property CDC_PKG_XCLK_WR;
		@(posedge pin_ci) (wait_flag) |-> ($rose(bus_write_ci2xclk) && ci_rst_f_n) |-> @(posedge xclk) `DELAY_XLCK (wr_req_xclk == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_XCLK_WR:
	assert property(CDC_PKG_XCLK_WR) else `uvm_error("[ASSERT ERR]","CDC_PKG_XCLK_WR not match!")
	cov_CDC_PKG_XCLK_WR:
	cover property(CDC_PKG_XCLK_WR);
	
	//check5  CDC_MYADDR_VLD
	property CDC_MYADDR_VLD;
		@(posedge pin_ci) (wait_flag) |-> ($rose(myaddr_vld_ci) && ci_rst_f_n) |=> @(posedge xclk) `DELAY_XLCK ( myaddr_vld_xclk == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_MYADDR_VLD:
	assert property(CDC_MYADDR_VLD) else `uvm_error("[ASSERT ERR]","CDC_MYADDR_VLD not match!")
	cov_CDC_MYADDR_VLD:
	cover property(CDC_MYADDR_VLD);
	//check6 ECC0
	property CDC_PKG_ECC0;
		@(posedge pin_ci) (wait_flag) |-> ($rose(t_z_ecc0) && ci_rst_f_n) |=> @(posedge xclk) `DELAY_XLCK ( t_ecc0 == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_ECC0:
	assert property(CDC_PKG_ECC0) else `uvm_error("[ASSERT ERR]","CDC_PKG_ECC0 not match!")
	cov_CDC_PKG_ECC0:
	cover property(CDC_PKG_ECC0);
	//check7 ECC1
	property CDC_PKG_ECC1;
		@(posedge pin_ci) (wait_flag) |-> ($rose(t_z_ecc1) && ci_rst_f_n) |=> @(posedge xclk) `DELAY_XLCK ( t_ecc1 == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_ECC1:
	assert property(CDC_PKG_ECC1) else `uvm_error("[ASSERT ERR]","CDC_PKG_ECC1 not match!")
	cov_CDC_PKG_ECC1:
	cover property(CDC_PKG_ECC1);
	//check8 ECC2
	property CDC_PKG_ECC2;
		@(posedge pin_ci) (wait_flag) |-> ($rose(t_z_ecc2) && ci_rst_f_n) |=> @(posedge xclk) `DELAY_XLCK ( t_ecc2 == 1'b1);  //jira sm2-105
	endproperty
	chk_CDC_PKG_ECC2:
	assert property(CDC_PKG_ECC2) else `uvm_error("[ASSERT ERR]","CDC_PKG_ECC2 not match!")
	cov_CDC_PKG_ECC2:
	cover property(CDC_PKG_ECC2);
	//check9 
	 property CDC_APB_RDATA_VLD;
	 	@(negedge clk) (wait_flag && mid_rst_f_n && $rose(`APB_RDATA_READY)) |-> @(posedge pin_ci) ##[1:30] ( `APB_RDATA_VLD_CI == 1'b1);
	 endproperty
	 chk_CDC_APB_RDATA_VLD:
	 assert property(CDC_APB_RDATA_VLD) else `uvm_error("[ASSERT ERR]","CDC_APB_RDATA_VLD not match!")
	 cov_CDC_APB_RDATA_VLD:
	 cover property(CDC_APB_RDATA_VLD);


	//check10
	property CDC_XCLK_APB_RDATA_VLD;
		@(negedge xclk) (wait_flag && ri_rst_f_n && $rose(xclk_apb_rdata_ready)) |=> @(posedge pin_ci) ##[1:30] (( xclk_apb_rdata_ready_ci == 1'b1) | (!ci_rst_n));
	endproperty
	chk_CDC_XCLK_APB_RDATA_VLD:
	assert property(CDC_XCLK_APB_RDATA_VLD) else `uvm_error("[ASSERT ERR]","CDC_XCLK_APB_RDATA_VLD not match!")
	cov_CDC_XCLK_APB_RDATA_VLD:
	cover property(CDC_XCLK_APB_RDATA_VLD);

	//check11
	 property CDC_NB_CNT_VLD;
	 	@(negedge clk) (wait_flag && mid_rst_f_n && $rose(nb_cnt_vld)) |-> @(posedge pin_ci) ##[1:30] ( (nb_cnt_vld_ci == 1'b1) | (!ci_rst_n));
	 endproperty
	 chk_CDC_NB_CNT_VLD:
	 assert property(CDC_NB_CNT_VLD) else `uvm_error("[ASSERT ERR]","CDC_NB_CNT_VLD not match!")
	 cov_CDC_NB_CNT_VLD:
	 cover property(CDC_NB_CNT_VLD);


	 property JLS_FSM;
	 	@(posedge pin_ci_J)  (wait_flag) |-> (((cur_state==JlS_FSM_NOP) && (nxt_state==JlS_FSM_LEN) && mid_rst_f_n) |-> (len_ecc_en==1));
	 endproperty
	 chk_JLS_FSM:
	 assert property(JLS_FSM) else `uvm_error("[ASSERT ERR]","len_ecc_en not match!")
	 cov_JLS_FSM:
	 cover property(JLS_FSM);

	 property JLS_FSM1;
	 	@(posedge pin_ci_J) (wait_flag) |->
					(((cur_state==JlS_FSM_CMD) && (nxt_state==JlS_FSM_ADDR) && mid_rst_f_n) |=>  (t_pkg_start==1));
	 endproperty
	 chk_JLS_FSM1:
	 assert property(JLS_FSM1) else `uvm_error("[ASSERT ERR]","t_pkg_start not match!")
	 cov_JLS_FSM1:
	 cover property(JLS_FSM1);

	 property JLS_FSM2;
	 	@(posedge pin_ci_J) (wait_flag) |->
				(((cur_state==JlS_FSM_CMD || cur_state==JlS_FSM_ADDR || cur_state==JlS_FSM_NOP || cur_state==JlS_FSM_INIT || cur_state==JlS_FSM_WR) && mid_rst_f_n) |->  (cycle41_di_state==1));
	 endproperty
	 chk_JLS_FSM2:
	 assert property(JLS_FSM2) else `uvm_error("[ASSERT ERR]","cycle41_di_state not match!")
	 cov_JLS_FSM2:
	 cover property(JLS_FSM2);

	 property JLS_FSM4;
	 	@(posedge pin_ci_J) (wait_flag) |->
						(((cur_state==JlS_FSM_IDLE) && mid_rst_f_n) |=>  (ci_cnt==6'b0));
	 endproperty
	 chk_JLS_FSM4:
	 assert property(JLS_FSM4) else `uvm_error("[ASSERT ERR]","ci_cnt not match!")
	 cov_JLS_FSM4:
	 cover property(JLS_FSM4);


	 property JLS_MID_FSM;
	 	@(posedge clk_J) (wait_flag) |->
				(((apb_state_cur==APB_BUS_ENABLE || apb_state_cur==APB_BUS_WSETUP || apb_state_cur==APB_BUS_RSETUP) && rst_n_mid) |=>  (mid_fsm_psel==1));
	 endproperty
	 chk_JLS_MID_FSM:
	 assert property(JLS_MID_FSM) else `uvm_error("[ASSERT ERR]","JLS_MID_FSM not match!")
	 cov_JLS_MID_FSM:
	 cover property(JLS_MID_FSM);

	 property JLS_MID_FSM1;
	 	@(posedge clk_J) (wait_flag) |->
				(((apb_state_cur==APB_BUS_ENABLE) && rst_n_mid) |=>  (mid_fsm_penable==1));
	 endproperty
	 chk_JLS_MID_FSM1:
	 assert property(JLS_MID_FSM1) else `uvm_error("[ASSERT ERR]","JLS_MID_FSM1 not match!")
	 cov_JLS_MID_FSM1:
	 cover property(JLS_MID_FSM1);

	 property JLS_MID_FSM2;
	 	@(posedge clk_J) (wait_flag) |->
				(((apb_state_cur==APB_BUS_WSETUP) && rst_n_mid) |=>  (mid_fsm_pwrite==1));
	 endproperty
	 chk_JLS_MID_FSM2:
	 assert property(JLS_MID_FSM2) else `uvm_error("[ASSERT ERR]","JLS_MID_FSM2 not match!")
	 cov_JLS_MID_FSM2:
	 cover property(JLS_MID_FSM2);

	 property JLS_MID_FSM3;
	 	@(posedge clk_J) (wait_flag) |->
			(((apb_state_cur==APB_BUS_ENABLE) && rst_n_mid) |=>  (mid_fsm_rdata_ready==1));
	 endproperty
	 chk_JLS_MID_FSM3:
	 assert property(JLS_MID_FSM3) else `uvm_error("[ASSERT ERR]","JLS_MID_FSM3 not match!")
	 cov_JLS_MID_FSM3:
	 cover property(JLS_MID_FSM3);




	 property JLS_XCLK_FSM;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((xclk_apb_state_cur==APB_BUS_ENABLE || xclk_apb_state_cur==APB_BUS_WSETUP || xclk_apb_state_cur==APB_BUS_RSETUP) && rst_n_xclk) |=>  (x_fsm_psel==1));
	 endproperty
	 chk_JLS_XCLK_FSM:
	 assert property(JLS_XCLK_FSM) else `uvm_error("[ASSERT ERR]","JLS_XCLK_FSM not match!")
	 cov_JLS_XCLK_FSM:
	 cover property(JLS_XCLK_FSM);

	 property JLS_XCLK_FSM1;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((xclk_apb_state_cur==APB_BUS_ENABLE) && rst_n_xclk) |=>  (x_fsm_penable==1) );
	 endproperty
	 chk_JLS_XCLK_FSM1:
	 assert property(JLS_XCLK_FSM1) else `uvm_error("[ASSERT ERR]","JLS_XCLK_FSM1 not match!")
	 cov_JLS_XCLK_FSM1:
	 cover property(JLS_XCLK_FSM1);

	 property JLS_XCLK_FSM2;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((xclk_apb_state_cur==APB_BUS_WSETUP) && rst_n_xclk) |=>  (x_fsm_pwrite==1) );
	 endproperty
	 chk_JLS_XCLK_FSM2:
	 assert property(JLS_XCLK_FSM2) else `uvm_error("[ASSERT ERR]","JLS_XCLK_FSM2 not match!")
	 cov_JLS_XCLK_FSM2:
	 cover property(JLS_XCLK_FSM2);

	 property JLS_XCLK_FSM3;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((xclk_apb_state_cur==APB_BUS_ENABLE) && rst_n_xclk) |=>  (x_fsm_rdata_ready==1) );
	 endproperty
	 chk_JLS_XCLK_FSM3:
	 assert property(JLS_XCLK_FSM3) else `uvm_error("[ASSERT ERR]","JLS_XCLK_FSM3 not match!")
	 cov_JLS_XCLK_FSM3:
	 cover property(JLS_XCLK_FSM3);



	 property JLS_STD_FSM;
	 	@(posedge xclk_J) (wait_flag) |->
							( (((std_apb_state_cur==APB_BUS_ENABLE)|| std_apb_state_cur==APB_BUS_WSETUP || std_apb_state_cur==APB_BUS_RSETUP) && rst_n_xclk) |->  (std_fsm_psel==1));
	 endproperty
	 chk_JLS_STD_FSM:
	 assert property(JLS_STD_FSM) else `uvm_error("[ASSERT ERR]","JLS_STD_FSM not match!")
	 cov_JLS_STD_FSM:
	 cover property(JLS_STD_FSM);

	 property JLS_STD_FSM1;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((std_apb_state_cur==APB_BUS_ENABLE) && rst_n_xclk) |->  (std_fsm_penable==1) );
	 endproperty
	 chk_JLS_STD_FSM1:
	 assert property(JLS_STD_FSM1) else `uvm_error("[ASSERT ERR]","JLS_STD_FSM1 not match!")
	 cov_JLS_STD_FSM1:
	 cover property(JLS_STD_FSM1);

	 property JLS_STD_FSM2;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((std_apb_state_cur==APB_BUS_WSETUP)&&(std_apb_state_cur==APB_BUS_ENABLE) && rst_n_xclk) |->  (std_fsm_pwrite==1) );
	 endproperty
	 chk_JLS_STD_FSM2:
	 assert property(JLS_STD_FSM2) else `uvm_error("[ASSERT ERR]","JLS_STD_FSM2 not match!")
	 cov_JLS_STD_FSM2:
	 cover property(JLS_STD_FSM2);

	 property JLS_STD_FSM3;
	 	@(posedge xclk_J) (wait_flag) |->
							( ((std_apb_state_cur==APB_BUS_RSETUP)&&(std_apb_state_cur==APB_BUS_ENABLE) && rst_n_xclk) |->  (std_fsm_pwrite==0) );
	 endproperty
	 chk_JLS_STD_FSM3:
	 assert property(JLS_STD_FSM3) else `uvm_error("[ASSERT ERR]","JLS_STD_FSM3 not match!")
	 cov_JLS_STD_FSM3:
	 cover property(JLS_STD_FSM3);

	//  property JLS_STD_FSM4;
	//  	@(posedge xclk_J) (wait_flag) |->
	// 						( ((std_apb_state_cur==APB_BUS_ENABLE) && rst_n_xclk) |=>  (std_fsm_rdata_ready==1) );
	//  endproperty
	//  chk_JLS_STD_FSM4:
	//  assert property(JLS_STD_FSM4) else `uvm_error("[ASSERT ERR]","JLS_STD_FSM4 not match!")
	//  cov_JLS_STD_FSM4:
	//  cover property(JLS_STD_FSM4);

`endif
`endif




	 property XCLK_WRITEMODE_PRDATA_STABLE;
	 	@(posedge xclk_a) disable iff (!ri_rst_f_n)
			(wait_flag)&&(xclk_psel_a)&&($rose(xclk_penable_a))&&($rose(xclk_pwrite_a)) |-> ($stable(xclk_prdata));
	 endproperty

	 chk_XCLK_WRITEMODE_PRDATA_STABLE: 
   assert property(XCLK_WRITEMODE_PRDATA_STABLE) else `uvm_error("[ASSERT ERR]","XCLK_WRITEMODE_PRDATA_STABLE not match!");

	 cov_XCLK_WRITEMODE_PRDATA_STABLE:
	 cover property(XCLK_WRITEMODE_PRDATA_STABLE);

	 property MID_WRITEMODE_PRDATA_STABLE;
	 	@(posedge clk_a) disable iff (!mid_rst_f_n)
			(wait_flag)&&(psel_a)&&($rose(penable_a))&&($rose(pwrite_a)) |-> ($stable(prdata));
	 endproperty

	 chk_MID_WRITEMODE_PRDATA_STABLE: 
   assert property(MID_WRITEMODE_PRDATA_STABLE) else  `uvm_error("[ASSERT ERR]","MID_WRITEMODE_PRDATA_STABLE not match!");

	 cov_MID_WRITEMODE_PRDATA_STABLE:
	 cover property(MID_WRITEMODE_PRDATA_STABLE);


