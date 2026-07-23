class reg_base_cfg extends uvm_object;

  rand bit [3:0] reg_ctrl1;
  rand bit [3:0] reg_ctrl2;

  // Registration
  /////////////////////////////////////////////////////////  
  `uvm_object_utils_begin(reg_base_cfg)
    `uvm_field_int(reg_ctrl1, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(reg_ctrl2, UVM_ALL_ON + UVM_HEX)
  `uvm_object_utils_end

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
  function new(string name="reg_base_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////  
    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
    this.constr_base_reg_ctrl1.constraint_mode(1);
    this.constr_base_reg_ctrl2.constraint_mode(1);
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
  constraint constr_base_reg_ctrl1;
  constraint constr_base_reg_ctrl2;

endclass: reg_base_cfg

constraint reg_base_cfg::constr_base_reg_ctrl1 
  {
    reg_ctrl1 inside {[4'h1:4'hf]};
  }

constraint reg_base_cfg::constr_base_reg_ctrl2 
  {
    reg_ctrl2 inside {[4'h1:4'hf]};
  }
