class ro_monitor extends base_monitor;

  uvm_analysis_port #(ro_item) ro_monitor_main_ap;
  uvm_analysis_port #(ro_coverage_item) frame_collected_port;

  `uvm_component_utils(ro_monitor);

  ro_coverage_item req;
  ro_item ro_item_h;
  virtual ro_if ro_vif;

  extern task monitor_trans();
  extern task collect_coverage();
  extern function print_monitor_status();
  function new(string name="ro_monitor" , uvm_component parent=null);
    super.new(name , parent);
    ro_monitor_main_ap = new("ro_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = ro_coverage_item::type_id::create("req",this);
    ro_item_h = ro_item::type_id::create("ro_item_h",this);
    if(!uvm_config_db#(virtual ro_if)::get(this , "" , "ro_vif" ,ro_vif))
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


endclass : ro_monitor
  
  // Sample vif data , trans to scoreboard or other component
  task ro_monitor::monitor_trans();
    forever begin
      @(posedge ro_vif.clk);
      begin
        ro_item_h.card_sel = ro_vif.card_sel  ;
        ro_monitor_main_ap.write(ro_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task ro_monitor::collect_coverage();
    forever begin
      @(posedge ro_vif.clk);
      req.card_sel  = ro_vif.card_sel ;
      req.ro_ctrl  = ro_vif.ro_ctrl ;
      if(cov_enable)begin
		    frame_collected_port.write(req);  
	    end 
    end
  endtask

  // Print monitor status of cov_enable & checks_enable
  function ro_monitor::print_monitor_status();
		`uvm_info(get_type_name(), $sformatf("ro_monitor status as following:"), UVM_MEDIUM)
		if(checks_enable)begin
			`uvm_info(get_type_name(), $sformatf("ro_monitor check switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("ro_monitor check switch OFF"), UVM_MEDIUM)
		end
		if(cov_enable)begin
			`uvm_info(get_type_name(), $sformatf("ro_monitor collect coverages switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("ro_monitor collect coverages switch OFF"), UVM_MEDIUM)
		end
  endfunction

