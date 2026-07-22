
`ifndef GUARD_CUST_SVT_UART_AGENT_CONFIGURATION_SV
`define GUARD_CUST_SVT_UART_AGENT_CONFIGURATION_SV

/**
 * Abstract:
 * This file contains the class extended from svt_uart_agent_configuration class.
 * Here user can customize the configuration parameters as per test case requirement.
 */
class cust_svt_uart_agent_configuration extends svt_uart_agent_configuration;

  /** UVM object utility macro */
  `uvm_object_utils(cust_svt_uart_agent_configuration)

  /** Class constructor */
  function new(string name ="cust_svt_uart_agent_configuration" );
    super.new(name);

    this.is_active=1;
    this.enable_tx_rx_handshake   = 1'b1;
    this.enable_rts_cts_handshake = 1'b0;
    this.enable_dtr_dsr_handshake = 1'b0;
    this.handshake_type           = cust_svt_uart_agent_configuration::HARDWARE;
    this.enable_xml_gen           = 0;
    this.pa_format_type           = svt_xml_writer::format_type_enum'(2);
    this.stop_bit                 = svt_uart_agent_configuration::ONE_BIT;
    this.data_width               = svt_uart_agent_configuration::EIGHT_BIT;
    this.baud_divisor             = 1;
    this.handshake_type           = cust_svt_uart_agent_configuration::HARDWARE;
    this.parity_type              = cust_svt_uart_agent_configuration::NO_PARITY;
    this.receiver_buffer_size     = 4;

  endfunction: new
   
endclass: cust_svt_uart_agent_configuration
`endif //GUARD_CUST_SVT_UART_AGENT_CONFIGURATION_SV

