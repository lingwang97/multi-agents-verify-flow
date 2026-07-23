import uvm_pkg::*;
class efuse_block_base_seq extends uvm_sequence;

    // Virtual interface declarations
    virtual interface efuse_if efuse_vif;
    // Other virtual interface declarations

    // Config declarations
    efuse_pkg::efuse_base_cfg efuse_cfg_h;

    // RAL_model-relative declarations
    RAL_PKG::ral_gen_main ral;
    uvm_status_e status;
    rand uvm_reg_data_t data;

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils(efuse_block_base_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="efuse_block_base_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();

        if (!uvm_config_db #(virtual interface efuse_if)::get(m_sequencer, "","efuse_vif", efuse_vif))
            `uvm_error("EFUSE_VIF:ERROR", "VIF efuse_vif is missing from config_db")    
        // Get other vitual interface

        if (!uvm_config_db #(efuse_pkg::efuse_base_cfg)::get(m_sequencer, "", "efuse_cfg", efuse_cfg_h))begin
            `uvm_warning("EFUSE_CFG:WARNING", "CFG efuse_cfg is missing from config_db,using default")
            efuse_cfg_h = new();
        end

        // Get other cfg

        // Get reg-model handle
        if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(m_sequencer,"", "ral" ,ral))
            `uvm_error(get_full_name(), "Ral handle missing")

    endtask

    virtual task body();
        super.body();
        `uvm_info(get_type_name(), "Starting efuse_block_base_seq", UVM_MEDIUM)

    endtask

    virtual task post_body();
        super.post_body();
        `uvm_info(get_type_name(), "efuse_block_base_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  DEFINE YOUR EFUSE COMMON TASKS AND FUNCTIONS   **
    //*************************************************


endclass: efuse_block_base_seq

/*  ====================================================================================  */
//  All efuse block sequence classes must inherit from the base class efuse_block_base_seq
/*  ====================================================================================  */

