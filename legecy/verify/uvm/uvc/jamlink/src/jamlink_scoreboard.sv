`uvm_analysis_imp_decl(_main_jamlink_monitor)
class jamlink_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(jamlink_scoreboard);

  uvm_analysis_imp_main_jamlink_monitor #(jamlink_item, jamlink_scoreboard)  jamlink_scoreboard_main_ap;

  function new(string name="jamlink_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       jamlink_scoreboard_main_ap = new("jamlink_scoreboard_main_ap",this);
 
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function void write_main_jamlink_monitor(jamlink_item  jamlink_item_h);
    begin
     `uvm_info(get_full_name(), $psprintf("jamlink_scoreboard card_sel =%d", jamlink_item_h.card_sel), UVM_LOW)
    end
  endfunction : write_main_jamlink_monitor

endclass :  jamlink_scoreboard
