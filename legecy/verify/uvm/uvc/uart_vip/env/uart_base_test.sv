
`ifndef GUARD_UART_BASE_TEST_SV
`define GUARD_UART_BASE_TEST_SV
`define SVT_UART_INTERMEDIATE_TEST_TIMEOUT 6000000

`include "cust_svt_uart_transaction.sv"
`include "cust_svt_uart_agent_configuration.sv"
//`include "uart_intermediate_env.sv"
//`include "uart_random_sequence.sv"
//`include "uart_random_virtual_sequence.sv"
//`include "uart_simple_reset_sequence.sv"

/**
 * Abstract:
 * This file creates a base test, which serves as the base class for the rest
 * of the tests in this environment.  This test sets up the default behavior
 * for the rest of the tests in this environment.
 *
 * In the build_phase phase of the test we will set the necessary test related 
 * information:
 * - Create the uart_intermediate_env instance (named env)
 * - Create a default configuration and set it to the uart_intermediate_env 
 *   instance using the configuration DB
 * - Configure the uart_random_virtual_sequence as the default
 *   sequence for the main phase of the UART ENV virtual sequencer
 * - Configure the sequence length to 10
 * - Configure the uart_simple_reset_sequence as the default sequence
 *   for the reset phase of the TB ENV virtual sequencer
 * - Set the Pass/Fail criterion in the final_phase() using report_server
 * .
 */
class uart_base_test extends uvm_test;

  /** Instance of the environment */
  uart_intermediate_env env;
  
  /** Configuration Instance for DTE agent */
  cust_svt_uart_agent_configuration dte_cfg;

  /** Configuration Instance for DCE agent */
  //cust_svt_uart_agent_configuration dce_cfg;

  /** UVM component utility macro */
  `uvm_component_utils(uart_base_test)

  /** Class constructor */
  function new(string name ="uart_base_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  /**
   * Build Phase
   * - Create and apply the customized configuration transaction factory
   * - Create the TB ENV
   * - Set the default sequences
   * .
   */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase","uart_base_test BUILD-FLOW:Starting...",UVM_LOW)
    super.build_phase(phase);
 
    /** Replace blueprint of svt_uart_transaction with cust_svt_uart_transaction using factories in UVM */
    //set_type_override_by_type(svt_uart_transaction::get_type(),cust_svt_uart_transaction::get_type());
    /** Create the configuration object for DTE agent */
    dte_cfg = cust_svt_uart_agent_configuration::type_id::create("dte_cfg");
 
    /** Create the configuration object for DCE agent */
    //dce_cfg = cust_svt_uart_agent_configuration::type_id::create("dce_cfg");
 
    /** Set the configuration values for DTE agent */
    dte_cfg.is_active = 1;

    /** Set the configuration values for DCE agent */
    //dce_cfg.is_active = 1;
 
    /** Set DTE configuration in environment */
    uvm_config_db#(cust_svt_uart_agent_configuration)::set(this,"env","dte_cfg",dte_cfg);
 
    /** Set DCE configuration in environment */
    //uvm_config_db#(cust_svt_uart_agent_configuration)::set(this,"env","dce_cfg",dce_cfg);
    
    /** Apply the random virtual sequence to the Uart ENV virtual sequencer */
    //uvm_config_db#(uvm_object_wrapper)::set(this, "env.sequencer.main_phase", "default_sequence",uart_random_virtual_sequence::type_id::get());
                                            
    /** Set the sequence 'length' to generate 10 transaction with constraints */
    //uvm_config_db#(int unsigned)::set(this, "env.sequencer.uart_random_virtual_sequence",  "sequence_length", 10);
    
    /** Apply the default reset sequence */
    //uvm_config_db#(uvm_object_wrapper)::set(this, "env.sequencer.reset_phase", "default_sequence", uart_simple_reset_sequence::type_id::get());
     
    /** Create the environment */
    env = uart_intermediate_env::type_id::create("env", this);

    `uvm_info("build_phase","uart_base_test BUILD-FLOW:Finishing...",UVM_LOW)
  endfunction: build_phase
  
  /** 
   * Set the value of drain time to ensure that all the  
   * transmitted packets are successfully received at the Receiver.
   * The timeunit must be ensured to be in units of 
   * nanoseconds(ns).
   */
  task main_phase(uvm_phase phase);
    uvm_objection phase_over;

    `uvm_info("main_phase","uart_base_test MAIN-FLOW:Starting...",UVM_LOW)
    phase.raise_objection(this);
    phase.drop_objection(this);
    `uvm_info("main_phase",$sformatf("Setting the drain time in the main_phase of the base test to %d",`SVT_UART_INTERMEDIATE_TEST_TIMEOUT),UVM_NONE) 
    phase_over = phase.get_objection();
    phase_over.set_drain_time(this, (6000000));
    `uvm_info("main_phase","uart_base_test MAIN-FLOW:Finishing...",UVM_LOW)
  endtask: main_phase 
 
  /**
   * Calculate the pass or fail status for the test in the final phase method of the
   * test. If a UVM_FATAL, UVM_ERROR, or a UVM_WARNING message has been generated the
   * test will fail.
   */
  function void final_phase(uvm_phase phase);
    uvm_report_server svr;
    `uvm_info("final_phase","uart_base_test FINAL-FLOW:Starting...",UVM_LOW)
 
    super.final_phase(phase);
 
    svr = uvm_report_server::get_server();
 
    if (svr.get_severity_count(UVM_FATAL) + 
      svr.get_severity_count(UVM_ERROR) + 
      svr.get_severity_count(UVM_WARNING) > 0)
      `uvm_info("final_phase","\nSvtTestEpilog: Failed\n",UVM_LOW)
    else
      `uvm_info("final_phase","\nSvtTestEpilog: Passed\n",UVM_LOW)

    `uvm_info("final_phase","uart_base_test FINAL-FLOW:Finishing...",UVM_LOW)
  endfunction: final_phase

endclass: uart_base_test

`endif //  `ifndef GUARD_UART_BASE_TEST_SV

