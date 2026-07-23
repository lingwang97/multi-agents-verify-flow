`uvm_analysis_imp_decl(_main_uart_monitor)
class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard);
  
  virtual uart_if uart_vif;

  uart_item uart_item_h;

  uvm_analysis_imp_main_uart_monitor #(uart_item, uart_scoreboard) uart_scoreboard_main_ap;
  
  function new(string name="uart_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_scoreboard_main_ap = new("uart_scoreboard_main_ap",this);  
    uart_item_h = uart_item::type_id::create("uart_item_h",this);
    if (!uvm_config_db #(virtual interface uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("uart_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;

  endtask:main_phase

  virtual function void write_main_uart_monitor(uart_item req);
    `uvm_info(get_type_name(), $sformatf("Received uart_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass
