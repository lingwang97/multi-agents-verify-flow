class jamlink_ecc_inject_new_seq extends jamlink_base_seq;
   `uvm_object_utils(jamlink_ecc_inject_new_seq)
   reg [31:0] qqport;
   integer i ,j;
   reg [31:0] tmp;
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_ecc_inject_new_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "jamlink_ecc_inject_new_seq start", UVM_MEDIUM);
     //top_vif.initc_glb();
     
     top_vif.testc_jls_ecc(.chipid(0));
     top_vif.testc_jls_ecc(.chipid(1));
     top_vif.testc_jls_ecc(.chipid(2));
     `uvm_info(get_type_name(), "jamlink_ecc_inject_new_seq end", UVM_MEDIUM);

   endtask
endclass

class jamlink_ecc_test_new_seq extends jamlink_base_seq;
   `uvm_object_utils(jamlink_ecc_test_seq)
   reg [31:0] qqport;
   integer i ,j;
   reg [31:0] tmp;
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_ecc_test_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "jamlink_ecc_test_seq start", UVM_MEDIUM);
     //top_vif.initc_glb();
     
     top_vif.testc_jls_ecc(.chipid(0));
     top_vif.testc_jls_ecc(.chipid(1));
     top_vif.testc_jls_ecc(.chipid(2));
     `uvm_info(get_type_name(), "jamlink_ecc_test_seq end", UVM_MEDIUM);

   endtask
endclass

