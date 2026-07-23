import uvm_pkg::*;
class uart_block_base_seq extends uvm_sequence;

    // Virtual interface declarations
    virtual interface uart_if uart_vif;
    // Other virtual interface declarations

    // Config declarations
    uart_pkg::uart_base_cfg uart_cfg_h;

    // RAL_model-relative declarations
    RAL_PKG::ral_gen_main ral;
    uvm_status_e status;
    rand uvm_reg_data_t data;

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils(uart_block_base_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="uart_block_base_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();

        if (!uvm_config_db #(virtual interface uart_if)::get(m_sequencer, "","uart_vif", uart_vif))
            `uvm_error("UART_VIF:ERROR", "VIF uart_vif is missing from config_db")    
        // Get other vitual interface

        if (!uvm_config_db #(uart_pkg::uart_base_cfg)::get(m_sequencer, "", "uart_cfg", uart_cfg_h))begin
            `uvm_warning("UART_CFG:WARNING", "CFG uart_cfg is missing from config_db,using default")
            uart_cfg_h = new();
        end

        // Get other cfg

        // Get reg-model handle
        if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(m_sequencer,"", "ral" ,ral))
            `uvm_error(get_full_name(), "Ral handle missing")

    endtask

    virtual task body();
        super.body();
        `uvm_info(get_type_name(), "Starting uart_block_base_seq", UVM_MEDIUM)

    endtask

    virtual task post_body();
        super.post_body();
        `uvm_info(get_type_name(), "uart_block_base_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  DEFINE YOUR UART COMMON TASKS AND FUNCTIONS   **
    //*************************************************


endclass: uart_block_base_seq

/*  ====================================================================================  */
//  All uart block sequence classes must inherit from the base class uart_block_base_seq
/*  ====================================================================================  */

