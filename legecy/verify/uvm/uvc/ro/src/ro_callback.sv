

class ro_callback extends uvm_callback;

  `uvm_object_utils(ro_callback)
  function new(string name = "ro_callback");
    super.new(name);
  endfunction : new

   virtual task set_ro_gold_freq();   endtask

endclass


class ro_rtl_callback extends ro_callback;
   `uvm_object_utils(ro_rtl_callback)
   ro_scoreboard             ro_scb  ;

   function new(string name = "ro_rtl_callback");
     super.new(name);
   endfunction : new

   virtual task set_ro_gold_freq();
      `uvm_info("[ro_rtl_callback]", "this is ro_rtl_callback set_ro_gold_freq", UVM_MEDIUM)

   endtask

endclass



