
//This task used for core register write.
//input:
//  parameter 1: target access register
//  parameter 2: target access core id
//  parameter 3: target write data
task core_wr(input uvm_btc_reg rg, input uvm_reg_data_t core_id, input uvm_reg_data_t core_wdata);
   	//uvm_reg_data_t data_t;
	//rg.coresel_rd(data_t);
	logic [31:0] data_t_w, data_t_r;
    logic [7:0] reg_addr;
    reg_addr = rg.get_offset();
	rg.coresel_rd(data_t_r);
	//step1: configure work_corecfg
	data_t_w = {23'h0,1'b0,8'h0,core_id[7:0]};
	rg.coresel_wr(data_t_w);
	//step2: configure work_core_wr_data
    ral.work.reg_core_wr_data.wr(core_wdata);
	//step3: wait long time to finish writing into core reg
    fork
    begin
        `uvm_info(get_type_name(),$psprintf("start to wait top tx core_wr_addr to be 0x%0x",reg_addr),UVM_MEDIUM);
        wait(work_ctrl_vif.top_tx_core_wr_addr==reg_addr);
        `uvm_info(get_type_name(),"start to wait core cfg done",UVM_MEDIUM);
        wait(work_ctrl_vif.top_tx_core_cfg_done);
    end
    begin
        #2000000;
        `uvm_error(get_type_name(),"till 2000000 top tx core_cfg_done not yet trigger, possible reason: waiting time too short for jamlink/uart, bridge is current busy with sending work or core cfg is truly not sent out.");
    end
    join_any
    disable fork;
endtask

//The task used for core register read.
//input:
//  parameter 1: target access register
//  parameter 2: target access core id
//output:
//  parameter 3: returned read value
task core_rd(input uvm_btc_reg rg, input uvm_reg_data_t core_id, output [31:0] core_wdata
`ifndef REAL_CORE
    , input [31:0] ref_data
`endif
    );
   	logic [31:0] data_t_w, data_t_r;
    logic [7:0] reg_addr;
    reg_addr=rg.get_offset();
	rg.coresel_rd(data_t_r);
	//step1: configure work_corecfg regrw==1, core_id == core_id
	data_t_w = {23'h0,1'b1,8'h0,core_id[7:0]};
	rg.coresel_wr(data_t_w);
	//step2: wait long time for finish writing into core reg
`ifndef PL_SIM
`ifndef REAL_CORE
    uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_in.receiver_id"),core_id);
    uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_in.boost_id"),0);
    uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_in.task_id"),0);
    uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_in.reg_addr"),rg.get_offset());
    uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_in.nonce"),ref_data);
    uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_ready",1);
    @(posedge work_ctrl_vif.mid_clk);
    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.core2top.data_ready");
`endif
`endif
    fork
    begin
        `uvm_info(get_type_name(),$psprintf("start to wait top tx core_rd_addr to be 0x%0x",reg_addr),UVM_MEDIUM);
        wait(work_ctrl_vif.top_tx_core_rd_addr==reg_addr);
        `uvm_info(get_type_name(),"start to wait core cfg done",UVM_MEDIUM);
        wait(work_ctrl_vif.top_tx_core_cfg_done);
        `uvm_info(get_type_name(),$psprintf("start to wait core2top recieve reg addr to be 0x%0x",reg_addr),UVM_MEDIUM);
        wait(work_ctrl_vif.core2top_reg_addr==reg_addr);
    end
    begin
        #2000000;
        `uvm_error(get_type_name(),"core cfg not done");
    end
    join_any
    disable fork;
    repeat(20) @(posedge work_ctrl_vif.mid_clk);
	//step4: read from work_core_rd_data
	ral.work.reg_core_rd_data.rd(data_t_r);
	core_wdata = data_t_r;
endtask



/*  ============================================================  */
/*  ==========================     rst     =====================  */
/*  ============================================================  */
/**
 *  task name: initRst
 *  Description:
 *    This task initialized the reset register after chip power on.
 *  Procedure:
 *    1. wait until ri_rst_n pulled up by rtl
 *    2. enable ri_wen
 *    3. lower ri_function
 *  parameter: none
 */
task initRst;
`uvm_info(get_type_name(), "initRst begin", UVM_MEDIUM);
`ifndef USE_JAMLINK_DRV
`ifndef USE_UART_DRV
    wait(top_vif.mid_rst_n);
`endif
`endif
    //REG_pin_ri is high when power-on, if want the speed pll feature functional, need to low the REG_pin_ri, so that it can select target pll_clk
//    `SET_REG_FIELD(crg,ri_wen,ri_wen,`ON);
//    `PRINT_REG_SETTING(crg, ri_wen);
//    `UPDATE_REG(crg,ri_wen);
//    `SET_REG_FIELD(crg,ri_enable,ri_function,`OFF);
//    `PRINT_REG_SETTING(crg,ri_enable);
//    `UPDATE_REG(crg,ri_enable);
      `WR_REG(crg, ri_wen, 1'h1);
      `PRINT_REG_SETTING(crg, ri_wen);
      `WR_REG(crg, ri_enable, 1'h0);
      `PRINT_REG_SETTING(crg, ri_enable);
      `uvm_info(get_type_name(), "initRst end", UVM_MEDIUM);
endtask: initRst
task initRst_en_ri_enable;
`uvm_info(get_type_name(), "initRst begin", UVM_MEDIUM);
`ifndef USE_JAMLINK_DRV
`ifndef USE_UART_DRV
    wait(top_vif.mid_rst_n);
`endif
`endif
    //REG_pin_ri is high when power-on, if want the speed pll feature functional, need to low the REG_pin_ri, so that it can select target pll_clk
//    `SET_REG_FIELD(crg,ri_wen,ri_wen,`ON);
//    `PRINT_REG_SETTING(crg, ri_wen);
//    `UPDATE_REG(crg,ri_wen);
//    `SET_REG_FIELD(crg,ri_enable,ri_function,`OFF);
//    `PRINT_REG_SETTING(crg,ri_enable);
//    `UPDATE_REG(crg,ri_enable);
      `WR_REG(crg, ri_wen, 1'h1);
      `PRINT_REG_SETTING(crg, ri_wen);
      `WR_REG(crg, ri_enable, 1'h1);
      `PRINT_REG_SETTING(crg, ri_enable);
      `uvm_info(get_type_name(), "initRst end", UVM_MEDIUM);
endtask: initRst_en_ri_enable


/*  ============================================================  */
/*  ==========================     work    =====================  */
/*  ============================================================  */
/**
 *  task name: work_reg_init_seq
 *  Description:
 *    This task initialized the work register that requires after chip power on.
 *  Procedure:
 *    1. config the REG_core_cfg to write mode and broadcase mode
 *    2. set the rolltime to 0'd7000, this time setting satisfying the work send to the mx2 core from mx2 bridge
 *    3. set the target to all 1, which means the easiest
 *    4. randomized work.REG_SpdSyc_CFG.spdsetup
 *    5. setting work.REG_SpdSyc_CFG.syccnt to full core
 *    6. clear chkdrop, nonce_cnt, nonce_cnt_rt, nonce_update
 *    7. enable work,REG_cfg.rstfifo & chken, randomize half_work_en
 *    8. CG_CTRL related reg field randomized
 *  parameter: none
 */
task work_reg_init_seq;
    logic [31:0] projectid;
    logic [31:0] reg_spdsyc_data;
    logic [31:0] reg_data;

    if(top_vif.chipaddr!=`BRD_ADDR) begin
        //check and print Porject_ID.
        ral.work.project_id.rd(projectid);
        if(projectid == `PRJID) begin
            `uvm_info($psprintf("work.project_id:(0x%0x)",ral.work.project_id.get_offset()), $psprintf("0x%0x",projectid), UVM_MEDIUM);
        end
        else begin
            `uvm_error("Project_ID is wrong.",$psprintf("projet_id is: 0x%0x, expect project_id is 0x%0x", projectid, `PRJID));
        end
    end

    //set the core cfg to write and broadcast mode (default)
    `SET_REG_FIELD(work,core_cfg,core_regrw,`WRITE);
    `SET_REG_FIELD(work,core_cfg,core_rw_coreid,`BROADCAST);
    `PRINT_REG_SETTING(work,core_cfg);
    reg_data = `GET_REG(work,core_cfg);
    `WR_REG(work,core_cfg,reg_data);

    //set the roll-time to 8000
    `ifndef ROLLTIME_24000//fix fakecore rolltime timeout
       `WR_REG(work,rolltime,'d8000);
    `elsif ROLLTIME_40000//fix fakecore rolltime timeout
        `WR_REG(work,rolltime,'d40000);
    `else
        `WR_REG(work,rolltime,'d24000);
    `endif
    `PRINT_REG_SETTING(work,rolltime);
    //set the target to full FF for both targetL&H
    `WR_REG(work,targetl,32'hffffffff);
    `PRINT_REG_SETTING(work,targetl);
    `WR_REG(work,targeth,32'hffffffff);
    `PRINT_REG_SETTING(work,targeth);
    //randomized h2ltime0.spdsetup
    //set reg_syccnt to full core nums
    `SET_REG_FIELD(work,spdsyc_cfg,spdsetup,work_ctrl_cfg_h.spd_setup);
    `SET_REG_FIELD(work,spdsyc_cfg,spdcnt_st_num,0);
    `SET_REG_FIELD(work,spdsyc_cfg,syccnt,`DESIGN_CORE_NUM+`TINY_CORE_NUM);
    reg_spdsyc_data = `GET_REG(work,spdsyc_cfg);
    `WR_REG(work,spdsyc_cfg, reg_spdsyc_data);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    //clear chkdrop reg
    `WR_REG(work,chkdrop,`W1C);
    `PRINT_REG_SETTING(work,chkdrop);
    //clear nonce_cnt reg
    `WR_REG(work,nonce_cnt,`W1C);
    `PRINT_REG_SETTING(work,nonce_cnt);
    //clear nonce_cnt_rt reg
    `WR_REG(work,nonce_cnt_rt,`W1C);
    `PRINT_REG_SETTING(work,nonce_cnt_rt);
    //clear nowz_NonceBufCnt_byte
    `SET_REG_FIELD(work,nonce_update,nonce_update,`W1C); // `WR_REG(work,nonce_update,`W1C);
    `UPDATE_REG(work,nonce_update);
    `PRINT_REG_SETTING(work,nonce_update);
    //randomize ntime_half_work
    //rst checker fifo and make sure enable checker clock
    `SET_REG_FIELD(work,cfg,ntime_half_work,work_ctrl_cfg_h.ntime_half_work);
    `SET_REG_FIELD(work,cfg,cfg_rstfifo,`ON);
    `SET_REG_FIELD(work,cfg,cfg_chken,`ON);
    `SET_REG_FIELD(work,cfg,work_coreid, `BROADCAST);
    `PRINT_REG_SETTING(work,cfg);
    reg_data = `GET_REG(work,cfg);
    `WR_REG(work,cfg,reg_data);
    //set check_cg_en with random value
    `SET_REG(work, cg_en, work_ctrl_cfg_h.cg_ctrl);
    `PRINT_REG_SETTING(work,cg_en);
    reg_data = `GET_REG(work,cg_en);
    `WR_REG(work, cg_en,reg_data);
endtask: work_reg_init_seq

/**
 *  task name: workAssignPreConfig
 *  Description:
 *    This task config the required setting before assigning work to chip.
 *  Procedure:
 *    1. config the speed.ss_ctrl. Several bit fields could be randomized by speed config setting
 *    2. configure the rollen on, and trigger spdgo
 *  parameter: none
 */
task workAssignPreConfig;
    `SET_REG_FIELD(speed, ss_ctrl, spdlow,`SPD_LEVEL0);
    `SET_REG_FIELD(speed, ss_ctrl, spdhigh,`TB_PLL_NUM-1);
    `SET_REG_FIELD(speed, ss_ctrl, spden,`ON);
    `SET_REG_FIELD(speed, ss_ctrl, glbsetvld, `ON);
    `SET_REG_FIELD(speed, ss_ctrl, glbset, `SPD_LEVEL1);
    `UPDATE_REG(speed,ss_ctrl);

    `SET_REG_FIELD(work, cfg, cfg_rollen, `ON);
    `UPDATE_REG(work, cfg);
endtask: workAssignPreConfig

/**
 *  task name: forceFakeCoreEnv
 *  Description:
 *    This task only works for fake core usage
 *  Procedure:
 *    1. get the target fake core path
 *    2. assign the signal with the expect value
 *  parameter: none
 */
task forceFakeCoreEnv(work_ctrl_mine_work work);
    logic [31:0] ntime_env;
    int loop, index,core_pool[$],core_num=8'hFF;
    string nonce_joint;

    core_num = work.random_core_cnt;
    `uvm_info(get_full_name(),$sformatf("Starting force fake core env..."),UVM_LOW);
    for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
        if(work.coreid==8'hFF) begin
            core_pool[i]=i;
            continue;
        end
        if(i==work.coreid) continue;
        else if (i>work.coreid) core_pool[i-1]=i;
        else core_pool[i]=i;
    end
    core_pool.shuffle;
    if(work.coreid!=8'hFF)begin
        core_pool.push_front(work.coreid);
    end

    //set the ntime for fake core usage
    ntime_env = work.tbase+work.ntime;

    if(`CHIP_NUM>1)begin
        if(top_vif.chipaddr == `BRD_ADDR) begin
            loop = `CHIP_NUM;
            `uvm_info(get_type_name(),$psprintf("CHIP_NUM value", loop), UVM_MEDIUM);
        end
        else begin
            loop = 1;
        end
        for(int i = 0; i < loop; i++) begin
            if(top_vif.chipaddr == `BRD_ADDR) begin
                index = i;
            end
            else begin
                index = top_vif.chipaddr;
            end
            for(int slice_index=0;slice_index<`SLICE_NUM;slice_index++)begin
                for(int j=slice_start[slice_index];j<=slice_end[slice_index];j++)begin

                    work_ctrl_vif.init_nonce_env[index][j]=work.nonce0;
                    work_ctrl_vif.work_send_env[index][j]=0;

                    work_ctrl_vif.taskid_ntime_env[index][j][7:0]=ntime_env[7:0];
                    work_ctrl_vif.taskid_ntime_env[index][j][8+`ABS_NUM-1:8]=work.taskid;
                    //set the tbase
                    work_ctrl_vif.tbase_reg[index][j]= work.tbase;
                end
            end
            for(int cid=0;cid<core_num;cid++)begin
                work_ctrl_vif.work_send_env[index][core_pool[cid]]=1;
                $display($sformatf("chip %0d, core %0d expect to return nonce",index,core_pool[cid]));
            end
    `ifndef PL_SIM
            nonce_joint=$sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.nonce_joint[7:0]",index);
    // `else
    //         nonce_joint=$sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.nonce_joint[7:0]",index);
    `endif
    `ifdef BROADCAST_NONCE
            if(work.coreid==`BROADCAST)
            `ifndef PL_SIM
                uvm_hdl_force(nonce_joint,`BROADCAST);
            `else
            begin
            //This shall adapt to each single version of netlist
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[7]",index),1);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[6]",index),0);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[5]",index),1);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[4]",index),1);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[3]",index),1);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[2]",index),1);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[1]",index),1);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[0]",index),0);
            end
            `endif
    `else
            if(work.random_core_cnt>1 && work.random_core_cnt<`DESIGN_CORE_NUM)
            `ifndef PL_SIM
                uvm_hdl_force(nonce_joint,work.coreid);
            `else
            begin
            //This shall adapt to each single version of netlist
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[7]",index),work.coreid[7]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[6]",index),work.coreid[6]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[5]",index),work.coreid[5]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[4]",index),work.coreid[4]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[3]",index),work.coreid[3]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[2]",index),work.coreid[2]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[1]",index),work.coreid[1]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[0]",index),work.coreid[0]);
            end
            `endif
    `endif
        end
    end
    else if(`CHIP_NUM==1)begin
        for(int slice_index=0;slice_index<`SLICE_NUM;slice_index++)begin
            for(int i=slice_start[slice_index];i<=slice_end[slice_index];i++)begin
	`ifdef NetList_MX2Core
            if(i==10)begin
                continue;
            end
	`endif
                work_ctrl_vif.init_nonce_env[0][i]=work.nonce0;

                work_ctrl_vif.work_send_env[0][i]=0;

                work_ctrl_vif.taskid_ntime_env[0][i][7:0]=ntime_env[7:0];
                work_ctrl_vif.taskid_ntime_env[0][i][8+`ABS_NUM-1:8]=work.taskid;
                //set the tbase
                work_ctrl_vif.tbase_reg[0][i]= work.tbase;
            end
        end
        for(int cid=0;cid<core_num;cid++)begin
            work_ctrl_vif.work_send_env[index][core_pool[cid]]=1;
            $display($sformatf("chip %0d, core %0d expect to return nonce",0,core_pool[cid]));
        end
    `ifndef PL_SIM
        nonce_joint=$sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.nonce_joint[7:0]",0);
    // `else
    //     nonce_joint=$sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.nonce_joint[7:0]",0);
    `endif
    `ifdef BROADCAST_NONCE
        if(work.coreid==`BROADCAST)
        `ifndef PL_SIM
            uvm_hdl_force(nonce_joint,`BROADCAST);
        `else
        begin
            //This shall adapt to each single version of netlist
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[7]",0),1);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[6]",0),0);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[5]",0),1);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[4]",0),1);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[3]",0),1);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[2]",0),1);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[1]",0),1);
            uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[0]",0),0);
        end
        `endif
    `else
        if(work.random_core_cnt>1 && work.random_core_cnt<`DESIGN_CORE_NUM)
            `ifndef PL_SIM
                uvm_hdl_force(nonce_joint,work.coreid);
            `else
            begin
            //This shall adapt to each single version of netlist
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[7]",0),work.coreid[7]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[6]",0),~work.coreid[6]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[5]",0),work.coreid[5]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[4]",0),work.coreid[4]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[3]",0),work.coreid[3]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[2]",0),work.coreid[2]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[1]",0),work.coreid[1]);
                uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.work_ctrl.core2top.raw_core_nonce[0]",0),~work.coreid[0]);
            end
            `endif
    `endif
    end
    else begin
        `uvm_error(get_type_name(),$psprintf("setting wrong `CHIP_NUM in the json file with value %0d",`CHIP_NUM));
    end

endtask

/**
 *  task name: workAssign
 *  Description:
 *    This task assign the work to the chip with the parameter of target work
 *  Procedure:
 *    1. config work.core_cfg register with write and broadcast mode. This is a ensurance to make sure it is in write mode
 *    2. config the tbase reg.
 *    3. write the work.version with the version in the parameter work
 *    4. write the work.Work with the work in the parameter work
 *    5. wait for signal vld_Work high, means work_ctrl module has received the work
 *    6. setting the fake core required info
 *  parameter: work_ctrl_mine_work work,
 *             logic [7:0] coreid
 */
task workAssign(work_ctrl_mine_work work, logic [7:0] coreid=`BROADCAST, logic ften=0);
    //set the core cfg to write and broadcast mode
    `SET_REG_FIELD(work,core_cfg,core_regrw,`WRITE);
    `SET_REG_FIELD(work,core_cfg,core_rw_coreid, coreid);
    `UPDATE_REG(work,core_cfg);

    `SET_REG_FIELD(work,cfg,work_coreid, coreid);
    //`SET_REG_FIELD(work,cfg,cfg_chken, 0);  // just skip check for current rtl issue
    `UPDATE_REG(work,cfg);

    //set the work tbase
    `WR_REG(work,tbase,work.tbase);
    //set the version fifo
    `WR_REG(work,version,work.WorkVersion);
    //set the work fifo
    `WR_REG(work,work,work.targetRegWork);

    if(ften)begin
        wait(work_ctrl_vif.vld_Work == 1);
        forceFakeCoreEnv(work);
        `SET_REG_FIELD(work,ft,ftst,1);
        `UPDATE_REG(work,ft);
        return;
    end

//send data from jamlink or uart regardless using fakecore or realcore
`ifdef USE_JAMLINK_DRV
    wait(jamlink_vif.do_fifo_empty);
    //if use jlm, data transmission need more time. It is about 35,000ns from do_fifo_empty high to work_ntime = 0.
    #35000;
    `ifndef REAL_CORE
    forceFakeCoreEnv(work);
    `endif
`elsif USE_UART_DRV
    //uart driver will make sure data send finish in the ral wr/rd
    //#70000;
    #35000;
    `ifndef REAL_CORE
    forceFakeCoreEnv(work);
    `endif
`else
    `ifndef REAL_CORE
		  `ifdef NETLIST_MX2CORE
         wait(work_ctrl_vif.top_tx_round_start);
				`uvm_info(get_type_name(),"after top_tx_round_start...",UVM_MEDIUM);
			`else
					 //vld_Work is the end of gen_mid
   				 @(posedge work_ctrl_vif.vld_Work);
   				 wait(work_ctrl_vif.top_tx_round_start);

   				 //wait for work data flow addr 0x40 reach core, so that for fake_core it could start to assign init_nonce_env
   				 //wait(work_ctrl_vif.top_tx_segcnt==3);
   				 wait(work_ctrl_vif.top_tx_segcnt==4);
   				 forceFakeCoreEnv(work);
			`endif
    `else
    wait(work_ctrl_vif.top_tx_round_start);
    `endif
`endif

endtask: workAssign

/**
 *  task name: initWorkCoreReg
 *  Description:
 *    This task initialized the work core reg
 *  Procedure:
 *    1. declare an instance of type work_ctrl_mine_work and new it.
 *    2. Assign this work to chip
 *  parameter: none
 */
task initWorkCoreReg();
    work_ctrl_pkg::work_ctrl_mine_work m_work;
    m_work=new();
    workAssignPreConfig;
    fork
    begin
        workAssign(m_work);
    end
    begin
`ifndef USE_JAMLINK_DRV
`ifndef USE_UART_DRV
    `ifndef NetList__MX2Core
        @(posedge work_ctrl_vif.send_work_vld_Work_r);
        repeat(10) @(posedge work_ctrl_vif.mid_clk);
        wait(work_ctrl_vif.work_ntime>0);
    `endif
        @(posedge work_ctrl_vif.top_tx_send_work_done);
`endif
`endif
    end
    join
endtask

/**
 *  task name: checkRollNonceReturnTimeout
 *  Description:
 *    This task check whether nonce is ready, only for rolltime mode enabled.
 *    Timeout when send_work ntime is greater then input parameter ntime+1
 *    The reason referenece adding one, is because for the fake core, there will be possibility that return nonce later than ntime+1
 *  Procedure:
 *    1. looping for REG_work_cfg.nonce_rdy to be 1
 *    2. if rtl signal work_ntime exceeds the target ntime+1 that call finish to end the simulation
 *  parameter:
 *    logic [7:0] ntime
 */
task checkRollNonceReturnTimeout(input [7:0] ntime);
    logic [31:0] rd_data;
    rd_data=0;
    //wait for work_ntime is ensured to be cleared by vld_work
    `uvm_info("checkNonceReturnTimeout",$psprintf("starttttttttttttttttttttttread cfg nonce_rdyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"), UVM_MEDIUM);
    wait(!work_ctrl_vif.top_tx_send_work_busy);
    @(posedge work_ctrl_vif.mid_clk);
    while(!work_ctrl_vif.nonce_rdy)
    begin
        #40;
        if (work_ctrl_vif.work_ntime > (ntime+1))begin
            `uvm_error("checkRollNonceReturnTimeout",$psprintf("  now rolltime exceeds ntime:%0d, the assigned work is not correct",(ntime+1)));
#100000ns;
            $finish();
        end
    end

endtask: checkRollNonceReturnTimeout

/*The returned nonce is not expected
 *  task name: checkRollNonceDisReturnTimeout
 *  Description:
 *    This task check whether nonce is unready, only for rolltime mode enabled.
 *    Timeout when send_work ntime is smaller then input parameter ntime
 *  Procedure:
 *    1. looping for rtl signal work_ntime less then the target ntime
 *    2. if REG_work_cfg.nonce_rdy always keep at zero that call finish to end the simulation
 *  parameter:
 *    logic [7:0] ntime
*/
task checkRollNonceDisReturnTimeout(input [7:0] ntime);
    logic [31:0] rd_data;
    rd_data=0;
    //wait for work_ntime is ensured to be cleared by vld_work
    wait(!work_ctrl_vif.top_tx_send_work_busy);
    @(posedge work_ctrl_vif.mid_clk);
    while(work_ctrl_vif.work_ntime <= ntime)
    begin
        #40;
        if (work_ctrl_vif.nonce_rdy)begin
            `uvm_error("checkRollNonceDisReturnTimeout",$psprintf(" work_ctrl_vif.nonce_rdy=%0d,nonce is ready",(work_ctrl_vif.nonce_rdy)));
            $finish();
        end
    end

endtask: checkRollNonceDisReturnTimeout

/**
 *  task name: checkNonceReturnTimeout
 *  Description:
 *    This task check whether nonce is ready, only for rolltime mode disabled.
 *  Procedure:
 *    1. wait for top_tx_send_work_busy and mx2 bridge end up with transferring data.
 *    2. for each posedge mid_clk, add the roll_cnt, if roll_cnt exceed twice of rolltime value, then call finish.
 *       If nonce_rdy goes high, then disable the timeoutcheck fork
 *  parameter:
 *    none
 */
task checkNonceReturnTimeout();
    logic [31:0] rd_data;
    logic [31:0] rolltime;
    int roll_cnt;
    roll_cnt=0;
    rd_data=0;
    //wait for work_ntime is cleared by vld_work
    wait(!work_ctrl_vif.top_tx_send_work_busy);
    @(posedge work_ctrl_vif.mid_clk);

    //obtain the set rolltime
    `RD_REG(work, rolltime, rolltime);
    fork
    begin : timeoutcheck
        do begin
            @(posedge work_ctrl_vif.send_work_clk)begin
                roll_cnt++;
            end
            //if(roll_cnt>(work_ctrl_vif.REG_RollTime*2))begin
            if(roll_cnt>(work_ctrl_vif.REG_RollTime*5))begin
                `uvm_error("checkNonceReturnTimeout","check nonce return timeout, no nonce return");
                $finish();
            end
        end
        while(1);
    end
    begin
        while(!work_ctrl_vif.nonce_rdy)
        begin
            #400;
            // `MIR_REG(work, cfg);
            // rd_data=`GET_REG_FIELD(work, nonce_update, nonce_rdy);
            `uvm_info("checkNonceReturnTimeout","nonce_rdy is still low", UVM_MEDIUM);
        end
    end
    join_any
    disable timeoutcheck;

endtask: checkNonceReturnTimeout

/**
 *  task name: checkMultiNonceCorrect
 *  Description:
 *    This task check return nonce in the noncebuf is as expected, only work for single work assigned.
 *  Procedure:
 *    1. W1T to REG_nonce_update to update the noncebuf
 *    2. read the nonce_cnt
 *    3. read the nonce_buf
 *    4. parsing the nonce_buf
 *    5. compare the returned nonce[0]: {ntime, version, nonce} to be as expected as exp_work
 *  parameter:
 *    work_ctrl_mine_work exp_work
 *    int nonce_update=1
 */
task checkMultiNonceCorrect(ref work_ctrl_mine_work exp_work);
    // logic [31:0] rd_data;
    logic [767:0] nonce_buf;
    logic [79:0] nonce_list[`NONCEBUF_LEN];
    logic [127:0] note;
    logic [31:0] version[`NONCEBUF_LEN];
    logic [31:0] nonce[`NONCEBUF_LEN];
    logic [7:0] ntime[`NONCEBUF_LEN];
    int nonce_cnt,matched_nonce_cnt=0;

    `SET_REG_FIELD(work,nonce_update,nonce_update,`W1T);
    `UPDATE_REG(work,nonce_update);
    `RD_REG(work,nonce_cnt,nonce_cnt);
    `WR_REG(work,nonce_cnt,`W1C);

    // `RD_REG(work, nonce_cnt, rd_data);
    `RD_REG(work, noncebuf, nonce_buf);
    note = nonce_buf[127:0];

    //parse the nonce format in the noncebuf
    for(int i=0;i<`NONCEBUF_LEN;i++)begin
        nonce_list[i]=nonce_buf[128+i*80 +: 80];
        version[i]=nonce_list[i][63:32];
        nonce[i]=nonce_list[i][31:0];
        ntime[i]=nonce_list[i][71:64];
    end

    //check the note to be as expected
    if(exp_work.note!==note)begin
        `uvm_error("checkMultiNonceCorrect",$psprintf("Please check the return note is as expected, expected: 0x%0x, actual: 0x%0x",exp_work.note, note));
    end

    //check the target nonce in the noncebuf
    for(int i=0;i<`NONCEBUF_LEN;i++)begin
        if(exp_work.nonce0 === nonce[i] && exp_work.version === version[i])begin
            `uvm_info("checkMultiNonceCorrect",$psprintf("match %0d nonce in the noncebuf, nonce:0x%0x, version:0x%0x",i,nonce[i],version[i]),UVM_MEDIUM);
            nonce_cnt-=1;
            matched_nonce_cnt+=1;
        end
    end
    if(nonce_cnt!=0) `uvm_error("checkMultiNonceCorrect",$psprintf("returned nonce cnt do not match with expected, remaining %0d nonce",nonce_cnt));
    exp_work.returned_nonce+=matched_nonce_cnt;
endtask : checkMultiNonceCorrect

/**
 *  task name: checkNonceCorrect
 *  Description:
 *    This task check return nonce in the noncebuf is as expected, only work for single work assigned.
 *  Procedure:
 *    1. W1T to REG_nonce_update to update the noncebuf
 *    2. read the nonce_cnt
 *    3. read the nonce_buf
 *    4. parsing the nonce_buf
 *    5. compare the returned nonce[0]: {ntime, version, nonce} to be as expected as exp_work
 *  parameter:
 *    work_ctrl_mine_work exp_work
 *    int nonce_update=1
 */
task checkNonceCorrect(input work_ctrl_mine_work exp_work, input int nonce_update=1);
    // logic [31:0] rd_data;
    logic [767:0] nonce_buf;
    logic [79:0] nonce_list[`NONCEBUF_LEN];
    logic [127:0] note;
    logic [31:0] version[`NONCEBUF_LEN];
    logic [31:0] nonce[`NONCEBUF_LEN];
    logic [7:0] ntime[`NONCEBUF_LEN];

    if(nonce_update)begin
        `uvm_info(get_full_name(),"set nonce_update ...",UVM_MEDIUM);
        // `WR_REG(work, nonce_update,`W1T);
        `SET_REG_FIELD(work,nonce_update,nonce_update,`W1T);
        `UPDATE_REG(work,nonce_update);
    end
    // `RD_REG(work, nonce_cnt, rd_data);
    `RD_REG(work, noncebuf, nonce_buf);
    note = nonce_buf[127:0];

    //parse the nonce format in the noncebuf
    for(int i=0;i<`NONCEBUF_LEN;i++)begin
        nonce_list[i]=nonce_buf[128+i*80 +: 80];
        version[i]=nonce_list[i][63:32];
        nonce[i]=nonce_list[i][31:0];
        ntime[i]=nonce_list[i][71:64];
    end

    //check the note to be as expected
    if(exp_work.note!==note)begin
        `uvm_error("checkNonceCorrect",$psprintf("Please check the return note is as expected, expected: 0x%0x, actual: 0x%0x",exp_work.note, note));
    end

    //check the target nonce in the noncebuf
    for(int i=0;i<`NONCEBUF_LEN;i++)begin
        if(exp_work.nonce0 === nonce[i])begin
            `uvm_info("checkNonceCorrect",$psprintf("match %0d nonce in the noncebuf, nonce:0x%0x",i,nonce[i]),UVM_MEDIUM);
            break;
        end
        if(i==(`NONCEBUF_LEN-1))begin
            `uvm_error("checkNonceCorrect",$psprintf("Please check the return nonce is as expected, expected: 0x%0x",exp_work.nonce0));
        end
    end
    //check the target version in the noncebuf
    for(int i=0;i<`NONCEBUF_LEN;i++)begin
        if(exp_work.version === version[i])begin
            `uvm_info("checkNonceCorrect",$psprintf("match %0d version in the noncebuf, version:0x%0x",i,version[i]),UVM_MEDIUM);
            break;
        end
        if(i==(`NONCEBUF_LEN-1))begin
            `uvm_error("checkNonceCorrect",$psprintf("Please check the return version is as expected, expected: 0x%0x",exp_work.version));
        end
    end
endtask : checkNonceCorrect



task checkNonceCorrect_uart(input work_ctrl_mine_work exp_work, input int nonce_update=1, input int workRound=0);
`ifdef VIP
         //#2000;
    if ($test$plusargs("INSERT_REG")) begin
         bit [31:0] rdata_tmp;
         bit [31:0] wdata_tmp;
         wdata_tmp = $random;
         `uvm_info(get_type_name(), $sformatf("insert swreg access when autoreport"), UVM_MEDIUM)
         ral.reg_targetl.wr(wdata_tmp);
         `uvm_info(get_type_name(), $sformatf("wr end, value: %h",wdata_tmp), UVM_MEDIUM)

         fork // nonce_update is assered during reading the inserted reg
           begin
             ral.reg_targetl.rd(rdata_tmp);
             `uvm_info(get_type_name(), $sformatf("rd end, value: %h",rdata_tmp), UVM_MEDIUM)
           end
           begin
             if ($test$plusargs("UART_PLL_MODE"))
                 wait (uart_vif.uart_fsm_p_state == 'd2);
             else
                 wait (uart_vif.uart_fsm_x_state == 'd2);

             if (!$test$plusargs("MULTI_WORK")) begin
                 `uvm_info(get_type_name(), $sformatf("uart_fsm_x_state is CMD_LD"), UVM_LOW)
                 uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.u_top_reg_cfg.REG_Nonce_Update"),1);
                 //wait (uart_vif.uart_fsm_x_state == 'd4);
                 repeat(2) @(posedge top_vif.jls_mid_clk);
                 uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.u_top_reg_cfg.REG_Nonce_Update"),0);
             end
           end
         join

         if(wdata_tmp == rdata_tmp)
           `uvm_info(get_type_name(), $sformatf("rd end pass, value: %h",rdata_tmp), UVM_MEDIUM)
         else
           `uvm_error(get_type_name(),$sformatf("uart reg read write check failed ! wdata = %0h, rdata=%0h",wdata_tmp,rdata_tmp) )
         #200000;
    end else begin
         #600000;
    end
`else
    logic [767:0] nonce_buf;
    logic [79:0] nonce_list[`NONCEBUF_LEN];
    logic [127:0] note;
    logic [31:0] version[`NONCEBUF_LEN];
    logic [31:0] nonce[`NONCEBUF_LEN];
    logic [7:0] ntime[`NONCEBUF_LEN];

    logic [31:0]   wdata;
    logic [39:0]   rx_data;
    logic [767:0]  noncebuf_act;
    int            frm_cnt = 0;
    int            pkt_cnt = 0;
    int            chip_cnt = 0;
    int            REG_UART_NONCE_CNT_MAX = 3;
    int            nonce_cnt_act = 3;
    int            skiped_cnt = 2;

    while(chip_cnt<`CHIP_NUM)begin
        if(chip_cnt == 0) skiped_cnt = 2;
        else skiped_cnt = 3;

        `uvm_info(get_type_name(), $sformatf("check_nonce, frm_cnt_max=%0h",(nonce_cnt_act+1+skiped_cnt-2)), UVM_MEDIUM)
        while(frm_cnt<(nonce_cnt_act+1+skiped_cnt-2)) begin
          while(pkt_cnt<5) begin
            @(negedge uart_vif.RX);
            if (nonce_cnt_act == 3) uvm_hdl_read("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.z_NonceBufCnt",nonce_cnt_act);
            repeat(4)@(posedge top_vif.xclk);

            for(int i=0;i<8;i++) begin
              //repeat(4)@(posedge top_vif.xclk);
              //rx_data[i+pkt_cnt*8] = uart_vif.RX;
              bit_arbiter(rx_data[i+pkt_cnt*8]);
            end
            repeat(4)@(posedge top_vif.xclk);
            pkt_cnt = pkt_cnt+1;
          end

          if(frm_cnt == skiped_cnt) noncebuf_act = rx_data[31:0];
          else if (frm_cnt > skiped_cnt) noncebuf_act = (rx_data[31:0]<<(32*(frm_cnt-skiped_cnt)))+(noncebuf_act);

          frm_cnt = frm_cnt+1;
          pkt_cnt = 0;
        end

        chip_cnt = chip_cnt+1;
        frm_cnt = 0;
        pkt_cnt = 0;

        nonce_buf = noncebuf_act;

        note = nonce_buf[127:0];

        //parse the nonce format in the noncebuf
        for(int i=0;i<`NONCEBUF_LEN;i++)begin
            nonce_list[i]=nonce_buf[128+i*80 +: 80];
            version[i]=nonce_list[i][63:32];
            nonce[i]=nonce_list[i][31:0];
            ntime[i]=nonce_list[i][71:64];
        end

        `ifdef UART_AUTOREPORT_MULTI_WORK
        if(workRound > 0) begin
        `endif
            //`ifndef UART_AUTOREPORT_MULTI_WORK
            //check the note to be as expected
            if(exp_work.note!==note)begin
                `uvm_error("checkNonceCorrect",$psprintf("Please check the return note is as expected, expected: 0x%0x, actual: 0x%0x",exp_work.note, note));
            end else begin
                `uvm_info("checkNonceCorrect",$psprintf("Please check the return note is as expected, expected: 0x%0x, actual: 0x%0x",exp_work.note, note),UVM_LOW);
            end

            //check the target nonce in the noncebuf
            for(int i=0;i<`NONCEBUF_LEN;i++)begin
                if(exp_work.nonce0 === nonce[i])begin
                    break;
                end
                if(i==(`NONCEBUF_LEN-1))begin
                    `uvm_error("checkNonceCorrect",$psprintf("Please check the return nonce is as expected, expected: 0x%0x",exp_work.nonce0));
                end
            end
            //check the target version in the noncebuf
            for(int i=0;i<`NONCEBUF_LEN;i++)begin
                `uvm_info("check_version",$psprintf("debug %0d nonce in the noncebuf, nonce:0x%0x",i,version[i]),UVM_LOW);
                if(exp_work.version === version[i])begin
                    `uvm_info("checkNonceCorrect",$psprintf("match %0d version in the noncebuf, version:0x%0x",i,version[i]),UVM_LOW);
                    break;
                end
                if(i==(`NONCEBUF_LEN-1))begin
                    `uvm_error("checkNonceCorrect",$psprintf("Please check the return version is as expected, expected: 0x%0x",exp_work.version));
                end
            end
        `ifdef UART_AUTOREPORT_MULTI_WORK
        end
        `endif
        noncebuf_act = 0;
    end //while(chip_cnt<`CHIP_NUM)
`endif
endtask : checkNonceCorrect_uart

task jamlink_read_noncebuf(output work_ctrl_jlm_nonce_data_item nonce_data_array []);
    logic [1:0] bsel;
    logic [4:0] cmask;
    logic [31:0] nonce_data [254:0][24:0];
    logic [767:0] nonce_buf;
    bsel=2'h0;
    cmask=5'h0;
    rd_noncebuf_fifo(bsel, cmask, nonce_data);
    nonce_data_array = new[`CHIP_NUM];
    for(int i=0;i<`CHIP_NUM;i++)begin
        nonce_data_array[i]=new();
        nonce_data_array[i].parsing(nonce_data[i]);
        nonce_data_array[i].print();
    end
endtask : jamlink_read_noncebuf

task uart_read_noncebuf(output work_ctrl_jlm_nonce_data_item nonce_data_array []);
`ifndef VIP
    logic [31:0] nonce_data [254:0][24:0];
    logic [767:0] nonce_buf;
    top_vif.chipaddr = `BRD_ADDR;
    `RD_REG(work, noncebuf, nonce_buf);
    //remove uart header 0x5a5a5a5a
    for(int i=0;i<`CHIP_NUM;i++)begin
        nonce_data[i]=uart_vif.noncebuf_data_o[i][25:1];
    end
    nonce_data_array = new[`CHIP_NUM];
    for(int i=0;i<`CHIP_NUM;i++)begin
        nonce_data_array[i]=new();
        nonce_data_array[i].parsing(nonce_data[i]);
        nonce_data_array[i].print();
    end
`endif
endtask : uart_read_noncebuf

/**
 *  task name: workAssignForSpd
 *  Description:
 *    This task do a work assignment with roll disable
 *  Procedure:
 *    1. prepare for the m_work_pool
 *    2. disable rollmode
 *    3. prepare work for broadcast mode, which means all core shall return nonce.
 *    4. assign work
 *  parameter:
 *    logic [7:0] coreid
 */
task workAssignForSpd(logic [7:0] coreid=`BROADCAST);
    work_ctrl_pkg::work_ctrl_mine_work m_work;
    logic [31:0] reg_data;
    bit is_fpga_core;
    logic [7:0] fpga_coreid;
    is_fpga_core=0;
    m_work=new();

    `uvm_info(get_type_name(),"pre step for fake spd start",UVM_MEDIUM)

    //retrieve all gold work from data file, the file selection is based on the macro define
    m_work_pool.setDatFile();

    //Generate work
    m_work.setGoldWork(m_work_pool.getGoldWork());
    m_work.setRegTBase(work_ctrl_cfg_h.tbase);
`ifdef FPGA_SYN
    for(int i=0;i<`SLICE_NUM;i++)begin
        for(int fpgacoreid=0;fpgacoreid<=slice_core_num[i];fpgacoreid++)begin
            uvm_hdl_read($psprintf("tb_top.C[0].btnode.btc.slice%0d.slice0_fpga_core_exist[%0d]",i,i,fpgacoreid),is_fpga_core);
            if(is_fpga_core)begin
                fpga_coreid=fpgacoreid;
                break;
            end
            if(is_fpga_core)    break;
        end
    end
    `uvm_info(get_type_name(), $sformatf("The FPGA instance core is %d",fpga_coreid), UVM_LOW)
    //select core id to return the nonce with fakecore
    m_work.nonceMask(fpga_coreid);
`else
    //select core id to return the nonce with fakecore
    m_work.nonceMask(coreid);
`endif

    //set the ntime to be 0, this means for the first time of roll mode, it will get the nonce back
    m_work.reCalcTime(0);
    //ft_en to be zero.
    m_work.workRegenerate(`FT_DIS);
    m_work.print();

    //set value to rollen close
    `SET_REG_FIELD(work, cfg, cfg_rollen, `OFF);
    `UPDATE_REG(work, cfg);

    workAssign(m_work);

    //nonce returned.
    checkNonceReturnTimeout();

    repeat(200) @(posedge work_ctrl_vif.mid_clk);
    //rst fifo.
    `SET_REG_FIELD(work,cfg,cfg_rstfifo,`W1T);
    `UPDATE_REG(work,cfg);
    checkNonceCorrect(m_work);
    `uvm_info(get_type_name(),"pre step for fake spd done",UVM_MEDIUM)
endtask : workAssignForSpd




/*  ============================================================  */
/*  ==========================     Efuse   =====================  */
/*  ============================================================  */
/**
 *  task name: initEfuse
 *  Description:
 *    This task initialized the efuse registers that requires after chip power on. it clear X when GLS.
 *  Procedure:
 *    1. write reset
 *    2. write sense
 *  parameter: none
 */
task initEfuse;
    // 
    // ral.crg.reg_ri_enable.reg_ri_function_pre.set(1'b0);
    // ral.crg.reg_ri_enable.upd();
    ral.crg.reg_mux.reg_xclk_efuse_en.set(1'b1);
    ral.crg.reg_mux.upd();   
    `uvm_info(get_type_name,"open efuse xlck...",UVM_MEDIUM)

    ral.efuse.reg_efuse_ctrl.wr(32'h8);
    ral.efuse.reg_efuse_ctrl.wr(32'h1);
endtask : initEfuse






















function bit chkc_real_diffequal(input real p_realdata_act, input real p_realdata_exp, input real p_max_diffrate=0.01);
    bit  v_result;
    real v_diff;
    real v_diffrate;
    v_diff = p_realdata_act - p_realdata_exp;
    if(v_diff < 0) begin
        v_diff = p_realdata_exp - p_realdata_act;
    end
    v_diffrate = v_diff / p_realdata_exp;
    if( v_diffrate > p_max_diffrate ) begin
        v_result = 0;
    end
    else begin
        v_result = 1;
    end
    return v_result;
endfunction

function bit chkc_real_equal(input real act, input real exp, input bit p_abs=0, input real p_max_diffrate=0.01);
    bit  v_result;
    real v_realdata_act_real;
    real v_realdata_exp_real;
    real v_diff;
    real v_diffrate;
    if(act == 0 && exp == 0) begin
        return 1;
    end
    if(p_abs === 1) begin
        v_result = (act == exp);
    end
    else begin
        v_result = chkc_real_diffequal(act, exp, p_max_diffrate);
    end
    return v_result;
endfunction

task clr_ecc();
	ral.comm.reg_ecc0.wr(32'h1);
	ral.comm.reg_ecc1.wr(32'h1);
	ral.comm.reg_ecc2.wr(32'h1);

endtask

task bit_arbiter (output logic rdata);
    int counter=0;
    for(int i = 0; i<16;i++) begin
        @(posedge uart_vif.uart_clk);
        if ((i>3)&&(i<12))begin
	  if(uart_vif.RX) counter++;
        end
    end
    if (counter>4) rdata=1; else rdata=0;
    counter=0;
endtask


   
 