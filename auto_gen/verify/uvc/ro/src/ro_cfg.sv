class ro_cfg extends ro_base_cfg;

  // Registration
  /////////////////////////////////////////////////////////
  `uvm_object_utils(ro_cfg)

  function new(string name="ro_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////

    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
     this.constr_ro_ctrl1.constraint_mode(1);
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
  constraint constr_ro_ctrl1;

endclass: ro_cfg

constraint ro_cfg::constr_ro_ctrl1
  {
    ro_ctrl1 inside {[4'ha:4'hf]};
  }

