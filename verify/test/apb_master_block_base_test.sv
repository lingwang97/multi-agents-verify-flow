import "DPI-C" function int wallclock();
import global_pkg::*;
class apb_master_block_base_test extends uvm_test;

    int unsigned start_time_int;
    int unsigned end_time_int;
    string start_time_str;
    string end_time_str;

    apb_master_pkg::apb_master_env                      apb_master_env_h;
    RAL_PKG::ral_gen_main                       ral;
    apb_master_pkg::apb_master_reg2apb_adapter   apb_master_adapter_h;

    // Virtual interface declarations
    virtual interface apb_master_if apb_master_vif;
    // Other virtual interface declarations

    // Config declarations
    apb_master_pkg::apb_master_base_cfg apb_master_cfg_h;

    // randomize declarations
    extern virtual function void apb_master_cfg_randomize();

    // cfg override declarations
    extern virtual function void set_apb_master_cfg_type(input string apb_master_cfg_override, bit replace=1);

    // global check setting function
    extern virtual function void set_enable(input string   array_name,input string   index_name,input on_off_t enable,input string event_bind="DEFAULT");
    extern virtual function void set_mon_checks_enable( input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_sb_checks_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_if_checks_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_mon_cov_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_if_cov_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    // ******************************************************************* 
    // *******User's Function and Task Declarations: *********************
    // *******************************************************************

    // automation macro
    `uvm_component_utils_begin(apb_master_block_base_test)
    `uvm_component_utils_end
    
    // constructor
    function new(string name = "apb_master_block_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable transaction recording for everything
        // Change your recording cfg depend on test scenario
        uvm_config_db#(int)::set(this, "*", "recording_detail" , UVM_FULL); //UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_FULL

        // Create the test environment
        `uvm_info(get_type_name(),"****** Creating apb_master_env class ******",UVM_LOW);
        apb_master_env_h = apb_master_pkg::apb_master_env::type_id::create("apb_master_env_h", this);
        apb_master_env_h.drv_is_active = UVM_ACTIVE;
        
        // create adapter
        apb_master_adapter_h = apb_master_pkg::apb_master_reg2apb_adapter::type_id::create("apb_master_adapter_h", this);

        // Create all config objects
        `uvm_info(get_type_name(),"****** Creating All base_cfg class ******",UVM_LOW);   
        apb_master_cfg_h = apb_master_pkg::apb_master_base_cfg::type_id::create("apb_master_cfg_h", this);
        // Set all config objects
        `uvm_info(get_type_name(),"****** Setting All base_cfg class ******",UVM_LOW);
        uvm_config_db #(apb_master_pkg::apb_master_base_cfg)::set(uvm_root::get(),"*", "apb_master_cfg", apb_master_cfg_h);

        // Set other objects

        // Get all virtual interfaces
        `uvm_info(get_type_name(),"****** Getting All the virtual interface ******",UVM_LOW);
        if (!uvm_config_db #(virtual interface apb_master_if)::get(this, "", "apb_master_vif", apb_master_vif))
            `uvm_error("APB_MASTER_VIF:ERROR", "VIF apb_master_vif is missing from config_db")

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
        ral.default_map.set_sequencer(apb_master_env_h.vseqr_h, apb_master_adapter_h);
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
        apb_master_cfg_randomize();
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
            //uvm_hdl_deposit("tb_top.RST",1);
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
            //init_seq.start(apb_master_env_h.vseqr_h);
            phase.drop_objection(this);
        end
    
    endtask : configure_phase
    
    virtual task post_configure_phase(uvm_phase phase);
        super.post_configure_phase(phase);
        `uvm_info(get_type_name(), "Starting post_configure_phase phase", UVM_MEDIUM);
        //setting your reg init cfg and warming up cfg here
        begin
          phase.raise_objection(this);       
          //uvm_hdl_deposit("tb_top.RST",0);   //need to be updated
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

endclass : apb_master_block_base_test


// Randomization functions

function void apb_master_block_base_test::apb_master_cfg_randomize();
    if(apb_master_cfg_h.randomize())
        `uvm_info(get_type_name(),apb_master_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"apb_master_cfg_h randomization failed")
endfunction

// User's other randomization functions

// cfg override function

function void apb_master_block_base_test::set_apb_master_cfg_type(input string apb_master_cfg_override, bit replace=1);
    set_type_override("apb_master_base_cfg", apb_master_cfg_override, replace);
endfunction

// User's other cfg override function


// global check setting function
function void apb_master_block_base_test::set_enable(input string   array_name,
                         input string   index_name,
                         input on_off_t enable,
                         input string event_bind="DEFAULT");

    string   name;   
    if(event_bind == "DEFAULT")begin
        case (array_name)
            "MON_CHECKS_ENABLE":
                if ( MON_CHECKS_ENABLE.exists(index_name) ) begin
                    MON_CHECKS_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting MON_CHECKS_ENABLE[%s] = %b\n",
                                                    index_name, MON_CHECKS_ENABLE[index_name]),UVM_MEDIUM)
                end else begin
                    //List valid names 
                    `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
                    if ( MON_CHECKS_ENABLE.first(name) ) begin
                        do begin
                            `uvm_info(report_id,$sformatf("    MON_CHECKS_ENABLE[%s]",name),UVM_LOW)
                        end
                        while (MON_CHECKS_ENABLE.next(name));
                    end
                end // else: !if( MON_CHECKS_ENABLE.exists(index_name) )
            "SB_CHECKS_ENABLE":
                if ( SB_CHECKS_ENABLE.exists(index_name) ) begin
                    SB_CHECKS_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting SB_CHECKS_ENABLE[%s] = %b\n",
                                                    index_name, SB_CHECKS_ENABLE[index_name]),UVM_MEDIUM)
                end else begin
                    //List valid names 
                    `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
                    if ( SB_CHECKS_ENABLE.first(name) ) begin
                        do begin
                            `uvm_info(report_id,$sformatf("    SB_CHECKS_ENABLE[%s]",name),UVM_LOW)
                        end
                        while (SB_CHECKS_ENABLE.next(name));
                    end
                end // else: !if( SB_CHECKS_ENABLE.exists(index_name) ) 
            "MON_COVERAGE_ENABLE":
                if ( MON_COVERAGE_ENABLE.exists(index_name) ) begin
                    MON_COVERAGE_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting MON_COVERAGE_ENABLE[%s] = %b\n",
                                                    index_name, MON_COVERAGE_ENABLE[index_name]),UVM_MEDIUM)
                end else begin
                    //List valid names 
                    `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
                    if ( MON_COVERAGE_ENABLE.first(name) ) begin
                        do begin
                            `uvm_info(report_id,$sformatf("    MON_COVERAGE_ENABLE[%s]",name),UVM_LOW)
                        end
                        while (MON_COVERAGE_ENABLE.next(name));
                    end
                end // else: !if( MON_COVERAGE_ENABLE.exists(index_name) )
                
            "IF_CHECKS_ENABLE":
                if ( IF_CHECKS_ENABLE.exists(index_name) ) begin
                    IF_CHECKS_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting IF_CHECKS_ENABLE[%s] = %b\n",
                                                    index_name, IF_CHECKS_ENABLE[index_name]),UVM_MEDIUM)
                end else begin
                    //List valid names 
                        `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
                    if ( IF_CHECKS_ENABLE.first(name) ) begin
                        do begin
                            `uvm_info(report_id,$sformatf("    IF_CHECKS_ENABLE[%s]",name),UVM_LOW)
                        end
                        while (IF_CHECKS_ENABLE.next(name));
                    end
                end // else: !if( IF_CHECKS_ENABLE.exists(index_name) )
                
            "IF_COVERAGE_ENABLE":
                if ( IF_COVERAGE_ENABLE.exists(index_name) ) begin
                    IF_COVERAGE_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting IF_COVERAGE_ENABLE[%s] = %b\n",
                                                    index_name, IF_COVERAGE_ENABLE[index_name]),UVM_MEDIUM)
                end else begin
                    //List valid names 
                    `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
                    if ( IF_COVERAGE_ENABLE.first(name) ) begin
                        do begin
                            `uvm_info(report_id,$sformatf("    IF_COVERAGE_ENABLE[%s]",name),UVM_LOW)
                        end
                        while (IF_COVERAGE_ENABLE.next(name));
                    end
                end // else: !if( IF_COVERAGE_ENABLE.exists(index_name) )
            
        endcase // (array_name)
    
    end // if (event_bind == "DEFAULT")
endfunction: set_enable

function void apb_master_block_base_test::set_mon_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon check for %s",name),UVM_LOW)
        set_enable(.array_name("MON_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));
endfunction: set_mon_checks_enable    

function void apb_master_block_base_test::set_sb_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting sb check for %s",name),UVM_LOW)
        set_enable(.array_name("SB_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind) );

endfunction: set_sb_checks_enable

function void apb_master_block_base_test::set_if_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if check for %s",name),UVM_LOW)
        set_enable(.array_name("IF_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_checks_enable

function void apb_master_block_base_test::set_mon_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon cov for %s",name),UVM_LOW)
        set_enable(.array_name("MON_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_mon_cov_enable

function void apb_master_block_base_test::set_if_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if cov for %s",name),UVM_LOW)
        set_enable(.array_name("IF_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_cov_enable


// *************************************************************
// *******function and task defination: ************************
// *************************************************************


/*  ====================================================================================  */
//  All apb_master block test classes must inherit from the base class apb_master_block_base_test
/*  ====================================================================================  */



class apb_master_smoke_block_test extends apb_master_block_base_test;

    string report_id = "apb_master_smoke_block_test"; 
    // automation macro
    `uvm_component_utils_begin(apb_master_smoke_block_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "apb_master_smoke_block_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        begin
            super.build_phase(phase);
        end
    endfunction: build_phase

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        //eg.
        //set_if_checks_enable(.name("apb_master_if"),.enable(OFF));
        //set_if_cov_enable(.name("apb_master_if"),.enable(OFF));
        //set_mon_checks_enable(.name("apb_master_monitor_h"),.enable(OFF));
        //set_mon_cov_enable(.name("apb_master_monitor_h"),.enable(OFF));
        //set_sb_checks_enable(.name("apb_master_scoreboard_h"),.enable(OFF));

    endfunction: start_of_simulation_phase

    task main_phase(uvm_phase phase);

        apb_master_smoke_block_seq   seq;
        phase.raise_objection(this);
        seq = apb_master_smoke_block_seq::type_id::create("apb_master_smoke_block_seq");
        seq.start(apb_master_env_h.vseqr_h);
        phase.drop_objection(this);

    endtask

endclass : apb_master_smoke_block_test


/*  ====================================================================================  */
//  Feature-point leaf tests: reset / random rw / out-of-range / boundary / wait states
/*  ====================================================================================  */

// FP1 reset behaviour: post-reset memory content and output values
class apb_master_reset_block_test extends apb_master_block_base_test;

    string report_id = "apb_master_reset_block_test";
    `uvm_component_utils_begin(apb_master_reset_block_test)
    `uvm_component_utils_end

    function new(string name = "apb_master_reset_block_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    task main_phase(uvm_phase phase);
        apb_master_reset_block_seq seq;
        phase.raise_objection(this);
        seq = apb_master_reset_block_seq::type_id::create("apb_master_reset_block_seq");
        seq.start(apb_master_env_h.vseqr_h);
        phase.drop_objection(this);
    endtask

endclass : apb_master_reset_block_test

// FP2/FP3/FP4 random read/write integrity vs scoreboard shadow model
class apb_master_rw_rand_block_test extends apb_master_block_base_test;

    string report_id = "apb_master_rw_rand_block_test";
    `uvm_component_utils_begin(apb_master_rw_rand_block_test)
    `uvm_component_utils_end

    function new(string name = "apb_master_rw_rand_block_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    task main_phase(uvm_phase phase);
        apb_master_rw_rand_block_seq seq;
        phase.raise_objection(this);
        seq = apb_master_rw_rand_block_seq::type_id::create("apb_master_rw_rand_block_seq");
        seq.start(apb_master_env_h.vseqr_h);
        phase.drop_objection(this);
    endtask

endclass : apb_master_rw_rand_block_test

// FP5 out-of-range PSLVERR / no write-through / stale PRDATA
class apb_master_error_block_test extends apb_master_block_base_test;

    string report_id = "apb_master_error_block_test";
    `uvm_component_utils_begin(apb_master_error_block_test)
    `uvm_component_utils_end

    function new(string name = "apb_master_error_block_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    task main_phase(uvm_phase phase);
        apb_master_error_block_seq seq;
        phase.raise_objection(this);
        seq = apb_master_error_block_seq::type_id::create("apb_master_error_block_seq");
        seq.start(apb_master_env_h.vseqr_h);
        phase.drop_objection(this);
    endtask

endclass : apb_master_error_block_test

// FP9 boundary addresses 0/1/62/63 in-range, 64 first error address
class apb_master_boundary_block_test extends apb_master_block_base_test;

    string report_id = "apb_master_boundary_block_test";
    `uvm_component_utils_begin(apb_master_boundary_block_test)
    `uvm_component_utils_end

    function new(string name = "apb_master_boundary_block_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    task main_phase(uvm_phase phase);
        apb_master_boundary_block_seq seq;
        phase.raise_objection(this);
        seq = apb_master_boundary_block_seq::type_id::create("apb_master_boundary_block_seq");
        seq.start(apb_master_env_h.vseqr_h);
        phase.drop_objection(this);
    endtask

endclass : apb_master_boundary_block_test

// FP7 wait states: built with +APB_SRAM_EN_WAIT (DUT EN_WAIT_DELAY_FUNC=1)
class apb_master_wait_block_test extends apb_master_block_base_test;

    string report_id = "apb_master_wait_block_test";
    `uvm_component_utils_begin(apb_master_wait_block_test)
    `uvm_component_utils_end

    function new(string name = "apb_master_wait_block_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    task main_phase(uvm_phase phase);
        apb_master_wait_block_seq seq;
        phase.raise_objection(this);
        seq = apb_master_wait_block_seq::type_id::create("apb_master_wait_block_seq");
        seq.start(apb_master_env_h.vseqr_h);
        phase.drop_objection(this);
    endtask

endclass : apb_master_wait_block_test



