
class reg_monitor extends base_monitor;

  uvm_analysis_port #(reg_coverage_item) frame_collected_port;

  `uvm_component_utils(reg_monitor);

  reg_coverage_item req;

  uvm_analysis_port #(reg_item)  regmon_2_uartsbd_ap;

  virtual reg_if reg_vif;
  virtual uart_if uart_vif;

  RAL_PKG::ral_gen_main ral;



  function new(string name="reg_monitor" , uvm_component parent=null);
    super.new(name , parent);
    frame_collected_port = new("frame_collected_port",this);
    regmon_2_uartsbd_ap  = new("regmon_2_uartsbd_ap", this);
  endfunction

   function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    req = reg_coverage_item::type_id::create("req",this);
    if(!uvm_config_db#(virtual reg_if)::get(this , "" , "reg_vif" ,reg_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif" ,uart_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(this , "" , "ral" ,ral))
      `uvm_fatal(get_full_name(), "Ral handle missing")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //@(posedge reg_vif.mid_rst_n);
		wait( reg_vif.reg_rstpor_done.triggered);
    fork

      `ifdef USE_UART_DRV
        chk_uart_crg_reg();
      `endif
      mon_xclk_trans();
      mon_mid_trans();
      mon_std_trans();
      collect_coverage();
    join_none
  endtask

  // -----------------------------------------
  // External task defined here
  // -----------------------------------------
  extern task mon_xclk_trans();
  extern task mon_mid_trans();
  extern task mon_std_trans();
  extern task collect_coverage();
  extern task chk_uart_crg_reg();

endclass : reg_monitor



/*  ============================================================  */
/*  external method                                               */
/*  1, chk_uart_crg_reg: check uart reg asyc to pll domain        */
/*  ============================================================  */
task reg_monitor::chk_uart_crg_reg();
  forever begin
    int uart_crg_x [string];
    int uart_crg_p [string];

    `ifdef PL_SIM
      @(negedge reg_vif.reg_uart_cfg_update) ;
    `else
      @(posedge reg_vif.reg_uart_cfg_update) ;
    `endif
    `uvm_info(get_type_name(), $sformatf("Uart_crg_reg check started ... "), UVM_MEDIUM)
    repeat(2) @(posedge reg_vif.xclk) ;
      uart_crg_x["PLLDIV_MODE"         ] =   reg_vif.REG_UART_PLLDIV_MODE         ;
      uart_crg_x["PLLDIV_INT"          ] =   reg_vif.REG_UART_PLLDIV_INT          ;
      uart_crg_x["PLLDIV_FRC"          ] =   reg_vif.REG_UART_PLLDIV_FRC          ;
      uart_crg_x["HEADER_INDICATOR"    ] =   reg_vif.REG_UART_HEADER_INDICATOR    ;
      uart_crg_x["CHECK_MODE_SEL"      ] =   reg_vif.REG_UART_CHECK_MODE_SEL      ;
      uart_crg_x["FSM_TO_CNT_MAX_SHIFT"] =   reg_vif.REG_UART_FSM_TO_CNT_MAX_SHIFT;
      uart_crg_x["RX_TO_CNT_MAX_SHIFT" ] =   reg_vif.REG_UART_RX_TO_CNT_MAX_SHIFT ;
      uart_crg_x["NONCE_RETURN_EN"     ] =   reg_vif.REG_UART_NONCE_RETURN_EN     ;
      uart_crg_x["NONCE_CNT_MAX"       ] =   reg_vif.REG_UART_NONCE_CNT_MAX       ;
      uart_crg_x["TIMED_RETURN_EN"     ] =   reg_vif.REG_UART_TIMED_RETURN_EN     ;
      uart_crg_x["FC_DISABLE"          ] =   reg_vif.REG_UART_FC_DISABLE          ;
      uart_crg_x["PLL_MODE"            ] =   reg_vif.REG_UART_PLL_MODE            ;
      uart_crg_x["TIMED_RETURN_CNT_MAX"] =   reg_vif.REG_UART_TIMED_RETURN_CNT_MAX;
      uart_crg_x["PLL_DO_SHAPING_EN"   ] =   reg_vif.REG_UART_PLL_DO_SHAPING_EN   ;
      uart_crg_x["PLL_FB_SHAPING_EN"   ] =   reg_vif.REG_UART_PLL_FB_SHAPING_EN   ;
      uart_crg_x["PLL_DO_SHAPING_MODE" ] =   reg_vif.REG_UART_PLL_DO_SHAPING_MODE ;
      uart_crg_x["PLL_FB_SHAPING_MODE" ] =   reg_vif.REG_UART_PLL_FB_SHAPING_MODE ;

      uart_crg_x["RX_BUSY_CNT_MAX"     ] =   reg_vif.REG_UART_RX_BUSY_CNT_MAX     ;
      uart_crg_x["RDFSM_WAIT_CNT_MAX"  ] =   reg_vif.REG_UART_RDFSM_WAIT_CNT_MAX  ;
      //uart_crg_x["SOFTRST"             ] =   reg_vif.REG_UART_SOFTRST             ;


    #41;  //max random delay
    //repeat(5) @(posedge uart_vif.pll_clk) ;
    // valid_b is generated in pclk = pll_clk//div
    repeat(5) @(posedge uart_vif.pclk) ;
      uart_crg_p["PLLDIV_MODE"         ] =   reg_vif.REG_UART_PLLDIV_MODE_pll       ;
      uart_crg_p["PLLDIV_INT"          ] =   reg_vif.REG_UART_PLLDIV_INT_pll        ;
      uart_crg_p["PLLDIV_FRC"          ] =   reg_vif.REG_UART_PLLDIV_FRC_pll        ;
      uart_crg_p["HEADER_INDICATOR"    ] =   reg_vif.REG_UART_HEADER_INDICATOR_p    ;
      uart_crg_p["CHECK_MODE_SEL"      ] =   reg_vif.REG_UART_CHECK_MODE_SEL_p      ;
      uart_crg_p["FSM_TO_CNT_MAX_SHIFT"] =   reg_vif.REG_UART_FSM_TO_CNT_MAX_SHIFT_p;
      uart_crg_p["RX_TO_CNT_MAX_SHIFT" ] =   reg_vif.REG_UART_RX_TO_CNT_MAX_SHIFT_p ;
      uart_crg_p["NONCE_RETURN_EN"     ] =   reg_vif.REG_UART_NONCE_RETURN_EN_p     ;
      uart_crg_p["NONCE_CNT_MAX"       ] =   reg_vif.REG_UART_NONCE_CNT_MAX_p       ;
      uart_crg_p["TIMED_RETURN_EN"     ] =   reg_vif.REG_UART_TIMED_RETURN_EN_p     ;
      uart_crg_p["FC_DISABLE"          ] =   reg_vif.REG_UART_FC_DISABLE_p          ;
      uart_crg_p["PLL_MODE"            ] =   reg_vif.REG_UART_PLL_MODE_p            ;
      uart_crg_p["TIMED_RETURN_CNT_MAX"] =   reg_vif.REG_UART_TIMED_RETURN_CNT_MAX_p;
      uart_crg_p["PLL_DO_SHAPING_EN"   ] =   reg_vif.REG_UART_PLL_DO_SHAPING_EN_p   ;
      uart_crg_p["PLL_FB_SHAPING_EN"   ] =   reg_vif.REG_UART_PLL_FB_SHAPING_EN_p   ;
      uart_crg_p["PLL_DO_SHAPING_MODE" ] =   reg_vif.REG_UART_PLL_DO_SHAPING_MODE_p ;
      uart_crg_p["PLL_FB_SHAPING_MODE" ] =   reg_vif.REG_UART_PLL_FB_SHAPING_MODE_p ;

      uart_crg_p["RX_BUSY_CNT_MAX"     ] =   reg_vif.REG_UART_RX_BUSY_CNT_MAX_p     ;
      uart_crg_p["RDFSM_WAIT_CNT_MAX"  ] =   reg_vif.REG_UART_RDFSM_WAIT_CNT_MAX_p  ;
      //uart_crg_p["SOFTRST"             ] =   reg_vif.REG_UART_SOFTRST_p             ;


    foreach (uart_crg_x[i]) begin
        if(uart_crg_x[i] != uart_crg_p[i])
          `uvm_error(get_type_name(), $sformatf("[%s FAIL] xclk: 'h%0h != pll: 'h%0h", i, uart_crg_x[i], uart_crg_p[i]))
        else
          `uvm_info(get_type_name(), $sformatf("[%s SUCC] xclk: 'h%0h == pll: 'h%0h", i, uart_crg_x[i], uart_crg_p[i]), UVM_HIGH)
    end

    `uvm_info(get_type_name(), $sformatf("Uart_crg_reg check finished !"), UVM_MEDIUM)
  end
endtask:chk_uart_crg_reg



task reg_monitor::collect_coverage();
    begin
    forever
    begin
    @(posedge reg_vif.clk);
    req.card_sel  = reg_vif.card_sel  ;
    frame_collected_port.write(req);
    end
    end
endtask


// -----------------------------------------
// monitor apb bus cmd, addr, data
// trans reg_item by regmon_2_uartsbd_ap
// -----------------------------------------
task reg_monitor::mon_xclk_trans();
  reg_item reg_item_h;
  //reg_item_h = reg_item::type_id::create("reg_item_h",this);
  `uvm_info(get_type_name(), "mon_xclk_trans begin", UVM_MEDIUM)
  forever begin
	  @(negedge reg_vif.xclk);
		if((reg_vif.xclk_pready == 1'b1) && (reg_vif.xclk_psel == 1'b1) && (reg_vif.xclk_penable == 1'b0)) begin
      reg_item_h = reg_item::type_id::create("reg_item_h",this);
		  reg_item_h.addr = reg_vif.xclk_paddr;
		  reg_item_h.we	  = reg_vif.xclk_pwrite;

	    @(negedge reg_vif.xclk);
      if((reg_vif.xclk_pready == 1'b1)&& (reg_vif.xclk_penable == 1'b1) )begin
		    if((reg_item_h.we == 1'b1) ) reg_item_h.data 	= reg_vif.xclk_pwdata;
		    else 		  	reg_item_h.data 	= reg_vif.xclk_prdata;

        if(reg_item_h.addr >= 'h3000)begin
          regmon_2_uartsbd_ap.write(reg_item_h);
          `ifdef USE_UART_DRV
            `uvm_info(get_type_name(), $sformatf("mon_xclk_trans: \n%s", reg_item_h.sprint()), UVM_MEDIUM)
          `endif
          end
      end
    end
  end
endtask:mon_xclk_trans

task reg_monitor::mon_mid_trans();
  reg_item reg_item_h;
  //reg_item_h = reg_item::type_id::create("reg_item_h",this);

  `uvm_info(get_type_name(), "mon_mid_trans begin", UVM_MEDIUM)
  forever begin
	  @(negedge reg_vif.clk);	//mid_clk
		if((reg_vif.pready == 1'b1) && (reg_vif.psel == 1'b1) && (reg_vif.penable == 1'b0)) begin
      reg_item_h = reg_item::type_id::create("reg_item_h",this);

		  reg_item_h.addr = reg_vif.paddr;
		  reg_item_h.we	  = reg_vif.pwrite;

	    @(negedge reg_vif.clk);
      if((reg_vif.pready == 1'b1) && (reg_vif.penable == 1'b1)) begin
		    if((reg_item_h.we == 1'b1) ) reg_item_h.data 	= reg_vif.pwdata;
		    else 		  	reg_item_h.data 	= reg_vif.prdata;

        if(reg_item_h.addr < 'h3000 ) begin
          regmon_2_uartsbd_ap.write(reg_item_h);
          `ifdef USE_UART_DRV
            `uvm_info(get_type_name(), $sformatf("mon_mid_trans: \n%s", reg_item_h.sprint()), UVM_MEDIUM)
          `endif
        end
      end
    end
  end
endtask:mon_mid_trans

task reg_monitor::mon_std_trans();
  reg_item reg_item_h;
  logic    timeout;
  //reg_item_h = reg_item::type_id::create("reg_item_h",this);
  `uvm_info(get_type_name(), "mon_std_apb_trans begin", UVM_MEDIUM)
  forever begin
	  @(negedge reg_vif.xclk);
		if((reg_vif.std_psel == 1'b1) && (reg_vif.std_penable == 1'b0)) begin
      reg_item_h = reg_item::type_id::create("reg_item_h",this);
		  reg_item_h.addr = reg_vif.std_paddr;
		  reg_item_h.we	  = reg_vif.std_pwrite;

      if (reg_vif.std_pwrite) uart_vif.uart_std_apb_trans_wvalid = '0;
      else uart_vif.uart_std_apb_trans_rvalid = '0;
      timeout = '1;
	    @(posedge reg_vif.xclk);
        for (int i=0; i<8; i++) begin
            @(posedge reg_vif.xclk);
            if (reg_vif.std_pready & reg_vif.std_penable) begin
                if (reg_vif.std_pwrite) uart_vif.uart_std_apb_trans_wvalid = '1;
                else uart_vif.uart_std_apb_trans_rvalid = '1;
                timeout = '0;
                break;
            end
        end
        `uvm_info (get_type_name(), $sformatf("pready = %0b @ %0t ", reg_vif.std_pready, $time), UVM_MEDIUM)
        if (timeout)
            `uvm_info (get_type_name(), $sformatf("TIMEOUT for the current APB transaction @ %0t", $time), UVM_MEDIUM)

		if((reg_item_h.we == 1'b1) ) reg_item_h.data 	= reg_vif.std_pwdata;
		else 		  	reg_item_h.data 	= reg_vif.std_prdata;

        if(reg_item_h.addr inside {[`DOMAIN_STD_BASE : `DOMAIN_STD_END]})begin
          regmon_2_uartsbd_ap.write(reg_item_h);
          `ifdef USE_UART_DRV
            `uvm_info(get_type_name(), $sformatf("mon_std_trans: \n%s", reg_item_h.sprint()), UVM_MEDIUM)
          `endif
          end
    end
  end
endtask:mon_std_trans
