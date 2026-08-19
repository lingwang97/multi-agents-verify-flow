class uart_cfg extends uart_base_cfg;

  // Registration
  /////////////////////////////////////////////////////////
  `uvm_object_utils(uart_cfg)

  function new(string name="uart_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////

    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
     this.constr_uart_ctrl1.constraint_mode(1);
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
  constraint constr_uart_ctrl1;

endclass: uart_cfg

constraint uart_cfg::constr_uart_ctrl1
  {
    uart_ctrl1 inside {[4'ha:4'hf]};
  }

