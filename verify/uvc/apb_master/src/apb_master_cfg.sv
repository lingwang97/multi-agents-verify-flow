class apb_master_cfg extends apb_master_base_cfg;

  // Registration
  /////////////////////////////////////////////////////////
  `uvm_object_utils(apb_master_cfg)

  function new(string name="apb_master_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////

    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
     this.constr_apb_master_ctrl1.constraint_mode(1);
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
  constraint constr_apb_master_ctrl1;

endclass: apb_master_cfg

constraint apb_master_cfg::constr_apb_master_ctrl1
  {
    apb_master_ctrl1 inside {[4'ha:4'hf]};
  }

