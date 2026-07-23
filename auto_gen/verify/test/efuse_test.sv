`ifndef __EFUSE_TEST_SV_
`define __EFUSE_TEST_SV_

class efuse_base_test extends base_test;

    string report_id = "efuse_base_test";
    // automation macro
    `uvm_component_utils_begin(efuse_base_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "efuse_base_test",uvm_component parent);
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

endclass : efuse_base_test


`endif  //`ifndef __EFUSE_TEST_SV_
