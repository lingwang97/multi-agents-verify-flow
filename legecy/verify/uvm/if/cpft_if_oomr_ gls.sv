//assign mc_pif.rst = tb_top.rst;
`ifndef PL_SIM
assign cpft_pif.xclk            = `BTC0.sys_ctrl.crg.xclk;
assign cpft_pif.spd_fresh_done  = `BTC0.sys_ctrl.work_ctrl.ft.spd_fresh_done;
assign cpft_pif.ft_pending      = `BTC0.sys_ctrl.work_ctrl.ft.ft_pending;
`endif