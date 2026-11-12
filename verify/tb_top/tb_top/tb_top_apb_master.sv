//==============================================
//=======block-level Tb for apb_master   ===========
//==============================================

`timescale 1ns/1ps
module tb_top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import tb-relative pkg


    // import dut-relative pkg


    // include tb-relative file

    `include "dump_wave.sv"

    //interface initialation and setting

    virtual  apb_master_if   apb_master_vif;
    apb_master_if            apb_master_pif();

    // vif assignment and config_db publication must share one initial block:
    // there is no initial-block ordering guarantee and the set must not
    // publish an unassigned handle.
    initial begin
        apb_master_vif = apb_master_pif;
        uvm_config_db#(virtual interface apb_master_if)::set(uvm_root::get(),"*","apb_master_vif", apb_master_vif);
    end


    // Setting time display format
    initial begin
        $timeformat(-9, 3, "ns", 10);
    end



    // Setting Rst initial config and signal connection
    // memory[] of apb_v3_sram is initialized only in the !PRESETn branch,
    // so reset must be asserted from time 0 and held for ~20 clocks.
    initial begin
        apb_master_pif.rst = 1'b1;
        repeat (20) @(posedge apb_master_pif.clk);
        apb_master_pif.rst = 1'b0;
    end



    // Setting Clkgen initial config and signal connection
    logic tb_clk;
    initial begin
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    assign apb_master_pif.clk = tb_clk;



    // DUT instance and signal connection
    // EN_WAIT_DELAY_FUNC is switched per-compile: +define+APB_SRAM_EN_WAIT
    // (from the case JSON VCS_MACRO_OPT) builds the wait-state config.
`ifdef APB_SRAM_EN_WAIT
    localparam int unsigned APB_WAIT_EN = 1;
`else
    localparam int unsigned APB_WAIT_EN = 0;
`endif

    apb_v3_sram #(
        .ADDR_BUS_WIDTH      (32),
        .DATA_BUS_WIDTH      (32),
        .MEMSIZE             (64),
        .MEM_BLOCK_SIZE      (32),  // match DATA_BUS_WIDTH: wr_data2mem indexes memory by PADDR only in this config
        .RESET_VAL           (0),
        .EN_WAIT_DELAY_FUNC  (APB_WAIT_EN),
        .MIN_RAND_WAIT_CYC   (0),
        .MAX_RAND_WAIT_CYC   (1)
    ) u_apb_v3_sram (
        .PRESETn (~apb_master_pif.rst),
        .PCLK    (apb_master_pif.clk),
        .PSEL    (apb_master_pif.psel),
        .PENABLE (apb_master_pif.penable),
        .PWRITE  (apb_master_pif.pwrite),
        .PADDR   (apb_master_pif.paddr),
        .PWDATA  (apb_master_pif.pwdata),
        .PRDATA  (apb_master_pif.prdata),
        .PREADY  (apb_master_pif.pready),
        .PSLVERR (apb_master_pif.pslverr)
    );



    // Setting UPF initial config



    // Module < if_conn >  instantiation

    `ifndef GPL_SIM
		`include "apb_master_if_conn.sv"

    `else
		`include "apb_master_if_conn_gpls.sv"

    `endif


    // Program  < sdf_annotate >  instantiation
`ifndef OPEN_EDA
    sdf_annotate sdf_annotate();
`endif

    initial begin run_test(""); end

endmodule


//***************************************************************************
//******* Program  < sdf_annotate >  is used for annotate sdf file.  ********
//***************************************************************************
`ifndef OPEN_EDA
program sdf_annotate;
    `include "tb_sdf.sv"
endprogram
`endif

// Other Component Module


// include dut-relative file
