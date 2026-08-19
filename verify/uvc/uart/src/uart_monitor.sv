class uart_monitor extends base_monitor;

  uvm_analysis_port #(uart_item) uart_monitor_main_ap;
  uvm_analysis_port #(uart_coverage_item) frame_collected_port;

  `uvm_component_utils(uart_monitor);

  uart_coverage_item req;
  uart_item uart_item_h;
  virtual uart_if uart_vif;

  extern task monitor_trans();
  extern task collect_coverage();
  extern function print_monitor_status();
  function new(string name="uart_monitor" , uvm_component parent=null);
    super.new(name , parent);
    uart_monitor_main_ap = new("uart_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = uart_coverage_item::type_id::create("req",this);
    uart_item_h = uart_item::type_id::create("uart_item_h",this);
    if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif" ,uart_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    print_monitor_status();
    fork
      monitor_trans();
      collect_coverage();
    join_none
  endtask


endclass : uart_monitor
  
  // Sample vif data , trans to scoreboard or other component
  task uart_monitor::monitor_trans();
    forever begin
      @(posedge uart_vif.clk);
      begin
        uart_item_h.card_sel = uart_vif.card_sel  ;
        uart_monitor_main_ap.write(uart_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task uart_monitor::collect_coverage();
    forever begin
      @(posedge uart_vif.clk);
      req.card_sel  = uart_vif.card_sel ;
      req.uart_ctrl  = uart_vif.uart_ctrl ;
      if(cov_enable)begin
		    frame_collected_port.write(req);  
	    end 
    end
  endtask

  // Print monitor status of cov_enable & checks_enable
  function uart_monitor::print_monitor_status();
		`uvm_info(get_type_name(), $sformatf("uart_monitor status as following:"), UVM_MEDIUM)
		if(checks_enable)begin
			`uvm_info(get_type_name(), $sformatf("uart_monitor check switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("uart_monitor check switch OFF"), UVM_MEDIUM)
		end
		if(cov_enable)begin
			`uvm_info(get_type_name(), $sformatf("uart_monitor collect coverages switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("uart_monitor collect coverages switch OFF"), UVM_MEDIUM)
		end
  endfunction

