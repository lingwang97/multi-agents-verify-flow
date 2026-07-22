class reg_cfg extends reg_base_cfg;

   // Registration
   /////////////////////////////////////////////////////////
   `uvm_object_utils(reg_cfg)

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
   function new(string name="reg_cfg");

      super.new(name);

      ///////////////////////////////////////////////////////
      // Assign to actual real variables in post_randomize()
      ///////////////////////////////////////////////////////
       post_randomize();

   endfunction : new

  function void pre_randomize();
      super.pre_randomize();
      this.constr_reg_ctrl1.constraint_mode(1);
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
   constraint constr_reg_ctrl1;

endclass: reg_cfg

constraint reg_cfg::constr_reg_ctrl1
  {
    reg_ctrl1 inside {[4'h1:4'ha]};
  }

