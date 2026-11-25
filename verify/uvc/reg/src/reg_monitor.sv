class reg_monitor extends base_monitor;

  uvm_analysis_port #(reg_item) reg_monitor_main_ap;
  uvm_analysis_port #(reg_coverage_item) frame_collected_port;

  `uvm_component_utils(reg_monitor);

  reg_coverage_item req;
  reg_item reg_item_h;
  virtual reg_if reg_vif;

  extern task monitor_trans();
  extern task collect_coverage();
`ifdef OPEN_EDA
  extern function void print_monitor_status();   // oEDA: explicit return type
`else
  extern function print_monitor_status();
`endif
  function new(string name="reg_monitor" , uvm_component parent=null);
    super.new(name , parent);
    reg_monitor_main_ap = new("reg_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = reg_coverage_item::type_id::create("req",this);
    reg_item_h = reg_item::type_id::create("reg_item_h",this);
    if(!uvm_config_db#(virtual reg_if)::get(this , "" , "reg_vif" ,reg_vif))
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


endclass : reg_monitor
  
  // Sample vif data , trans to scoreboard or other component
  task reg_monitor::monitor_trans();
    forever begin
      @(posedge reg_vif.clk);
      begin
        reg_item_h.card_sel = reg_vif.card_sel  ;
        reg_monitor_main_ap.write(reg_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task reg_monitor::collect_coverage();
    forever begin
      @(posedge reg_vif.clk);
      req.card_sel  = reg_vif.card_sel ;
      req.reg_ctrl  = reg_vif.reg_ctrl ;
      if(cov_enable)begin
		    frame_collected_port.write(req);  
	    end 
    end
  endtask

  // Print monitor status of cov_enable & checks_enable
`ifdef OPEN_EDA
  function void reg_monitor::print_monitor_status();
`else
  function reg_monitor::print_monitor_status();
`endif
		`uvm_info(get_type_name(), $sformatf("reg_monitor status as following:"), UVM_MEDIUM)
		if(checks_enable)begin
			`uvm_info(get_type_name(), $sformatf("reg_monitor check switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("reg_monitor check switch OFF"), UVM_MEDIUM)
		end
		if(cov_enable)begin
			`uvm_info(get_type_name(), $sformatf("reg_monitor collect coverages switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("reg_monitor collect coverages switch OFF"), UVM_MEDIUM)
		end
  endfunction

