class uart_coverage extends uvm_subscriber #(uart_coverage_item);
 
  `uvm_component_utils(uart_coverage)
  
  uvm_analysis_imp #(uart_coverage_item, uart_coverage) mon2cov;

  virtual uart_if uart_vif;
  uart_coverage_item req_h;

  string report_id = "uart_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_uart_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.uart_ctrl {
      type_option.weight = 0;
      bins uart_ctrl[] = {[0:31]};
    }
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_uart_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint uart_vif.uart_ctrl {
      bins uart_ctrl[] = {[0:31]};
    }
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_uart_ctrl = new();
    cg_uart_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = uart_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif" ,uart_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(uart_coverage_item t);
    req_h = t;
    cg_uart_ctrl.sample();
    cg_uart_ctrl_by_if.sample();
  endfunction

endclass
