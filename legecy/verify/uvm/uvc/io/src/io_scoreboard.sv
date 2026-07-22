`uvm_analysis_imp_decl(_main_io_monitor)
class io_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(io_scoreboard);

  uvm_analysis_imp_main_io_monitor #(io_item, io_scoreboard)  io_scoreboard_main_ap;

  function new(string name="io_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       io_scoreboard_main_ap = new("io_scoreboard_main_ap",this);
 
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function void write_main_io_monitor(io_item  io_item_h);
    begin
     `uvm_info(get_full_name(), $psprintf("io_scoreboard card_sel =%d", io_item_h.card_sel), UVM_LOW)
    end
  endfunction : write_main_io_monitor

endclass :  io_scoreboard
