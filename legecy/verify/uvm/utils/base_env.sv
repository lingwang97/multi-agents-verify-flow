
class base_env extends uvm_env;

    string              report_id = "base_env";   // Report Id String For Messaging

    bit                 intf_tb_reset        = 0; // Reset Cov or Sv Checks
    bit                 intf_checks_enable   = 1; // Enable SVA Checks
    bit                 intf_coverage_enable = 1; // Enable SVA Coverage

    ////////////////////////////////////////////////////
    // Register
    ////////////////////////////////////////////////////
   `uvm_component_utils_begin(base_env)
     `uvm_field_int(intf_tb_reset,        UVM_ALL_ON)
     `uvm_field_int(intf_checks_enable,   UVM_ALL_ON)
     `uvm_field_int(intf_coverage_enable, UVM_ALL_ON)
   `uvm_component_utils_end

    ////////////////////////////////////////////////////
    // Called At New Phase
    ////////////////////////////////////////////////////
    function new(string name="base_env", uvm_component parent = null); 
      super.new(name, parent);
    endfunction : new

    ////////////////////////////////////////////////////
    // Called At Build Phase
    ////////////////////////////////////////////////////
    virtual function void build_phase( uvm_phase phase );
      `uvm_info(report_id, "build() START",UVM_HIGH);
      super.build_phase( phase );
      `uvm_info(report_id, "build() END",UVM_HIGH);
    endfunction : build_phase
       
    ////////////////////////////////////////////////////
    // Called At Connect Phase
    ////////////////////////////////////////////////////
    virtual function void connect_phase( uvm_phase phase );
      `uvm_info(report_id, "connect() START",UVM_HIGH);
      // Call UVM version of method to preserve function, extended environments overloading
      // this method should also call super.connect to preserve any function 
      // introduced here.
      super.connect_phase( phase );
      `uvm_info(report_id, "connect() END",UVM_HIGH);
    endfunction : connect_phase

    ////////////////////////////////////////////////////
    // Called At End Of Elaboration Phase
    ////////////////////////////////////////////////////
    virtual function void end_of_elaboration_phase( uvm_phase phase );
      `uvm_info(report_id, "end_of_elaboration() START",UVM_HIGH);
      // Call UVM version of method to preserve function, extended environments overloading
      // this method should also call super.start_of_simulation to preserve any function 
      // introduced here.
      super.end_of_elaboration_phase( phase );
      `uvm_info(report_id, "end_of_elaboration() END",UVM_MEDIUM);
    endfunction : end_of_elaboration_phase

    ////////////////////////////////////////////////////
    // Called At Start Of Sim Phase
    ////////////////////////////////////////////////////
    virtual function void start_of_simulation_phase( uvm_phase phase );
      `uvm_info(report_id,"start_of_simulation() START",UVM_HIGH);
      // Call UVM version of method to preserve function, extended environments overloading
      // this method should also call super.start_of_simulation to preserve any function 
      // introduced here.
      super.start_of_simulation_phase( phase );
      `uvm_info(report_id, "start of simulation() END",UVM_HIGH);
    endfunction : start_of_simulation_phase

    ////////////////////////////////////////////////////
    virtual task run_phase( uvm_phase phase );
      `uvm_info(report_id,"run() START",UVM_HIGH);

      // Call UVM version of method to preserve function, extended environments overloading
      // this method should also call super.run to preserve any function 
      // introduced here.
      super.run_phase( phase );
      `uvm_info(report_id, "run() END",UVM_HIGH);
    endtask : run_phase
    
endclass : base_env
