class jls_cfg extends jls_base_cfg;

   // Registration
   /////////////////////////////////////////////////////////
   `uvm_object_utils(jls_cfg)

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
   function new(string name="jls_cfg");

      super.new(name);

      ///////////////////////////////////////////////////////
      // Assign to actual real variables in post_randomize()
      ///////////////////////////////////////////////////////
       post_randomize();

   endfunction : new

  function void pre_randomize();
      super.pre_randomize();
      this.constr_jls_ctrl1.constraint_mode(1);
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
   constraint constr_jls_ctrl1;

endclass: jls_cfg

constraint jls_cfg::constr_jls_ctrl1
  {
    jls_ctrl1 inside {[4'h1:4'ha]};
  }

