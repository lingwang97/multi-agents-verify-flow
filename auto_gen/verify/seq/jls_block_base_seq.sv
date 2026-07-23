import uvm_pkg::*;
class jls_block_base_seq extends uvm_sequence;

    // Virtual interface declarations
    virtual interface jls_if jls_vif;
    // Other virtual interface declarations

    // Config declarations
    jls_pkg::jls_base_cfg jls_cfg_h;

    // RAL_model-relative declarations
    RAL_PKG::ral_gen_main ral;
    uvm_status_e status;
    rand uvm_reg_data_t data;

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils(jls_block_base_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="jls_block_base_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();

        if (!uvm_config_db #(virtual interface jls_if)::get(m_sequencer, "","jls_vif", jls_vif))
            `uvm_error("JLS_VIF:ERROR", "VIF jls_vif is missing from config_db")    
        // Get other vitual interface

        if (!uvm_config_db #(jls_pkg::jls_base_cfg)::get(m_sequencer, "", "jls_cfg", jls_cfg_h))begin
            `uvm_warning("JLS_CFG:WARNING", "CFG jls_cfg is missing from config_db,using default")
            jls_cfg_h = new();
        end

        // Get other cfg

        // Get reg-model handle
        if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(m_sequencer,"", "ral" ,ral))
            `uvm_error(get_full_name(), "Ral handle missing")

    endtask

    virtual task body();
        super.body();
        `uvm_info(get_type_name(), "Starting jls_block_base_seq", UVM_MEDIUM)

    endtask

    virtual task post_body();
        super.post_body();
        `uvm_info(get_type_name(), "jls_block_base_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  DEFINE YOUR JLS COMMON TASKS AND FUNCTIONS   **
    //*************************************************


endclass: jls_block_base_seq

/*  ====================================================================================  */
//  All jls block sequence classes must inherit from the base class jls_block_base_seq
/*  ====================================================================================  */

