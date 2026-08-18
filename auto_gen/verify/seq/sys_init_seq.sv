/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your sys_init sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class sys_init_seq extends base_seq;

    `uvm_object_utils(sys_init_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="sys_init_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting sys_init_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        

    endtask

    task post_body();
        `uvm_info(get_type_name(), "Ending sys_init_seq ", UVM_MEDIUM);
        super.post_body();
    endtask

endclass

