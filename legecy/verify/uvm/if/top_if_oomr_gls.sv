//assign top_pif.rst = tb_top.rst;
//initial chipaddr
initial begin
	top_pif.chipaddr = 8'h0;
	top_pif.cpft_print_flag = 1'b0;
end

`ifdef VIP
  assign top_pif.REG_UART_CHECK_MODE_SEL = `BTC0.sys_ctrl.comm_interface.REG_UART_CHECK_MODE_SEL;
  assign top_pif.uart_state     = `BTC0.sys_ctrl.comm_interface.uart_top.uart_fsm_xclk.state;
  generate for(genvar i=0;i<`CHIP_NUM; i=i+1 ) begin
     assign top_pif.uart_dirx_state[i] = tb_top.C[i].btnode.btc.sys_ctrl.comm_interface.uart_top.DI_RX.state;
  end
  assign top_pif.uart_vip_cts_n = `BTC0.sys_ctrl.comm_interface.uart_top.CTS_n;
  endgenerate
`endif

assign top_pif.HEADER       = `BTC0.sys_ctrl.comm_interface.REG_UART_HEADER_INDICATOR ;


assign top_pif.jls_mid_clk = `BTC0.sys_ctrl.comm_interface.mid_clk;
assign top_pif.jls_pin_ci = `BTC0.sys_ctrl.comm_interface.pin_ci;

assign top_pif.RO = tb_top.RO;
assign top_pif.ri_rst_f_n = `BTC0.sys_ctrl.crg.ri_rst_f_n;
//add by haiyang for mid_rst
assign top_pif.mid_rst_f_n = `BTC0.sys_ctrl.crg.mid_rst_f_n;
assign top_pif.mid_rst_n = `BTC0.sys_ctrl.crg.mid_rst_n;

assign top_pif.apb_state_cur = `BTC0.sys_ctrl.comm_interface.jls_top.mid_apb_fsm.apb_state_cur;
assign top_pif.jls_cur_state = `BTC0.sys_ctrl.comm_interface.jls_top.jls_fsm.cur_state;
assign top_pif.ri_rst_pin_ri  = `BTC0.sys_ctrl.crg.REG_pin_ri;
assign top_pif.ri_rst_n = `BTC0.sys_ctrl.crg.ri_rst_n; 
assign top_pif.spdcnt_st_num = `BTC0.sys_ctrl.work_ctrl.REG_spdcnt_st_num;
assign top_pif.work_z_NonceFlip = `BTC0.sys_ctrl.work_ctrl.z_NonceFlip;    
assign top_pif.is_REG_Spdlog_Timer =  `BTC0.sys_ctrl.speed.is_REG_Spdlog_Timer;
assign top_pif.speed_midclk = `BTC0.sys_ctrl.speed.mid_clk;
assign top_pif.spd_fresh_done = `BTC0.sys_ctrl.work_ctrl.spd2core.spd_fresh_done;
assign top_pif.xclk = `BTC0.sys_ctrl.xclk;

assign top_pif.spd_cur_state = `BTC0.sys_ctrl.work_ctrl.spd2core.spd_cur_state;
assign top_pif.spdcore_cnt = `BTC0.sys_ctrl.work_ctrl.spd2core.spd_cnt;
assign top_pif.clk=tb_top.CI_CLK;
assign top_pif.btn_to=tb_top.btn_to;
assign top_pif.btc_to = `BTC0.TO;
assign top_pif.g_rsp_inject_err = tb_top.g_rsp_inject_err;

//######
assign top_pif.clk_spd = tb_top.clk_spd;
assign top_pif.timer_stop = `BTC0.sys_ctrl.speed.REG_timer_stop;

`ifndef FPGA_SYN
assign top_pif.send_work_busy = `BTC0.sys_ctrl.mx2_bridge.send_work_busy;
assign top_pif.core_cfg_busy = `BTC0.sys_ctrl.mx2_bridge.core_cfg_busy;
`ifndef REAL_CORE
`ifdef PL_SIM
`HDLREF_AllSliceAllMx2CoreBus2Bus(0,assign top_pif.core_config0[,] =,ctrl.sha256_reg_ctrl.tstclk_cfg;,NoNLSig,NoNLSig,31,0)
`HDLREF_AllSliceAllMx2CoreBus2Bus(0,assign top_pif.core_config1[,] =,ctrl.sha256_reg_ctrl.mask_cfg;,NoNLSig,NoNLSig,31,0)
`else      //ifdef PL_SIM
generate for(genvar i=0;i<`SLICE_NUM;i++)begin
    case (i)
        0:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice0.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice0.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        1:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice1.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice1.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        2:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice2.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice2.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        3:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice3.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice3.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        4:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice4.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice4.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        5:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice5.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice5.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        6:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice6.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice6.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        default: begin
        end
    endcase
end
endgenerate
`endif      //ifdef PL_SIM
`else   //ifndef REAL_CORE
`ifdef PL_SIM
`HDLREF_AllSliceAllMx2CoreBus2Bus(0,assign top_pif.core_config0[,] =,ctrl.sha256_reg_ctrl.tstclk_cfg;,NoNLSig,NoNLSig,31,0)
`HDLREF_AllSliceAllMx2CoreBus2Bus(0,assign top_pif.core_config1[,] =,ctrl.sha256_reg_ctrl.mask_cfg;,NoNLSig,NoNLSig,31,0)
`else      //ifdef PL_SIM
generate for(genvar i=0;i<`SLICE_NUM;i++)begin
    case (i)
        0:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice0.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice0.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        1:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice1.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice1.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        2:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice2.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice2.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        3:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice3.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice3.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        4:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice4.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice4.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        5:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice5.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice5.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        6:begin 
            for(genvar j=slice_start[i];j<=slice_end[i];j++)begin
                assign top_pif.core_config0[j] = `BTC0.slice6.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.tstclk_cfg;
                assign top_pif.core_config1[j] = `BTC0.slice6.G_MX2[j].mx2.ctrl.sha256_reg_ctrl.mask_cfg;
            end
        end
        default: begin
        end
    endcase
end
endgenerate
`endif      //ifdef PL_SIM
`endif
`endif
//`BTC0.slice[%0d].G.slice.G_MX2[%0d].mx2.mx2_tail.core_config0


//generate for(genvar i = 0 ; i < `CH_NUM; i=i+1)
generate for(genvar i = 0 ; i < `SLICE_NUM; i=i+1)
begin  
    case (i) //duanzhiwei comment 2024/09/13  
        0:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",0);
        1:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",1);//`BTC0.ch1.syc;
        2:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",2);//`BTC0.ch2.syc;
        3:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",3);//`BTC0.ch3.syc;
        4:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",4);//`BTC0.ch4.syc;
        5:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",5);//`BTC0.ch5.syc;
        6:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",6);//`BTC0.ch6.syc;
        7:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.syc",7);//`BTC0.ch7.syc;
      //  8:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.slice_in.spd.syc",8);//`BTC0.ch4.syc;
      //  9:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.slice_in.spd.syc",9);//`BTC0.ch5.syc;
      //  10:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.slice_in.spd.syc",10);//`BTC0.ch6.syc;
      //  11:assign top_pif.cps_slice_syc_in[i] =  $sformatf("`BTC0.slice%0d.slice_in.spd.syc",11);//`BTC0.ch7.syc;
        default:begin
        end
    endcase
end
endgenerate

`ifndef STUB_PLL
generate for(genvar i = 1 ; i < `TB_PLL_NUM; i=i+1)
begin  
assign top_pif.xclk_clksel[i] = `BTC0.sys_ctrl.crg.G_MUX_XCLK_PLL[i].Mux_XCLK_PLL.clksel;
end
endgenerate
assign top_pif.xclk_clksel[0] = `BTC0.sys_ctrl.crg.trunk0_sel.clksel;
//generate for(genvar i = 0 ; i < `TB_PLL_NUM; i=i+1)
//begin  
//assign top_pif.xclk_clksel[i] = `BTC0.sys_ctrl.crg.G_MUX_XCLK_PLL[i].Mux_XCLK_PLL.clksel;
//end
//endgenerate

/*generate for(genvar i = 0 ; i < `TB_PLL_NUM; i=i+1)
begin  
assign top_pif.cpm_change_cnt[i] =  `BTC0.sys_ctrl.crg.G_PLL_INSTANTIATE[i].u_cpm_pll.change_cnt;
end
endgenerate*/

generate for(genvar i = 0 ; i < `TB_PLL_NUM; i=i+1)
begin  
assign top_pif.cpm_trunk_clk[i] = `BTC0.sys_ctrl.crg.trunk_clk[i];
end
endgenerate
`endif

`ifndef PL_SIM
generate for(genvar ga = 0; ga < `CHIP_NUM; ga = ga + 1) begin
    assign top_pif.gaddr[`CHIPID_LEN*(ga+1)-1:`CHIPID_LEN*ga] = `BTC(ga).sys_ctrl.comm_interface.jls_top.jls_fsm.myaddr;
end
endgenerate
`endif

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign top_pif.cps_sysc_to_io_s_xclk_chips[i] = tb_top.C[i].btnode.btc.sys_ctrl.to_io_s_xclk;
end
endgenerate

generate for(genvar i = 0 ; i < `CHIP_NUM; i=i+1)
begin           
assign top_pif.cps_sysc_to_io_n_xclk_chips[i] = tb_top.C[i].btnode.btc.sys_ctrl.to_io_n_xclk;
end
endgenerate
