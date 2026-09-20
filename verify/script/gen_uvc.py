#!/usr/bin/env python3
################################################################################
#
# UVC Auto Generation Script
# Function: Automatically generate the standard component files for UVM Verification Component
# Usage: python gen_uvc.py -n <uvc_name> -o <output_dir>
# Author: Mr Wang
################################################################################

import os
import sys
import argparse
import re
from datetime import datetime

def get_template_content():
    templates = {
        'sequence_item': '''class {name}_sequence_item extends uvm_sequence_item;

  string report_id = "{name}_sequence_item";
  
  int card_sel;
  logic [31:0] addr;
  logic [31:0] data;
  logic we;
  

  // registering the properties of this object
  `uvm_object_utils_begin({name}_sequence_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(card_sel, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="{name}_sequence_item");
    super.new(name);
    addr = 0;
    data = 0;
    we = 0;
    card_sel = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("{name_upper}_SEQUENCE_ITEM:", this);
  endfunction

endclass : {name}_sequence_item
''',
        
        'item': '''class {name}_item extends uvm_object;

  // used for messaging purposes between components (MON2SCB,Etc..)
  string report_id = "{name}_item";

  int card_sel;

  // registering the properties of this object
  `uvm_object_utils_begin({name}_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="{name}_item");
    super.new(name);
    card_sel = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("{name_upper}_ITEM:", this);
  endfunction

endclass : {name}_item
''',
        
        'coverage_item': '''class {name}_coverage_item extends uvm_object;

  // Used to collect coverage messages
  string report_id = "{name}_coverage_item";

  int card_sel;
  bit[31:0] {name}_ctrl;

  // registering the properties of this object
  `uvm_object_utils_begin({name}_coverage_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int({name}_ctrl, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="{name}_coverage_item");
    super.new(name);
    card_sel = 0;
    {name}_ctrl = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("{name_upper}_COVERAGE_ITEM:", this);
  endfunction

endclass : {name}_coverage_item
''',
        
        'sequencer': '''`ifndef __{name_upper}_SEQUENCER__SVH__
`define __{name_upper}_SEQUENCER__SVH__

class {name}_sequencer extends uvm_sequencer#({name}_sequence_item);

  `uvm_component_utils({name}_sequencer)

  {name}_sequence_item {name}_seq_item_h;
  
  function new (string name = "{name}_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

endclass: {name}_sequencer
`endif
''',
        
        'base_cfg': '''class {name}_base_cfg extends uvm_object;

  rand bit [3:0] {name}_ctrl1;
  rand bit [3:0] {name}_ctrl2;

  // Registration
  /////////////////////////////////////////////////////////  
  `uvm_object_utils_begin({name}_base_cfg)
    `uvm_field_int({name}_ctrl1, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int({name}_ctrl2, UVM_ALL_ON + UVM_HEX)
  `uvm_object_utils_end

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
  function new(string name="{name}_base_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////  
    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
    this.constr_base_{name}_ctrl1.constraint_mode(1);
    this.constr_base_{name}_ctrl2.constraint_mode(1);
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
  constraint constr_base_{name}_ctrl1;
  constraint constr_base_{name}_ctrl2;

endclass: {name}_base_cfg

constraint {name}_base_cfg::constr_base_{name}_ctrl1 
  {{
    {name}_ctrl1 inside {{[4'h1:4'hf]}};
  }}

constraint {name}_base_cfg::constr_base_{name}_ctrl2 
  {{
    {name}_ctrl2 inside {{[4'h1:4'hf]}};
  }}
''',
        
        'cfg': '''class {name}_cfg extends {name}_base_cfg;

  // Registration
  /////////////////////////////////////////////////////////
  `uvm_object_utils({name}_cfg)

  function new(string name="{name}_cfg");
    super.new(name);

    ///////////////////////////////////////////////////////
    // Assign to actual real variables in post_randomize()
    ///////////////////////////////////////////////////////

    post_randomize();
  endfunction : new

  function void pre_randomize();
    super.pre_randomize();
     this.constr_{name}_ctrl1.constraint_mode(1);
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
  constraint constr_{name}_ctrl1;

endclass: {name}_cfg

constraint {name}_cfg::constr_{name}_ctrl1
  {{
    {name}_ctrl1 inside {{[4'ha:4'hf]}};
  }}

''',
        
        'driver': '''class {name}_driver extends uvm_driver#({name}_sequence_item);

  uvm_analysis_port #({name}_sequence_item) ap;

  `uvm_component_utils({name}_driver);

  virtual {name}_if vif;
  {name}_base_cfg m_cfg;
  
  function new(string name="{name}_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual {name}_if)::get(this , "" , "{name}_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #({name}_base_cfg)::get(this, "", "{name}_cfg", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration {name}_cfg from uvm_config_db. Have you set it?", UVM_MEDIUM)
  endfunction
  
  task main_phase(uvm_phase phase);
    
    forever begin
      wait(~vif.rst);   //could be updated
      reset_signals();
      seq_item_port.get_next_item(req);
      $cast(rsp,req.clone());
      rsp.set_id_info(req);
      do_drive(req, rsp);
      seq_item_port.item_done(rsp);
    end
  endtask
  
  virtual task do_drive({name}_sequence_item req, {name}_sequence_item rsp);

    `uvm_info(get_full_name(), "Driving transaction in {name}_driver...", UVM_MEDIUM)
    // begin your drv logic here.

    @(posedge vif.clk);
    vif.card_sel  <= req.card_sel;

  endtask

  virtual task reset_signals();
    vif.card_sel  <= 'h0;
  endtask
  
endclass
''',
        
        'monitor': '''class {name}_monitor extends base_monitor;

  uvm_analysis_port #({name}_item) {name}_monitor_main_ap;
  uvm_analysis_port #({name}_coverage_item) frame_collected_port;

  `uvm_component_utils({name}_monitor);

  {name}_coverage_item req;
  {name}_item {name}_item_h;
  virtual {name}_if {name}_vif;

  extern task monitor_trans();
  extern task collect_coverage();
  extern function print_monitor_status();
  function new(string name="{name}_monitor" , uvm_component parent=null);
    super.new(name , parent);
    {name}_monitor_main_ap = new("{name}_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = {name}_coverage_item::type_id::create("req",this);
    {name}_item_h = {name}_item::type_id::create("{name}_item_h",this);
    if(!uvm_config_db#(virtual {name}_if)::get(this , "" , "{name}_vif" ,{name}_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    print_monitor_status();
    fork
      monitor_trans();
      collect_coverage();
    join_none
  endtask


endclass : {name}_monitor
  
  // Sample vif data , trans to scoreboard or other component
  task {name}_monitor::monitor_trans();
    forever begin
      @(posedge {name}_vif.clk);
      begin
        {name}_item_h.card_sel = {name}_vif.card_sel  ;
        {name}_monitor_main_ap.write({name}_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task {name}_monitor::collect_coverage();
    forever begin
      @(posedge {name}_vif.clk);
      req.card_sel  = {name}_vif.card_sel ;
      req.{name}_ctrl  = {name}_vif.{name}_ctrl ;
      if(cov_enable)begin
		    frame_collected_port.write(req);  
	    end 
    end
  endtask

  // Print monitor status of cov_enable & checks_enable
  function {name}_monitor::print_monitor_status();
		`uvm_info(get_type_name(), $sformatf("{name}_monitor status as following:"), UVM_MEDIUM)
		if(checks_enable)begin
			`uvm_info(get_type_name(), $sformatf("{name}_monitor check switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("{name}_monitor check switch OFF"), UVM_MEDIUM)
		end
		if(cov_enable)begin
			`uvm_info(get_type_name(), $sformatf("{name}_monitor collect coverages switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("{name}_monitor collect coverages switch OFF"), UVM_MEDIUM)
		end
  endfunction

''',
        
        'scoreboard': '''`uvm_analysis_imp_decl(_main_{name}_monitor)
class {name}_scoreboard extends base_scoreboard;

  `uvm_component_utils({name}_scoreboard);
  
  virtual {name}_if {name}_vif;

  {name}_item {name}_item_h;

  uvm_analysis_imp_main_{name}_monitor #({name}_item, {name}_scoreboard) {name}_scoreboard_main_ap;
  
  function new(string name="{name}_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    {name}_scoreboard_main_ap = new("{name}_scoreboard_main_ap",this);  
    {name}_item_h = {name}_item::type_id::create("{name}_item_h",this);
    if (!uvm_config_db #(virtual interface {name}_if)::get(this, "", "{name}_vif", {name}_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("{name}_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;
    if(checks_enable) `uvm_info(get_type_name(), $sformatf("begin to do scoreboard check"), UVM_MEDIUM)
    else `uvm_info(get_type_name(), $sformatf("stop to do scoreboard check"), UVM_MEDIUM)

  endtask:main_phase

  virtual function void write_main_{name}_monitor({name}_item req);
    `uvm_info(get_type_name(), $sformatf("Received {name}_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass
''',
        
        'coverage': '''class {name}_coverage extends uvm_subscriber #({name}_coverage_item);
 
  `uvm_component_utils({name}_coverage)
  
  uvm_analysis_imp #({name}_coverage_item, {name}_coverage) mon2cov;

  virtual {name}_if {name}_vif;
  {name}_coverage_item req_h;

  string report_id = "{name}_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_{name}_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.{name}_ctrl {{
      type_option.weight = 0;
      bins {name}_ctrl[] = {{[0:31]}};
    }}
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_{name}_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint {name}_vif.{name}_ctrl {{
      bins {name}_ctrl[] = {{[0:31]}};
    }}
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_{name}_ctrl = new();
    cg_{name}_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = {name}_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual {name}_if)::get(this , "" , "{name}_vif" ,{name}_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write({name}_coverage_item t);
    req_h = t;
    cg_{name}_ctrl.sample();
    cg_{name}_ctrl_by_if.sample();
  endfunction

endclass
''',
        
        'agent': '''class {name}_agent extends base_agent;

  `uvm_component_utils({name}_agent)

  {name}_monitor      {name}_monitor_h;  
  {name}_sequencer    m_sequencer;
  {name}_scoreboard   {name}_scoreboard_h;  
  {name}_driver       m_driver;    
  uvm_analysis_port#({name}_coverage_item) coverage_ap;

  function new(string name = "{name}_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    {name}_monitor_h = {name}_monitor::type_id::create("{name}_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = {name}_sequencer::type_id::create("m_sequencer",this);
      m_driver = {name}_driver::type_id::create("m_driver", this);  
    end
    {name}_scoreboard_h = {name}_scoreboard::type_id::create("{name}_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    {name}_monitor_h.frame_collected_port.connect(coverage_ap); 
    {name}_monitor_h.{name}_monitor_main_ap.connect({name}_scoreboard_h.{name}_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : {name}_agent
''',
        
        'env': '''class {name}_env extends base_env;

  `uvm_component_utils({name}_env)

  {name}_agent      {name}_agent_h;
  {name}_sequencer  vseqr_h;
  {name}_coverage   {name}_coverage_h;

  function new(string name = "{name}_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    {name}_agent_h = {name}_agent::type_id::create("{name}_agent_h" , this);
    {name}_agent_h.is_active = drv_is_active;
    vseqr_h = {name}_sequencer::type_id::create("vseqr_h", this);
    {name}_coverage_h = {name}_coverage::type_id::create("{name}_coverage_h" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    {name}_agent_h.coverage_ap.connect({name}_coverage_h.mon2cov);
    if({name}_agent_h.is_active == UVM_ACTIVE)
      vseqr_h = {name}_agent_h.m_sequencer;
  endfunction

endclass
''',
        
        'if': '''interface {name}_if ();

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
''',
        'if_pc': '''//==Add {name}-relative property asserion and coverage here==
        //change the file name!!!
        ''',
        
        'pkg': '''`ifndef __{name_upper}_PKG__SV__
`define __{name_upper}_PKG__SV__
package {name}_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "{name}_base_cfg.sv"
`include "{name}_cfg.sv"
`include "{name}_item.sv"
`include "{name}_sequence_item.sv"
`include "{name}_coverage_item.sv"
`include "{name}_sequencer.sv"
`include "{name}_driver.sv"
`include "{name}_monitor.sv"
`include "{name}_scoreboard.sv"
`include "{name}_coverage.sv"
`include "{name}_agent.sv"
`include "{name}_env.sv"



endpackage : {name}_pkg
`endif //`ifndef __{name_upper}_PKG__SV__
''',
             
        'uvm_f': '''+incdir+../../../verify/uvc/{name}/env
+incdir+../../../verify/uvc/{name}/src
../../../verify/uvc/{name}/env/{name}_pkg.sv
../../../verify/uvc/{name}/src/{name}_if.sv
''',
        'adapter': '''class {name}_reg2{type}_adapter extends uvm_reg_adapter;

  `uvm_object_utils({name}_reg2{type}_adapter)

   function new(string name = "{name}_reg2{type}_adapter");
      super.new(name);
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    {name}_sequence_item {type} = {name}_sequence_item::type_id::create("{type}");
    //Please complete the conversion logic of the bus. Refer to the following as an example.
    {type}.we   = (rw.kind == UVM_READ) ? 0 : 1;
	  {type}.addr = rw.addr;
    {type}.data = rw.data;

    return {type};
  endfunction: reg2bus

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    {name}_sequence_item {type};
    if (!$cast({type}, bus_item)) begin
      `uvm_fatal("NOT_VALID_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    //Please complete the conversion logic of the bus. Refer to the following as an example.
    rw.kind = {type}.we ? UVM_WRITE : UVM_READ;
    rw.addr = {type}.addr;
    rw.data = {type}.data;
    rw.status = UVM_IS_OK;
  endfunction: bus2reg

endclass: {name}_reg2{type}_adapter
'''
    }
    return templates


def generate_uvc(name, output_dir,bus_type):
    name_lower = name.lower()
    name_upper = name.upper()
    name_cap = name.capitalize()
    if(bus_type !=None):
	    bus_type = bus_type.lower()
    
    templates = get_template_content()
    
    dirs_to_create = [
        os.path.join(output_dir, 'src'),
        os.path.join(output_dir, 'env'),
        os.path.join(output_dir, 'script'),
    ]
    
    for d in dirs_to_create:
        os.makedirs(d, exist_ok=True)
        print(f"Created directory: {d}")
    
    file_contents = {
        os.path.join(output_dir, 'src', f'{name_lower}_sequence_item.sv'): templates['sequence_item'].format(name=name_lower,name_upper=name_upper),
        os.path.join(output_dir, 'src', f'{name_lower}_item.sv'): templates['item'].format(name=name_lower,name_upper=name_upper),
        os.path.join(output_dir, 'src', f'{name_lower}_coverage_item.sv'): templates['coverage_item'].format(name=name_lower,name_upper=name_upper),
        os.path.join(output_dir, 'src', f'{name_lower}_sequencer.sv'): templates['sequencer'].format(name=name_lower,name_upper=name_upper),
        os.path.join(output_dir, 'src', f'{name_lower}_base_cfg.sv'): templates['base_cfg'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_cfg.sv'): templates['cfg'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_driver.sv'): templates['driver'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_monitor.sv'): templates['monitor'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_scoreboard.sv'): templates['scoreboard'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_coverage.sv'): templates['coverage'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_agent.sv'): templates['agent'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_if.sv'): templates['if'].format(name=name_lower),
        os.path.join(output_dir, 'src', f'{name_lower}_if_pc.sv'): templates['if_pc'].format(name=name_lower),

        os.path.join(output_dir, 'src', f'{name_lower}_reg2{bus_type}_adapter.sv'): templates['adapter'].format(name=name_lower,type=bus_type),

        os.path.join(output_dir, 'env', f'{name_lower}_env.sv'): templates['env'].format(name=name_lower),
        os.path.join(output_dir, 'env', f'{name_lower}_pkg.sv'): templates['pkg'].format(name=name_lower,name_upper=name_upper),
        os.path.join(output_dir, 'script', 'uvm.f'): templates['uvm_f'].format(name=name_lower),
    }
    
    for file_path, content in file_contents.items():
        if(bus_type ==None and ("adapter" in file_path)):
            continue
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Generated: {file_path}")
    
    print(f"\n{'='*60}")
    print(f"UVC '{name}' generated successfully!")
    print(f"Output directory: {output_dir}")
    print(f"{'='*60}")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description='UVC Auto Generation Script - Generate UVM Verification Component files'
    )
    parser.add_argument('-n', '--name', required=True, help='UVC name (e.g., reg, jls, cpft)')
    parser.add_argument('-o', '--output', default=None, help='Output directory path')
    parser.add_argument('-p', '--parent', default='uvc', help='Parent directory for UVC (default: uvc)')
    parser.add_argument('-t', '--bus_type', default=None, help='Setting bus type for reg model adapter')
    
    args = parser.parse_args()
    
    name = args.name.strip()
    if not name:
        print("Error: UVC name cannot be empty")
        sys.exit(1)
    
    if not re.match(r'^[a-zA-Z][a-zA-Z0-9_]*$', name):
        print("Error: Invalid UVC name. Use letters, numbers, and underscores only.")
        sys.exit(1)
    
    if args.output:
        output_dir = args.output
    else:
        output_dir = os.path.join(args.parent, name)

    if args.bus_type:
        bus_type = args.bus_type
    else:
        bus_type = None
    
    print(f"Generating UVC: {name}")
    print(f"Output directory: {output_dir}")
    print()
    
    generate_uvc(name, output_dir,bus_type)


if __name__ == '__main__':
    main()
