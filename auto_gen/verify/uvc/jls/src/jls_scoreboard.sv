`uvm_analysis_imp_decl(_main_jls_monitor)
class jls_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(jls_scoreboard);
  
  virtual jls_if jls_vif;

  jls_item jls_item_h;

  uvm_analysis_imp_main_jls_monitor #(jls_item, jls_scoreboard) jls_scoreboard_main_ap;
  
  function new(string name="jls_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    jls_scoreboard_main_ap = new("jls_scoreboard_main_ap",this);  
    jls_item_h = jls_item::type_id::create("jls_item_h",this);
    if (!uvm_config_db #(virtual interface jls_if)::get(this, "", "jls_vif", jls_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("jls_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;

  endtask:main_phase

  virtual function void write_main_jls_monitor(jls_item req);
    `uvm_info(get_type_name(), $sformatf("Received jls_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass
