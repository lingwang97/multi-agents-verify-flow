`ifndef __BASE_TEST_SV_
`define __BASE_TEST_SV_

import "DPI-C" function int wallclock();

class base_test extends uvm_test;

    int unsigned start_time_int;
    int unsigned end_time_int;
    string start_time_str;
    string end_time_str;

    top_env top_env_h;
    top_virtual_sequencer vseqr_h;
    
    // Virtual interface declarations
    virtual interface top_if top_vif;
    virtual interface reg_if reg_vif;
    virtual interface apb_master_if apb_master_vif;
    virtual interface ro_if ro_vif;
    virtual interface uart_if uart_vif;
    virtual interface efuse_if efuse_vif;
    // Other virtual interface declarations



    // Config declarations
    reg_pkg::reg_base_cfg reg_cfg_h;
`ifdef OPEN_EDA
    typedef reg_pkg::reg_base_cfg reg_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    apb_master_pkg::apb_master_base_cfg apb_master_cfg_h;
`ifdef OPEN_EDA
    typedef apb_master_pkg::apb_master_base_cfg apb_master_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    ro_pkg::ro_base_cfg ro_cfg_h;
`ifdef OPEN_EDA
    typedef ro_pkg::ro_base_cfg ro_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    uart_pkg::uart_base_cfg uart_cfg_h;
`ifdef OPEN_EDA
    typedef uart_pkg::uart_base_cfg uart_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    efuse_pkg::efuse_base_cfg efuse_cfg_h;
`ifdef OPEN_EDA
    typedef efuse_pkg::efuse_base_cfg efuse_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif

    // randomize declarations
    extern virtual function void reg_cfg_randomize();
    extern virtual function void apb_master_cfg_randomize();
    extern virtual function void ro_cfg_randomize();
    extern virtual function void uart_cfg_randomize();
    extern virtual function void efuse_cfg_randomize();

    // cfg override declarations
    extern virtual function void set_reg_cfg_type(input string reg_cfg_override, bit replace=1);
    extern virtual function void set_apb_master_cfg_type(input string apb_master_cfg_override, bit replace=1);
    extern virtual function void set_ro_cfg_type(input string ro_cfg_override, bit replace=1);
    extern virtual function void set_uart_cfg_type(input string uart_cfg_override, bit replace=1);
    extern virtual function void set_efuse_cfg_type(input string efuse_cfg_override, bit replace=1);
    
    // global check setting function
    extern virtual function void set_enable_flag_debug();
    extern virtual function void set_enable(input string   array_name,input string   index_name,input on_off_t enable,input string event_bind="DEFAULT");
    extern virtual function void set_mon_checks_enable( input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_sb_checks_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_if_checks_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_mon_cov_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");
    extern virtual function void set_if_cov_enable(input string   name, input on_off_t enable,input string   event_bind="DEFAULT");

    // ******************************************************************* 
    // *******User's Function and Task Declarations: *********************
    // *******************************************************************
    extern function void print_project();


    // automation macro
    `uvm_component_utils_begin(base_test)
    `uvm_component_utils_end
    
    // constructor
    function new(string name = "base_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create the test environment
        `uvm_info(get_type_name(),"****** Creating top_env class ******",UVM_LOW);
        top_env_h = top_env::type_id::create("top_env_h", this);

        // Enable transaction recording for everything
        // Change your recording cfg depend on test scenario
        uvm_config_db#(int)::set(this, "*", "recording_detail" , UVM_FULL); //UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_FULL

        // Create all config objects
        `uvm_info(get_type_name(),"****** Creating All base_cfg class ******",UVM_LOW);   
        reg_cfg_h = reg_pkg::reg_base_cfg::type_id::create("reg_cfg_h", this);
        apb_master_cfg_h = apb_master_pkg::apb_master_base_cfg::type_id::create("apb_master_cfg_h", this);
        ro_cfg_h = ro_pkg::ro_base_cfg::type_id::create("ro_cfg_h", this);
        uart_cfg_h = uart_pkg::uart_base_cfg::type_id::create("uart_cfg_h", this);
        efuse_cfg_h = efuse_pkg::efuse_base_cfg::type_id::create("efuse_cfg_h", this);
        
        // Set all config objects
        `uvm_info(get_type_name(),"****** Setting All base_cfg class ******",UVM_LOW);
`ifdef OPEN_EDA
        uvm_config_db #(reg_cfg_t)::set(uvm_root::get(),"*", "reg_cfg", reg_cfg_h);
`else
        uvm_config_db #(reg_pkg::reg_base_cfg)::set(uvm_root::get(),"*", "reg_cfg", reg_cfg_h);
`endif
`ifdef OPEN_EDA
        uvm_config_db #(apb_master_cfg_t)::set(uvm_root::get(),"*", "apb_master_cfg", apb_master_cfg_h);
`else
        uvm_config_db #(apb_master_pkg::apb_master_base_cfg)::set(uvm_root::get(),"*", "apb_master_cfg", apb_master_cfg_h);
`endif
`ifdef OPEN_EDA
        uvm_config_db #(ro_cfg_t)::set(uvm_root::get(),"*", "ro_cfg", ro_cfg_h);
`else
        uvm_config_db #(ro_pkg::ro_base_cfg)::set(uvm_root::get(),"*", "ro_cfg", ro_cfg_h);
`endif
`ifdef OPEN_EDA
        uvm_config_db #(uart_cfg_t)::set(uvm_root::get(),"*", "uart_cfg", uart_cfg_h);
`else
        uvm_config_db #(uart_pkg::uart_base_cfg)::set(uvm_root::get(),"*", "uart_cfg", uart_cfg_h);
`endif
`ifdef OPEN_EDA
        uvm_config_db #(efuse_cfg_t)::set(uvm_root::get(),"*", "efuse_cfg", efuse_cfg_h);
`else
        uvm_config_db #(efuse_pkg::efuse_base_cfg)::set(uvm_root::get(),"*", "efuse_cfg", efuse_cfg_h);
`endif

        // Set other objects
        uvm_config_db #(top_env)::set(uvm_root::get(),"*", "top_env", top_env_h);
        uvm_config_db#(logic)::set(this, "*", "check_input_enable", 1);
        uvm_config_db#(logic)::set(this, "*", "check_pad_enable", 1);


        // Get all virtual interfaces
        `uvm_info(get_type_name(),"****** Getting All the virtual interface ******",UVM_LOW);
        if (!uvm_config_db #(virtual interface top_if)::get(this, "", "top_vif", top_vif))
            `uvm_error("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface reg_if)::get(this, "", "reg_vif", reg_vif))
            `uvm_error("REG_VIF:ERROR", "VIF reg_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface apb_master_if)::get(this, "", "apb_master_vif", apb_master_vif))
            `uvm_error("APB_MASTER_VIF:ERROR", "VIF apb_master_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface ro_if)::get(this, "", "ro_vif", ro_vif))
            `uvm_error("RO_VIF:ERROR", "VIF ro_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface uart_if)::get(this, "", "uart_vif", uart_vif))
            `uvm_error("UART_VIF:ERROR", "VIF uart_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface efuse_if)::get(this, "", "efuse_vif", efuse_vif))
            `uvm_error("EFUSE_VIF:ERROR", "VIF efuse_vif is missing from config_db")

        start_time_int = wallclock();
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction : connect_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Prints the topology.
        uvm_top.print_topology();
        vseqr_h = top_env_h.vseqr_h;

    endfunction: end_of_elaboration_phase

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        // randomize all module base cfg
        reg_cfg_randomize();
        apb_master_cfg_randomize();
        ro_cfg_randomize();
        uart_cfg_randomize();
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
            //print_project();                      //need to be updated
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
            //init_seq.start(vseqr_h);
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

endclass : base_test


// Randomization functions
function void base_test::reg_cfg_randomize();
    if(reg_cfg_h.randomize())
        `uvm_info(get_type_name(),reg_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"reg_cfg_h randomization failed")
endfunction

function void base_test::apb_master_cfg_randomize();
    if(apb_master_cfg_h.randomize())
        `uvm_info(get_type_name(),apb_master_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"apb_master_cfg_h randomization failed")
endfunction

function void base_test::ro_cfg_randomize();
    if(ro_cfg_h.randomize())
        `uvm_info(get_type_name(),ro_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"ro_cfg_h randomization failed")
endfunction

function void base_test::uart_cfg_randomize();
    if(uart_cfg_h.randomize())
        `uvm_info(get_type_name(),uart_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"uart_cfg_h randomization failed")
endfunction

function void base_test::efuse_cfg_randomize();
    if(efuse_cfg_h.randomize())
        `uvm_info(get_type_name(),efuse_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"efuse_cfg_h randomization failed")
endfunction


// User's other randomization functions

// cfg override function
function void base_test::set_reg_cfg_type(input string reg_cfg_override, bit replace=1);
    set_type_override("reg_base_cfg", reg_cfg_override, replace);
endfunction

function void base_test::set_apb_master_cfg_type(input string apb_master_cfg_override, bit replace=1);
    set_type_override("apb_master_base_cfg", apb_master_cfg_override, replace);
endfunction

function void base_test::set_ro_cfg_type(input string ro_cfg_override, bit replace=1);
    set_type_override("ro_base_cfg", ro_cfg_override, replace);
endfunction

function void base_test::set_uart_cfg_type(input string uart_cfg_override, bit replace=1);
    set_type_override("uart_base_cfg", uart_cfg_override, replace);
endfunction

function void base_test::set_efuse_cfg_type(input string efuse_cfg_override, bit replace=1);
    set_type_override("efuse_base_cfg", efuse_cfg_override, replace);
endfunction


// User's other cfg override function


// global check setting function

function void base_test::set_enable_flag_debug();
        string   name;   
        foreach(MON_CHECKS_ENABLE[name]) begin
            `uvm_info(report_id,$sformatf("MON_CHECKS_ENABLE[%s]=%b",name,MON_CHECKS_ENABLE[name]),UVM_LOW)
        end
        foreach(MON_COVERAGE_ENABLE[name]) begin
            `uvm_info(report_id,$sformatf("MON_COVERAGE_ENABLE[%s]=%b",name,MON_COVERAGE_ENABLE[name]),UVM_LOW)
        end
        foreach(SB_CHECKS_ENABLE[name]) begin
            `uvm_info(report_id,$sformatf("SB_CHECKS_ENABLE[%s]=%b",name,SB_CHECKS_ENABLE[name]),UVM_LOW)
        end
        foreach(IF_CHECKS_ENABLE[name]) begin
            `uvm_info(report_id,$sformatf("IF_CHECKS_ENABLE[%s]=%b",name,IF_CHECKS_ENABLE[name]),UVM_LOW)
        end
        foreach(IF_COVERAGE_ENABLE[name]) begin
            `uvm_info(report_id,$sformatf("IF_COVERAGE_ENABLE[%s]=%b",name,IF_COVERAGE_ENABLE[name]),UVM_LOW)
        end
endfunction


function void base_test::set_enable(input string   array_name,
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

function void base_test::set_mon_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon check for %s",name),UVM_LOW)
        set_enable(.array_name("MON_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));
endfunction: set_mon_checks_enable    

function void base_test::set_sb_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting sb check for %s",name),UVM_LOW)
        set_enable(.array_name("SB_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind) );

endfunction: set_sb_checks_enable

function void base_test::set_if_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if check for %s",name),UVM_LOW)
        set_enable(.array_name("IF_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_checks_enable

function void base_test::set_mon_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon cov for %s",name),UVM_LOW)
        set_enable(.array_name("MON_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_mon_cov_enable

function void base_test::set_if_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if cov for %s",name),UVM_LOW)
        set_enable(.array_name("IF_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_cov_enable


// *************************************************************
// *******function and task defination: ************************
// *************************************************************

function void base_test::print_project();
    integer fp;
    integer code;
    string v_name;
    string project_name;
    $display("*************************************************************");
    $display("**                    Project Checking                     **");
    $display("*************************************************************");
    fp = $fopen("project_name", "r");
    if(fp == 'h0) begin
        $display("Error, Can not open project_name!");
        $finish;
    end
    else begin
        code = $fgets( v_name, fp );
        //$display("code is %d,v_name is %s",code,v_name);
        project_name = v_name.substr(0, v_name.len() - 2);
        $display("    |-Chip is %s", project_name);
        $fclose(fp);
    end
endfunction

`endif //`ifndef __BASE_TEST_SV_
