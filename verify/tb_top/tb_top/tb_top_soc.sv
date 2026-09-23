//==============================================
//=======System-level Tb for soc   ===========
//==============================================

`timescale 1ns/1ps
module tb_top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import tb-relative pkg


    // import dut-relative pkg


    // include tb-relative file
    `include "vif_declare.sv"
    `include "dump_wave.sv"



    // Setting time display format
    initial begin
        $timeformat(-9, 3, "ns", 10);
    end

    // Setting Rst initial config and signal connection
    initial begin
        top_pif.rst   = 1'b1;
        reg_pif.rst   = 1'b1;
        jls_pif.rst   = 1'b1;
        ro_pif.rst    = 1'b1;
        uart_pif.rst  = 1'b1;
        efuse_pif.rst = 1'b1;
        #100;
        top_pif.rst   = 1'b0;
        reg_pif.rst   = 1'b0;
        jls_pif.rst   = 1'b0;
        ro_pif.rst    = 1'b0;
        uart_pif.rst  = 1'b0;
        efuse_pif.rst = 1'b0;
    end



    // Setting Clkgen initial config and signal connection
    logic tb_clk;
    initial begin
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    assign top_pif.clk   = tb_clk;
    assign reg_pif.clk   = tb_clk;
    assign jls_pif.clk   = tb_clk;
    assign ro_pif.clk    = tb_clk;
    assign uart_pif.clk  = tb_clk;
    assign efuse_pif.clk = tb_clk;



    // DUT instance and signal connection
    // Placeholder stub DUT (hdl/rtl/soc_stub.sv) for local open-source sim;
    // replaced by the real design when the hdl/ database lands.
    soc_stub u_soc_stub (
        .clk        (reg_pif.clk),
        .rst        (reg_pif.rst),
        .card_sel   (reg_pif.card_sel),
        .reg_ctrl   (reg_pif.reg_ctrl),
        .reg_status ()                    // reg_if has no status input; leave open
    );



    // Setting UPF initial config



    // Module < if_conn >  instantiation
    if_conn if_conn();



`ifndef VERILATOR
    // Program  < sdf_annotate >  instantiation
    sdf_annotate sdf_annotate();
`endif

    initial begin run_test(""); end

endmodule


`include "if_conn.sv"

`ifndef VERILATOR
//***************************************************************************
//******* Program  < sdf_annotate >  is used for annotate sdf file.  ********
//***************************************************************************
program sdf_annotate;
    `include "tb_sdf.sv"
endprogram
`endif

// Other Component Module


// include dut-relative file
