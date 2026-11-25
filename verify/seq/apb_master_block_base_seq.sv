import uvm_pkg::*;
import apb_master_pkg::*;
class apb_master_block_base_seq extends uvm_sequence;

    // Virtual interface declarations
    virtual interface apb_master_if apb_master_vif;
    // Other virtual interface declarations

    // Config declarations
    apb_master_pkg::apb_master_base_cfg apb_master_cfg_h;
`ifdef OPEN_EDA
    typedef apb_master_pkg::apb_master_base_cfg apb_master_cfg_t;   // oEDA: no pkg-scoped type as a class-parameter argument
`endif

    // no RAL: register front-door/backdoor not used

    // Other declarations
    uvm_table_printer _printer;


    `uvm_object_utils(apb_master_block_base_seq)

   //////////////////////////////////////////////////////////////
   // Used To "New" The Class
   //////////////////////////////////////////////////////////////
    function new(string name="apb_master_block_base_seq");
        super.new(name);
        _printer = new();

    endfunction : new

    virtual task pre_body();
        super.pre_body();

        if (!uvm_config_db #(virtual interface apb_master_if)::get(m_sequencer, "","apb_master_vif", apb_master_vif))
            `uvm_error("APB_MASTER_VIF:ERROR", "VIF apb_master_vif is missing from config_db")
        // Get other vitual interface

`ifdef OPEN_EDA
        if (!uvm_config_db #(apb_master_cfg_t)::get(m_sequencer, "", "apb_master_cfg", apb_master_cfg_h))begin
`else
        if (!uvm_config_db #(apb_master_pkg::apb_master_base_cfg)::get(m_sequencer, "", "apb_master_cfg", apb_master_cfg_h))begin
`endif
            `uvm_warning("APB_MASTER_CFG:WARNING", "CFG apb_master_cfg is missing from config_db,using default")
            apb_master_cfg_h = new();
        end

        // Get other cfg


    endtask

    virtual task body();
        // super.body();
        `uvm_info(get_type_name(), "Starting apb_master_block_base_seq", UVM_MEDIUM)

    endtask

    virtual task post_body();
        // super.post_body();
        `uvm_info(get_type_name(), "apb_master_block_base_seq end", UVM_MEDIUM)

    endtask

    //*************************************************
    //**  APB_MASTER COMMON STIMULUS HELPERS  **
    //**  the driver returns responses (item_done(rsp)), every helper must
    //**  consume its response to keep the sequencer response queue balanced
    //*************************************************

    // one APB write transfer; pslverr returns the observed slave response
    task apb_write(input bit [31:0] addr, input bit [31:0] wdata, output bit pslverr);
        apb_master_sequence_item req_item;
        uvm_sequence_item rsp_generic;
        apb_master_sequence_item rsp_item;
        req_item = apb_master_sequence_item::type_id::create("wr_item");
        start_item(req_item);
        req_item.addr = addr;
        req_item.data = wdata;
        req_item.we   = 1'b1;
        finish_item(req_item);
        get_response(rsp_generic);
        if (!$cast(rsp_item, rsp_generic))
            `uvm_error(get_type_name(), "write response cast failed")
        else
            pslverr = rsp_item.pslverr;
    endtask

    // one APB read transfer; rdata/pslverr return the observed slave response
    task apb_read(input bit [31:0] addr, output bit [31:0] rdata, output bit pslverr);
        apb_master_sequence_item req_item;
        uvm_sequence_item rsp_generic;
        apb_master_sequence_item rsp_item;
        req_item = apb_master_sequence_item::type_id::create("rd_item");
        start_item(req_item);
        req_item.addr = addr;
        req_item.data = '0;
        req_item.we   = 1'b0;
        finish_item(req_item);
        get_response(rsp_generic);
        if (!$cast(rsp_item, rsp_generic))
            `uvm_error(get_type_name(), "read response cast failed")
        else begin
            rdata   = rsp_item.prdata;
            pslverr = rsp_item.pslverr;
        end
    endtask

    // idle gap on the bus (the DUT lags one phase after each transfer)
    task apb_idle(input int unsigned n);
        repeat (n) @(negedge apb_master_vif.clk);
    endtask

endclass: apb_master_block_base_seq

/*  ====================================================================================  */
//  All apb_master block sequence classes must inherit from the base class apb_master_block_base_seq
/*  ====================================================================================  */

//----------------------------------------------
// smoke: a few in-range w/r plus one error pair
//----------------------------------------------
class apb_master_smoke_block_seq extends apb_master_block_base_seq;
    `uvm_object_utils(apb_master_smoke_block_seq)

    function new(string name="apb_master_smoke_block_seq");
        super.new(name);
    endfunction : new

    task pre_body();
            super.pre_body();
    endtask

    task body();
        bit [31:0] rdata;
        bit werr, rerr;

        super.body();
        `uvm_info(get_type_name(), "apb_master_smoke_block_seq start", UVM_MEDIUM);

        apb_write(32'h0000_0000, 32'hA5A5_5A5A, werr);
        apb_read (32'h0000_0000, rdata, rerr);
        apb_write(32'h0000_003F, 32'h1234_5678, werr);
        apb_read (32'h0000_003F, rdata, rerr);
        apb_write(32'h0000_0040, 32'hDEAD_BEEF, werr);  // out-of-range (>= MEMSIZE)
        apb_read (32'h0000_0040, rdata, rerr);          // out-of-range read
        apb_idle(3);

        `uvm_info(get_type_name(), "apb_master_smoke_block_seq end", UVM_MEDIUM);
    endtask

    task post_body();
        super.post_body();
    endtask

endclass

//----------------------------------------------
// reset behaviour: post-reset reads of the whole memory must return
// RESET_VAL(0) with PSLVERR low (scoreboard compares against its model)
//----------------------------------------------
class apb_master_reset_block_seq extends apb_master_block_base_seq;
    `uvm_object_utils(apb_master_reset_block_seq)

    function new(string name="apb_master_reset_block_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [31:0] rdata;
        bit rerr;

        super.body();
        `uvm_info(get_type_name(), "apb_master_reset_block_seq start", UVM_MEDIUM);
        apb_idle(apb_master_cfg_h.idle_cycles);
        for (int unsigned i = 0; i < apb_master_cfg_h.mem_size; i++) begin
            apb_read(i[31:0], rdata, rerr);
            if (rdata !== 32'h0)
                `uvm_error(get_type_name(), $sformatf("post-reset memory not RESET_VAL: addr=0x%08h got=0x%08h", i, rdata))
            if (rerr !== 1'b0)
                `uvm_error(get_type_name(), $sformatf("unexpected PSLVERR on post-reset read: addr=0x%08h", i))
        end
        `uvm_info(get_type_name(), "apb_master_reset_block_seq end", UVM_MEDIUM);
    endtask

endclass

//----------------------------------------------
// random read/write integrity: scoreboard shadow model checks every transfer
//----------------------------------------------
class apb_master_rw_rand_block_seq extends apb_master_block_base_seq;
    `uvm_object_utils(apb_master_rw_rand_block_seq)

    function new(string name="apb_master_rw_rand_block_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [31:0] addr, wdata, rdata;
        bit werr, rerr;
        int unsigned n_trans;

        super.body();
        `uvm_info(get_type_name(), "apb_master_rw_rand_block_seq start", UVM_MEDIUM);
        n_trans = apb_master_cfg_h.num_trans;

        // first two transfers pinned to the boundary addresses
        apb_write(32'h0, $urandom(), werr);
        apb_read (32'h0, rdata, rerr);
        apb_write(32'h3F, $urandom(), werr);
        apb_read (32'h3F, rdata, rerr);

        for (int unsigned i = 4; i < n_trans; i++) begin
            addr  = $urandom_range(apb_master_cfg_h.mem_size - 1, 0);
            wdata = $urandom();
            if ($urandom_range(1, 0)) begin
                apb_write(addr, wdata, werr);
                if (werr !== 1'b0)
                    `uvm_error(get_type_name(), $sformatf("unexpected PSLVERR on in-range write: addr=0x%08h", addr))
            end
            else begin
                apb_read(addr, rdata, rerr);
                if (rerr !== 1'b0)
                    `uvm_error(get_type_name(), $sformatf("unexpected PSLVERR on in-range read: addr=0x%08h", addr))
            end
        end
        `uvm_info(get_type_name(), $sformatf("random phase done: %0d transfers requested", n_trans), UVM_LOW);
        `uvm_info(get_type_name(), "apb_master_rw_rand_block_seq end", UVM_MEDIUM);
    endtask

endclass

//----------------------------------------------
// out-of-range behaviour: PSLVERR on w/r, no write-through to memory,
// PRDATA stays stale on error reads (stale value checked by scoreboard)
//----------------------------------------------
class apb_master_error_block_seq extends apb_master_block_base_seq;
    `uvm_object_utils(apb_master_error_block_seq)

    function new(string name="apb_master_error_block_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [31:0] rdata;
        bit werr, rerr;

        super.body();
        `uvm_info(get_type_name(), "apb_master_error_block_seq start", UVM_MEDIUM);

        // anchor an in-range value
        apb_write(32'hA, 32'hCAFE_BABE, werr);
        apb_read (32'hA, rdata, rerr);
        if (rdata !== 32'hCAFE_BABE)
            `uvm_error(get_type_name(), $sformatf("anchor read-back failed: got=0x%08h", rdata))

        // out-of-range writes: PSLVERR expected, no memory effect
        apb_write(32'h40,        32'h1111_1111, werr);
        if (werr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range write @0x40")
        apb_idle(1);
        apb_write(32'h41,        32'h2222_2222, werr);
        if (werr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range write @0x41")
        apb_write(32'h64,        32'h3333_3333, werr);
        if (werr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range write @0x64")
        apb_write(32'h100,       32'h4444_4444, werr);
        if (werr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range write @0x100")
        apb_write(32'hFFFF_FFFF, 32'h5555_5555, werr);
        if (werr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range write @0xFFFFFFFF")

        // out-of-range reads: PSLVERR expected, PRDATA stale (scoreboard checks)
        apb_read(32'h40,        rdata, rerr);
        if (rerr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range read @0x40")
        apb_read(32'hFFFF_FFFF, rdata, rerr);
        if (rerr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on out-of-range read @0xFFFFFFFF")

        // anchor must be intact: error writes never reached the memory
        apb_read(32'hA, rdata, rerr);
        if (rdata !== 32'hCAFE_BABE)
            `uvm_error(get_type_name(), $sformatf("memory corrupted by out-of-range writes: addr=0xA got=0x%08h", rdata))

        `uvm_info(get_type_name(), "apb_master_error_block_seq end", UVM_MEDIUM);
    endtask

endclass

//----------------------------------------------
// boundary addresses: 0/1/62/63 in range, 64 is the first error address
//----------------------------------------------
class apb_master_boundary_block_seq extends apb_master_block_base_seq;
    `uvm_object_utils(apb_master_boundary_block_seq)

    function new(string name="apb_master_boundary_block_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [31:0] rdata;
        bit werr, rerr;

        super.body();
        `uvm_info(get_type_name(), "apb_master_boundary_block_seq start", UVM_MEDIUM);

        apb_write(32'h0, 32'h0000_0001, werr);
        apb_read (32'h0, rdata, rerr);
        apb_write(32'h1, 32'h8000_0000, werr);
        apb_read (32'h1, rdata, rerr);
        apb_write(32'h3E, 32'hAAAA_5555, werr);
        apb_read (32'h3E, rdata, rerr);
        apb_write(32'h3F, 32'h5555_AAAA, werr);
        apb_read (32'h3F, rdata, rerr);
        apb_write(32'h40, 32'h6666_6666, werr);
        if (werr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on boundary error write @0x40")
        apb_read (32'h40, rdata, rerr);
        if (rerr !== 1'b1) `uvm_error(get_type_name(), "missing PSLVERR on boundary error read @0x40")

        `uvm_info(get_type_name(), "apb_master_boundary_block_seq end", UVM_MEDIUM);
    endtask

endclass

//----------------------------------------------
// wait states (built with +APB_SRAM_EN_WAIT): mixed transfers must complete
// with the master holding ACCESS until PREADY; wait_cyc_limit is drawn once
// at time 0, so wait_cycles is logged/covered, never asserted
//----------------------------------------------
class apb_master_wait_block_seq extends apb_master_block_base_seq;
    `uvm_object_utils(apb_master_wait_block_seq)

    function new(string name="apb_master_wait_block_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [31:0] rdata;
        bit werr, rerr;

        super.body();
        `uvm_info(get_type_name(), "apb_master_wait_block_seq start", UVM_MEDIUM);

        for (int unsigned i = 0; i < 10; i++) begin
            apb_write(i[31:0], 32'h9000_0000 + i, werr);
            if (werr !== 1'b0)
                `uvm_error(get_type_name(), $sformatf("unexpected PSLVERR on write in wait test: addr=0x%08h", i))
            apb_read(i[31:0], rdata, rerr);
            if (rdata !== (32'h9000_0000 + i))
                `uvm_error(get_type_name(), $sformatf("wait-test read mismatch: addr=0x%08h got=0x%08h", i, rdata))
        end

        `uvm_info(get_type_name(), "apb_master_wait_block_seq end", UVM_MEDIUM);
    endtask

endclass
