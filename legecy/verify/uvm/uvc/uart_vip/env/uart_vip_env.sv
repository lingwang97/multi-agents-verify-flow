
`ifndef GUARD_UART_ENV_SV
`define GUARD_UART_ENV_SV 

//`include "uart_virtual_sequencer.sv"
`include "uart_vip_scoreboard.sv"
`include "uart_subscriber.sv"

`include "cust_reg_cbs.sv"
`include "uart_vip_frontdoor_sequence.sv"

//`include "svt_uart_reg_adapter.sv"

//`include "svt_uart_reg_adapter.sv"

/**
 * Abstract: 
 * class 'uart_vip_env' is extended from uvm_env base class.  It implements 
 * the build phase to construct the structural elements of this environment. 
 * 
 * uart_vip_env is the testbench environment, which constructs UART DTE 
 * and DCE agents in the build_phase method using the UVM factory service.  
 *
 * uart_intermediate env also constructs the virtual sequencer. This virtual sequencer 
 * in the testbench environment obtains a handle to the reset interface using 
 * the config db.  This allows reset sequences to be written for this virtual 
 * sequencer.
 *
 * uart_intermediate env also constructs the Scoreboard. This Scoreboard 
 * compares the transmiting and receiving transactions for DTE and DCE.  
 * 
 * uart_intermediate env also constructs the Subscriber. This Subscriber have few APIs 
 * which reads the received data back from the VIP and also received data can be comapred  
 * with the transmitted data. User can call these APIs from the top level test.
 *
 * In the connect_phase it connects DTE and DCE agent’s sequencer handle to 
 * virtual sequencer handle.
 *
 * In the connect_phase it also makes agent's monitor port and scoreboard analysis imp connections  
 */

class uart_vip_env extends uvm_env ;

      RAL_PKG::ral_gen_main 	ral;
      uvm_reg                   all_regs[$];   
      cust_reg_cbs 		my_reg_cbs;
 
      work_ctrl_pkg::work_ctrl_mine_work m_work;



  /** Declare customized agent configuration for dte_agent */
  cust_svt_uart_agent_configuration dte_cfg;
  
  /** Declare DTE agent */
  svt_uart_agent dte_agent;
  
  /** Declare SV Interface for DTE */
  svt_uart_vif dte_vif;
  
  /** Declare the handle of the Virtual Sequencer */
  svt_uart_transaction_sequencer vseqr_h;
  
  /** Declare the handle of the Scoreboard */
  uart_vip_scoreboard sb;
  
  /** Declare the handle of the Subscriber */
  uart_subscriber subcr;

  cust_uart_monitor cus_mon;

  svt_uart_configuration uart_cfg;


  // ----------------------------------------------------
  // user define ral model frontdoor sequence
  // ----------------------------------------------------
  uart_vip_frontdoor_sequence fd_seq;

  /** UVM object utility macro */
  `uvm_component_utils(uart_vip_env)
    
  /** Class constructor */
  function new( string  name = "uart_vip_env", uvm_component parent = null);
    super.new(name, parent);
    my_reg_cbs = new("my_reg_cbs");

    m_work=new();
  endfunction : new 
 
  /** Build Phase for the environment.  */
  virtual function void build_phase(uvm_phase phase) ;
    int build_ok = 1;
    
    super.build_phase(phase);

    `uvm_info("build_phase","uart_vip_env BUILD-FLOW:Starting...",UVM_LOW)
   
    /** Get the DTE configuration using config_db */
    if (!uvm_config_db#(cust_svt_uart_agent_configuration)::get(this,"","dte_cfg",this.dte_cfg) || (this.dte_cfg == null)) begin
      `uvm_fatal("build_phase", "'dte_cfg' is null. A cust_svt_uart_agent_configuration object must be set using the UVM configuration infrastructure.");
    end
    else begin
      `uvm_info("build_phase",$sformatf("***************uart_vip_env Agent Configuration For DTE**************\n%0s",
					this.dte_cfg.sprint()), UVM_LOW);
      /** Get the DTE BFM Port Interface to factory */
      if (uvm_config_db#(svt_uart_vif)::get(this, "", "dte_vif", dte_vif) && dte_vif != null) begin
        `uvm_info("build_phase","Applying the DTE virtual interface received through the config db to the configuration.",UVM_HIGH);
        dte_cfg.set_uart_if(dte_vif);
      end else begin 
        if (dte_cfg.uart_if == null) begin
          `uvm_fatal("build_phase","A DTE virtual interface was not received either through the config db, or through the configuration object for the master.");
          build_ok = 0;
        end
      end
    end

    if (!uvm_config_db#(work_ctrl_pkg::work_ctrl_mine_work)::get(this,"","m_work",this.m_work) )
      `uvm_fatal("build_phase", "'m_work' is null");
   
    if (build_ok) begin
      /** Apply the configuration to the agents */
      uvm_config_db#(svt_uart_agent_configuration)::set(this, "dte_agent", "cfg", dte_cfg);

      /** Apply the configuration to the Scoreboard */
      uvm_config_db#(svt_uart_configuration)::set(this, "sb", "cfg", dte_cfg);
      uvm_config_db#(work_ctrl_pkg::work_ctrl_mine_work)::set(this, "sb", "m_work", m_work);
      
      /** Apply the configuration to the Subscriber */
      uvm_config_db#(svt_uart_configuration)::set(this, "subcr", "cfg", dte_cfg);

      /** Construct the agents */
      dte_agent = svt_uart_agent::type_id::create("dte_agent",this);
      
      /** Create the testbench object for the scoreboard */
      sb = uart_vip_scoreboard::type_id::create("sb",this); 
    
      /** Create the testbench object for the subscriber */
      subcr = uart_subscriber::type_id::create("subcr",this); 


      cus_mon = cust_uart_monitor::type_id::create("cus_mon",this); 

      /** Construct the virtual sequencer */
      vseqr_h = svt_uart_transaction_sequencer::type_id::create("vseqr_h", this);

      if (!uvm_config_db#(svt_uart_configuration)::get(this, "", "uart_cfg", uart_cfg)) begin
        uart_cfg = svt_uart_configuration::type_id::create("uart_cfg");
        `uvm_info("uart_vip_env_build_phase", "uart_cfg is not set ...",UVM_LOW)
      end

      `uvm_info("uart_vip_env_build_phase", "uart_cfg is     set ...",UVM_LOW)
      uvm_config_db#(svt_uart_configuration)::set(this, "vseqr_h", "cfg", uart_cfg);

    if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(this, "" , "ral" ,ral))
      `uvm_fatal(get_full_name(), "Ral handle missing")

        fd_seq = uart_vip_frontdoor_sequence::type_id::create("fd_seq");

        ral.get_registers(all_regs);
        foreach (all_regs[i]) begin
            all_regs[i].set_frontdoor(fd_seq);
        end
    end // if (build_ok)
    `uvm_info("build_phase","uart_vip_env BUILD-FLOW:Finishing...",UVM_LOW)
  endfunction: build_phase
  
  /** 
   * Connect phase connects the DTE and DCE agent's sequencer handle to the virtual
   * sequencer's handle.It also does port connections between DTE & DCE agent's monitor 
   * and scoreboard
   */ 
  function void connect_phase(uvm_phase phase);
    `uvm_info("connect_phase","uart_vip_env CONNECT-FLOW:Starting...",UVM_LOW)
    super.connect_phase(phase);
    
    /** Connect the agent's sequencer handle to the virtual sequencer's handle */
    vseqr_h = dte_agent.sequencer ;

    /** Analysis port of DTE & DCE connections with Scoreboard imp */
    dte_agent.monitor.tx_xact_observed_port.connect(sb.item_collected_dte_tx);
    dte_agent.monitor.rx_xact_observed_port.connect(sb.item_collected_dte_rx);

    /** Analysis port of DTE or DCE RX connections with Subscriber imp */
    dte_agent.monitor.rx_xact_observed_port.connect(subcr.item_collected_recv);

    dte_agent.monitor.rx_xact_observed_port.connect(cus_mon.item_collected_dte_rx);
    dte_agent.monitor.tx_xact_observed_port.connect(cus_mon.item_collected_dte_tx);

    `uvm_info("connect_phase","uart_vip_env CONNECT-FLOW:Finishing...",UVM_LOW)
  endfunction: connect_phase
endclass: uart_vip_env

`endif //  `ifndef GUARD_UART_ENV_SV

