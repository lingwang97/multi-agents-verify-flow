
`ifndef GUARD_CUST_SVT_UART_MONITOR_READ_CALLBACK_SV
`define GUARD_CUST_SVT_UART_MONITOR_READ_CALLBACK_SV


class cust_svt_uart_monitor_read_callback extends svt_uart_monitor_callback;

  integer rx_port_cnt = 0;
  rand svt_uart_transaction     rx_xact;

  function new(string name);
    super.new(name);
    rx_xact = svt_uart_transaction::type_id::create("rx_xact");

  endfunction: new
  
  virtual function void pre_xact_observed_put(svt_uart_monitor monitor, svt_uart_transaction xact, ref bit drop);

      //if (xact.direction == svt_uart_transaction::RX) begin
      //  drop = 1;

      //  if (rx_port_cnt == 0) begin
      //    $cast(rx_xact, xact.clone());
      //    rx_xact.payload      = new[15];
      //    rx_xact.packet_count = 15;
      //  end

      //  `uvm_info("body", $sformatf("rx_port_cnt: %0d, packet_count: %0d",rx_port_cnt,rx_xact.packet_count), UVM_NONE)

      //  rx_xact.direction    = svt_uart_transaction::RX;
      //  rx_xact.payload[rx_port_cnt] = xact.payload[0];

      //  if ( rx_xact.payload[6][1:0] == 'b11 ) begin
      //    if  ((rx_xact.payload[10] == 'h1) &&
      //         (rx_xact.payload[11] == 'h0) &&
      //         (rx_xact.payload[12] == 'h0) &&
      //         (rx_xact.payload[13] == 'h0) &&
      //         (rx_xact.payload[14] == 'hd5)) begin
      //       drop = 1;
      //       rx_port_cnt = -1;
      //    end
      //  end else if ( rx_xact.payload[6][1:0] == 'b00 ) begin
      //    if (rx_port_cnt >= 10) begin
      //      drop = 0;
      //      xact = rx_xact;
      //      `uvm_info("body", $sformatf("callback: rx_xact_observed_port is \ %s",xact.sprint()), UVM_NONE)
      //       if (rx_port_cnt == 14) begin
      //         rx_port_cnt = -1;
      //       end
      //    end
      //  end

      //  rx_port_cnt = rx_port_cnt+1;

      //end

  endfunction: pre_xact_observed_put

endclass: cust_svt_uart_monitor_read_callback
`endif // GUARD_CUST_SVT_UART_MONITOR_READ_CALLBACK_SV


