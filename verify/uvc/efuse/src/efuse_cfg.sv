class efuse_cfg extends efuse_base_cfg;

  // Registration
  /////////////////////////////////////////////////////////
  `uvm_object_utils(efuse_cfg)

  function new(string name="efuse_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////

    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
     this.constr_efuse_ctrl1.constraint_mode(1);
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
  constraint constr_efuse_ctrl1;

endclass: efuse_cfg

constraint efuse_cfg::constr_efuse_ctrl1
  {
    efuse_ctrl1 inside {[4'ha:4'hf]};
  }

