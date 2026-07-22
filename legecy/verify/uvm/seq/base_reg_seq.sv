/*  ============================================================  */
/*  ==========================     reg     =====================  */
/*  ============================================================  */

`ifndef BASE_REG_SEQ
`define BASE_REG_SEQ

/*  ============================================================  */
/*  Function:                                                     */
/*  wait for  power on reset                                      */
/*  ============================================================  */
virtual task set_wait_for_reset();
 `uvm_info(get_type_name(), $sformatf("[RESET] Wait for reset"), UVM_MEDIUM)
 #200;
 ral.reset();
 //force not on reset state
 wait(top_vif.ri_rst_n === 1'b1);
 #200;
 //release reset flag
  `MIR_REG_BKDR(crg, ri_wen);
  `SET_REG_FIELD(crg, ri_wen, ri_wen, 1'b1);
  `UPDATE_REG(crg, ri_wen);    
  
  `MIR_REG_BKDR(crg, ri_enable);
  `SET_REG_FIELD(crg, ri_enable, ri_function_pre, 1'b0);
  `UPDATE_REG(crg, ri_enable);    
  #200;
 `uvm_info(get_type_name(), $sformatf("[RESET] Reset end"), UVM_MEDIUM)
endtask:set_wait_for_reset


/*  ============================================================  */
/*  Function:                                                     */
/*  change mid_clk config                                         */
/*  ============================================================  */
virtual task switch_clk(input bit common_sel_xclk = 0);
  //set 0 to switch to xclk, set 1 to switch to pll0 clk
  `MIR_REG_BKDR(crg,mux);
  `SET_REG_FIELD(crg, mux, mid_clk_mux, common_sel_xclk);
  `PRINT_REG_SETTING(crg,mux);
  `UPDATE_REG(crg,mux);    
  `uvm_info(get_type_name(), $sformatf("switch to 'd%0d clk", common_sel_xclk), UVM_MEDIUM)
endtask:switch_clk

/*  ============================================================  */
/*  Function:                                                     */
/*  only wrc pll0 in order to speedup mid_clk config,             */
/*  ============================================================  */
//task wrc_cpm_pll_x(input [2:0] idx = 0);
//  logic [7:0] now_chipaddr;
//
//  `uvm_info(get_type_name(), $sformatf("Write pll%0d start", idx), UVM_MEDIUM); 

//  //step 1 config com pllcomcfg
//  `SET_REG_FIELD(crg,pll_com_cfg,pll_com_cfg_xclk_div_num,cpm_cfg_h.xclk_div_num);
//  `SET_REG_FIELD(crg,pll_com_cfg,pll_com_cfg_lock_timer,cpm_cfg_h.lock_timer);
//  `PRINT_REG_SETTING(crg,pll_com_cfg);
//  `UPDATE_REG(crg,pll_com_cfg);
//  
//  `SET_REG_FIELD(crg,mux,mid_clk_div,cpm_cfg_h.mid_clk_div);
//  //`SET_REG_FIELD(crg,mux,mid_clk_div2,cpm_cfg_h.mid_clk_div2);
//  //`SET_REG_FIELD(crg,mux,mid_clk_div1,cpm_cfg_h.mid_clk_div1);
//  //`SET_REG_FIELD(crg,mux,mid_clk_mux,cpm_cfg_h.mid_clk_mux);
//  `PRINT_REG_SETTING(crg,mux);
//  `UPDATE_REG(crg,mux);    
//
//  // //step2 config pll rstt 
//  // `WR_REG(crg,pllrstt,cpm_cfg_h.pllrstt);
//  // `PRINT_REG_SETTING(crg,pllrstt);
//
//  // ////step2 config pll chgt 
//  // `WR_REG(crg,pllchgt,cpm_cfg_h.pllchgt);
//  // `PRINT_REG_SETTING(crg,pllchgt);
//
//  //step 3 config pllxl
//  wrc_pll_reg(idx);
//    `ifdef USE_JAMLINK_DRV
//        //step 4 wati pll stable
//        // now_chipaddr = top_vif.chipaddr;
//        if(top_vif.chipaddr==`BRD_ADDR) begin
//            `uvm_info(get_type_name(),$psprintf("wait pll stable chip addr = %0d", top_vif.chipaddr), UVM_MEDIUM);
//            for(int j = 0; j < `CHIP_NUM; j++) begin
//                top_vif.chipaddr = j;
//                wait_pll_stable(i);
//            end
//            top_vif.chipaddr=`BRD_ADDR;
//        end
//
//        else begin
//            `uvm_info(get_type_name(),$psprintf("wait pll stable chip addr = %0d", top_vif.chipaddr), UVM_MEDIUM);
//            wait_pll_stable(i);
//        end
//    `elsif USE_UART_DRV
//        //step 4 wati pll stable
//        // now_chipaddr = top_vif.chipaddr;
//        if(top_vif.chipaddr==`BRD_ADDR) begin
//            `uvm_info(get_type_name(),$psprintf("wait pll stable chip addr = %0d", top_vif.chipaddr), UVM_MEDIUM);
//            for(int j = 0; j < `CHIP_NUM; j++) begin
//                top_vif.chipaddr = j;
//                wait_pll_stable(i);
//            end
//            top_vif.chipaddr=`BRD_ADDR;
//        end
//
//        else begin
//            `uvm_info(get_type_name(),$psprintf("wait pll stable chip addr = %0d", top_vif.chipaddr), UVM_MEDIUM);
//            wait_pll_stable(i);
//        end
//    `else
//        //step 4 wati pll stable
//        wait_pll_stable(i);
//    `endif
//    end
//
//  `SET_REG_FIELD(crg,mux,mid_clk_mux,cpm_cfg_h.mid_clk_mux);
//  `PRINT_REG_SETTING(crg,mux);
//  `UPDATE_REG(crg,mux);    
//endtask:wrc_cpm_pll_x

/*  ============================================================  */
/*  Function:                                                     */
/*  W1T regs is write 1 toggle, and toggle back at next cycle     */
/*  ============================================================  */
virtual task set_W1T_no_check();
  uvm_reg rg[$];

  ral.get_registers(rg, UVM_HIER);
  foreach(rg[m])begin
    uvm_reg_map mps[$];
    rg[m].get_maps(mps);
    foreach(mps[i])begin
      uvm_reg_field fd[$];
      rg[m].get_fields(fd);
      foreach(fd[k])begin
        if(fd[k].get_access() == "W1T")begin 
          fd[k].set_compare(UVM_NO_CHECK);
          `uvm_info(get_type_name(),$sformatf("FIELD[%s] set_no_compare",fd[k].get_full_name()), UVM_HIGH)
        end
      end
    end
  end
endtask:set_W1T_no_check

/*  ============================================================  */
/*  Function:                                                     */
/*  get a wr/rd roctrl check mask                                 */
/*  ============================================================  */ 
virtual task get_roctrl_mask(input string reg_name, output bit[31:0] ro_mask);
  string reg_name_sub;
  //bit[31:0] 
  ro_mask = 32'hffff_ffff;
  reg_name_sub = reg_name.substr(0,9);
      //`uvm_info(get_type_name(), $sformatf("reg[%s],reg_sub[%s] mask = 'h%h", reg_name,reg_name_sub,ro_mask),UVM_MEDIUM)
  case(reg_name_sub)
    "reg_vldctr": 
      begin
        // reg_vldctrl: only check vld_div_num, reset_0_ctrl
        ro_mask[31:8] = 0; ro_mask[6:4] = 0;
      end
    "reg_roctrl", "reg_top_ro": 
      begin
      ro_mask[31:15] = 0; ro_mask[8:5] = 0;
      end
      
    "reg_lvro_r", "reg_hvro_r": 
      begin
      ro_mask[31:10] = 0; 
      end
    default: `uvm_warning(get_type_name(),$sformatf("Unknown roctrl reg_name!"))
  endcase
      `uvm_info(get_type_name(), $sformatf("reg[%s],reg_sub[%s] mask = 'h%h", reg_name,reg_name_sub,ro_mask),UVM_MEDIUM)
endtask: get_roctrl_mask

/*  ============================================================  */
/*  Function:                                                     */
/*  get a random value                                         */
/*  ============================================================  */
virtual function uvm_reg_data_t get_random_data();
  uvm_reg_data_t data;
  void'(std::randomize(data));
  return data;
endfunction: get_random_data



/*    
  task body();
    //super.body();
    logic [31:0] rd_val;
    uvm_reg_data_t   rd_val2;
    `uvm_info(get_type_name(), "reg_noncebuf_ral_jlm_seq start", UVM_MEDIUM); 
    set_wait_for_reset();
    
    reg_read_by_addr(32'h8, rd_val);
    ral.work.reg_work.read(status, rd_val2, UVM_FRONTDOOR, null);
    `uvm_info(get_type_name(), $sformatf("rd_val='h%0h, rd_val2 = 'h%0h", rd_val, rd_val2), UVM_MEDIUM)
  endtask: body
*/
task reg_read_by_addr(input [31:0] addr, output [31:0] val);
  uvm_reg     target;
  uvm_reg_addr_t  addrs[];
  uvm_reg_data_t  data;
  uvm_status_e status;

  target = ral.default_map.get_reg_by_offset(addr);
  if(target == null)
    `uvm_warning(get_type_name(), $sformatf("cannot get reg by addr"))
  target.read(status, data);
  target.get_addresses(null, addrs);
  `uvm_info(get_type_name(), $sformatf("target is %s, addrs.size = 'd%d", target.get_name(), addrs.size()), UVM_MEDIUM)

  if(addrs.size() == 1)
    val = data[31:0];
  else begin
    foreach(addrs[i])begin
      if(addrs[i] == addr) 
        val = data[(32*(i+1) - 1)-: 32];
    end
  end
endtask:reg_read_by_addr


`endif 