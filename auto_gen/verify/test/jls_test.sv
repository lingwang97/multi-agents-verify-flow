
class jls_base_test extends base_test;

    string report_id = "jls_base_test";
    // automation macro
    `uvm_component_utils_begin(jls_base_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "jls_base_test",uvm_component parent);
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

endclass : jls_base_test

class jls_smoke_test extends jls_base_test;

    string report_id = "jls_smoke_test"; 
    // automation macro
    `uvm_component_utils_begin(jls_smoke_test)
    `uvm_component_utils_end

    // constructor
    function new(string name = "jls_smoke_test",uvm_component parent);
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
        //set_if_checks_enable(.name("jls_if"),.enable(OFF));
        //set_if_cov_enable(.name("jls_if"),.enable(OFF));
        //set_mon_checks_enable(.name("jls_monitor_h"),.enable(OFF));
        //set_mon_cov_enable(.name("jls_monitor_h"),.enable(OFF));
        //set_sb_checks_enable(.name("jls_scoreboard_h"),.enable(OFF));

    endfunction: start_of_simulation_phase

    task main_phase(uvm_phase phase);
 
        jls_smoke_seq   seq;
        phase.raise_objection(this);
        seq = jls_smoke_seq::type_id::create("jls_smoke_seq");
        seq.start(vseqr_h.jls_seqr_h);
        phase.drop_objection(this);

    endtask
    
endclass : jls_smoke_test

