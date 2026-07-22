interface cpft_if ();

   import uvm_pkg::*;
   import global_pkg::*;
import reg_addr::*;   
   string       report_id = "cal_adc_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["cpft_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["cpft_if"];

   initial begin
      IF_CHECKS_ENABLE["cpft_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["cpft_if"] = 1'b1;   //initially on
   end


   logic clk;
   logic rst;
   logic card_sel;
   logic g_cp_ft_sample;
   logic xclk;
   logic spd_fresh_done;
   logic ft_pending;
   `include "../../../verify/uvm/uvc/cpft/src/cpft_if_pc.sv"  



   //**************start dump **********
   task dump_cp(input string vcd_filename, input bit p_ft_switch=0);

       `uvm_info("[CPFT]",$sformatf("\n[NOTE]\tStart Dump VCD file %s at\n",vcd_filename),UVM_LOW)
       begin:setc_cp_dumpvars
           $display($time, "setting dumpvars ...");
           `ifndef PL_SIM
               $dumpvars(0, `BTC0.DSEL);
               $dumpvars(0, `BTC0.FBDI_FBDO);
               $dumpvars(0, `BTC0.FBDO_FBDI);
               $dumpvars(0, `BTC0.CKI_CO);
               $dumpvars(0, `BTC0.CKO_CI);
               $dumpvars(0, `BTC0.CI_CKO);
               $dumpvars(0, `BTC0.CO_CKI);
               $dumpvars(0, `BTC0.RI_DO);
               $dumpvars(0, `BTC0.DI_RO);
               $dumpvars(0, `BTC0.RO_DI);
               $dumpvars(0, `BTC0.DO_RI);
               $dumpvars(0, `BTC0.TO);
               $dumpvars(0, `BTC0.SEL);
    
               //dump apb interface
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.paddr);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.pwdata);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.psel);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.penable);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.pwrite);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.pready);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.mid_apb_decoder.prdata);

               //dump xclk apb interface
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.paddr);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.pwdata);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.psel);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.penable);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.pwrite);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.pready);
               $dumpvars(0, `BTC0.sys_ctrl.comm_interface.xclk_apb_decoder.prdata);              
               if(p_ft_switch === 1'b1)
                   $dumpvars(0, g_cp_ft_sample);
           
               //g_cp_dumpvars_switch = 1;
           `endif    
       end:setc_cp_dumpvars

       $dumpfile(vcd_filename);
       $dumpon;
   
   endtask


   //**************stop dump***********
   task undump_cp();
       $dumpoff;
       `uvm_info("[CPFT]",$sformatf("\n[NOTE]\tComplete Dump VCD file .......... \n"),UVM_LOW)

   endtask
   
   //each round start
`ifndef PL_SIM
  initial begin
    g_cp_ft_sample = 1'b0;
    //forever @(posedge `BTC0.sys_ctrl.work_ctrl.ft_gate) begin
    forever @(posedge spd_fresh_done) begin
      if((spd_fresh_done===1)&&(ft_pending===1)) begin
        repeat(20) @(posedge xclk);
        g_cp_ft_sample = 1'b1;
        repeat(8) @(posedge xclk);
        g_cp_ft_sample = 1'b0;
      end
    end
  end
`endif



endinterface : cpft_if
