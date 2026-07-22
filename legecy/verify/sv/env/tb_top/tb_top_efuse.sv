`timescale 1ns/1ps
`include "uvm_macros.svh"
import reg_addr::*;
import  btc_pkg::*;

import uvm_pkg::*;


module tb_top;

initial begin
    $timeformat(-9, 3, "ns", 10);
end

//`include "vif_declare.sv"
//*********************************************************
//************* < clk_gen > and wire in tb_top*************

//*********************************************************
virtual efuse_if efuse_vif;
efuse_if efuse_pif();

initial  efuse_vif = efuse_pif;


initial begin
    efuse_pif.xclk_gated=0;
    #10ns;
    forever begin
        #20.83ns efuse_pif.xclk_gated=~efuse_pif.xclk_gated;
    end
end

initial begin
    efuse_pif.pin_ri=1;
    #200ns efuse_pif.pin_ri=0;
end
//********************************************************
wire  pready_out;

assign efuse_pif.xclk=efuse_pif.xclk_gated;

initial begin
    uvm_config_db#(virtual interface efuse_if)::set(uvm_root::get(),"*","efuse_vif", efuse_vif);
end

efuse efuse_inst(

    .xclk_g(efuse_pif.xclk_gated) ,
    .pin_ri(efuse_pif.pin_ri)     ,
    //APB BUS
    .psel(efuse_pif.psel)       ,
    .paddr(efuse_pif.paddr)      ,
    .penable(efuse_pif.penable)    ,
    .pwrite(efuse_pif.pwrite)     ,
    .pwdata(efuse_pif.pwdata)     ,
    .prdata(efuse_pif.prdata)   ,   
    .pready_in(1'b1),
    .pready_out(pready_out)      
);

initial begin   run_test("");   end

`ifdef DUMP_FSDB
    initial begin   $fsdbDumpvars(0,"+all",tb_top);   end
`endif

`include "efuse_if_oomr.sv"

endmodule


