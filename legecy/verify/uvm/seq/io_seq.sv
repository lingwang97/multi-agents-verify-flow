class io_base_seq extends base_seq;
   virtual io_if io_vif;
   virtual top_if   top_vif;
   `uvm_object_utils(io_base_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="io_base_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface io_if)::get(m_sequencer, "", "io_vif", io_vif))
      `uvm_error("RO_VIP:ERROR", "VIF io_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")

   endtask

   task body();
     super.body();
   endtask
endclass


class io_tpsel_connection_seq extends io_base_seq;
   `uvm_object_utils(io_tpsel_connection_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="io_tpsel_connection_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "io_tpsel_connection_seq start", UVM_MEDIUM);

     #10000ns;
     uvm_hdl_force("tb_top.C[0].btnode.btc.TPSEL", 1);
     #1ns;
     if(io_vif.from_io_n_pin_tpsel !== 1) `uvm_error("CMP ERROR",$sformatf("from_io_n_pin_tpsel is 'h%0x", io_vif.from_io_n_pin_tpsel));
     #5000ns;
     uvm_hdl_force("tb_top.C[0].btnode.btc.TPSEL", 0);
     #1ns;
     if(io_vif.from_io_n_pin_tpsel !== 0) `uvm_error("CMP ERROR",$sformatf("from_io_n_pin_tpsel is 'h%0x", io_vif.from_io_n_pin_tpsel));     
     #5000ns;
     uvm_hdl_release("tb_top.C[0].btnode.btc.TPSEL");

     `uvm_info(get_type_name(), "io_tpsel_connection_seq end", UVM_MEDIUM);

   endtask
endclass