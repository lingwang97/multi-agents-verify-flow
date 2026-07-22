
class uart_vip_monitor extends svt_uart_monitor;

  uvm_analysis_port #(svt_uart_transaction) rx_xact_ap;

  `uvm_component_utils(uart_vip_monitor);

  svt_uart_transaction rx_xact;
  logic [7:0] payload[0:19];
  integer payload_cnt = 0;

  svt_uart_vif   dte_vif;
  virtual top_if top_vif;
  
  extern task tran_adapter();
  extern task collect_data();

  function new(string name="uart_vip_monitor" , uvm_component parent=null);
    super.new(name , parent);
    rx_xact_ap = new("rx_xact_ap",this);
    rx_xact = svt_uart_transaction::type_id::create("rx_xact");
  endfunction
 
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (!uvm_config_db#(svt_uart_vif)::get(null, "uvm_test_top.top_env_h.uart_vip_env_h", "dte_vif", dte_vif))
     `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    tran_adapter();
  endtask

endclass



task uart_vip_monitor::collect_data();
  forever begin
    if(!dte_vif.rst) begin
      @(posedge dte_vif.rst);
    end
    @(negedge dte_vif.RX);
    repeat(4)@(posedge top_vif.xclk);

    for(int ii=0;ii<8;ii++) begin
        repeat(4)@(posedge top_vif.xclk);
        tmp = payload[payload_cnt];
        payload[payload_cnt] = {dte_vif.RX,tmp};
    end

    payload_cnt = payload_cnt+1;

    repeat(4)@(posedge top_vif.xclk);
  end
endtask:collect_data

task uart_vip_monitor::tran_adapter();
  string s;

  integer len = 0;

  forever begin
    if ((payload[0] == top_vif.HEADER[0*8+:8]) &&
        (payload[1] == top_vif.HEADER[1*8+:8]) &&
        (payload[2] == top_vif.HEADER[2*8+:8]) &&
        (payload[3] == top_vif.HEADER[3*8+:8]) &&
        (payload[4] == top_vif.HEADER[4*8+:8]) &&
        (payload[6][1:0] == 'h0))begin
      len = payload[8];
    end

    if (payload_cnt == (len*4+10)) begin
      for (int tmp=0;tmp<payload_cnt;tmp=tmp+1) begin
        rx_xact.packet_count = payload_cnt;
        rx_xact.payload      = new[payload_cnt];
        rx_xact.payload[tmp] = payload[tmp];
      end
      payload_cnt = 0;

      rx_xact_ap.write(rx_xact);
    end
  end
endtask

