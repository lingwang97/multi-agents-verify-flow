
`ifdef DUMP_VPD
initial begin
	$display("\n[NOTE]\tStart Dump VPD at%t\n", $time);
	$vcdplusfile("simv.vpd");
	$vcdpluson(15, `TB_TOP);
end
`endif

`ifdef DUMP_FSDB
initial begin
	$display("\n[NOTE]\tStart Dump FSDB at%t\n", $time);
	$fsdbDumpfile("novas.fsdb");
	$fsdbDumpMDA;
        `ifdef UPF
            $fsdbDumpvars("+power");
        `endif
`ifdef CORE0_DUMP
    $fsdbDumpvars(0, "+all", tb_top.C[0].btnode.btc.slice0.G_MX2[0].mx2);
    $fsdbDumpMDA;
`elsif PTPX
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice0);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice1);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice2);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice3);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice4);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice5);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice6);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice7);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice8);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice9);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice10);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice11);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.evt_top);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.io_pad_n);
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.io_pad_s);
    `ifdef NetList__MX2Core
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.slice0.G_MX2_18__mx2);
    `endif
    $fsdbDumpvars(11,"+all",tb_top.C[0].btnode.btc.sys_ctrl);
`elsif SCOPE_SET
    `ifndef NETSCOPE_SET
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice0);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice1);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice2);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice3);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice4);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice5);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice6);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice7);
       // $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.sys_ctrl.speed);
       // $fsdbDumpvars(7,"+all",tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl);
       // $fsdbDumpvars(5,"+all",tb_top.C[0].btnode.btc.sys_ctrl.u_top_reg_cfg);
       // $fsdbDumpvars(3,"+all",tb_top.C[0].btnode.btc.sys_ctrl.crg);
       // $fsdbDumpvars(5,"+all",tb_top.C[0].btnode.btc.sys_ctrl.mx2_bridge);
        $fsdbDumpvars(8,"+all",tb_top.C[0].btnode.btc.sys_ctrl);  
        $fsdbDumpvars(1,"+all",tb_top.if_oomr);
    `else
        $fsdbDumpvars(4,"+all",tb_top.C[0].btnode.btc.slice5);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice0.G_MX2_6__mx2);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice0.G_MX2_7__mx2);
        $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.slice0.G_MX2_8__mx2);
       // $fsdbDumpvars(6,"+all",tb_top.C[0].btnode.btc.sys_ctrl.speed);  
       // $fsdbDumpvars(7,"+all",tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl);
       // $fsdbDumpvars(5,"+all",tb_top.C[0].btnode.btc.sys_ctrl.u_top_reg_cfg);
       // $fsdbDumpvars(3,"+all",tb_top.C[0].btnode.btc.sys_ctrl.crg);
       // $fsdbDumpvars(5,"+all",tb_top.C[0].btnode.btc.sys_ctrl.mx2_bridge);
        $fsdbDumpvars(8,"+all",tb_top.C[0].btnode.btc.sys_ctrl);  
        $fsdbDumpvars(1,"+all",tb_top.if_oomr);


    `endif

`else
    $fsdbDumpvars(0,"+all",`TB_TOP);
	// $fsdbDumpvars(0, "+all", `BTC0);
    // $fsdbDumpvars(0, "+all", tb_top.jlm);
    // $fsdbDumpvars(0, "+all", `BTC0.sys_ctrl.jls);
    // $fsdbDumpvars(0, "+all", `BTC0.sys_ctrl.work_ctrl);
    // $fsdbDumpvars(0, "+all", `BTC0.io_pad_n);
    // $fsdbDumpvars(0, "+all", `BTC0.io_pad_s);

    // $fsdbDumpvars(0, "+all", `BTC(1).sys_ctrl.jls);
    // $fsdbDumpvars(0, "+all", `BTC(1).sys_ctrl.work_ctrl);
    // $fsdbDumpvars(0, "+all", `BTC(1).io_pad_n);
    // $fsdbDumpvars(0, "+all", `BTC(1).io_pad_s);
`endif

`ifdef PTPX
    $fsdbDumpoff;
`else
	$fsdbDumpon;
`endif
end
`endif

`ifdef UVM_SPEED_SIM
//genvar i;
generate for(genvar i = 0; i < `DESIGN_CORE_NUM; i = i + 1) begin : gen_chker
    speed_checker #(
        .ID             (i)
    ) u_speed_checker(
        .top_clk        (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.mid_clk        ),
        .spd_mark       (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_simple.mark           ),
        .check_done     (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.check_done     ),
        .check_pass     (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.check_pass     ),
        .check_id       (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.check_id       ),
        .th_ms          (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_simple.th_ms          ),
        .th_pass        (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_th_pass    ),
        .th_fail        (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_th_fail    ),
        .spd_to         (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.th_timeout_of  ),
        .add_ms         (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_simple.add_ms         ),
        .reg_spd_en     (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_spd_en     ),
        .vld_spd_global (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.vld_spd_global ),
        .vld_reg_spd_sel(`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.vld_reg_spd_sel),
        .reg_th_init    (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_th_init    ), 
        .spd_sel        (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.spd_sel_tmp    ),
        .spd_sel_max    (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_spdhigh    ),
        .spd_sel_min    (`BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_spdlow     )  
    );
end endgenerate
`endif
