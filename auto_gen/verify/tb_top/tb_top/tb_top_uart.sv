//==============================================
//=======block-level Tb for uart   ===========
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

    virtual  uart_if   uart_vif;
    uart_if            uart_pif();   
    initial     uart_vif = uart_pif;

    initial begin
        uvm_config_db#(virtual interface uart_if)::set(uvm_root::get(),"*","uart_vif", uart_vif);
    end


    // Setting time display format
    initial begin
        $timeformat(-9, 3, "ns", 10);
    end



    // Setting Rst initial config and signal connection




    // Setting Clkgen initial config and signal connection



    // DUT instance and signal connection 



    // Setting UPF initial config



    // Module < if_conn >  instantiation 

    `ifndef GPL_SIM
		`include "uart_if_conn.sv"

    `else
		`include "uart_if_conn_gpls.sv"

    `endif                                    



    // Program  < sdf_annotate >  instantiation 
    sdf_annotate sdf_annotate();

    initial begin run_test(""); end

endmodule


//***************************************************************************
//******* Program  < sdf_annotate >  is used for annotate sdf file.  ********
//***************************************************************************
program sdf_annotate;
    `include "tb_sdf.sv"
endprogram

// Other Component Module 


// include dut-relative file

