import "DPI-C" function int wallclock();

class efuse_block_base_test extends uvm_test;

    int unsigned start_time_int;
    int unsigned end_time_int;
    string start_time_str;
    string end_time_str;

    efuse_pkg::efuse_env                      efuse_env_h;
    RAL_PKG::ral_gen_main                       ral;
    efuse_pkg::efuse_reg2apb_adapter   efuse_adapter_h;

    // Virtual interface declarations
    virtual interface efuse_if efuse_vif;
    // Other virtual interface declarations

    // Config declarations
    efuse_pkg::efuse_base_cfg efuse_cfg_h;

    // randomize declarations
    extern virtual function void efuse_cfg_randomize();

    // cfg override declarations
    extern virtual function void set_efuse_cfg_type(input string efuse_cfg_override, bit replace=1);

    // ******************************************************************* 
    // *******User's Function and Task Declarations: *********************
    // *******************************************************************

    // automation macro
    `uvm_component_utils_begin(efuse_block_base_test)
    `uvm_component_utils_end
    
    // constructor
    function new(string name = "efuse_block_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable transaction recording for everything
        // Change your recording cfg depend on test scenario
        uvm_config_db#(int)::set(this, "*", "recording_detail" , UVM_FULL); //UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_FULL

        // Create the test environment
        `uvm_info(get_type_name(),"****** Creating efuse_env class ******",UVM_LOW);
        efuse_env_h = efuse_pkg::efuse_env::type_id::create("efuse_env_h", this);
        efuse_env_h.drv_is_active = UVM_ACTIVE;
        
        // create adapter
        efuse_adapter_h = efuse_pkg::efuse_reg2apb_adapter::type_id::create("efuse_adapter_h", this);

        // Create all config objects
        `uvm_info(get_type_name(),"****** Creating All base_cfg class ******",UVM_LOW);   
        efuse_cfg_h = efuse_pkg::efuse_base_cfg::type_id::create("efuse_cfg_h", this);
        // Set all config objects
        `uvm_info(get_type_name(),"****** Setting All base_cfg class ******",UVM_LOW);
        uvm_config_db #(efuse_pkg::efuse_base_cfg)::set(uvm_root::get(),"*", "efuse_cfg", efuse_cfg_h);

        // Set other objects

        // Get all virtual interfaces
        `uvm_info(get_type_name(),"****** Getting All the virtual interface ******",UVM_LOW);
        if (!uvm_config_db #(virtual interface efuse_if)::get(this, "", "efuse_vif", efuse_vif))
            `uvm_error("EFUSE_VIF:ERROR", "VIF efuse_vif is missing from config_db")

        start_time_int = wallclock();

        // Create RAL model and cfg db setting
        ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);
        ral.configure(null, "");
        ral.build();
        ral.set_coverage(UVM_CVR_ALL);	
        ral.lock_model();
        ral.reset();
        ral.set_hdl_path_root("tb_top"); //need to be updated

        uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(), "*", "ral", ral);


    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //set regmodel prediction
        ral.default_map.set_sequencer(efuse_env_h.vseqr_h, efuse_adapter_h);
        ral.default_map.set_auto_predict(1);

    endfunction : connect_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Prints the topology.
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        // randomize all module base cfg
        efuse_cfg_randomize();
    endfunction: start_of_simulation_phase

    virtual task pre_reset_phase(uvm_phase phase);
        super.pre_reset_phase(phase);
        `uvm_info(get_type_name(), "Starting pre_reset_phase phase", UVM_MEDIUM);
        //setting your prepare reset cfg here

    endtask : pre_reset_phase

    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        `uvm_info(get_type_name(), "Starting reset_phase phase", UVM_MEDIUM);
        //setting your rst operation here
        begin
            phase.raise_objection(this);
            //uvm_hdl_deposit("tb_top.RO",1);
            `uvm_info(get_type_name(),"tb reset triggered...",UVM_MEDIUM);
            phase.drop_objection(this);
        end
    endtask : reset_phase

    virtual task post_reset_phase(uvm_phase phase);
        super.post_reset_phase(phase);
        `uvm_info(get_type_name(), "Starting post_reset_phase phase", UVM_MEDIUM);
        //setting your post reset cfg here

    endtask : post_reset_phase

    virtual task pre_configure_phase(uvm_phase phase);
        super.pre_configure_phase(phase);
        `uvm_info(get_type_name(), "Starting pre_configure_phase phase", UVM_MEDIUM);
        //setting your reg init cfg and warming up cfg here

    endtask : pre_configure_phase

    virtual task configure_phase(uvm_phase phase); 
        super.configure_phase(phase);
        `uvm_info(get_type_name(), "Starting configure_phase phase", UVM_MEDIUM);
        //setting your reg init cfg and warming up cfg here
        begin
            //init_normal_seq init_seq;
            phase.raise_objection(this);
            //init_seq = init_normal_seq::type_id::create("init_seq");
            //init_seq.start(efuse_env_h.vseqr_h);
            phase.drop_objection(this);
        end
    
    endtask : configure_phase
    
    virtual task post_configure_phase(uvm_phase phase);
        super.post_configure_phase(phase);
        `uvm_info(get_type_name(), "Starting post_configure_phase phase", UVM_MEDIUM);
        //setting your reg init cfg and warming up cfg here
        begin
          phase.raise_objection(this);       
          uvm_hdl_deposit("tb_top.RO",0);
          `uvm_info(get_type_name(),"release tb reset...",UVM_MEDIUM);
          #1000ns;
          phase.drop_objection(this);
        end
    endtask : post_configure_phase


    virtual task pre_main_phase(uvm_phase phase);
        super.pre_main_phase(phase);
        `uvm_info(get_type_name(), "Starting pre_main_phase phase", UVM_MEDIUM);
        //main operation
    endtask : pre_main_phase

    virtual task main_phase(uvm_phase phase);
        super.main_phase(phase);
        `uvm_info(get_type_name(), "Starting main_phase phase", UVM_MEDIUM);
        //main operation

    endtask : main_phase

    virtual task post_main_phase(uvm_phase phase);
        super.post_main_phase(phase);
        `uvm_info(get_type_name(), "Starting post_main_phase phase", UVM_MEDIUM);
        //main operation

    endtask : post_main_phase

    virtual task pre_shutdown_phase(uvm_phase phase);
        super.pre_shutdown_phase(phase);
        `uvm_info(get_type_name(), "Starting pre_shutdown_phase phase", UVM_MEDIUM);
        // setting power off cfg here

    endtask : pre_shutdown_phase

    virtual task shutdown_phase(uvm_phase phase);
        super.shutdown_phase(phase);
        `uvm_info(get_type_name(), "Starting shutdown_phase phase", UVM_MEDIUM);
        // setting power off cfg here

    endtask : shutdown_phase

    virtual task post_shutdown_phase(uvm_phase phase);
        super.post_shutdown_phase(phase);
        `uvm_info(get_type_name(), "Starting post_shutdown_phase phase", UVM_MEDIUM);
        // setting power off cfg here

    endtask : post_shutdown_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    	phase.raise_objection(this);

    	phase.drop_objection(this);
    endtask : run_phase



    virtual function void extract_phase( uvm_phase phase );
        super.extract_phase(phase);
        
    endfunction : extract_phase

    virtual function void check_phase( uvm_phase phase );
        super.check_phase(phase);
        
    endfunction : check_phase

    virtual function void report_phase( uvm_phase phase );
        super.report_phase(phase);
        end_time_int = wallclock();
        $display(">>>>>>>>>>>>>>>>>>>>>>>> %s Runned %d Hours<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",get_type_name(), end_time_int-start_time_int);
    endfunction : report_phase

    virtual function void final_phase( uvm_phase phase );
        super.final_phase(phase);

    endfunction : final_phase

endclass : efuse_block_base_test


// Randomization functions

function void efuse_block_base_test::efuse_cfg_randomize();
    if(efuse_cfg_h.randomize())
        `uvm_info(get_type_name(),efuse_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"efuse_cfg_h randomization failed")
endfunction

// User's other randomization functions

// cfg override function

function void efuse_block_base_test::set_efuse_cfg_type(input string efuse_cfg_override, bit replace=1);
    set_type_override("efuse_base_cfg", efuse_cfg_override, replace);
endfunction

// User's other cfg override function


// *************************************************************
// *******function and task defination: ************************
// *************************************************************




