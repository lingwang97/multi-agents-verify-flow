`ifndef __TOP_ENV__SVH__
`define __TOP_ENV__SVH__

`ifdef VIP
  `include "svt_uart_agent_configuration.sv"
  `include "svt_uart_reg_adapter.sv"
`endif

class top_env extends uvm_env;

  string           report_id = "top_env";
  ro_env        ro_env_h;
  mx2_env          mx2_env_h;
  cpm_env          cpm_env_h;
  pvt_env          pvt_env_h;
  rst_env          rst_env_h;
  work_ctrl_env    work_ctrl_env_h;
  mc_env           mc_env_h;
  io_env           io_env_h;
  jls_env          jls_env_h;
  jamlink_env      jamlink_env_h;
`ifdef VIP
  uart_vip_env     uart_vip_env_h;
`endif

  uart_env         uart_env_h;

  efuse_env        efuse_env_h;
  cpft_env         cpft_env_h;
  dfx_env          dfx_env_h;
  spd_env          spd_env_h;
  ft_env           ft_env_h;
  reg_env           reg_env_h;
  selfclk_env       selfclk_env_h;

  top_virtual_sequencer vseqr_h;



    RAL_PKG::ral_gen_main        ral;
`ifndef VIP
    jls_pkg::reg2apb_adapter     reg_adapter;
    jls_pkg::reg2apb_adapter     reg_mon_adapter;
    jamlink_pkg::jamlink_adapter reg_jamlink_adapter;
    jamlink_pkg::jamlink_adapter reg_jamlink_mon_adapter;

    uart_pkg::uart_adapter reg_uart_adapter;
    uart_pkg::uart_adapter reg_uart_mon_adapter;
    `ifdef USE_JAMLINK_DRV
    uvm_reg_predictor#(jamlink_sequence_item) reg_predictor;
    `elsif USE_UART_DRV
    uvm_reg_predictor#(uart_sequence_item) reg_predictor;
    `else
    uvm_reg_predictor#(jls_sequence_item) reg_predictor;
    `endif
`else
    uart_vip_pkg::svt_uart_reg_adapter                     reg_uart_adapter;
    uart_vip_pkg::svt_uart_reg_adapter                     reg_uart_mon_adapter;
    uvm_reg_predictor#(cust_svt_uart_transaction)           reg_predictor;
`endif


  // Provide implementations of virtual methods such as get_type_name and create      
  `uvm_component_utils(top_env)
  
  // new constructor
  function new(string name = "top_env", uvm_component parent);
    super.new(name,parent);
  endfunction // new
  
  // build phase
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    ro_env_h=ro_env::type_id::create("ro_env_h", this);
    mx2_env_h=mx2_env::type_id::create("mx2_env_h", this);
    spd_env_h=spd_env::type_id::create("spd_env_h", this);
    ft_env_h=ft_env::type_id::create("ft_env_h", this);
    cpm_env_h=cpm_env::type_id::create("cpm_env_h", this);
    pvt_env_h=pvt_env::type_id::create("pvt_env_h", this);
    rst_env_h=rst_env::type_id::create("rst_env_h", this);
    work_ctrl_env_h=work_ctrl_env::type_id::create("work_ctrl_env_h", this);
    mc_env_h=mc_env::type_id::create("mc_env_h", this);
    io_env_h=io_env::type_id::create("io_env_h", this);
    dfx_env_h=dfx_env::type_id::create("dfx_env_h", this);
    jls_env_h=jls_env::type_id::create("jls_env_h", this);
    jamlink_env_h=jamlink_env::type_id::create("jamlink_env_h", this);
    //**********************************************************************
    `ifdef VIP
    uart_vip_env_h=uart_vip_env::type_id::create("uart_vip_env_h", this);
    `endif

    uart_env_h=uart_env::type_id::create("uart_env_h", this);
    //**********************************************************************
    efuse_env_h=efuse_env::type_id::create("efuse_env_h", this);
    cpft_env_h=cpft_env::type_id::create("cpft_env_h", this);
    reg_env_h=reg_env::type_id::create("reg_env_h", this);
    selfclk_env_h=selfclk_env::type_id::create("selfclk_env_h", this);

    `ifdef UVM_ERR_QUIT_COUNT
      //deprecated function: set_report_max_quit_count(`UVM_ERR_QUIT_COUNT);
      uvm_report_server::get_server().set_max_quit_count(`UVM_ERR_QUIT_COUNT);
    `endif
    
  // ---------------------------------------------
	// RAL MODEL: for different driver 
	// 1, create adpater, reg2bus & bus2reg
  // 2, create predictor
  // 3. create ral model 
  // 4, ral model: configure -> build -> set_coverage -> lock_model -> reset -> set root backdoor path
`ifndef VIP
    reg_adapter = jls_pkg::reg2apb_adapter::type_id::create("reg_adapter", this);
    reg_mon_adapter = jls_pkg::reg2apb_adapter::type_id::create("reg_mon_adapter", this);
    reg_jamlink_adapter = jamlink_pkg::jamlink_adapter::type_id::create("reg_jamlink_adapter", this);
    reg_jamlink_mon_adapter = jamlink_pkg::jamlink_adapter::type_id::create("reg_jamlink_mon_adapter", this);
    reg_uart_adapter = uart_pkg::uart_adapter::type_id::create("reg_uart_adapter", this);
    reg_uart_mon_adapter = uart_pkg::uart_adapter::type_id::create("reg_uart_mon_adapter", this);

    `ifdef USE_JAMLINK_DRV
      reg_predictor  = uvm_reg_predictor #(jamlink_sequence_item)::type_id::create("reg_predictor", this);
    `elsif USE_UART_DRV
      reg_predictor  = uvm_reg_predictor #(uart_sequence_item)::type_id::create("reg_predictor", this);
    `else
      reg_predictor  = uvm_reg_predictor #(jls_sequence_item)::type_id::create("reg_predictor", this);
    `endif

`else //uart VIP adapter
    reg_uart_adapter     = uart_vip_pkg::svt_uart_reg_adapter::type_id::create("reg_uart_adapter", this);
    reg_predictor        = uvm_reg_predictor#(cust_svt_uart_transaction)::type_id::create("reg_predictor", this);
`endif


    ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);
    ral.configure(null, "");
    ral.build();
    ral.set_coverage(UVM_CVR_ALL);	
    ral.lock_model();
    ral.reset();
    ral.set_hdl_path_root("tb_top.C[0].btnode.btc");


    // build the virtual sequencer
    vseqr_h = top_virtual_sequencer::type_id::create("vseqr_h", this); 


    uvm_config_db#(RAL_PKG::ral_gen_main)::set(this, "*", "ral", ral);
    uvm_config_db#(RAL_PKG::ral_gen_main)::set(this, "", "ral", ral);

  endfunction

  // connect virtual sequencer to subsequencers
  virtual function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);

    vseqr_h.ro_seqr_h = ro_env_h.vseqr_h;
    vseqr_h.mx2_seqr_h = mx2_env_h.vseqr_h;
    vseqr_h.ft_seqr_h = ft_env_h.vseqr_h;
    vseqr_h.spd_seqr_h = spd_env_h.vseqr_h;
    vseqr_h.cpm_seqr_h = cpm_env_h.vseqr_h;
    vseqr_h.pvt_seqr_h = pvt_env_h.vseqr_h;
    vseqr_h.rst_seqr_h = rst_env_h.rst_agent_h.m_sequencer;
    vseqr_h.work_ctrl_seqr_h = work_ctrl_env_h.vseqr_h;
    vseqr_h.mc_seqr_h = mc_env_h.vseqr_h;
    vseqr_h.jls_seqr_h = jls_env_h.vseqr_h;
    vseqr_h.jamlink_seqr_h = jamlink_env_h.vseqr_h;
    vseqr_h.dfx_seqr_h = dfx_env_h.vseqr_h;
    vseqr_h.efuse_seqr_h = efuse_env_h.vseqr_h;
    vseqr_h.io_seqr_h = io_env_h.vseqr_h;
    vseqr_h.cpft_seqr_h = cpft_env_h.vseqr_h;
    vseqr_h.reg_seqr_h = reg_env_h.vseqr_h;
    vseqr_h.selfclk_seqr_h = selfclk_env_h.vseqr_h;

    jamlink_env_h.jamlink_agent_h.m_driver.rsp_port.connect(jls_env_h.jls_agent_h.m_scoreboard.jam2jls);//*
    
    reg_env_h.reg_agent_h.m_monitor.regmon_2_uartsbd_ap.connect(uart_env_h.uart_agent_h.m_scoreboard.regmon_2_uartsbd_imp);
	
    `ifdef VIP
    vseqr_h.uart_vip_seqr_h = uart_vip_env_h.vseqr_h;
    `endif

    vseqr_h.uart_seqr_h = uart_env_h.vseqr_h;
	  vseqr_h.ral = this.ral;

  // ---------------------------------------------
	// RAL MODEL: for different driver 
  // 1, map.set_sequencer 
  // 2, connect adapter to predictor
  // 3, connect bus_in port of predictor to adapter_ap
  // 4, set predictoon mothod (implicit or explicit)
  // 5, connect ral.map to predictor
  // ---------------------------------------------
`ifndef VIP
	`ifdef USE_JAMLINK_DRV
      ral.default_map.set_sequencer(jamlink_env_h.jamlink_agent_h.m_sequencer, reg_jamlink_adapter);
	    reg_predictor.adapter = reg_jamlink_mon_adapter;
	   // if(`CHIP_NUM == 1)begin jamlink_env_h.jamlink_agent_h.adapter_ap.connect(reg_predictor.bus_in); end

	`elsif USE_UART_DRV
      ral.default_map.set_sequencer(uart_env_h.uart_agent_h.m_sequencer, reg_uart_adapter);
	    reg_predictor.adapter = reg_uart_mon_adapter;
	    //jamlink_env_h.jamlink_agent_h.adapter_ap.connect(reg_predictor.bus_in);
	`else
      ral.default_map.set_sequencer(jls_env_h.jls_agent_h.m_sequencer, reg_adapter);
	    reg_predictor.map = ral.default_map;
	    reg_predictor.adapter = reg_mon_adapter;
      // WARNING: Explicit prediction and implicit prediction cannot be turned on at the same time
      
      //jls_env_h.jls_agent_h.adapter_ap.connect(reg_predictor.bus_in);      
      	    
	`endif
	  ral.default_map.set_auto_predict(1);

`else //uart VIP
        //uart_env_h.dte_agent.monitor.rx_xact_observed_port.connect(reg_predictor.bus_in);
        uart_vip_env_h.cus_mon.rx_xact_ap.connect(reg_predictor.bus_in);
        ral.default_map.set_sequencer(uart_vip_env_h.dte_agent.sequencer, reg_uart_adapter);
        ral.default_map.set_auto_predict(0);
        ral.default_map.print();
        reg_predictor.adapter = reg_uart_adapter;
`endif
	reg_predictor.map = ral.default_map;


  endfunction 

  // print topology information
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    //`uvm_info(get_type_name(), $sformatf("Printing environment settings: \n %0s", this.sprint()), UVM_LOW)

    //It is prinited in base test , so we disable here.
  endfunction 
  
endclass

`endif // __TOP_ENV__SVH__