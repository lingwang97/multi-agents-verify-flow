`uvm_analysis_imp_decl(_main_cpft_monitor)
class cpft_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(cpft_scoreboard);
  
  virtual cpft_if cpft_vif;

  cpft_item cpft_item_h;

  uvm_analysis_imp_main_cpft_monitor #(cpft_item, cpft_scoreboard) cpft_scoreboard_main_ap;
  
  function new(string name="cpft_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cpft_scoreboard_main_ap = new("cpft_scoreboard_main_ap",this);  
    cpft_item_h = cpft_item::type_id::create("cpft_item_h",this);
    if (!uvm_config_db #(virtual interface cpft_if)::get(this, "", "cpft_vif", cpft_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("cpft_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;

  endtask:main_phase

  virtual function void write_main_cpft_monitor(cpft_item req);
    `uvm_info(get_type_name(), $sformatf("Received cpft_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass
