#!/usr/bin/env python3
################################################################################
#
# UVM Environment Auto Generation Script
# function: 
#       1. Support the invocation of gen_uvc to generate multiple modules
#       2. Generate a complete base_sequence template, including multi-module configuration
#       3. Generate a complete base_test template, including multi-module configuration
# Usage:
#       1.python gen_uvm_env.py --gcfg
#       2.python gen_uvm_env.py -c <config_file.json> --guvc
#       3.python gen_uvm_env.py --guvc -c <config_file.json> --overwrite
# Author: Mr Wang
################################################################################

import os
import sys
import json
import argparse
import re
import subprocess
import shutil
from datetime import datetime

def get_base_sequence_template():
    return '''`ifndef __{name_upper}_SEQ_SV_
`define __{name_upper}_SEQ_SV_

import global_pkg::*;{bseq_reg_import}

class {name}_seq extends uvm_sequence;

    {env_name}_env {env_name}_env_h;
    // Virtual interface declarations
{vif_declarations}

    // Other virtual interface declarations

    // Config declarations
{cfg_declarations}

    // RAL_model-relative declarations
    {bseq_ral_decl}
    uvm_status_e status;
    rand uvm_reg_data_t data;

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils({name}_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="{name}_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting {name}_seq", UVM_MEDIUM)
        if (!uvm_config_db #({env_name}_env)::get(m_sequencer, "", "{env_name}_env", {env_name}_env_h))
            `uvm_error("{env_name_upper}_ENV:ERROR", "Env {env_name}_env is missing from config_db")
{vif_get}
        // Get other vitual interface


{cfg_get}
        // Get other cfg


        // Get reg-model handle
        {bseq_ral_assign}

    endtask

    virtual task body();
        //super.body();


    endtask

    virtual task post_body();
        //super.post_body();
        `uvm_info(get_type_name(), "{name}_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  DEFINE YOUR GLOBAL TASKS AND FUNCTIONS   **
    //*************************************************

    virtual task wait_cycles(input bit[31:0] n_cycles);
        repeat(n_cycles) @(posedge top_vif.clk);
    endtask: wait_cycles

    virtual task wait_rst_n();
        wait(top_vif.rst == 1'b1);
    endtask: wait_rst_n




// inlcude each module comm task and functions
{inlcude_module_base_seq}

endclass: {name}_seq
`endif
'''

def get_block_base_sequence_template():
    return '''import uvm_pkg::*;
class {name}_block_base_seq extends uvm_sequence;

    // Virtual interface declarations
    virtual interface {name}_if {name}_vif;
    // Other virtual interface declarations

    // Config declarations
    {name}_pkg::{name}_base_cfg {name}_cfg_h;
`ifdef OPEN_EDA
    typedef {name}_pkg::{name}_base_cfg {name}_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif

    {seq_ral_decl}

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils({name}_block_base_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="{name}_block_base_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();

        if (!uvm_config_db #(virtual interface {name}_if)::get(m_sequencer, "","{name}_vif", {name}_vif))
            `uvm_error("{name_upper}_VIF:ERROR", "VIF {name}_vif is missing from config_db")    
        // Get other vitual interface

`ifdef OPEN_EDA
        if (!uvm_config_db #({name}_cfg_t)::get(m_sequencer, "", "{name}_cfg", {name}_cfg_h))begin
`else
        if (!uvm_config_db #({name}_pkg::{name}_base_cfg)::get(m_sequencer, "", "{name}_cfg", {name}_cfg_h))begin
`endif
            `uvm_warning("{name_upper}_CFG:WARNING", "CFG {name}_cfg is missing from config_db,using default")
            {name}_cfg_h = new();
        end

        // Get other cfg

        {seq_ral_fetch}

    endtask

    virtual task body();
        // super.body();
        `uvm_info(get_type_name(), "Starting {name}_block_base_seq", UVM_MEDIUM)

    endtask

    virtual task post_body();
        // super.post_body();
        `uvm_info(get_type_name(), "{name}_block_base_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  DEFINE YOUR {name_upper} COMMON TASKS AND FUNCTIONS   **
    //*************************************************


endclass: {name}_block_base_seq

/*  ====================================================================================  */
//  All {name} block sequence classes must inherit from the base class {name}_block_base_seq
/*  ====================================================================================  */

class {name}_smoke_block_seq extends {name}_block_base_seq;
    `uvm_object_utils({name}_smoke_block_seq)

    function new(string name="{name}_smoke_block_seq");
        super.new(name);
    endfunction : new

    task pre_body();
            super.pre_body();
    endtask

    task body();
        super.body(); 
        `uvm_info(get_type_name(), "{name}_smoke_block_seq start", UVM_MEDIUM);
    
        `uvm_info(get_type_name(), "{name}_smoke_block_seq end", UVM_MEDIUM);

    endtask

    task post_body();
        super.post_body();
    endtask

endclass


'''


def get_seq_lib_template():
    return '''/*  ============================================================  */
/*  **  manage all module sequence                              ***/
/*  ============================================================  */
`include "{seq_name}_seq.sv"
{inlude_seq_lib}
'''


def get_naming_template():
    return '''/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your {name} sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class {name}_seq extends base_seq;

    `uvm_object_utils({name}_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="{name}_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting {name}_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        

    endtask

    task post_body();
        `uvm_info(get_type_name(), "Ending {name}_seq ", UVM_MEDIUM);
        super.post_body();
    endtask

endclass

'''


def get_module_seq_template():
    return '''/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your {name} sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class {name}_base_seq extends base_seq;

    `uvm_object_utils({name}_base_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="{name}_base_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting {name}_base_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        // build your common cfg or init operation here

    endtask

    task post_body();
        `uvm_info(get_type_name(), "Ending {name}_base_seq ", UVM_MEDIUM);
        super.post_body();
    endtask

endclass


/*  ====================================================================================  */
//  All {name} sequence classes must inherit from the base class {name}_base_seq
/*  ====================================================================================  */

class {name}_smoke_seq extends {name}_base_seq;
    `uvm_object_utils({name}_smoke_seq)

    function new(string name="{name}_smoke_seq");
        super.new(name);
    endfunction : new

    task pre_body();
            super.pre_body();
    endtask

    task body();
        super.body(); 
        `uvm_info(get_type_name(), "{name}_smoke_seq start", UVM_MEDIUM);
    
        `uvm_info(get_type_name(), "{name}_smoke_seq end", UVM_MEDIUM);

    endtask

    task post_body();
        super.post_body();
    endtask

endclass

'''

def get_module_base_seq_template():
    return '''/*  ============================================================  */
/*  ============================================================  */
/*  **  Define your {name}-relative global common methods here ** */
/*  **  If not needed, the file can be removed                 ** */
/*  ============================================================  */
/*  ============================================================  */
'''


def get_module_test_template():
    return '''
class {name}_base_test extends base_test;

    string report_id = "{name}_base_test";
    // automation macro
    `uvm_component_utils_begin({name}_base_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "{name}_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
    begin
        super.build_phase(phase);
    end
    endfunction: build_phase

    task main_phase(uvm_phase phase);
        super.main_phase(phase);
    endtask

endclass : {name}_base_test

class {name}_smoke_test extends {name}_base_test;

    string report_id = "{name}_smoke_test"; 
    // automation macro
    `uvm_component_utils_begin({name}_smoke_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "{name}_smoke_test",uvm_component parent);
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
        //set_if_checks_enable(.name("{name}_if"),.enable(OFF));
        //set_if_cov_enable(.name("{name}_if"),.enable(OFF));
        //set_mon_checks_enable(.name("{name}_monitor_h"),.enable(OFF));
        //set_mon_cov_enable(.name("{name}_monitor_h"),.enable(OFF));
        //set_sb_checks_enable(.name("{name}_scoreboard_h"),.enable(OFF));

    endfunction: start_of_simulation_phase

    task main_phase(uvm_phase phase);
 
        {name}_smoke_seq   seq;
        phase.raise_objection(this);
        seq = {name}_smoke_seq::type_id::create("{name}_smoke_seq");
        seq.start(vseqr_h.{name}_seqr_h);
        phase.drop_objection(this);

    endtask
    
endclass : {name}_smoke_test

'''


def get_base_test_template():
    return '''`ifndef __{name_upper}_TEST_SV_
`define __{name_upper}_TEST_SV_

import "DPI-C" function int wallclock();

class {name}_test extends uvm_test;

    int unsigned start_time_int;
    int unsigned end_time_int;
    string start_time_str;
    string end_time_str;

    {env_name}_env {env_name}_env_h;
    top_virtual_sequencer vseqr_h;
    
    // Virtual interface declarations
{vif_declarations}
    // Other virtual interface declarations



    // Config declarations
{cfg_declarations}

    // randomize declarations
{randomize_declaration}

    // cfg override declarations
{cfg_override_declarations}
    
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
    `uvm_component_utils_begin({name}_test)
    `uvm_component_utils_end
    
    // constructor
    function new(string name = "{name}_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create the test environment
        `uvm_info(get_type_name(),"****** Creating {env_name}_env class ******",UVM_LOW);
        {env_name}_env_h = {env_name}_env::type_id::create("{env_name}_env_h", this);

        // Enable transaction recording for everything
        // Change your recording cfg depend on test scenario
        uvm_config_db#(int)::set(this, "*", "recording_detail" , UVM_FULL); //UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_FULL

        // Create all config objects
        `uvm_info(get_type_name(),"****** Creating All base_cfg class ******",UVM_LOW);   
{cfg_create}
        
        // Set all config objects
        `uvm_info(get_type_name(),"****** Setting All base_cfg class ******",UVM_LOW);
{cfg_set}

        // Set other objects
        uvm_config_db #({env_name}_env)::set(uvm_root::get(),"*", "{env_name}_env", {env_name}_env_h);
        uvm_config_db#(logic)::set(this, "*", "check_input_enable", 1);
        uvm_config_db#(logic)::set(this, "*", "check_pad_enable", 1);


        // Get all virtual interfaces
        `uvm_info(get_type_name(),"****** Getting All the virtual interface ******",UVM_LOW);
{vif_get}

        start_time_int = wallclock();
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction : connect_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Prints the topology.
        uvm_top.print_topology();
        vseqr_h = {env_name}_env_h.vseqr_h;

    endfunction: end_of_elaboration_phase

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        // randomize all module base cfg
{randomize_calls}

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

endclass : {name}_test


// Randomization functions
{randomize_functions}

// User's other randomization functions

// cfg override function
{cfg_override_functions}

// User's other cfg override function


// global check setting function

function void {name}_test::set_enable_flag_debug();
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


function void {name}_test::set_enable(input string   array_name,
                         input string   index_name,
                         input on_off_t enable,
                         input string event_bind="DEFAULT");

    string   name;   
    if(event_bind == "DEFAULT")begin
        case (array_name)
            "MON_CHECKS_ENABLE":
                if ( MON_CHECKS_ENABLE.exists(index_name) ) begin
                    MON_CHECKS_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting MON_CHECKS_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting SB_CHECKS_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting MON_COVERAGE_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting IF_CHECKS_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting IF_COVERAGE_ENABLE[%s] = %b\\n",
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

function void {name}_test::set_mon_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon check for %s",name),UVM_LOW)
        set_enable(.array_name("MON_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));
endfunction: set_mon_checks_enable    

function void {name}_test::set_sb_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting sb check for %s",name),UVM_LOW)
        set_enable(.array_name("SB_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind) );

endfunction: set_sb_checks_enable

function void {name}_test::set_if_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if check for %s",name),UVM_LOW)
        set_enable(.array_name("IF_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_checks_enable

function void {name}_test::set_mon_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon cov for %s",name),UVM_LOW)
        set_enable(.array_name("MON_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_mon_cov_enable

function void {name}_test::set_if_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if cov for %s",name),UVM_LOW)
        set_enable(.array_name("IF_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_cov_enable


// *************************************************************
// *******function and task defination: ************************
// *************************************************************

function void {name}_test::print_project();
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

`endif //`ifndef __{name_upper}_TEST_SV_
'''

def get_top_ral_snippets(enable_ral, env_name='top'):
    """Chip-level RAL wiring for the system flow (top_env / top_vseqr / base_seq / uvm.f).
    The system has ONE chip model built from the whole reg table CSV - per-module
    enable_ral has no system-level meaning; this flag is chip-global."""
    if enable_ral:
        return {
            "top_ral_decl":    "// register model object declaration" + chr(10) +
                               "    RAL_PKG::ral_gen_main " + chr(9) + "ral;",
            "top_ral_build":   "// Create RAL model and cfg db setting" + chr(10) +
                               '        ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);' + chr(10) +
                               '        ral.configure(null, "");' + chr(10) +
                               "        ral.build();" + chr(10) +
                               "        ral.set_coverage(UVM_CVR_ALL);" + chr(10) +
                               "        ral.lock_model();" + chr(10) +
                               "        ral.reset();" + chr(10) +
                               '        ral.set_hdl_path_root("tb_top.C[0].btnode.btc"); //need to be updated' + chr(10) +
                               chr(10) +
                               '        uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(), "*", "ral", ral);',
            "top_ral_connect": "vseqr_h.ral = this.ral;",
            # no leading indentation: the template placeholders carry it
            "vsqr_ral_decl":   "RAL_PKG::ral_gen_main " + chr(9) + "ral;",
            "bseq_ral_decl":   "RAL_PKG::ral_gen_main ral;",
            "bseq_ral_assign": "ral = " + env_name + "_env_h.ral;",
            "bseq_reg_import": chr(10) + "import reg_mdl_pkg::*;",
            "flist_ral":       "../../../verify/utils/reg/reg_mdl_pkg.sv" + chr(10) +
                               "../../../verify/ral/ral_reg_model.sv",
        }
    return {
        "top_ral_decl":    "// no chip RAL: enable_ral is false at config top level",
        "top_ral_build":   "// no chip RAL model created (enable_ral is false)",
        "top_ral_connect": "// no RAL: vseqr carries no model handle",
        "vsqr_ral_decl":   "// no chip RAL: enable_ral is false at config top level",
        "bseq_ral_decl":   "// no chip RAL: enable_ral is false at config top level",
        "bseq_ral_assign": "        // no RAL: no model handle",
        "bseq_reg_import": "",
        "flist_ral":       "",
    }


def get_block_test_ral_snippets(enable_ral):
    """RAL wiring for the block base test/seq and the block uvm.f filelist.
    RAL_PKG (ral_reg_model.sv) and reg_mdl_pkg only exist when the RAL model is
    generated, so ral-disabled modules must not reference them."""
    if enable_ral:
        return {
            "ral_handle":    "RAL_PKG::ral_gen_main                       ral;",
            "ral_build":     "// Create RAL model and cfg db setting" + chr(10) +
                             '        ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);' + chr(10) +
                             '        ral.configure(null, "");' + chr(10) +
                             "        ral.build();" + chr(10) +
                             "        ral.set_coverage(UVM_CVR_ALL);" + chr(10) +
                             "        ral.lock_model();" + chr(10) +
                             "        ral.reset();" + chr(10) +
                             '        ral.set_hdl_path_root("tb_top"); //need to be updated' + chr(10) +
                             chr(10) +
                             '        uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(), "*", "ral", ral);',
            "ral_predict":   "ral.default_map.set_auto_predict(1);",
            "seq_ral_decl":  "// RAL_model-relative declarations" + chr(10) +
                             "    RAL_PKG::ral_gen_main ral;" + chr(10) +
                             "    uvm_status_e status;" + chr(10) +
                             "    rand uvm_reg_data_t data;",
            "seq_ral_fetch": "// Get reg-model handle" + chr(10) +
                             '        if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(m_sequencer,"", "ral" ,ral))' + chr(10) +
                             '            `uvm_error(get_full_name(), "Ral handle missing")',
            "flist_ral":     "../../../verify/utils/reg/reg_mdl_pkg.sv" + chr(10) +
                             "../../../verify/ral/ral_reg_model.sv",
        }
    return {
        "ral_handle":    "// no RAL: enable_ral is false for this module",
        "ral_build":     "// no RAL model created (enable_ral is false)",
        "ral_predict":   "// no RAL: auto-predict not wired",
        "seq_ral_decl":  "// no RAL: register front-door/backdoor not used",
        "seq_ral_fetch": "",
        "flist_ral":     "",
    }


def get_block_test_adapter_snippets(name, bus_type, adapter_type):
    """Adapter wiring for <name>_block_base_test. The adapter class (and its pkg include) only
    exists when adapter_type is non-empty, so the test must not reference it otherwise."""
    if adapter_type:
        return {
            "adapter_decl":    f"{name}_pkg::{name}_reg2{bus_type}_adapter   {name}_adapter_h;",
            "adapter_create":  f"// create adapter\n        {name}_adapter_h = {name}_pkg::{name}_reg2{bus_type}_adapter::type_id::create(\"{name}_adapter_h\", this);",
            "adapter_connect": f"ral.default_map.set_sequencer({name}_env_h.vseqr_h, {name}_adapter_h);",
        }
    return {
        "adapter_decl":    "// no adapter: adapter_type is empty for this module",
        "adapter_create":  "// no adapter created (adapter_type is empty)",
        "adapter_connect": "// no adapter: RAL map has no bus sequencer, register front-door access is not wired",
    }


def get_block_base_test_template():
    return '''import "DPI-C" function int wallclock();
import global_pkg::*;
class {name}_block_base_test extends uvm_test;

    int unsigned start_time_int;
    int unsigned end_time_int;
    string start_time_str;
    string end_time_str;

    {name}_pkg::{name}_env                      {name}_env_h;
    {ral_handle}
    {adapter_decl}

    // Virtual interface declarations
    virtual interface {name}_if {name}_vif;
    // Other virtual interface declarations

    // Config declarations
    {name}_pkg::{name}_base_cfg {name}_cfg_h;
`ifdef OPEN_EDA
    typedef {name}_pkg::{name}_base_cfg {name}_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif

    // randomize declarations
    extern virtual function void {name}_cfg_randomize();

    // cfg override declarations
    extern virtual function void set_{name}_cfg_type(input string {name}_cfg_override, bit replace=1);

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
    `uvm_component_utils_begin({name}_block_base_test)
    `uvm_component_utils_end
    
    // constructor
    function new(string name = "{name}_block_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable transaction recording for everything
        // Change your recording cfg depend on test scenario
        uvm_config_db#(int)::set(this, "*", "recording_detail" , UVM_FULL); //UVM_NONE,UVM_LOW,UVM_MEDIUM,UVM_FULL

        // Create the test environment
        `uvm_info(get_type_name(),"****** Creating {name}_env class ******",UVM_LOW);
        {name}_env_h = {name}_pkg::{name}_env::type_id::create("{name}_env_h", this);
        {name}_env_h.drv_is_active = UVM_ACTIVE;
        
        {adapter_create}

        // Create all config objects
        `uvm_info(get_type_name(),"****** Creating All base_cfg class ******",UVM_LOW);   
        {name}_cfg_h = {name}_pkg::{name}_base_cfg::type_id::create("{name}_cfg_h", this);
        // Set all config objects
        `uvm_info(get_type_name(),"****** Setting All base_cfg class ******",UVM_LOW);
`ifdef OPEN_EDA
        uvm_config_db #({name}_cfg_t)::set(uvm_root::get(),"*", "{name}_cfg", {name}_cfg_h);
`else
        uvm_config_db #({name}_pkg::{name}_base_cfg)::set(uvm_root::get(),"*", "{name}_cfg", {name}_cfg_h);
`endif

        // Set other objects

        // Get all virtual interfaces
        `uvm_info(get_type_name(),"****** Getting All the virtual interface ******",UVM_LOW);
        if (!uvm_config_db #(virtual interface {name}_if)::get(this, "", "{name}_vif", {name}_vif))
            `uvm_error("{name_upper}_VIF:ERROR", "VIF {name}_vif is missing from config_db")

        start_time_int = wallclock();

        {ral_build}


    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //set regmodel prediction
        {adapter_connect}
        {ral_predict}

    endfunction : connect_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Prints the topology.
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        // randomize all module base cfg
        {name}_cfg_randomize();
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
            //init_seq.start({name}_env_h.vseqr_h);
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

endclass : {name}_block_base_test


// Randomization functions

function void {name}_block_base_test::{name}_cfg_randomize();
    if({name}_cfg_h.randomize())
        `uvm_info(get_type_name(),{name}_cfg_h.sprint(),UVM_MEDIUM)
    else
        `uvm_fatal(get_type_name(),"{name}_cfg_h randomization failed")
endfunction

// User's other randomization functions

// cfg override function

function void {name}_block_base_test::set_{name}_cfg_type(input string {name}_cfg_override, bit replace=1);
    set_type_override("{name}_base_cfg", {name}_cfg_override, replace);
endfunction

// User's other cfg override function


// global check setting function
function void {name}_block_base_test::set_enable(input string   array_name,
                         input string   index_name,
                         input on_off_t enable,
                         input string event_bind="DEFAULT");

    string   name;   
    if(event_bind == "DEFAULT")begin
        case (array_name)
            "MON_CHECKS_ENABLE":
                if ( MON_CHECKS_ENABLE.exists(index_name) ) begin
                    MON_CHECKS_ENABLE[index_name] = (enable==ON);
                    `uvm_info(report_id,$sformatf("Setting MON_CHECKS_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting SB_CHECKS_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting MON_COVERAGE_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting IF_CHECKS_ENABLE[%s] = %b\\n",
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
                    `uvm_info(report_id,$sformatf("Setting IF_COVERAGE_ENABLE[%s] = %b\\n",
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

function void {name}_block_base_test::set_mon_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon check for %s",name),UVM_LOW)
        set_enable(.array_name("MON_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));
endfunction: set_mon_checks_enable    

function void {name}_block_base_test::set_sb_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting sb check for %s",name),UVM_LOW)
        set_enable(.array_name("SB_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind) );

endfunction: set_sb_checks_enable

function void {name}_block_base_test::set_if_checks_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if check for %s",name),UVM_LOW)
        set_enable(.array_name("IF_CHECKS_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_checks_enable

function void {name}_block_base_test::set_mon_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting mon cov for %s",name),UVM_LOW)
        set_enable(.array_name("MON_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_mon_cov_enable

function void {name}_block_base_test::set_if_cov_enable(input string   name,input on_off_t enable,input string   event_bind="DEFAULT");

        `uvm_info(get_full_name(),$psprintf("setting if cov for %s",name),UVM_LOW)
        set_enable(.array_name("IF_COVERAGE_ENABLE"),.index_name(name),.enable(enable),.event_bind(event_bind));

endfunction: set_if_cov_enable


// *************************************************************
// *******function and task defination: ************************
// *************************************************************


/*  ====================================================================================  */
//  All {name} block test classes must inherit from the base class {name}_block_base_test
/*  ====================================================================================  */



class {name}_smoke_block_test extends {name}_block_base_test;

    string report_id = "{name}_smoke_block_test"; 
    // automation macro
    `uvm_component_utils_begin({name}_smoke_block_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "{name}_smoke_block_test",uvm_component parent);
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
        //set_if_checks_enable(.name("{name}_if"),.enable(OFF));
        //set_if_cov_enable(.name("{name}_if"),.enable(OFF));
        //set_mon_checks_enable(.name("{name}_monitor_h"),.enable(OFF));
        //set_mon_cov_enable(.name("{name}_monitor_h"),.enable(OFF));
        //set_sb_checks_enable(.name("{name}_scoreboard_h"),.enable(OFF));

    endfunction: start_of_simulation_phase

    task main_phase(uvm_phase phase);
 
        {name}_smoke_block_seq   seq;
        phase.raise_objection(this);
        seq = {name}_smoke_block_seq::type_id::create("{name}_smoke_block_seq");
        seq.start({name}_env_h.vseqr_h);
        phase.drop_objection(this);

    endtask
    
endclass : {name}_smoke_block_test



'''

def get_top_env_template():
    return '''`ifndef __{env_name_upper}_ENV__SVH__
`define __{env_name_upper}_ENV__SVH__

class {env_name}_env extends uvm_env;

    `uvm_component_utils({env_name}_env)
    string      report_id = "{env_name}_env";

    {top_ral_decl}
    
    // top_virtual_sequencer declaration
    top_virtual_sequencer   vseqr_h;

    // module envs declarations
{env_declarations}

    // add reg-model-relative component declaration  



    // add VIP-relative component declaration  


    // new constructor
    function new(string name = "{env_name}_env" , uvm_component parent = null);
        super.new(name , parent);
    endfunction

    // build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `ifdef UVM_ERR_QUIT_COUNT
            uvm_report_server::get_server().set_max_quit_count(`UVM_ERR_QUIT_COUNT);
        `endif
        // Create all module envs
{envs_create}
        
        // Setting the active driver
{env_drv_mode}

        // Create reg-model related component 



        // Create VIP-relative component  
        

        // build the virtual sequencer
        vseqr_h = top_virtual_sequencer::type_id::create("vseqr_h", this); 

        {top_ral_build}

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        {top_ral_connect}
        // connect virtual sequencer to subsequencers
{vsqr_connect}


        // top connect between different module component  



        // ---------------------------------------------
        // RAL MODEL: for top different driver 
        // 1, map.set_sequencer 
        // 2, connect adapter to predictor
        // 3, connect bus_in port of predictor to adapter_ap
        // 4, set predictoon mothod (implicit or explicit)
        // 5, connect ral.map to predictor
        // ---------------------------------------------
        // connect reg-model-relative component    


        // connect VIP-relative component 



    endfunction

endclass
`endif // __{env_name_upper}_ENV__SVH__
'''

def get_top_pkg_template():
    
    return '''`ifndef __TOP_PKG__SV__
`define __TOP_PKG__SV__

`include "uvm_macros.svh"
`ifndef OPEN_EDA
`include "uvm_pkg.sv"
`endif

package top_pkg;
  import uvm_pkg::*;
  import global_pkg::*;
  //import reg_addr::*;         //USE YOUR REG DEFINE PKG IF YOU HAS ONE
  import base_uvc_pkg::*;

  //import all module pkg
{import_module_pkg}

  //add VIP-relative pkg begin


  //add VIP-relative pkg end

  `include "top_vseqr.sv"
  `include "{env_name}_env.sv"
  `include "{pid}_sequence_lib.sv"
  

  //include all module test
  `include "{test_name}_test.sv"
{include_mudule_test}

  //add VIP-relative test begin

  //add VIP-relative test end

  


endpackage: top_pkg
`endif //`ifndef __TOP_PKG__SV__
'''

def get_top_vsqr_template():
    
    return '''`ifndef __TOP_VIRTUAL_SEQUENCER__SVH__
`define __TOP_VIRTUAL_SEQUENCER__SVH__

class top_virtual_sequencer extends uvm_sequencer;

  //Control subsequences for convenient coordination and management

  // instance register model object
  {vsqr_ral_decl}
  // module squencer declaration
{seqr_declaration}
  
  //UVM automation macros for sequencers
  `uvm_component_utils_begin(top_virtual_sequencer)
{seqr_automation}
  `uvm_component_utils_end


  // constructor
  function new(string name = "top_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass
`endif // __TOP_VIRTUAL_SEQUENCER__SVH__
'''

def get_if_coon_template():
    return '''//The current file is used to connect DUT with testbeach under Gray-Box verify
//================================================================================================================
//======Strictly follow the signal classification among black-box signals ,gray-box signals, white-box signals====
//================================================================================================================


// Part 1
//================================================================================================================
//=========================================black-box signals begin================================================
// ******include Module input/output port signals in DUT *******
//================================================================================================================
// Black-box: one net per DUT port, named dut_<port>; the DUT instance in the tb top binds to them.
// The direction of each assign follows the port; adapt polarity or width here, not at the DUT.
//   wire [31:0] dut_addr;  assign dut_addr  = {module_name}_pif.addr;    // DUT input  <- interface
//   wire [31:0] dut_rdata; assign {module_name}_pif.rdata = dut_rdata;   // DUT output -> interface
//   wire        dut_rst_n; assign dut_rst_n = ~{module_name}_pif.rst;    // active-low reset
// The _gpls variant connects the netlist ports (e.g. bit-blasted buses) the same way.









//================================================================================================================
//=========================================black-box signals end==================================================
//================================================================================================================

// Part 2
//================================================================================================================
//=========================================gray-box signals begin=================================================
// ******include Key signal in DUT,Such as ctrl-reg,FSM-signal,flag bit*******
// ***   such signal for block-verify, asssertion check,or coverage sample ***
// ***   NOTE: coverage sample should skip GPLS 
//================================================================================================================
// Gray-box: hierarchical reads of key internals (RTL only - leave them out of the _gpls variant), e.g.
//   assign {module_name}_pif.fsm_state = u_<dut>.u_ctrl.state;









//================================================================================================================
//=========================================gray-box signals end===================================================
//================================================================================================================

// Part 3
//================================================================================================================
//=========================================white-box signals begin================================================
// ******include internal signal in DUT,Strongly related to design logic*******
// ***   submudule signals,gate-level signals,Fault-injection signals,debug signals...
// ***   NOTE: GPLS should consider the necessity of this signals
//================================================================================================================







//================================================================================================================
//=========================================white-box signals end==================================================
//================================================================================================================


'''


def get_tif_template():
    
    return '''interface {name}_if ();

  import uvm_pkg::*;
  import global_pkg::*;
  //import reg_addr::*;      //USE YOUR REG DEFINE PKG IF YOU HAS ONE
  string report_id = "{name}_if";
    
  logic checks_enable;      
  logic coverage_enable;    
  logic rst;
  logic clk;
  logic card_sel;
  logic[31:0] {name}_ctrl;

  initial begin
      IF_CHECKS_ENABLE["{name}_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["{name}_if"] = 1'b1;   //initially on
      checks_enable   = 1'b1;                   //initially on
      coverage_enable = 1'b1;                   //initially on
  end

  //Real-time update of the flag signal in specific test scenarios
  always@(IF_CHECKS_ENABLE["{name}_if"]) checks_enable = IF_CHECKS_ENABLE["{name}_if"];
  always@(IF_COVERAGE_ENABLE["{name}_if"]) coverage_enable = IF_COVERAGE_ENABLE["{name}_if"];
  //add common interface signal here

 `include "{name}_if_pc.sv" //maybe need to update
endinterface : {name}_if
'''

def get_testjson_template():
    return '''{{
	"UVM_VCS_MACRO_OPT": "+UVM_NO_DEPRECATED",
	"GLOBAL_VCS_MACOR_OPT": "+USE_RAL_MODEL+SIM_RAMDOM+UVM_ERR_QUIT_COUNT=100",
	"REAL_CORE_OPT":"",
	"modules":
    {{  
{modulelst}
	}}
}}
'''

def get_mjson_template():
    return '''{{
    "name":"{module_name}",
    "COMMON_VCS_MACRO_OPT":"+COM_DEFINE1+COM_DEFINE2",
    "tests":
    {{
    "{module_name}_smoke_test":
        {{
            "stage1":"true",
			"stage2":"false",
			"smoke":"true",
			"full":"true",
			"codecoverage":"true",
			"iteration":"1",
			"UVM_TESTNAME":"{module_name}_smoke_test",
			"VCS_MACRO_OPT":"+DEFINE1+DEFINE2+DEFINE3=100",
			"VCS_PLUSARGS_OPT":"+PLUSARGS1+PLUSARG2"
        }},
    "{module_name}_smoke_block_test":
        {{
            "stage1":"true",
			"stage2":"false",
			"smoke":"true",
			"full":"true",
			"codecoverage":"true",
			"iteration":"1",
			"UVM_TESTNAME":"{module_name}_smoke_block_test",
			"VCS_MACRO_OPT":"+{module_name_upper}_BLOCK_TEST+DEFINE1+DEFINE2+DEFINE3=100",
			"VCS_PLUSARGS_OPT":"+PLUSARGS1+PLUSARG2"
        }},
    "{module_name}_random1_test":
        {{
            "stage1":"false",
			"stage2":"true",
			"smoke":"false",
			"full":"true",
			"codecoverage":"true",
			"iteration":"6",
			"UVM_TESTNAME":"{module_name}_random_test",
			"VCS_MACRO_OPT":"+DEFINE1+DEFINE2+DEFINE3=100",
			"VCS_PLUSARGS_OPT":"+PLUSARGS1+PLUSARG2"
        }},
    "{module_name}_random2_test":
        {{
            "stage1":"false",
			"stage2":"true",
			"smoke":"false",
			"full":"true",
			"codecoverage":"true",
			"iteration":"10",
			"UVM_TESTNAME":"{module_name}_random_test",
			"VCS_MACRO_OPT":"+DEFINE4",
			"VCS_PLUSARGS_OPT":""
        }}
	}}
}}
'''
def get_vif_declare():
    return '''//========================================
//==   instance all module interface    ==
//==   vitual if declaration            ==
//========================================
{if_instance}
// Other Interface Instances

{vif_declare}
// Other Vitual Interface Declare 

// Vif assignment and config_db set run in one initial block: the handles must
// be assigned before they are published, independent of initial-block order.
initial begin
{vif_init}
	// Other Vitual Interface Initialization

	// TB Top set inteface
{vif_set}
    //Other Vitual Interface Setting

end

'''

def get_tb_top():
    return '''//==============================================
//=======System-level Tb for {pid}   ===========
//==============================================

`timescale 1ns/1ps
module tb_top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import tb-relative pkg


    // import dut-relative pkg


    // include tb-relative file
    `include "vif_declare.sv"
    `include "dump_wave.sv" 



    // Setting time display format
    initial begin
        $timeformat(-9, 3, "ns", 10);
    end

    // Setting Rst initial config and signal connection




    // Setting Clkgen initial config and signal connection



    // DUT instance and signal connection 



    // Setting UPF initial config



    // Module < if_conn >  instantiation 
    if_conn if_conn();                                       


    `ifndef OPEN_EDA
    // Program  < sdf_annotate >  instantiation 
    sdf_annotate sdf_annotate();
    `endif
    // Setting Clkgen/Rst initial config (DUT integration plugs into tb_clk/tb_rst)
    logic tb_clk;
    logic tb_rst;
    initial begin
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    initial begin
        tb_rst = 1'b1;
        repeat (20) @(posedge tb_clk);
        tb_rst = 1'b0;
    end
    initial begin run_test(""); end

endmodule


`include "if_conn.sv"

`ifndef OPEN_EDA
//***************************************************************************
//******* Program  < sdf_annotate >  is used for annotate sdf file.  ********
//***************************************************************************
program sdf_annotate;
    `include "tb_sdf.sv"
endprogram
`endif
// Other Component Module 


// include dut-relative file

'''

def get_tb_top_blk():
    return '''//==============================================
//=======block-level Tb for {pid}   ===========
//==============================================

`timescale 1ns/1ps
module tb_top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import tb-relative pkg


    // import dut-relative pkg


    // include tb-relative file
    `include "dump_wave.sv"

    // Interface instance and initialization: the vif assignment and the config_db
    // publication share ONE initial block (no ordering guarantee between initial blocks)
    virtual  {pid}_if   {pid}_vif;
    {pid}_if            {pid}_pif();
    initial begin
        {pid}_vif = {pid}_pif;
        uvm_config_db#(virtual interface {pid}_if)::set(uvm_root::get(),"*","{pid}_vif", {pid}_vif);
    end

    // Setting time display format
    initial begin
        $timeformat(-9, 3, "ns", 10);
    end

    // Clock and reset: reset asserted from time 0 and held for 20 clocks
    logic tb_clk;
    initial begin
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    assign {pid}_pif.clk = tb_clk;
    initial begin
        {pid}_pif.rst = 1'b1;
        repeat (20) @(posedge {pid}_pif.clk);
        {pid}_pif.rst = 1'b0;
    end

    // DUT <-> interface signal connection (intf/, RTL or gate/post-layout variant):
    // declares the dut_* nets the DUT instance below binds to - keep it BEFORE the DUT
    `ifndef GPL_SIM
        `include "{pid}_if_conn.sv"
    `else
        `include "{pid}_if_conn_gpls.sv"
    `endif

    // DUT instance (hand work): its ports bind only to the dut_* nets of the
    // if_conn file, never to interface signals directly, e.g.
    //   <dut> u_<dut> (.CLK(dut_clk), .RST_N(dut_rst_n), .ADDR(dut_addr), .RDATA(dut_rdata));


    // Setting UPF initial config


    `ifndef OPEN_EDA
        // Program  < sdf_annotate >  instantiation
        sdf_annotate sdf_annotate();
    `endif

    initial begin run_test(""); end

endmodule

`ifndef OPEN_EDA
//***************************************************************************
//******* Program  < sdf_annotate >  is used for annotate sdf file.  ********
//***************************************************************************
program sdf_annotate;
    `include "tb_sdf.sv"
endprogram
`endif

// Other Component Module


// include dut-relative file

'''


def get_if_conn():
    return '''//==============================================
//====== Manage each module's if_conn  =========
//==============================================

module if_conn;

    import uvm_pkg::*;

    //Other initial cfg


    `ifndef GPL_SIM

{include_if}

    `else

{include_if_gpls}


    `endif

    // Other if connection 

endmodule

'''

def get_dump():
    return '''//==============================================
//======     Setting dump waveform     =========
//==============================================

`ifdef OPEN_EDA
    initial begin
        $display("\\n[NOTE]\\tStart Dump FST waveform (Verilator) at%t\\n", $time);
        $dumpfile("wave.fst");
        $dumpvars(0, tb_top);
    end
`endif

`ifdef DUMP_VPD
    initial begin
        $display(\"\\n[NOTE]\\tStart Dump VPD at%t\\n\", $time);
        $vcdplusfile(\"novas.vpd\");
        $vcdpluson(12, `TB_TOP);
    end
`endif


`ifdef DUMP_FSDB
    initial begin
        $display(\"\\n[NOTE]\\tStart Dump FSDB at%t\\n\", $time);
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpMDA;
        
        `ifdef UPF
            $fsdbDumpvars(\"+power\");
        `endif

        $fsdbDumpvars(12,\"+all\",`TB_TOP);
        $fsdbDumpon;
    end
`endif

'''

def get_sdf():
    return '''//==============================================
//======  Rebuild sdf defination file ==========
//==============================================


`ifdef GPL_SIM

    // INSTACE 1
    //define instance path

    //define sdf path

    //sdf_annotate


    // INSTACE 2
    //define instance path

    //define sdf path

    //sdf_annotate
   
`endif

'''

def get_tb_define():
    return '''//----------------------------------------------------------------------------------------
// Define Tb-Relative Macro Here
// 1. define different Macro under BLOCK-LEVEL or SYSTEM-LEVEL 
// 2. define different Macro under RTL or GATE-NETLIST
//
// entry macro
//----------------------------------------------------------------------------------------
`define PROJ_ID                 dpu_w
`define TB_TOP                  tb_top

// ==========================================================================
// Define Paremater-type MACRO 
// ==========================================================================

//`define    PI  3


// ==========================================================================
// Define Path-type MACRO 
// ==========================================================================

//`define   UART   `TB_TOP.XX.XX




// ==========================================================================
// Define conditon-type MACRO 
// eg. behavior Simulation VS GPL_SIM , Sys-level VS sub-sys VS blcok
// ==========================================================================



// ==========================================================================
// Define Other MACRO 
// ==========================================================================


// include Other Macro Files 
// eg.
// `include "uvm_define.v"
// `include "vip_define.v"

'''


def get_rtl_define():
    return '''//----------------------------------------------------------------------------------------
// Place Your RTL-Relative Macro File Here
// Please Use file relative path.
//----------------------------------------------------------------------------------------

//eg.
//../../../hdl/chip_define.sv

// RTL define files Start
// RTL define files End

'''


def get_top_f():
    return '''+incdir+../../../verify/tb_top/component
+incdir+../../../verify/tb_top/scripts
+incdir+../../../verify/tb_top/macro

//../../../verify/tb_top/component/TBD
../../../verify/tb_top/tb_top/tb_top_{pid}.sv

'''

def get_rtl_file_lst():
    return '''//----------------------------------------------------------------------------------------
// Place Your {kind} File Here
//----------------------------------------------------------------------------------------

// Custom-Design Lib File Start

// Custom-Design Lib File End


// Header FILE Start

// Header FILE End


// Module 1 Start

// Module 1 End

// Module 2 Start

// Module 2 END

// Module x...


'''

def get_lib_lst():
    return '''//----------------------------------------------------------------------------------------
// Place Your Foundry and Custom lib Here
//----------------------------------------------------------------------------------------

// --------------STANDARD LIB Start-------------------- 

// --------------STANDARD LIB End----------------------


// --------------Custom LIB Start----------------------

// --------------Custom LIB End------------------------


// --------------Modue x  Start------------------------

// --------------Modue x  End--------------------------
'''


def get_inclue_dir():
    return '''//----------------------------------------------------------------------------------------
// Place Your Include Dir Here
//----------------------------------------------------------------------------------------

// --------------DESIGN-RELATIVE Start-------------------- 
// eg.
// +incdir+../../../hdl/file1/
// +incdir+../../../hdl/file2/

// --------------DESIGN-RELATIVE End----------------------


// --------------TB-RELATIVE Start----------------------

+incdir+../../../verify/ral
+incdir+../../../verify/env
+incdir+../../../verify/intf
+incdir+../../../verify/seq
+incdir+../../../verify/tb_top
+incdir+../../../verify/test
+incdir+../../../verify/utils/reg
+incdir+../../../verify/utils/base_uvc
+incdir+../../../verify/utils
+incdir+../../../verify/uvc

// --------------TB-RELATIVE End------------------------

'''

def get_glb_uvm_f():
    return '''//----------------------------------------------------------------------------------------
// Place Global Uvm-base Env Filelist Here
//----------------------------------------------------------------------------------------

// --------------BASE FILE Start-------------------- 
../../../verify/utils/global_pkg.sv
{flist_ral}

../../../verify/utils/base_uvc/base_uvc_pkg.sv

// --------------BASE FILE End----------------------


// --------------MODULE-FILE Start----------------------
{module_uvm_f}
// --------------MODULE-FIlE End------------------------



-f ../../../verify/tb_top/filelist/tb_top_{pid}.f
../../../verify/env/top_pkg.sv


'''

def get_blk_uvm_f():
    return '''//----------------------------------------------------------------------------------------
// Place Block Uvm-base Env Filelist Here
//----------------------------------------------------------------------------------------

// --------------BASE FILE Start-------------------- 
../../../verify/utils/global_pkg.sv
{flist_ral}

../../../verify/utils/base_uvc/base_uvc_pkg.sv

// --------------BASE FILE End----------------------


-f ../../../verify/uvc/{module_name}/script/uvm.f

../../../verify/seq/{module_name}_block_base_seq.sv
../../../verify/test/{module_name}_block_base_test.sv

-f ../../../verify/tb_top/filelist/tb_top_{module_name}.f


'''


def generate_tb_top(config, output_dir):
    """generate tb_top cfg tool..."""

    env_name = config['env_name'].lower()
    pid = config['project_name'].lower()
    test_name = config['test_name'].lower()
    modules = config.get('modules', [])
    

    tb_dir = os.path.join(output_dir, 'tb_top')
    os.makedirs(tb_dir, exist_ok=True)

    ## generate tb_top
    #
    tb_top_ls=[]
    adapter_ls=[]
    ral_map={}
    tb_top_ls.append(pid)
    for module in modules:
        has_tb_top = module['has_tb_top']
        adapter_type = module.get('adapter_type', '')
        module_name = module['name'].lower()
        if(has_tb_top):
            tb_top_ls.append(module_name)
        if(adapter_type):
            adapter_ls.append(module_name)
        ral_map[module_name] = module.get('enable_ral', True)


    ## generate components
    #  generate vitual if declare
    if_instance =[]
    vif_declare =[]
    vif_init    =[]
    vif_set     =[]
    #  generate if_conn
    include_if= []
    include_if_gpls= []
    #  generatedump_wave



    ## generate filelist
    #  generate  uvm_f
    module_uvm_f =[]
    ## generate data
    #  generate  


    if(config['has_top_if_cfg']):
        if_instance.append(f"top_if\ttop_pif();")
        vif_declare.append(f"virtual\ttop_if\ttop_vif;")
        vif_init.append(f"\ttop_vif = top_pif;")
        vif_set.append(f"\tuvm_config_db#(virtual interface top_if)::set(null,\"*\", \"top_vif\",top_vif);")

        include_if.append(f"\t\t`include \"top_if_conn.sv\"")
        include_if_gpls.append(f"\t\t`include \"top_if_conn_gpls.sv\"")
        module_uvm_f.append(f"../../../verify/env/top_if.sv")
    
    for module in modules:
        module_name = module['name'].lower()
        
        if_instance.append(f"{module_name}_if\t{module_name}_pif();")
        vif_declare.append(f"virtual\t{module_name}_if\t{module_name}_vif;")
        vif_init.append(f"\t{module_name}_vif = {module_name}_pif;")
        vif_set.append(f"\tuvm_config_db#(virtual interface {module_name}_if)::set(null,\"*\", \"{module_name}_vif\",{module_name}_vif);")

        include_if.append(f"\t\t`include \"{module_name}_if_conn.sv\"")
        include_if_gpls.append(f"\t\t`include \"{module_name}_if_conn_gpls.sv\"")
        module_uvm_f.append(f"-f ../../../verify/uvc/{module_name}/script/uvm.f")


    ## generate  component file 
    cmpt_dir = os.path.join(tb_dir, 'component')
    os.makedirs(cmpt_dir, exist_ok=True)

    vif_template = get_vif_declare()
    content = vif_template.format(if_instance='\n'.join(if_instance),
                                vif_declare='\n'.join(vif_declare),
                                vif_init='\n'.join(vif_init),
                                vif_set='\n'.join(vif_set)
                                )
                                  
    filepath = os.path.join(cmpt_dir, f'vif_declare.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    filepath = os.path.join(cmpt_dir, f'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores object instance files and components that tb needs.")
    print(f"Generated: {filepath}")

    conn_template = get_if_conn()
    content = conn_template.format(include_if='\n'.join(include_if),include_if_gpls='\n'.join(include_if_gpls))
    filepath = os.path.join(cmpt_dir, f'if_conn.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")
    
    content = get_dump()
    filepath = os.path.join(cmpt_dir, f'dump_wave.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    content = get_sdf()
    filepath = os.path.join(cmpt_dir, f'tb_sdf.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    



    ## generate  tb_top 
    tb_top_dir = os.path.join(tb_dir, 'tb_top')
    os.makedirs(tb_top_dir, exist_ok=True)


    top_tb_template = get_tb_top()
    content = top_tb_template.format(pid=pid)
                        
    filepath = os.path.join(tb_top_dir, 'tb_top_'+pid+'.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    top_tb_template = get_tb_top_blk()
    for tls in tb_top_ls:
        if(tls ==pid): 
            continue
        content = top_tb_template.format(pid=tls)                  
        write_new(os.path.join(tb_top_dir, 'tb_top_'+tls+'.sv'), content)

    #update pkg
    for tls in adapter_ls:
        print(f"begin to update pkg for mudule "+tls)
        new_pkg=[]
        adapter_type=""
        for module in modules:
            module_name = module['name'].lower()
            if(module_name==tls):
                adapter_type = module['adapter_type']
                break
        
        skip_update=False
        with open("../uvc/"+tls+"/env/"+tls+"_pkg.sv",mode='r' ,encoding='utf-8') as f:
            lines =f.readlines()
            #print("line",lines)
            for line in lines:
                if("_adapter" in line):
                    skip_update=True
                    break
            if(skip_update ==False):
                for line in lines:
                    if("env.sv" in line):
                        new_pkg.append(line)
                        new_pkg.append("`include \""+tls+"_reg2"+adapter_type+"_adapter.sv\"")
                    else:
                        new_pkg.append(line)
                    #print("new_pkg",new_pkg)   
            else:
                new_pkg=lines

        with open("../uvc/"+tls+"/env/"+tls+"_pkg.sv",mode='w' ,encoding='utf-8') as f:    
            for newline in new_pkg:
                f.write(newline)
        print(f"update pkg done for mudule "+tls)

    filepath = os.path.join(tb_top_dir,  'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores system,subsystem,block testbeach files")
    print(f"Generated: {filepath}")


    ## generate  cfg  (user-maintained skeletons: written once, never overwritten)
    cfg_dir = os.path.join(tb_dir, 'config')
    os.makedirs(cfg_dir, exist_ok=True)
    
    write_new(os.path.join(cfg_dir, 'xprop.cfg'), "merge = xmerge;")
    
    write_new(os.path.join(cfg_dir, 'initreg.cfg'), "modtree tb_top 0 random;")

    write_new(os.path.join(cfg_dir, 'coverage.cfg'), "+tree tb_top")

    write_new(os.path.join(cfg_dir, 'specify.cfg'), "//tree {xx} {noSpecify};\n//instance {TB.xx} {noSpecify};")
    
    write_new(os.path.join(cfg_dir, 'async_lst.cfg'), "//timing.cfg\n//instance {tb_top.xx} {noTiming};")




    ## generate  filelist 
    filelist = os.path.join(tb_dir, 'filelist')
    os.makedirs(filelist, exist_ok=True)
  
    f_template = get_top_f()
    
    for ls in tb_top_ls:
        content = f_template.format(pid=ls)
        write_new(os.path.join(filelist, 'tb_top_'+ls+'.f'), content)

        if(ls!=pid):
            content=get_blk_uvm_f()
            content=content.format(module_name=ls, **get_block_test_ral_snippets(ral_map.get(ls, True)))
            write_new(os.path.join(filelist, 'uvm_blk_'+ls+'.f'), content)

    rtl_file_lst = get_rtl_file_lst()

    for ls in ["rtl_file_lst","gate_file_lst","ip_file_lst","gate_ip_file_lst"]:
        if(ls=="rtl_file_lst"):
            content = rtl_file_lst.format(kind="RTL")
        elif((ls=="gate_file_lst")):
            content = rtl_file_lst.format(kind="NETLIST")
        elif((ls=="ip_file_lst")): 
            content = rtl_file_lst.format(kind="IP")
        else:
            content = rtl_file_lst.format(kind="IP NETLIST")


        # user-maintained file lists (RTL/IP/netlist sources): skeleton written once,
        # never overwritten - a regeneration must not wipe the design sources
        write_new(os.path.join(filelist, ls+'.f'), content)

    lib_lst = get_lib_lst()
    for ls in ["lib_lst","gpls_lib_lst"]:
        write_new(os.path.join(filelist, ls+'.f'), lib_lst)

    inclue_dir = get_inclue_dir()
    write_new(os.path.join(filelist, 'include.f'), inclue_dir)

    glb_uvm_f = get_glb_uvm_f()
    content = glb_uvm_f.format(module_uvm_f='\n'.join(module_uvm_f),pid=pid,
                               **get_top_ral_snippets(config.get('enable_ral', True), env_name=config.get('env_name', 'top')))
    filepath = os.path.join(filelist,  'uvm.f')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    filepath = os.path.join(filelist,  'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores some compile-relative filelist")
    print(f"Generated: {filepath}")


    ## generate data 
    data_dir = os.path.join(tb_dir, 'data')
    os.makedirs(data_dir, exist_ok=True)
    filepath = os.path.join(data_dir,  'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores data-type file,such database file or data-pool files")
    print(f"Generated: {filepath}")


    ## generate macro 
    macro_dir = os.path.join(tb_dir, 'macro')
    os.makedirs(macro_dir, exist_ok=True)

    tb_define = get_tb_define()
    content = tb_define.format(pid=pid)
                        
    filepath = os.path.join(macro_dir, 'tb_define.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    rtl_define = get_rtl_define()
                      
    write_new(os.path.join(macro_dir, 'rtl_define.f'), rtl_define)   # user-maintained, written once

    filepath = os.path.join(macro_dir,  'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores some macro-relative files")
    print(f"Generated: {filepath}")


    ## generate coverage 
    cov_dir = os.path.join(tb_dir, 'coverage')
    os.makedirs(cov_dir, exist_ok=True)

    filepath = os.path.join(cov_dir,  'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores coverage-relative files,such as exclude file from verdi")
    print(f"Generated: {filepath}")

    ## generate scripts 
    script_dir = os.path.join(tb_dir, 'scripts')
    os.makedirs(script_dir, exist_ok=True)

    filepath = os.path.join(script_dir,  'README')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write("This folder stores functional-scripts files or others script tools")
    print(f"Generated: {filepath}")

def generate_uvc_modules(config, output_dir,overwrite):
    """call gen_uvc.py generate UVC"""
    modules = config.get('modules', [])
    
    for module in modules:
        module_name = module['name'].lower()
        adapter_type = module.get('adapter_type', '')
        module_dir = os.path.join(output_dir, 'uvc', module_name)
        
        print(f"Generating UVC module: {module_name}")
        if os.path.exists(module_dir) and os.path.isdir(module_dir) and (not overwrite):
            print("module_dir exit, skip this module")
            continue

        # gen_uvc.py
        print("adapter_type:",adapter_type)
        if(adapter_type):
            cmd = [sys.executable, "gen_uvc.py", "-n", module_name, "-o", module_dir,"-t",adapter_type]
        else:
            cmd = [sys.executable, "gen_uvc.py", "-n", module_name, "-o", module_dir]
        
        try:
            #result = subprocess.run(cmd, capture_output=True, text=True, cwd=os.getcwd())
            result = subprocess.run(cmd, cwd=os.getcwd())
            if result.returncode == 0:
                print(f"== Successfully generated {module_name} UVC")
            else:
                print(f"== Failed to generate {module_name} UVC: {result.stderr}")
        except Exception as e:
            print(f"== Error generating {module_name} UVC: {e}")

def generate_testjson(config, output_dir):
    """generate test json and json file"""
  
    testjson_template=get_testjson_template()
    mjson_template=get_mjson_template()
    
    modules = config.get('modules', [])
    module_list=[]
    for module in modules:
        module_name = module['name'].lower()
        if(module==modules[-1]):
            module_list.append(f"        \"{module_name}\":\"case/{module_name}.json\"")
        else:
            module_list.append(f"        \"{module_name}\":\"case/{module_name}.json\",")

    #print('\n'.join(module_list))
    content=testjson_template.format(modulelst='\n'.join(module_list))

    if(not os.path.isdir(output_dir)):
        print("create dir:"+output_dir)
        os.makedirs(output_dir)
    else:
        print(output_dir +" generation is skipped")
    with open(os.path.join(output_dir,'module.json'), 'w', encoding='utf-8') as f:
        f.write(content)

    module_dir = os.path.join(output_dir, 'case')
    if(not os.path.exists(module_dir)):
        os.makedirs(module_dir)
    else:
        print(module_dir+" generation is skipped")

    for module in modules:
        module_name = module['name'].lower()
        fname=module_name+".json"    
        mcontent=mjson_template.format(module_name=module_name,module_name_upper=module_name.upper())
        write_new(os.path.join(module_dir,fname), mcontent)


        
def generate_interface(config, output_dir):
    """generate if_conn """

    modules = config.get('modules', [])  
    if_dir = os.path.join(output_dir, 'intf')
    if(not os.path.exists(if_dir)):
        os.makedirs(if_dir)
    else:
        print(if_dir+" generation is skipped")

    for module in modules:
        module_name = module['name'].lower()
        fname=module_name+"_if_conn.sv"
        if_template=get_if_coon_template()
        ifcontent=if_template.format(module_name=module_name)
        write_new(os.path.join(if_dir,fname), ifcontent)

        fname_gpls=module_name+"_if_conn_gpls.sv"
        if_template=get_if_coon_template()
        ifcontent=if_template.format(module_name=module_name)
        write_new(os.path.join(if_dir,fname_gpls), ifcontent)
    

    has_top_if_cfg = config["has_top_if_cfg"]
    if(has_top_if_cfg):
        # add top_if_connect or glb_if_connect
        module_name = "top"
        fname=module_name+"_if_conn.sv"    
        if_template=get_if_coon_template()
        ifcontent=if_template.format(module_name=module_name)
        write_new(os.path.join(if_dir,fname), ifcontent)

        fname_gpls=module_name+"_if_conn_gpls.sv"    
        if_template=get_if_coon_template()
        ifcontent=if_template.format(module_name=module_name)
        write_new(os.path.join(if_dir,fname_gpls), ifcontent)

def generate_base_sequence(config, output_dir):
    """generate base_sequence"""
    name = config['seq_name'].lower()
    name_upper = name.upper()
    env_name = config['env_name'].lower()
    pid = config['project_name'].lower()
    modules = config.get('modules', [])
    
    # generate virtual interface
    vif_declarations = []
    vif_get = []
    
    # generate config
    cfg_declarations = []
    cfg_get = []

    # generate  base_seq
    inlcude_module_base_seq = []

    #generate lib
    inlude_seq_lib = []

    if (config['has_top_if_cfg'] == True):
        vif_declarations.append(f"    virtual interface top_if top_vif;")
        vif_get.append(f"        if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, \"\", \"top_vif\", top_vif))")
        vif_get.append(f"            `uvm_error(\"TOP_VIF:ERROR\", \"VIF top_vif is missing from config_db\")")

    for module in modules:
        module_name = module['name'].lower()
        
        if module.get('has_interface', True):
            vif_declarations.append(f"    virtual interface {module_name}_if {module_name}_vif;")
            vif_get.append(f"        if (!uvm_config_db #(virtual interface {module_name}_if)::get(m_sequencer, \"\", \"{module_name}_vif\", {module_name}_vif))")
            vif_get.append(f"            `uvm_error(\"{module_name.upper()}_VIF:ERROR\", \"VIF {module_name}_vif is missing from config_db\")")
        
        if module.get('has_config', True):
            cfg_declarations.append(f"    {module_name}_pkg::{module_name}_base_cfg {module_name}_cfg_h;")
            cfg_declarations += ["`ifdef OPEN_EDA", f"    typedef {module_name}_pkg::{module_name}_base_cfg {module_name}_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument", "`endif"]
            cfg_get.append("`ifdef OPEN_EDA")
            cfg_get.append(f"        if (!uvm_config_db #({module_name}_cfg_t)::get(m_sequencer, \"\", \"{module_name}_cfg\", {module_name}_cfg_h))begin")
            cfg_get.append("`else")
            cfg_get.append(f"        if (!uvm_config_db #({module_name}_pkg::{module_name}_base_cfg)::get(m_sequencer, \"\", \"{module_name}_cfg\", {module_name}_cfg_h))begin")
            cfg_get.append("`endif")
            cfg_get.append(f"            `uvm_warning(\"{module_name.upper()}_CFG:WARNING\", \"CFG {module_name}_cfg is missing from config_db,using default\")")
            cfg_get.append(f"            {module_name}_cfg_h = new();")
            cfg_get.append(f"        end")
        
        inlcude_module_base_seq.append(f"`include \"comm_{module_name}_methods.sv\"")
        inlude_seq_lib.append(f"`include \"{module_name}_seq.sv\"")

    template = get_base_sequence_template()
    content = template.format(
        name=name,
        name_upper=name_upper,
        env_name=env_name,
        env_name_upper=env_name.upper(),
        vif_declarations='\n'.join(vif_declarations),
        cfg_declarations='\n'.join(cfg_declarations),
        vif_get='\n'.join(vif_get),
        cfg_get='\n'.join(cfg_get),
        inlcude_module_base_seq='\n'.join(inlcude_module_base_seq),
        **get_top_ral_snippets(config.get('enable_ral', True), env_name=config.get('env_name', 'top'))
    )
    
    seq_dir = os.path.join(output_dir, 'seq')
    os.makedirs(seq_dir, exist_ok=True)
    
    filepath = os.path.join(seq_dir, f'{name}_seq.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    mtemplate=get_module_base_seq_template()
    for module in modules:
        module_name = module['name'].lower()
        content = mtemplate.format(name=module_name)
        filepath = os.path.join(seq_dir, f'comm_{module_name}_methods.sv')
        write_new(filepath, content)

    mtemplate=get_module_seq_template()
    for module in modules:
        module_name = module['name'].lower()
        content = mtemplate.format(name=module_name)
        filepath = os.path.join(seq_dir, f'{module_name}_seq.sv')
        write_new(filepath, content)

    # cfg init and exit seq
    mtemplate=get_naming_template()
    for naming in ["sys_init","exit_chk"]:
        content = mtemplate.format(name=naming)
        inlude_seq_lib.append(f"`include \"{naming}_seq.sv\"")
        filepath = os.path.join(seq_dir, f'{naming}_seq.sv')
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Generated: {filepath}")



    ltemplate=get_seq_lib_template()
    content = ltemplate.format(seq_name=name,inlude_seq_lib='\n'.join(inlude_seq_lib))
    filepath = os.path.join(seq_dir, pid+'_sequence_lib.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")


    #add blcok seq
    for module in modules:
        module_name = module['name'].lower()
        has_tb_top = module['has_tb_top']
        if(has_tb_top): 
            ltemplate=get_block_base_sequence_template()
            content = ltemplate.format(name=module_name,name_upper=module_name.upper(),
                                       **get_block_test_ral_snippets(module.get('enable_ral', True)))

            filepath = os.path.join(seq_dir, module_name+'_block_base_seq.sv')
            write_new(filepath, content)



def generate_base_test(config, output_dir):
    """generate  base_test"""
    name = config['test_name'].lower()
    name_upper = name.upper()
    env_name = config['env_name'].lower()
    modules = config.get('modules', [])
    
    # generate virtual interface
    vif_declarations = []
    vif_get = []
    
    # generate config
    cfg_declarations = []
    cfg_create = []
    cfg_set = []
    
    # generate  random func
    randomize_declaration=[]
    randomize_functions = []
    randomize_calls = []
    # generate  override
    cfg_override_declarations=[]
    cfg_override_functions=[]

    if (config['has_top_if_cfg'] == True):
        vif_declarations.append(f"    virtual interface top_if top_vif;")
        vif_get.append(f"        if (!uvm_config_db #(virtual interface top_if)::get(this, \"\", \"top_vif\", top_vif))")
        vif_get.append(f"            `uvm_error(\"TOP_VIF:ERROR\", \"VIF top_vif is missing from config_db\")")

    for module in modules:
        module_name = module['name'].lower()
        
        if module.get('has_interface', True):
            vif_declarations.append(f"    virtual interface {module_name}_if {module_name}_vif;")
            vif_get.append(f"        if (!uvm_config_db #(virtual interface {module_name}_if)::get(this, \"\", \"{module_name}_vif\", {module_name}_vif))")
            vif_get.append(f"            `uvm_error(\"{module_name.upper()}_VIF:ERROR\", \"VIF {module_name}_vif is missing from config_db\")")
        
        if module.get('has_config', True):
            cfg_declarations.append(f"    {module_name}_pkg::{module_name}_base_cfg {module_name}_cfg_h;")
            cfg_declarations += ["`ifdef OPEN_EDA", f"    typedef {module_name}_pkg::{module_name}_base_cfg {module_name}_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument", "`endif"]
            randomize_declaration.append(f"    extern virtual function void {module_name}_cfg_randomize();")
            cfg_override_declarations.append(f"    extern virtual function void set_{module_name}_cfg_type(input string {module_name}_cfg_override, bit replace=1);")
            cfg_create.append(f"        {module_name}_cfg_h = {module_name}_pkg::{module_name}_base_cfg::type_id::create(\"{module_name}_cfg_h\", this);")
            cfg_set += ["`ifdef OPEN_EDA", f"        uvm_config_db #({module_name}_cfg_t)::set(uvm_root::get(),\"*\", \"{module_name}_cfg\", {module_name}_cfg_h);", "`else",
                        f"        uvm_config_db #({module_name}_pkg::{module_name}_base_cfg)::set(uvm_root::get(),\"*\", \"{module_name}_cfg\", {module_name}_cfg_h);", "`endif"]
            
            randomize_calls.append(f"        {module_name}_cfg_randomize();")
            # generate  random function
            randomize_functions.append(f"function void base_test::{module_name}_cfg_randomize();")
            randomize_functions.append(f"    if({module_name}_cfg_h.randomize())")
            randomize_functions.append(f"        `uvm_info(get_type_name(),{module_name}_cfg_h.sprint(),UVM_MEDIUM)")
            randomize_functions.append(f"    else")
            randomize_functions.append(f"        `uvm_fatal(get_type_name(),\"{module_name}_cfg_h randomization failed\")")
            randomize_functions.append(f"endfunction")
            randomize_functions.append("")
            # generate override
            cfg_override_functions.append(f"function void base_test::set_{module_name}_cfg_type(input string {module_name}_cfg_override, bit replace=1);")
            cfg_override_functions.append(f"    set_type_override(\"{module_name}_base_cfg\", {module_name}_cfg_override, replace);")
            cfg_override_functions.append(f"endfunction")
            cfg_override_functions.append(f"")
    
            
    
    template = get_base_test_template()
    content = template.format(
        name=name,
        name_upper=name_upper,
        env_name=env_name,
        vif_declarations='\n'.join(vif_declarations),
        cfg_declarations='\n'.join(cfg_declarations),
        randomize_declaration='\n'.join(randomize_declaration),
        cfg_override_declarations='\n'.join(cfg_override_declarations),
        cfg_create='\n'.join(cfg_create),
        cfg_set='\n'.join(cfg_set),
        vif_get='\n'.join(vif_get),
        randomize_calls='\n'.join(randomize_calls),
        randomize_functions='\n'.join(randomize_functions),
        cfg_override_functions='\n'.join(cfg_override_functions)
    )
    
    test_dir = os.path.join(output_dir, 'test')
    os.makedirs(test_dir, exist_ok=True)
    
    filepath = os.path.join(test_dir, f'{name}_test.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")


    mtemplate=get_module_test_template()

    for module in modules:
        module_name = module['name'].lower()
        module_name_upper=module_name.upper()
        content = mtemplate.format(name=module_name)
        
        filepath = os.path.join(test_dir, f'{module_name}_test.sv')
        write_new(filepath, content)

    #add block test
    mtemplate=get_block_base_test_template()
    for module in modules:
        module_name = module['name'].lower()
        has_tb_top = module['has_tb_top']
        adapter_type = module['adapter_type']
        if(has_tb_top):
            adapter_sv = get_block_test_adapter_snippets(module_name, adapter_type, module.get('adapter_type', ''))
            content = mtemplate.format(name=module_name,name_upper=module_name.upper(),bus_type=adapter_type,
                                       **adapter_sv, **get_block_test_ral_snippets(module.get('enable_ral', True)))
            filepath = os.path.join(test_dir, module_name+'_block_base_test.sv')
            write_new(filepath, content)

        




def generate_top_env(config, output_dir):
    """generate  top_env,top_pkg,top_vsqr,top_if..."""

    env_name = config['env_name'].lower()
    pid = config['project_name'].lower()
    test_name = config['test_name'].lower()
    modules = config.get('modules', [])

    # top_env   
    # generate env,sqr declarations 
    env_declarations = []
    envs_create = []
    vsqr_connect = []
    
    env_drv_mode = []

    for module in modules:
        module_name = module['name'].lower()
        
        env_declarations.append(f"\t{module_name}_env\t\t{module_name}_env_h;")
        envs_create.append(f"\t\t{module_name}_env_h = {module_name}_env::type_id::create(\"{module_name}_env_h\", this);")
        vsqr_connect.append(f"\t\tvseqr_h.{module_name}_seqr_h= {module_name}_env_h.vseqr_h;")
        if(module['is_active']):
            env_drv_mode.append(f"\t\t{module_name}_env_h.drv_is_active = UVM_ACTIVE ;")

    template = get_top_env_template()
    content = template.format(
        env_name=env_name,
        env_name_upper=env_name.upper(),
        env_declarations='\n'.join(env_declarations),
        envs_create='\n'.join(envs_create),
        vsqr_connect='\n'.join(vsqr_connect),
        env_drv_mode='\n'.join(env_drv_mode),
        **get_top_ral_snippets(config.get('enable_ral', True), env_name=config.get('env_name', 'top'))
    )
    
    env_dir = os.path.join(output_dir, 'env')
    os.makedirs(env_dir, exist_ok=True)
    
    filepath = os.path.join(env_dir, f'{env_name}_env.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")


    # top_pkg
    import_module_pkg=[]
    include_mudule_test=[]

    for module in modules:
        module_name = module['name'].lower()
        import_module_pkg.append(f"  import {module_name}_pkg::*;")
        include_mudule_test.append(f'''  `include "{module_name}_test.sv"''')
        
        
    top_pkg_template=get_top_pkg_template()
    content = top_pkg_template.format(
        pid=pid,
        env_name=env_name,
        test_name=test_name,
        import_module_pkg='\n'.join(import_module_pkg),
        include_mudule_test='\n'.join(include_mudule_test)
    )

    filepath = os.path.join(env_dir, f'top_pkg.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")

    #top vitual sequencer
    seqr_declaration=[]
    seqr_automation=[]

    for module in modules:
        module_name = module['name'].lower()
        seqr_declaration.append(f"  {module_name}_sequencer\t\t{module_name}_seqr_h;")
        seqr_automation.append(f"    `uvm_field_object({module_name}_seqr_h, UVM_ALL_ON)")    
    top_vsqr_template=get_top_vsqr_template()
    content = top_vsqr_template.format(
        seqr_declaration='\n'.join(seqr_declaration),
        seqr_automation='\n'.join(seqr_automation),
        **get_top_ral_snippets(config.get('enable_ral', True), env_name=config.get('env_name', 'top'))
    )

    filepath = os.path.join(env_dir, f'top_vseqr.sv')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated: {filepath}")


    # top_if   
    has_top_if_cfg = config["has_top_if_cfg"]
    if(has_top_if_cfg):
        tif_template=get_tif_template()
        if_content= tif_template.format(name="top")
        filepath = os.path.join(env_dir, 'top_if.sv')
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(if_content)
        filepath = os.path.join(env_dir, 'top_if_pc.sv')
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write("//==Add top-relative property asserion and coverage here==")
        

def generate_default_config():
    """generate default cfg"""
    return {
        "project_name": "soc",
        "seq_name": "base", 
        "test_name": "base",
        "env_name": "top",
        "has_top_if_cfg":  True,
        "enable_ral": True,
        "modules": [
            {
                "name": "reg",
                "has_interface": True,
                "has_config": True,
                "has_tb_top": False,
                "is_active": False,
                "adapter_type":"",
                "enable_ral":True
            },
            {
                "name": "apb_master",
                "has_interface": True,
                "has_config": True,
                "has_tb_top": True,
                "is_active": True,
                "adapter_type":"",
                "enable_ral":False
            },
            {
                "name": "cpft",
                "has_interface": True,
                "has_config": True,
                "has_tb_top": False,
                "is_active": False,
                "adapter_type":"",
                "enable_ral":True
            },
            {
                "name": "uart",
                "has_interface": True,
                "has_config": True,
                "has_tb_top": True,
                "is_active": True,
                "adapter_type":"uart",
                "enable_ral":True
            },
            {
                "name": "efuse",
                "has_interface": True,
                "has_config": True,
                "has_tb_top": True,
                "is_active": True,
                "adapter_type": "apb",
                "enable_ral": True
            }
        ]
    }

def main():
    parser = argparse.ArgumentParser(
        description='UVM Environment Auto Generation Script'
    )
    parser.add_argument('-c', '--config', default=None, 
                        help='Configuration JSON file')
    parser.add_argument('-o', '--output', default='../',
                        help='Output directory')
    parser.add_argument('--gcfg', action='store_true',
                        help='Generate default config file')
    parser.add_argument('--guvc', action='store_true',
                        help='Generate UVC modules using gen_uvc.py')
    parser.add_argument('--overwrite', action='store_true',default=False,
                        help='Generate UVC modules using gen_uvc.py')
    parser.add_argument('--prune', action='store_true', default=False,
                        help='List module files whose module is gone from the config')
    parser.add_argument('--yes', action='store_true', default=False,
                        help='With --prune: actually delete the listed orphan files/dirs')
    
    args = parser.parse_args()
    if args.prune:
        if not args.config:
            print('--prune requires -c <config>')
            sys.exit(1)
        prune_orphans(parse_config(args.config), os.path.abspath(args.output), args.yes)
        return
    
    if args.gcfg:
        config = generate_default_config()
        #config_file = os.path.join(args.output, 'json/uvm_env_config_template.json')
        config_file = os.path.join(args.output, 'script/uvm_env_config_template.json')
        os.makedirs(args.output, exist_ok=True)
        #os.makedirs(os.path.join(args.output, 'json'), exist_ok=True)
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
        print(f"Generated default config: {config_file}")
        print("Please modify the config file and run again with -c option")
        return
    
    if args.config:
        config = parse_config(args.config)
        check_config(config)
    else:
        config = generate_default_config()
    
    output_dir = args.output
    overwrite = args.overwrite
    
    print(f"\n{'='*60}")
    print(f"Generating UVM Environment: {config['project_name']}")
    print(f"Output directory: {output_dir}")
    print(f"{'='*60}\n")
    
    # generate UVC 
    if args.guvc:
        print("Generating UVC modules...")
        generate_uvc_modules(config, output_dir,overwrite)
        print()

    print("Generating Test Json File...")
    generate_testjson(config=config, output_dir="../json")

    print("Generating Interface Connect File...")
    generate_interface(config, output_dir)


    print("Generating Base Sequence...")
    generate_base_sequence(config, output_dir)
    
    print("\nGenerating Top Environment...")
    generate_top_env(config, output_dir)
    
    print("\nGenerating Base Test...")
    generate_base_test(config, output_dir)

    print("\nGenerating TB Top ...")
    generate_tb_top(config, output_dir)

    print(f"\n{'='*60}")
    print(f"UVM Environment generation completed successfully!")
    print(f"Output directory: {output_dir}")
    print(f"{'='*60}")

    

def write_new(filepath, content):
    """Module-private files and the user-maintained skeletons (tb_top/config/*.cfg, the
    tb_top/filelist source lists + include.f, macro/rtl_define.f) are generated once and then
    hand-maintained; never overwrite an existing one (assembly files are template-pure and
    are rewritten unconditionally)."""
    if os.path.exists(filepath):
        print("Skipped (exists): %s" % filepath)
        return
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Generated: %s" % filepath)


def prune_orphans(config, output_dir, do_delete):
    """Remove module-private files whose module is gone from the config. Paths are
    fully derived from the module name, so the filesystem itself is the manifest."""
    mods = {m['name'].lower() for m in config.get('modules', [])}
    patterns = [
        'uvc/{}', 'seq/{}_seq.sv', 'seq/{}_block_base_seq.sv', 'seq/comm_{}_methods.sv',
        'test/{}_test.sv', 'test/{}_block_base_test.sv', 'json/case/{}.json',
        'tb_top/tb_top/tb_top_{}.sv', 'tb_top/filelist/uvm_blk_{}.f',
        'tb_top/filelist/tb_top_{}.f', 'intf/{}_if_conn.sv', 'intf/{}_if_conn_gpls.sv',
    ]
    import shutil
    orphans = []
    known = set()
    for mod in os.listdir(os.path.join(output_dir, 'uvc')):
        known.add(mod)
    ormods = known - mods - {'README'}
    for m in sorted(ormods):
        for pat in patterns:
            t = pat.format(m)
            fp = os.path.join(output_dir, t)
            if os.path.isfile(fp):
                orphans.append(fp)
            elif os.path.isdir(fp):
                orphans.append(fp + os.sep)
    if not orphans:
        print("prune: no orphans")
        return
    for fp in orphans:
        print(('prune: orphan ' + fp) if do_delete else ('orphan (use --yes to delete): ' + fp))
    if do_delete:
        for fp in orphans:
            if fp.endswith(os.sep):
                shutil.rmtree(fp.rstrip(os.sep))
            else:
                os.remove(fp)
        print("prune: %d item(s) deleted" % len(orphans))


def parse_config(config_file):
    with open(config_file, 'r', encoding='utf-8') as f:
        return json.load(f)


def check_config(config):
    """The reg2<bus> adapter converts uvm_reg front-door access to bus transactions;
    it is meaningless without the RAL model, so adapter_type implies enable_ral."""
    for module in config.get('modules', []):
        name = module.get('name', '?')
        adapter_type = module.get('adapter_type', '')
        enable_ral = module.get('enable_ral', True)
        if adapter_type and not enable_ral:
            print("ERROR: module '%s' sets adapter_type='%s' but enable_ral=false; "
                  "an adapter without a RAL model is not supported. "
                  "Set adapter_type to \"\", or enable_ral to true." % (name, adapter_type))
            sys.exit(1)
    if not config.get('enable_ral', True):
        for module in config.get('modules', []):
            name = module.get('name', '?')
            if module.get('enable_ral', True):
                print("ERROR: config top-level enable_ral is false but module '%s' sets "
                      "enable_ral=true; the system flow has one chip-level model, a module "
                      "cannot keep RAL when the chip has none." % name)
                sys.exit(1)
            if module.get('adapter_type', ''):
                print("ERROR: config top-level enable_ral is false but module '%s' sets "
                      "adapter_type='%s'; set adapter_type to \"\"." % (name, module.get('adapter_type')))
                sys.exit(1)


if __name__ == '__main__':
    main()
