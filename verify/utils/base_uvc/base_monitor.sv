class base_monitor extends uvm_monitor;

   string name_h = "";
   bit    checks_enable = 1'b1;
   bit    cov_enable    = 1'b1;
  ///////////////////////////////////////////////////////////////
  //  This function "News" the class
  ///////////////////////////////////////////////////////////////
  function new (string name = "base_monitor", uvm_component parent = null);
    super.new(name, parent);
    //Create an entry in the global assoc arrays using the class 
    //handle as the index. 
    name_h                      = name;
    MON_CHECKS_ENABLE[name_h]   = 1'b1;
    MON_COVERAGE_ENABLE[name_h] = 1'b1;
  endfunction : new
  
  ///////////////////////////////////////////////////////////////////
  // Fucntion Called At Build Phase
  ///////////////////////////////////////////////////////////////////
  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );

  endfunction : build_phase

  ///////////////////////////////////////////////////////////////////
  // Function To Handle Any Connections Of Objects
  ///////////////////////////////////////////////////////////////////
  virtual function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
  endfunction : connect_phase

  ///////////////////////////////////////////////////////////////////
  // Function Called At End Of Elaboration Phase
  ///////////////////////////////////////////////////////////////////
  virtual function void end_of_elaboration_phase( uvm_phase phase );
  endfunction : end_of_elaboration_phase

  ///////////////////////////////////////////////////////////////////
  // Function Called At Start Of Simulation Phase
  ///////////////////////////////////////////////////////////////////
  virtual function void start_of_simulation_phase( uvm_phase phase );
  endfunction : start_of_simulation_phase

  ///////////////////////////////////////////////////////////////////
  // This task creates a local version of checks_enable        
  ///////////////////////////////////////////////////////////////////
  virtual task update_checks_enable();
    forever begin
        @(MON_CHECKS_ENABLE[name_h] ) begin
          checks_enable = MON_CHECKS_ENABLE[name_h];
          `uvm_info(report_id,$sformatf("Setting %s.checks_enable = %b ",name_h,checks_enable),UVM_MEDIUM);
        end
    end
  endtask: update_checks_enable

  ///////////////////////////////////////////////////////////////////
  // This task creates a local version of coverage_enable        
  ///////////////////////////////////////////////////////////////////
  virtual task update_cov_enable();
    forever begin
        @(MON_COVERAGE_ENABLE[name_h]) begin
          cov_enable = MON_COVERAGE_ENABLE[name_h];
          `uvm_info(report_id,$sformatf("Setting %s.coverage_enable = %b",name_h,cov_enable),UVM_MEDIUM);
        end
    end
  endtask: update_cov_enable

  ////////////////////////////////////////////////////
  // Function Called At The Run Phase
  ////////////////////////////////////////////////////
  virtual task run_phase( uvm_phase phase );
     // Update local enables just in case they changed during time 0 before run() could start the monitors
     checks_enable = MON_CHECKS_ENABLE[name_h];
     cov_enable = MON_COVERAGE_ENABLE[name_h];
     fork
        update_checks_enable(); //update in background
        update_cov_enable();
     join_none
  endtask : run_phase

endclass
