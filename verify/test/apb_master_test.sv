
class apb_master_base_test extends base_test;

    string report_id = "apb_master_base_test";
    // automation macro
    `uvm_component_utils_begin(apb_master_base_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "apb_master_base_test",uvm_component parent);
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

endclass : apb_master_base_test

class apb_master_smoke_test extends apb_master_base_test;

    string report_id = "apb_master_smoke_test"; 
    // automation macro
    `uvm_component_utils_begin(apb_master_smoke_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "apb_master_smoke_test",uvm_component parent);
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
 
        apb_master_smoke_seq   seq;
        phase.raise_objection(this);
        seq = apb_master_smoke_seq::type_id::create("apb_master_smoke_seq");
        seq.start(vseqr_h.apb_master_seqr_h);
        phase.drop_objection(this);

    endtask
    
endclass : apb_master_smoke_test

