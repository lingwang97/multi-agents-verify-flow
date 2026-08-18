class jls_monitor extends base_monitor;

  uvm_analysis_port #(jls_item) jls_monitor_main_ap;
  uvm_analysis_port #(jls_coverage_item) frame_collected_port;

  `uvm_component_utils(jls_monitor);

  jls_coverage_item req;
  jls_item jls_item_h;
  virtual jls_if jls_vif;

  extern task monitor_trans();
  extern task collect_coverage();
  extern function print_monitor_status();
  function new(string name="jls_monitor" , uvm_component parent=null);
    super.new(name , parent);
    jls_monitor_main_ap = new("jls_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = jls_coverage_item::type_id::create("req",this);
    jls_item_h = jls_item::type_id::create("jls_item_h",this);
    if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,jls_vif))
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


endclass : jls_monitor
  
  // Sample vif data , trans to scoreboard or other component
  task jls_monitor::monitor_trans();
    forever begin
      @(posedge jls_vif.clk);
      begin
        jls_item_h.card_sel = jls_vif.card_sel  ;
        jls_monitor_main_ap.write(jls_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task jls_monitor::collect_coverage();
    forever begin
      @(posedge jls_vif.clk);
      req.card_sel  = jls_vif.card_sel ;
      req.jls_ctrl  = jls_vif.jls_ctrl ;
      if(cov_enable)begin
		    frame_collected_port.write(req);  
	    end 
    end
  endtask

  // Print monitor status of cov_enable & checks_enable
  function jls_monitor::print_monitor_status();
		`uvm_info(get_type_name(), $sformatf("jls_monitor status as following:"), UVM_MEDIUM)
		if(checks_enable)begin
			`uvm_info(get_type_name(), $sformatf("jls_monitor check switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("jls_monitor check switch OFF"), UVM_MEDIUM)
		end
		if(cov_enable)begin
			`uvm_info(get_type_name(), $sformatf("jls_monitor collect coverages switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("jls_monitor collect coverages switch OFF"), UVM_MEDIUM)
		end
  endfunction

