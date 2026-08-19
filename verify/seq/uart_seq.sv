/*  ============================================================  */
/*  ============================================================  */
/*  **  develop your uart sequence here                       ***/
/*  ============================================================  */
/*  ============================================================  */

class uart_base_seq extends base_seq;

    `uvm_object_utils(uart_base_seq)

    //////////////////////////////////////////////////////////////
    // Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="uart_base_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting uart_base_seq ", UVM_MEDIUM);
    endtask

    task body();
        super.body();
        // build your common cfg or init operation here

    endtask

    task post_body();
        `uvm_info(get_type_name(), "Ending uart_base_seq ", UVM_MEDIUM);
        super.post_body();
    endtask

endclass


/*  ====================================================================================  */
//  All uart sequence classes must inherit from the base class uart_base_seq
/*  ====================================================================================  */

class uart_smoke_seq extends uart_base_seq;
    `uvm_object_utils(uart_smoke_seq)

    function new(string name="uart_smoke_seq");
        super.new(name);
    endfunction : new

    task pre_body();
            super.pre_body();
    endtask

    task body();
        super.body(); 
        `uvm_info(get_type_name(), "uart_smoke_seq start", UVM_MEDIUM);
    
        `uvm_info(get_type_name(), "uart_smoke_seq end", UVM_MEDIUM);

    endtask

    task post_body();
        super.post_body();
    endtask

endclass

