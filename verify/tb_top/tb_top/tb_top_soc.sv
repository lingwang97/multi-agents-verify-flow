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




    // Setting Clkgen initial config and signal connection



    // DUT instance and signal connection 



    // Setting UPF initial config



    // Module < if_conn >  instantiation 
    if_conn if_conn();                                       



    // Program  < sdf_annotate >  instantiation 
    sdf_annotate sdf_annotate();

    initial begin run_test(""); end

endmodule


`include "if_conn.sv"

//***************************************************************************
//******* Program  < sdf_annotate >  is used for annotate sdf file.  ********
//***************************************************************************
program sdf_annotate;
    `include "tb_sdf.sv"
endprogram

// Other Component Module 


// include dut-relative file

