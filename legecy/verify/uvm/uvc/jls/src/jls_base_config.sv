class jls_base_cfg extends uvm_object;

   rand bit [3:0]  jls_ctrl1;
   rand bit [3:0]  jls_ctrl2;
   // Registration
   /////////////////////////////////////////////////////////
   `uvm_object_utils_begin(jls_base_cfg)
     `uvm_field_int(jls_ctrl1,UVM_ALL_ON + UVM_HEX)
     `uvm_field_int(jls_ctrl2,UVM_ALL_ON + UVM_HEX)
   `uvm_object_utils_end

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
   function new(string name="jls_base_cfg");

      super.new(name);

      ///////////////////////////////////////////////////////
      // Assign to actual real variables in post_randomize()
      ///////////////////////////////////////////////////////
       post_randomize();

   endfunction : new

  function void pre_randomize();
      super.pre_randomize();
      this.constr_base_jls_ctrl1.constraint_mode(1);
      this.constr_base_jls_ctrl2.constraint_mode(1);
   endfunction : pre_randomize


   /////////////////////////////////////////////////////
   // Function To Run After Randomization
   // Get Real Numbers From Randomized Values
   /////////////////////////////////////////////////////
   function void post_randomize();
      super.post_randomize();
   endfunction : post_randomize

  /////////////////////////////////////
   // Constraints
   /////////////////////////////////////
   constraint constr_base_jls_ctrl1;
   constraint constr_base_jls_ctrl2;

endclass: jls_base_cfg

constraint jls_base_cfg::constr_base_jls_ctrl1
  {
    jls_ctrl1 inside {[4'h0:4'he]};
  }

constraint jls_base_cfg::constr_base_jls_ctrl2
  {
    jls_ctrl2 inside {[4'h0:4'he]};
  }
