class apb_master_base_cfg extends uvm_object;

  rand bit [3:0] apb_master_ctrl1;
  rand bit [3:0] apb_master_ctrl2;

  // tb knobs (DUT reference-model constants for the apb_v3_sram block env)
  int unsigned mem_size    = 64;   // DUT MEMSIZE (entries)
  int unsigned num_trans   = 100;  // random stimulus length
  int unsigned idle_cycles = 1;    // idle gap inserted between transfers

  // Registration
  /////////////////////////////////////////////////////////
  `uvm_object_utils_begin(apb_master_base_cfg)
    `uvm_field_int(apb_master_ctrl1, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(apb_master_ctrl2, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(mem_size, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(num_trans, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(idle_cycles, UVM_ALL_ON + UVM_DEC)
  `uvm_object_utils_end

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
  function new(string name="apb_master_base_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////  
    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
    this.constr_base_apb_master_ctrl1.constraint_mode(1);
    this.constr_base_apb_master_ctrl2.constraint_mode(1);
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
  constraint constr_base_apb_master_ctrl1;
  constraint constr_base_apb_master_ctrl2;

endclass: apb_master_base_cfg

constraint apb_master_base_cfg::constr_base_apb_master_ctrl1 
  {
    apb_master_ctrl1 inside {[4'h1:4'hf]};
  }

constraint apb_master_base_cfg::constr_base_apb_master_ctrl2 
  {
    apb_master_ctrl2 inside {[4'h1:4'hf]};
  }
