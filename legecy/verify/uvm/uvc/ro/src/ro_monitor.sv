
class ro_monitor extends base_monitor;

  uvm_analysis_port #(ro_item) ro_monitor_main_ap;
  uvm_analysis_port #(ro_coverage_item) frame_collected_port;

  `uvm_component_utils(ro_monitor);

  ro_coverage_item req;
  ro_item ro_item_h;

  virtual ro_if vif;
  
  extern task main_traffic();
  extern task collect_coverage();

  function new(string name="ro_monitor" , uvm_component parent=null);
    super.new(name , parent);
    ro_monitor_main_ap = new("ro_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ro_if)::get(this , "" , "ro_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    req = ro_coverage_item::type_id::create("req",this);
    ro_item_h = ro_item::type_id::create("ro_item_h",this);
      
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      main_traffic();
      collect_coverage();
    join_none
  endtask  
endclass

task ro_monitor::main_traffic();
    begin
    forever
    begin
      wait(~vif.rst);
      @(posedge vif.clk);
      begin
        ro_item_h.card_sel = vif.card_sel  ;
        ro_monitor_main_ap.write(ro_item_h);
      end
    end
    end
endtask

task ro_monitor::collect_coverage();
    begin 
    forever
    begin
    @(posedge vif.clk);
    req.card_sel  = vif.card_sel  ;
    frame_collected_port.write(req);   
    end
    end
endtask
