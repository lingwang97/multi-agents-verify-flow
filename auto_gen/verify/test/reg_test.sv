`ifndef __REG_TEST_SV_
`define __REG_TEST_SV_

class reg_base_test extends base_test;

    string report_id = "reg_base_test";
    // automation macro
    `uvm_component_utils_begin(reg_base_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "reg_base_test",uvm_component parent);
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

endclass : reg_base_test


`endif  //`ifndef __REG_TEST_SV_
