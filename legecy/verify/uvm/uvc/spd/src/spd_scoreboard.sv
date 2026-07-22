`uvm_analysis_imp_decl(_main_spd_monitor)
class spd_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(spd_scoreboard);

  uvm_analysis_imp_main_spd_monitor #(spd_item, spd_scoreboard)  spd_scoreboard_main_ap;

  function new(string name="spd_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       spd_scoreboard_main_ap = new("spd_scoreboard_main_ap",this);
 
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function void write_main_spd_monitor(spd_item  spd_item_h);
    begin
     //`uvm_info(get_full_name(), $psprintf("spd_scoreboard card_sel =%d", spd_item_h.card_sel), UVM_LOW)
    end
  endfunction : write_main_spd_monitor

endclass :  spd_scoreboard
