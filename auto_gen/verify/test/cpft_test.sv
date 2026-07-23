`ifndef __CPFT_TEST_SV_
`define __CPFT_TEST_SV_

class cpft_base_test extends base_test;

    string report_id = "cpft_base_test";
    // automation macro
    `uvm_component_utils_begin(cpft_base_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "cpft_base_test",uvm_component parent);
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

endclass : cpft_base_test


`endif  //`ifndef __CPFT_TEST_SV_
