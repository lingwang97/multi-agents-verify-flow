/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your exit_chk sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class exit_chk_seq extends base_seq;

    `uvm_object_utils(exit_chk_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="exit_chk_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting exit_chk_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        

    endtask

    task post_body();
        super.post_body();
        `uvm_info(get_type_name(), "Ending exit_chk_seq ", UVM_MEDIUM);
    endtask

endclass

