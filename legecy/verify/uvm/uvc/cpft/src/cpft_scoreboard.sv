`uvm_analysis_imp_decl(_main_cpft_monitor)
class cpft_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(cpft_scoreboard);

  uvm_analysis_imp_main_cpft_monitor #(cpft_item, cpft_scoreboard)  cpft_scoreboard_main_ap;

  function new(string name="cpft_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       cpft_scoreboard_main_ap = new("cpft_scoreboard_main_ap",this);
 
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function void write_main_cpft_monitor(cpft_item  cpft_item_h);
    begin
     `uvm_info(get_full_name(), $psprintf("cpft_scoreboard card_sel =%d", cpft_item_h.card_sel), UVM_LOW)
    end
  endfunction : write_main_cpft_monitor

endclass :  cpft_scoreboard
