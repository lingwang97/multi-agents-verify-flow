`ifndef __BASE_SEQ_SV_
`define __BASE_SEQ_SV_

import global_pkg::*;
import reg_mdl_pkg::*;

class base_seq extends uvm_sequence;

    top_env top_env_h;
    // Virtual interface declarations
    virtual interface top_if top_vif;
    virtual interface reg_if reg_vif;
    virtual interface apb_master_if apb_master_vif;
    virtual interface ro_if ro_vif;
    virtual interface uart_if uart_vif;
    virtual interface efuse_if efuse_vif;

    // Other virtual interface declarations

    // Config declarations
    reg_pkg::reg_base_cfg reg_cfg_h;
`ifdef OPEN_EDA
    typedef reg_pkg::reg_base_cfg reg_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    apb_master_pkg::apb_master_base_cfg apb_master_cfg_h;
`ifdef OPEN_EDA
    typedef apb_master_pkg::apb_master_base_cfg apb_master_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    ro_pkg::ro_base_cfg ro_cfg_h;
`ifdef OPEN_EDA
    typedef ro_pkg::ro_base_cfg ro_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    uart_pkg::uart_base_cfg uart_cfg_h;
`ifdef OPEN_EDA
    typedef uart_pkg::uart_base_cfg uart_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif
    efuse_pkg::efuse_base_cfg efuse_cfg_h;
`ifdef OPEN_EDA
    typedef efuse_pkg::efuse_base_cfg efuse_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif

    // RAL_model-relative declarations
    RAL_PKG::ral_gen_main ral;
    uvm_status_e status;
    rand uvm_reg_data_t data;

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils(base_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="base_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();
        `uvm_info(get_type_name(), "Starting base_seq", UVM_MEDIUM)
        if (!uvm_config_db #(top_env)::get(m_sequencer, "", "top_env", top_env_h))
            `uvm_error("TOP_ENV:ERROR", "Env top_env is missing from config_db")
        if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
            `uvm_error("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface reg_if)::get(m_sequencer, "", "reg_vif", reg_vif))
            `uvm_error("REG_VIF:ERROR", "VIF reg_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface apb_master_if)::get(m_sequencer, "", "apb_master_vif", apb_master_vif))
            `uvm_error("APB_MASTER_VIF:ERROR", "VIF apb_master_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface ro_if)::get(m_sequencer, "", "ro_vif", ro_vif))
            `uvm_error("RO_VIF:ERROR", "VIF ro_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface uart_if)::get(m_sequencer, "", "uart_vif", uart_vif))
            `uvm_error("UART_VIF:ERROR", "VIF uart_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface efuse_if)::get(m_sequencer, "", "efuse_vif", efuse_vif))
            `uvm_error("EFUSE_VIF:ERROR", "VIF efuse_vif is missing from config_db")
        // Get other vitual interface


`ifdef OPEN_EDA
        if (!uvm_config_db #(reg_cfg_t)::get(m_sequencer, "", "reg_cfg", reg_cfg_h))begin
`else
        if (!uvm_config_db #(reg_pkg::reg_base_cfg)::get(m_sequencer, "", "reg_cfg", reg_cfg_h))begin
`endif
            `uvm_warning("REG_CFG:WARNING", "CFG reg_cfg is missing from config_db,using default")
            reg_cfg_h = new();
        end
`ifdef OPEN_EDA
        if (!uvm_config_db #(apb_master_cfg_t)::get(m_sequencer, "", "apb_master_cfg", apb_master_cfg_h))begin
`else
        if (!uvm_config_db #(apb_master_pkg::apb_master_base_cfg)::get(m_sequencer, "", "apb_master_cfg", apb_master_cfg_h))begin
`endif
            `uvm_warning("APB_MASTER_CFG:WARNING", "CFG apb_master_cfg is missing from config_db,using default")
            apb_master_cfg_h = new();
        end
`ifdef OPEN_EDA
        if (!uvm_config_db #(ro_cfg_t)::get(m_sequencer, "", "ro_cfg", ro_cfg_h))begin
`else
        if (!uvm_config_db #(ro_pkg::ro_base_cfg)::get(m_sequencer, "", "ro_cfg", ro_cfg_h))begin
`endif
            `uvm_warning("RO_CFG:WARNING", "CFG ro_cfg is missing from config_db,using default")
            ro_cfg_h = new();
        end
`ifdef OPEN_EDA
        if (!uvm_config_db #(uart_cfg_t)::get(m_sequencer, "", "uart_cfg", uart_cfg_h))begin
`else
        if (!uvm_config_db #(uart_pkg::uart_base_cfg)::get(m_sequencer, "", "uart_cfg", uart_cfg_h))begin
`endif
            `uvm_warning("UART_CFG:WARNING", "CFG uart_cfg is missing from config_db,using default")
            uart_cfg_h = new();
        end
`ifdef OPEN_EDA
        if (!uvm_config_db #(efuse_cfg_t)::get(m_sequencer, "", "efuse_cfg", efuse_cfg_h))begin
`else
        if (!uvm_config_db #(efuse_pkg::efuse_base_cfg)::get(m_sequencer, "", "efuse_cfg", efuse_cfg_h))begin
`endif
            `uvm_warning("EFUSE_CFG:WARNING", "CFG efuse_cfg is missing from config_db,using default")
            efuse_cfg_h = new();
        end
        // Get other cfg


        // Get reg-model handle
        ral = top_env_h.ral;

    endtask

    virtual task body();
        //super.body();


    endtask

    virtual task post_body();
        //super.post_body();
        `uvm_info(get_type_name(), "base_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  DEFINE YOUR GLOBAL TASKS AND FUNCTIONS   **
    //*************************************************

    virtual task wait_cycles(input bit[31:0] n_cycles);
        repeat(n_cycles) @(posedge top_vif.clk);
    endtask: wait_cycles

    virtual task wait_rst_n();
        wait(top_vif.rst == 1'b1);
    endtask: wait_rst_n




// inlcude each module comm task and functions
`include "comm_reg_methods.sv"
`include "comm_apb_master_methods.sv"
`include "comm_ro_methods.sv"
`include "comm_uart_methods.sv"
`include "comm_efuse_methods.sv"

endclass: base_seq
`endif
