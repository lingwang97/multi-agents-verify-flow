/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your ro sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class ro_base_seq extends base_seq;

    `uvm_object_utils(ro_base_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="ro_base_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting ro_base_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        // build your common cfg or init operation here

    endtask

    task post_body();
        `uvm_info(get_type_name(), "Ending ro_base_seq ", UVM_MEDIUM);
        super.post_body();
    endtask

endclass


/*  ====================================================================================  */
//  All ro sequence classes must inherit from the base class ro_base_seq
/*  ====================================================================================  */

class ro_smoke_seq extends ro_base_seq;
    `uvm_object_utils(ro_smoke_seq)

    function new(string name="ro_smoke_seq");
        super.new(name);
    endfunction : new

    task pre_body();
            super.pre_body();
    endtask

    task body();
        super.body(); 
        `uvm_info(get_type_name(), "ro_smoke_seq start", UVM_MEDIUM);
    
        `uvm_info(get_type_name(), "ro_smoke_seq end", UVM_MEDIUM);

    endtask

    task post_body();
        super.post_body();
    endtask

endclass

