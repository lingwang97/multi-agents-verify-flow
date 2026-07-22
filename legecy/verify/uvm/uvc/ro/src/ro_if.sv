interface ro_if ();

   import uvm_pkg::*;
   import global_pkg::*;
import reg_addr::*;   
   string       report_id = "cal_adc_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["ro_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["ro_if"];

   initial begin
      IF_CHECKS_ENABLE["ro_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["ro_if"] = 1'b1;   //initially on
   end


   logic clk;
   logic rst;
   logic card_sel;


   logic ro_clk;

   logic reg_ro_cg_en;

   //////////////////////////////////////////////////////////////
   // RO VLD
   //////////////////////////////////////////////////////////////

   logic [3:0] RO_div_num;

   //////////////////////////////////////////////////////////////
   // RO 0 : ro in slice0
   //////////////////////////////////////////////////////////////

   logic RO0_rdy_inst0;
   logic RO0_rdy_inst1;
   logic RO0_rdy_inst2;

   logic [5:0] RO0_sel_inst0;
   logic [5:0] RO0_sel_inst1;
   logic [5:0] RO0_sel_inst2;

   //////////////////////////////////////////////////////////////
   // RO 1 : ro in pd_top
   //////////////////////////////////////////////////////////////

   logic RO1_rdy_inst0;
   logic RO1_rdy_inst1;
   logic RO1_rdy_inst2;

   logic [5:0] RO1_sel_inst0;
   logic [5:0] RO1_sel_inst1;
   logic [5:0] RO1_sel_inst2;

   //////////////////////////////////////////////////////////////
   // RO 2 : ro in pd_top
   //////////////////////////////////////////////////////////////

   logic RO2_rdy_inst0;
   logic RO2_rdy_inst1;
   logic RO2_rdy_inst2;

   logic [5:0] RO2_sel_inst0;
   logic [5:0] RO2_sel_inst1;
   logic [5:0] RO2_sel_inst2;


   logic ro0_ro_core0_rdy;
   logic ro0_ro_core0_rosc;
   logic ro0_ro_core1_rdy;
   logic ro0_ro_core1_rosc;
   logic ro0_ro_core2_rdy;
   logic ro0_ro_core2_rosc;
   
   logic ro1_ro_core0_rdy;
   logic ro1_ro_core0_rosc;
   logic ro1_ro_core1_rdy;
   logic ro1_ro_core1_rosc;
   logic ro1_ro_core2_rdy;
   logic ro1_ro_core2_rosc;
  

 



`ifdef RO_TEST
`ifndef FPGA_SYN
`ifndef STUB_RO
   initial begin

      int all_five_array[12]='{19,20,21,22,26,27,28,29,33,34,35,36};
      int find_res[$];

     `ifndef PL_SIM //RTL_SIM

         for(int i=26;i<40;i++)begin
            for(int l=0;l<2;l++)begin
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.XIdont_touch_pulse_to_ro.netq",l,i), 1'b0);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.XIdont_touch_pulse_to_ro.netq",l,i), 1'b0);
            end
         end

         for(int i=19;i<40;i++)begin
            for(int l=0;l<2;l++)begin
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.XIdont_touch_mblat.CP ",l,i), 1'b0);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.XIdont_touch_mblat.CP ",l,i), 1'b0);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.net2nand",l,i), 1'b1);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.net2nand",l,i), 1'b1);
            end
         end

         for(int i=19;i<40;i++)begin
            for(int l=0;l<2;l++)begin
               find_res=all_five_array.find with(item ==i);
               if($size(find_res)==1)  begin
                  `uvm_info("lvro init value deposit",$sformatf("current line=%0d init D_value is 32'h5555_5555",i),UVM_MEDIUM)
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.D",l,i), 32'h5555_5555);
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.D",l,i), 32'h5555_5555);
               end
               else begin
                  `uvm_info("lvro init value deposit",$sformatf("current line=%0d init D_value is 64'haaaa_aaaa_5555_5555",i),UVM_MEDIUM)
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.D",l,i), 64'haaaa_aaaa_5555_5555);
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK[%0d].RO_INST.u_rosc.u_DL%0d.D",l,i), 64'haaaa_aaaa_5555_5555);
               end
            end
         end

     `else //post_gate sim*****

         for(int i=26;i<40;i++)begin
            for(int l=0;l<2;l++)begin
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.XIdont_touch_pulse_to_ro.netq",l,i), 1'b0);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.XIdont_touch_pulse_to_ro.netq",l,i), 1'b0);
            end
         end

         for(int i=19;i<40;i++)begin
            for(int l=0;l<2;l++)begin
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.XIdont_touch_mblat.CP ",l,i), 1'b0);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.XIdont_touch_mblat.CP ",l,i), 1'b0);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.net2nand",l,i), 1'b1);
               uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.net2nand",l,i), 1'b1);
            end
         end

         for(int i=19;i<40;i++)begin
            for(int l=0;l<2;l++)begin
               find_res=all_five_array.find with(item ==i);
               if($size(find_res)==1)  begin
                  `uvm_info("lvro init value deposit",$sformatf("current line=%0d init D_value is 32'h5555_5555",i),UVM_MEDIUM)
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.D",l,i), 32'h5555_5555);
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.D",l,i), 32'h5555_5555);
               end
               else begin
                  `uvm_info("lvro init value deposit",$sformatf("current line=%0d init D_value is 64'haaaa_aaaa_5555_5555",i),UVM_MEDIUM)
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.D",l,i), 64'haaaa_aaaa_5555_5555);
                  uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.D",l,i), 64'haaaa_aaaa_5555_5555);
               end
            end
         end

         // for(int i=19;i<40;i++)begin
         //    for(int l=0;l<2;l++)begin
         //       uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.EN",l,i), 1'b0);
         //       uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.EN",l,i), 1'b0);
         //    end
         // end
         // //@(posedge rst);
         // #2ns;
         // for(int i=19;i<40;i++)begin
         //    for(int l=0;l<2;l++)begin
         //       uvm_hdl_release($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_slice1.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.EN",l,i));
         //       uvm_hdl_release($sformatf("tb_top.C[0].btnode.btc.lvro_wrapper_top.G_CORE_RO_BLK_%0d__RO_INST.u_rosc.u_DL%0d.EN",l,i));
         //    end
         // end

     `endif
//---------------------------------
     $display($time, " [debug] LVRO MBLAT deposit completed .. .. ..");

   end
`endif
`endif
`endif




   `include "../../../verify/uvm/uvc/ro/src/ro_if_pc.sv"  


endinterface : ro_if
