
class cpft_monitor extends base_monitor;

  uvm_analysis_port #(cpft_item) cpft_monitor_main_ap;
  uvm_analysis_port #(cpft_coverage_item) frame_collected_port;

  `uvm_component_utils(cpft_monitor);

  cpft_coverage_item req;
  cpft_item cpft_item_h;

  virtual cpft_if vif;
  
  extern task main_traffic();
  extern task collect_coverage();

  function new(string name="cpft_monitor" , uvm_component parent=null);
    super.new(name , parent);
    cpft_monitor_main_ap = new("cpft_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual cpft_if)::get(this , "" , "cpft_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    req = cpft_coverage_item::type_id::create("req",this);
    cpft_item_h = cpft_item::type_id::create("cpft_item_h",this);
      
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

task cpft_monitor::main_traffic();
    begin
    forever
    begin
      wait(~vif.rst);
      @(posedge vif.clk);
      begin
        cpft_item_h.card_sel = vif.card_sel  ;
        cpft_monitor_main_ap.write(cpft_item_h);
      end
    end
    end
endtask

task cpft_monitor::collect_coverage();
    begin 
    forever
    begin
    @(posedge vif.clk);
    req.card_sel  = vif.card_sel  ;
    frame_collected_port.write(req);   
    end
    end
endtask
