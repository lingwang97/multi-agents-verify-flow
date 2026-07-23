/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your jls sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class jls_base_seq extends base_seq;

    `uvm_object_utils(jls_base_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="jls_base_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting jls_base_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        // build your common cfg or init operation here

    endtask

    task post_body();
        super.post_body();
        `uvm_info(get_type_name(), "Ending jls_base_seq ", UVM_MEDIUM);
    endtask

endclass


/*  ====================================================================================  */
//  All jls sequence classes must inherit from the base class jls_base_seq
/*  ====================================================================================  */
