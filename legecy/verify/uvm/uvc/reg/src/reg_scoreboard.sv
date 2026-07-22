`uvm_analysis_imp_decl(_main_reg_monitor)
class reg_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(reg_scoreboard);
  virtual reg_if reg_vif;
  virtual jls_if jls_vif;
  reg_item reg_item_h;
  reg_item vtsensorw_reg_item;

  uvm_analysis_imp_main_reg_monitor #(reg_item, reg_scoreboard)  reg_scoreboard_main_ap;
  uvm_tlm_analysis_fifo #(reg_item) reg_scoreboard_mon_fifo;
  function new(string name="reg_scoreboard" , uvm_component parent=null);
    super.new(name , parent);

  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       reg_scoreboard_main_ap = new("reg_scoreboard_main_ap",this); 
       reg_scoreboard_mon_fifo = new("reg_scoreboard_mon_fifo",this); 
       
      if (!uvm_config_db #(virtual interface reg_if)::get(this, "", "reg_vif", reg_vif))
        `uvm_error("REG_VIP:ERROR", "VIF reg_vif is missing from config_db")
     
     if (!uvm_config_db #(virtual interface jls_if)::get(this, "", "jls_vif", jls_vif))
        `uvm_error("JLS_VIP:ERROR", "VIF jls_vif is missing from config_db")

    //reg_item_h = reg_item::type_id::create("reg_item_h",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase) ;
  endfunction


  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
   `uvm_info(get_type_name(), $sformatf("Reg_scoreboard begin check"), UVM_MEDIUM)
    fork
      `ifdef USE_RAL_MODEL
      `ifdef USE_JAMLINK_DRV
        //do_pvt_shadow_chk();
      `endif
      `endif
      //do_crc_check();
    join_none
  endtask:run_phase



//   task do_pvt_shadow_chk();
//     forever begin    
//       bit [31:0] vtsensorw_shadow_reg;
//       bit [31:0] vtsensorw_mask = 32'hffff_ffff;
//       vtsensorw_mask[31:15] = 0;

// //      wait(jls_vif.ri_rst_f_n);
//       wait(jls_vif.mid_rst_f_n);  //jira sm2-105
//       //@(posedge reg_vif.clk);
//       reg_scoreboard_mon_fifo.get(reg_item_h); 
//       //`uvm_info(get_type_name(), $sformatf("[PVT] /n%s", reg_item_h.sprint()), UVM_MEDIUM)
//       if(reg_item_h.addr == 32'h700 && reg_item_h.write == 1)begin
//         vtsensorw_reg_item = reg_item_h;

//        //if(reg_item_h.addr == 32'h700 )
//         //`uvm_info(get_type_name(), $sformatf("[PVT] /n%s", reg_item_h.sprint()), UVM_MEDIUM)
//        repeat(4) @(posedge reg_vif.xclk);
//       #10ps;
//        //`uvm_info(get_type_name(), $sformatf("A write item"), UVM_MEDIUM)

//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_tdc_mode_xclk;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_pu_vtdc_xclk << 1;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_rb_xclk << 2;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_trim_xclk << 3;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_clk_div_select_xclk << 8;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_clk_gate_en_xclk << 10;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_test_en_xclk << 11;
//        vtsensorw_shadow_reg += reg_vif.reg_vtsensorw_sel_xclk << 12;
//        if(vtsensorw_shadow_reg == (vtsensorw_reg_item.data & vtsensorw_mask))
//          `uvm_info(get_type_name(), $sformatf("\n[CHKSUC] vtsensorw_reg_item.write = 'h%0h;\nvtsensorw_shadow_reg == vtsensorw_reg_item == 'h%0h", vtsensorw_reg_item.write, vtsensorw_shadow_reg), UVM_MEDIUM)
//        else `uvm_error(get_type_name(),$sformatf("\n[CHKFAIL] vtsensorw_reg_item.write = 'h%0h;\nvtsensorw_shadow_reg = h%0h, vtsensorw_reg_item = 'h%0h",vtsensorw_reg_item.write, vtsensorw_shadow_reg, (vtsensorw_reg_item.data & vtsensorw_mask)))

//       end
//     end
//   endtask:do_pvt_shadow_chk

  virtual function void write_main_reg_monitor(reg_item  reg_item_h);
    begin
     `uvm_info(get_full_name(), $psprintf("reg_scoreboard /n%s", reg_item_h.sprint()), UVM_HIGH)
      //if(reg_item_h.addr == 32'h700)
        //do_pvt_chk(reg_item_h);
    end
  endfunction : write_main_reg_monitor

endclass :  reg_scoreboard
