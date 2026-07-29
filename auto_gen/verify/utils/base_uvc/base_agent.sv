class base_agent extends uvm_agent;

  uvm_active_passive_enum is_active;

  `uvm_component_utils_begin(base_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="base_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

endclass : base_agent 
