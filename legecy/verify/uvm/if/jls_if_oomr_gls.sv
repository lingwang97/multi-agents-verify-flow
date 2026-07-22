//assign mc_pif.rst = tb_top.rst;
//define the jls path macro 
//`define  JLS  `BTC0.sys_ctrl.comm_interface
`define COMM_INTERFACE `BTC0.sys_ctrl.comm_interface
`define JLS_TOP `BTC0.sys_ctrl.comm_interface.jls_top
//`define JLS_TOP `BTC0.sys_ctrl.comm_interface.jls_top
`ifdef USE_RAL_MODEL
	`ifndef USE_JAMLINK_DRV

		`ifndef USE_UART_DRV
			initial begin
				//mid
				force `COMM_INTERFACE.mid_apb_decoder.psel  		= jls_pif.psel;
				force `COMM_INTERFACE.mid_apb_decoder.penable  		= jls_pif.penable;
				force `COMM_INTERFACE.mid_apb_decoder.pwrite  		= jls_pif.pwrite;
				force `COMM_INTERFACE.jls_top.cdc_apb_rdata_vld.pulse_a  		= jls_pif.pready;
				//xclk
				force `COMM_INTERFACE.xclk_apb_decoder.psel  		= jls_pif.xclk_psel;
				force `COMM_INTERFACE.xclk_apb_decoder.penable  	= jls_pif.xclk_penable;
				force `COMM_INTERFACE.xclk_apb_decoder.pwrite  		= jls_pif.xclk_pwrite;
				force `COMM_INTERFACE.jls_top.cdc_xclk_apb_rdata_vld.pulse_a = jls_pif.xclk_pready;
	
				force `JLS_TOP.pkg_addr  		= jls_pif.paddr;
				force `JLS_TOP.pkg_wdat  		= jls_pif.pwdata;

				//std apb
				force `COMM_INTERFACE.std_apb_decoder.psel  		= jls_pif.std_psel;
				force `COMM_INTERFACE.std_apb_decoder.penable  		= jls_pif.std_penable;
				force `COMM_INTERFACE.std_apb_decoder.pwrite  		= jls_pif.std_pwrite;
				force `COMM_INTERFACE.std_apb_decoder.pwdata  		= jls_pif.std_pwdata;
				force `COMM_INTERFACE.std_apb_decoder.paddr  		= jls_pif.std_paddr;
				assign jls_pif.std_pready 							= `COMM_INTERFACE.std_apb_decoder.pready;
				force `COMM_INTERFACE.jls_top.cdc_std_apb_rdata_vld.pulse_a = jls_pif.std_pready;		

				// NOTE: Liping Tang
				// support jls drv when tp_sel==1, 
				force `COMM_INTERFACE.uart_top.mid_paddr		  = jls_pif.paddr;
				force `COMM_INTERFACE.uart_top.mid_pwdata	  = jls_pif.pwdata;
				
				force `COMM_INTERFACE.uart_top.apb_paddr		  = jls_pif.paddr;
				force `COMM_INTERFACE.uart_top.apb_pwdata	  = jls_pif.pwdata;
			end
		`endif
		
	`else
		//mid
		assign jls_pif.paddr = `COMM_INTERFACE.mid_apb_decoder.paddr;
		assign jls_pif.psel = `COMM_INTERFACE.mid_apb_decoder.psel;
		assign jls_pif.penable = `COMM_INTERFACE.mid_apb_decoder.penable;
		assign jls_pif.pwrite = `COMM_INTERFACE.mid_apb_decoder.pwrite;
		assign jls_pif.pwdata = `COMM_INTERFACE.mid_apb_decoder.pwdata;
		assign jls_pif.pready = `COMM_INTERFACE.mid_apb_decoder.pready;
		//xclk
		assign jls_pif.xclk_paddr = `COMM_INTERFACE.xclk_apb_decoder.paddr;
		assign jls_pif.xclk_psel = `COMM_INTERFACE.xclk_apb_decoder.psel;
		assign jls_pif.xclk_penable = `COMM_INTERFACE.xclk_apb_decoder.penable;
		assign jls_pif.xclk_pwrite = `COMM_INTERFACE.xclk_apb_decoder.pwrite;
		assign jls_pif.xclk_pwdata = `COMM_INTERFACE.xclk_apb_decoder.pwdata;
		assign jls_pif.xclk_pready = `COMM_INTERFACE.xclk_apb_decoder.pready;
		//std apb
		assign jls_pif.std_paddr = `COMM_INTERFACE.std_apb_decoder.paddr;
		assign jls_pif.std_psel = `COMM_INTERFACE.std_apb_decoder.psel;
		assign jls_pif.std_penable = `COMM_INTERFACE.std_apb_decoder.penable;
		assign jls_pif.std_pwrite = `COMM_INTERFACE.std_apb_decoder.pwrite;
		assign jls_pif.std_pwdata = `COMM_INTERFACE.std_apb_decoder.pwdata;
		assign jls_pif.std_pready = `COMM_INTERFACE.std_apb_decoder.pready;

	`endif

`endif	


	assign jls_pif.prdata = `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.prdata;
  	assign jls_pif.xclk_prdata = `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.prdata;
  	assign jls_pif.std_prdata = `BTC0.sys_ctrl.comm_interface.std_apb_decoder.prdata;

    
    assign jls_pif.tp_sel = `COMM_INTERFACE.tp_sel;
    assign jls_pif.ci_cnt = `JLS_TOP.jls_fsm.ci_cnt;//for coverage
    assign jls_pif.cycle41_di_state = `JLS_TOP.jls_fsm.cycle41_di_state;//for coverage
    assign jls_pif.len_ecc_en = `JLS_TOP.jls_fsm.len_ecc_en;//for coverage
    assign jls_pif.t_pkg_start = `JLS_TOP.jls_fsm.t_pkg_start;//for coverage

    
    assign jls_pif.mid_fsm_psel = `JLS_TOP.mid_apb_fsm.psel;
    assign jls_pif.mid_fsm_penable = `JLS_TOP.mid_apb_fsm.penable;
    assign jls_pif.mid_fsm_pwrite = `JLS_TOP.mid_apb_fsm.pwrite;
    assign jls_pif.mid_fsm_rdata_ready = `JLS_TOP.mid_apb_fsm.rdata_ready;

    assign jls_pif.x_fsm_psel = `JLS_TOP.xclk_apb_fsm.psel;
    assign jls_pif.x_fsm_penable = `JLS_TOP.xclk_apb_fsm.penable;
    assign jls_pif.x_fsm_pwrite = `JLS_TOP.xclk_apb_fsm.pwrite;
    assign jls_pif.x_fsm_rdata_ready = `JLS_TOP.xclk_apb_fsm.rdata_ready;

    assign jls_pif.std_fsm_psel = `JLS_TOP.std_apb_fsm.psel;
    assign jls_pif.std_fsm_penable = `JLS_TOP.std_apb_fsm.penable;
    assign jls_pif.std_fsm_pwrite = `JLS_TOP.std_apb_fsm.pwrite;
    assign jls_pif.std_fsm_rdata_ready = `JLS_TOP.std_apb_fsm.rdata_ready;



    assign jls_pif.len_fifo = `JLS_TOP.jls_fsm.len_fifo;



    assign jls_pif.ack_fail = `BTC0.sys_ctrl.comm_interface.jls_top.jls_fsm.ack_fail;
	assign jls_pif.chip_id = `BTC0.sys_ctrl.comm_interface.jls_top.REG_chip_id[9:0];





    
  //for assertion begin
    assign jls_pif.paddr_a = `COMM_INTERFACE.mid_apb_decoder.paddr;
    assign jls_pif.psel_a = `COMM_INTERFACE.mid_apb_decoder.psel;
    assign jls_pif.penable_a = `COMM_INTERFACE.mid_apb_decoder.penable;
    assign jls_pif.pwrite_a = `COMM_INTERFACE.mid_apb_decoder.pwrite;
    assign jls_pif.pwdata_a = `COMM_INTERFACE.mid_apb_decoder.pwdata;
    assign jls_pif.pready_a = `COMM_INTERFACE.mid_apb_decoder.pready;
    assign jls_pif.clk_a = `COMM_INTERFACE.mid_apb_decoder.clk;

    assign jls_pif.xclk_paddr_a = `COMM_INTERFACE.xclk_apb_decoder.paddr;
    assign jls_pif.xclk_psel_a = `COMM_INTERFACE.xclk_apb_decoder.psel;
    assign jls_pif.xclk_penable_a = `COMM_INTERFACE.xclk_apb_decoder.penable;
    assign jls_pif.xclk_pwrite_a = `COMM_INTERFACE.xclk_apb_decoder.pwrite;
    assign jls_pif.xclk_pwdata_a = `COMM_INTERFACE.xclk_apb_decoder.pwdata;
    assign jls_pif.xclk_pready_a = `COMM_INTERFACE.xclk_apb_decoder.pready;
    assign jls_pif.xclk_a = `COMM_INTERFACE.xclk_apb_decoder.clk;
  //for assertion end

    assign jls_pif.clk  = `COMM_INTERFACE.mid_clk ;
    assign jls_pif.xclk = `COMM_INTERFACE.xclk;
    assign jls_pif.pin_ci  = `COMM_INTERFACE.pin_ci ;


    assign jls_pif.clk_J = `JLS_TOP.mid_clk ;
    assign jls_pif.xclk_J = `JLS_TOP.xclk;
    assign jls_pif.pin_ci_J  = `JLS_TOP.pin_ci ;

    // assign jls_pif.uart_xclk = `COMM_INTERFACE.uart_xclk;
    // assign jls_pif.uart_mid_clk = `COMM_INTERFACE.uart_mid_clk;
    // assign jls_pif.uart_pll_clk  = `COMM_INTERFACE.uart_pll_clk;

    assign jls_pif.rst_n_mid = `JLS_TOP.mid_apb_fsm.rst_n;
    assign jls_pif.rst_n_xclk = `JLS_TOP.xclk_apb_fsm.rst_n;


    assign jls_pif.pin_di  = `JLS_TOP.pin_di ;
    assign jls_pif.pin_do  = `JLS_TOP.pin_do ;
    assign jls_pif.fb_do  = `COMM_INTERFACE.fb_do ;
    assign jls_pif.ri_rst_f_n  = `JLS_TOP.ri_rst_f_n; 
    assign jls_pif.ci_rst_f_n  = `JLS_TOP.ci_rst_f_n;
    assign jls_pif.mid_rst_f_n = `JLS_TOP.mid_rst_n; 
	
    assign jls_pif.z_NonceBufCnt = `JLS_TOP.z_NonceBufCnt ;

    assign jls_pif.work_paddr  = `COMM_INTERFACE.work_paddr ;
    assign jls_pif.work_psel  = `COMM_INTERFACE.work_psel ;
    assign jls_pif.work_penable  = `COMM_INTERFACE.work_penable ;
    assign jls_pif.work_pwrite  = `COMM_INTERFACE.work_pwrite ;
    assign jls_pif.work_pwdata  = `COMM_INTERFACE.work_pwdata ;
    assign jls_pif.work_pready  = `COMM_INTERFACE.work_pready ;
    assign jls_pif.work_prdata  = `COMM_INTERFACE.work_prdata ;

    assign jls_pif.speed_paddr  = `COMM_INTERFACE.speed_paddr ;
    assign jls_pif.speed_psel  = `COMM_INTERFACE.speed_psel ;
    assign jls_pif.speed_penable = `COMM_INTERFACE.speed_penable;
    assign jls_pif.speed_pwrite  = `COMM_INTERFACE.speed_pwrite ;
    assign jls_pif.speed_pwdata  = `COMM_INTERFACE.speed_pwdata ;
    assign jls_pif.speed_pready  = `COMM_INTERFACE.speed_pready ;
    assign jls_pif.speed_prdata  = `COMM_INTERFACE.speed_prdata ;

    assign jls_pif.rst_paddr  = `COMM_INTERFACE.crg_paddr ;
    assign jls_pif.rst_psel  = `COMM_INTERFACE.crg_psel ;
    assign jls_pif.rst_penable = `COMM_INTERFACE.crg_penable ;
    assign jls_pif.rst_pwrite  = `COMM_INTERFACE.crg_pwrite ;
    assign jls_pif.rst_pwdata  = `COMM_INTERFACE.crg_pwdata ;
  	assign jls_pif.rst_pready  = `COMM_INTERFACE.crg_pready ;
    assign jls_pif.rst_prdata  = `COMM_INTERFACE.crg_prdata ;

    assign jls_pif.cpm_paddr  = `COMM_INTERFACE.crg_paddr ;
    assign jls_pif.cpm_psel  = `COMM_INTERFACE.crg_psel ;
    assign jls_pif.cpm_penable  = `COMM_INTERFACE.crg_penable ;
    assign jls_pif.cpm_pwrite  = `COMM_INTERFACE.crg_pwrite ;
    assign jls_pif.cpm_pwdata  = `COMM_INTERFACE.crg_pwdata ;
    assign jls_pif.cpm_pready  = `COMM_INTERFACE.crg_pready ;
    assign jls_pif.cpm_prdata  = `COMM_INTERFACE.crg_prdata ;

    assign jls_pif.pvt_paddr  = `COMM_INTERFACE.pvt_paddr ;
    assign jls_pif.pvt_psel  = `COMM_INTERFACE.pvt_psel ;
    assign jls_pif.pvt_penable  = `COMM_INTERFACE.pvt_penable ;
    assign jls_pif.pvt_pwrite  = `COMM_INTERFACE.pvt_pwrite ;
    assign jls_pif.pvt_pwdata  = `COMM_INTERFACE.pvt_pwdata ;
    assign jls_pif.pvt_pready  = `COMM_INTERFACE.pvt_pready ;
    assign jls_pif.pvt_prdata  = `COMM_INTERFACE.pvt_prdata ;

    assign jls_pif.efuse_paddr  = `COMM_INTERFACE.efuse_paddr ;
    assign jls_pif.efuse_psel  = `COMM_INTERFACE.efuse_psel ;
    assign jls_pif.efuse_penable = `COMM_INTERFACE.efuse_penable;
    assign jls_pif.efuse_pwrite  = `COMM_INTERFACE.efuse_pwrite ;
    assign jls_pif.efuse_pwdata  = `COMM_INTERFACE.efuse_pwdata ;
    assign jls_pif.efuse_pready  = `COMM_INTERFACE.efuse_pready ;
    assign jls_pif.efuse_prdata  = `COMM_INTERFACE.efuse_prdata ;

    assign jls_pif.lvro_paddr  = `COMM_INTERFACE.lvro_paddr ;
    assign jls_pif.lvro_psel  = `COMM_INTERFACE.lvro_psel ;
    assign jls_pif.lvro_penable  = `COMM_INTERFACE.lvro_penable ;
    assign jls_pif.lvro_pwrite  = `COMM_INTERFACE.lvro_pwrite ;
    assign jls_pif.lvro_pwdata  = `COMM_INTERFACE.lvro_pwdata ;
    assign jls_pif.lvro_pready  = `COMM_INTERFACE.lvro_pready ;
    assign jls_pif.lvro_prdata  = `COMM_INTERFACE.lvro_prdata ;

    assign jls_pif.lvro_master_paddr  = `COMM_INTERFACE.lvro_master_paddr ;
    assign jls_pif.lvro_master_psel  = `COMM_INTERFACE.lvro_master_psel ;
    assign jls_pif.lvro_master_penable  = `COMM_INTERFACE.lvro_master_penable ;
    assign jls_pif.lvro_master_pwrite  = `COMM_INTERFACE.lvro_master_pwrite ;
    assign jls_pif.lvro_master_pwdata  = `COMM_INTERFACE.lvro_master_pwdata ;
    assign jls_pif.lvro_master_pready  = `COMM_INTERFACE.lvro_master_pready ;
    assign jls_pif.lvro_master_prdata  = `COMM_INTERFACE.lvro_master_prdata ;
    

    //assign jls_pif.pready_out  = `JLS_TOP.pready_out ;

    assign jls_pif.z_dbg_w_req  = `JLS_TOP.z_dbg_w_req ;
    assign jls_pif.z_dbg_r_req  = `JLS_TOP.z_dbg_r_req ;
	//fsm
	//assign jls_pif.cur_state = `JLS.cur_state;
	`HDLREF_reg_assign(jls_pif.cur_state , `JLS_TOP.jls_fsm.cur_state,2,0)
  `HDLREF_reg_assign(jls_pif.nxt_state , `JLS_TOP.jls_fsm.nxt_state,2,0)
	//pin_ci clk
	//assign jls_pif.pin_ci = `JLS.pin_ci;
	//correct_data
	assign jls_pif.correct_data = `JLS_TOP.Ecc_dec.dataout;

	// assign jls_pif.apb_state_cur = `JLS_TOP.mid_apb_fsm.apb_state_cur;
	// assign jls_pif.xclk_apb_state_cur = `JLS_TOP.xclk_apb_fsm.apb_state_cur;
	assign jls_pif.std_apb_state_cur = `JLS_TOP.std_apb_fsm.apb_state_cur;

	`HDLREF_reg_assign(jls_pif.apb_state_cur , `JLS_TOP.mid_apb_fsm.apb_state_cur,1,0);
	`HDLREF_reg_assign(jls_pif.xclk_apb_state_cur , `JLS_TOP.xclk_apb_fsm.apb_state_cur,1,0);


   /**************************************************************/
   /*															 */
   /*           this is for cdc check    						 */
   /**************************************************************/

   assign jls_pif.bus_read_ci2mid 		= `JLS_TOP.cdc_pkg_mid_rd.pulse_a;
   assign jls_pif.rd_req_mid 			= `JLS_TOP.cdc_pkg_mid_rd.pulse_b;
   //cdc_pkg_wr
   assign jls_pif.bus_write_ci2mid 		= `JLS_TOP.cdc_pkg_mid_wr.pulse_a;
   assign jls_pif.wr_req_mid 			= `JLS_TOP.cdc_pkg_mid_wr.pulse_b;
   //cdc_pkg_rd 
   assign jls_pif.bus_read_ci2xclk 		= `JLS_TOP.cdc_pkg_xclk_rd.pulse_a;
   assign jls_pif.rd_req_xclk 			= `JLS_TOP.cdc_pkg_xclk_rd.pulse_b;
   //cdc_pkg_wr
   assign jls_pif.bus_write_ci2xclk 		= `JLS_TOP.cdc_pkg_xclk_wr.pulse_a;
   assign jls_pif.wr_req_xclk 			= `JLS_TOP.cdc_pkg_xclk_wr.pulse_b;

   assign jls_pif.bus_read_ci2std 		= `JLS_TOP.cdc_pkg_std_rd.pulse_a;
   assign jls_pif.rd_req_std 			= `JLS_TOP.cdc_pkg_std_rd.pulse_b;
   //cdc_pkg_wr
   assign jls_pif.bus_write_ci2std 		= `JLS_TOP.cdc_pkg_std_wr.pulse_a;
   assign jls_pif.wr_req_std 			= `JLS_TOP.cdc_pkg_std_wr.pulse_b;

   //cdc_myaddr_vld
   assign jls_pif.myaddr_vld_ci = `JLS_TOP.cdc_myaddr_vld.pulse_a;
   assign jls_pif.myaddr_vld_xclk = `JLS_TOP.cdc_myaddr_vld.pulse_b;
    //cdc_pkg_ecc0
   assign jls_pif.t_z_ecc0 = `JLS_TOP.cdc_pkg_ecc0.pulse_a;
   assign jls_pif.t_ecc0 = `JLS_TOP.cdc_pkg_ecc0.pulse_b;
   //cdc_pkg_ecc1
   assign jls_pif.t_z_ecc1 = `JLS_TOP.cdc_pkg_ecc1.pulse_a;
   assign jls_pif.t_ecc1 = `JLS_TOP.cdc_pkg_ecc1.pulse_b;
   //cdc_pkg_ecc2
   assign jls_pif.t_z_ecc2 = `JLS_TOP.cdc_pkg_ecc2.pulse_a;
   assign jls_pif.t_ecc2 = `JLS_TOP.cdc_pkg_ecc2.pulse_b;
   //cdc_apb_rdata_vld
   assign jls_pif.apb_rdata_ready = `JLS_TOP.cdc_apb_rdata_vld.pulse_a;
   assign jls_pif.apb_rdata_vld_ci = `JLS_TOP.cdc_apb_rdata_vld.pulse_b;  
   //cdc_xclk_apb_rdata_vld
   assign jls_pif.xclk_apb_rdata_ready = `JLS_TOP.cdc_xclk_apb_rdata_vld.pulse_a;
   assign jls_pif.xclk_apb_rdata_ready_ci = `JLS_TOP.cdc_xclk_apb_rdata_vld.pulse_b;
   assign jls_pif.std_apb_rdata_ready = `JLS_TOP.cdc_std_apb_rdata_vld.pulse_a;
   assign jls_pif.std_apb_rdata_ready_ci = `JLS_TOP.cdc_std_apb_rdata_vld.pulse_b;
   //cdc_nb_cnt_vld
   assign jls_pif.nb_cnt_vld    = `JLS_TOP.cdc_nb_cnt_vld.pulse_a;
   assign jls_pif.nb_cnt_vld_ci = `JLS_TOP.cdc_nb_cnt_vld.pulse_b;
   assign jls_pif.ci_rst_n   = `BTC0.sys_ctrl.comm_interface.jls_top.ci_rst_n;
