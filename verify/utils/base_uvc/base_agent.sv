class base_agent extends uvm_agent;

  `uvm_component_utils(base_agent)

  function new(string name="base_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

endclass : base_agent 
