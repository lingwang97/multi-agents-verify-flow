class reg_configuration_seq extends base_seq;
   `uvm_object_utils(reg_configuration_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="reg_configuration_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();
   endtask:pre_body


   task body();
     super.body();
      `uvm_info(get_type_name(), "reg_configuration_seq start", UVM_MEDIUM)

      //////////////////////////////////////////////////
      // Increase mid_clk frequency when STUB_PLL
      // Re constrain cpm_cfg_h in reg_base_test
      //////////////////////////////////////////////////
      `ifdef STUB_PLL
          wrc_cpm_pll_x();
      `endif

      `uvm_info(get_type_name(), "reg_configuration_seq end", UVM_MEDIUM)
    endtask:body

endclass:reg_configuration_seq
