`ifndef PL_SIM
`ifndef SPD_ASSERTION_NO_CHK
property spd2_up_down(i);
    @(posedge mid_clk) disable iff(!rst || !rst_stable)
       (global_spd_en==1'b1 && ss_sel==2'b10) |=> !(spd2_up[i]==1'b1 && spd2_down[i]==1'b1);
endproperty

generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
chk_spd2_up_down: 
    assert property(spd2_up_down(i)) 
        else `uvm_error("[ASSERT ERR]","spd2_up spd2_down cannot be one sametime");
cov_spd2_up_down: 
    cover property(spd2_up_down(i));
end
endgenerate


property trigger_valid(i);
    @(posedge mid_clk) disable iff(!rst || !rst_stable)
        (global_spd_en==1'b1 && ss_sel==2'b10) |=> $countones({pass_trigger[i], normal_trigger[i], fail_trigger[i], timeout_trigger[i]}) < 2;
endproperty
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_trigger_valid:
        assert property(trigger_valid(i))
            else `uvm_error("[ASSERT ERR]", $psprintf("pass_trigger=%b normal_trigger=%b fail_trigger=%b, timeout_trigger=%b", pass_trigger[i], normal_trigger[i], fail_trigger[i], timeout_trigger[i]));
    cov_trigger_valid:
        cover property(trigger_valid(i));
end
endgenerate


property reg_spdhigh_low_tmp(i);
    @(posedge mid_clk) disable iff(!rst || !rst_stable)
        (global_spd_en==1'b1 && ss_sel==2'b10) |-> reg_spdlow_tmp[i] <= reg_spdhigh_tmp[i]; 
endproperty
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_reg_spdhigh_low_tmp: 
        assert property(reg_spdhigh_low_tmp(i))
            else `uvm_error("[ASSERT ERR]", $psprintf("core_id=%0d,reg_spdhigh_tmp=%d reg_spdlow_tmp=%d",i, reg_spdhigh_tmp[i], reg_spdlow_tmp[i]));
    cov_reg_spdhigh_low_tmp: cover property(reg_spdhigh_low_tmp(i));
end
endgenerate



localparam SS_IDLE                = 4'b0000;
localparam SS_WORK                = 4'b0001;
localparam SS_FAULT_SHOT_1        = 4'b0011;
localparam SS_RANGE_CHG           = 4'b0010;
localparam SS_DIAG                = 4'b0110;
localparam SS_SPD_CHG             = 4'b0111;
localparam SS_MONITOR             = 4'b0101;
localparam SS_FAULT_SHOT_2        = 4'b0100;
localparam SS_RELEASE             = 4'b1100;
localparam SS_RECHK               = 4'b1101;
localparam SS_SLC                 = 4'b1111;
localparam SS_REWARD              = 4'b1110;
localparam SS_TRY_UP              = 4'b1010;
localparam SS_TRY_MONI            = 4'b1011;
localparam SS_TRY_FAIL            = 4'b1001;

property state_keep_1_cycle(i, exp_state);
    @(posedge mid_clk) disable iff(!rst || !rst_stable)
        (global_spd_en==1'b1 && ss_sel==2'b10 && spd_state_cur[i]==exp_state) |=>  spd_state_cur[i] != exp_state;
endproperty

generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_FAULT_SHOT_1)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_FAULT_SHOT_1 Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_FAULT_SHOT_1));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_TRY_UP)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_TRY_UP Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_TRY_UP));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_TRY_FAIL)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_TRY_FAIL Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_TRY_FAIL));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_REWARD)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_REWARD Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_REWARD));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_SPD_CHG)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_SPD_CHG Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_SPD_CHG));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_RANGE_CHG)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_RANGE_CHG Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_RANGE_CHG));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_DIAG)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_DIAG Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_DIAG));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_RELEASE)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_RELEASE Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_RELEASE));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_SLC)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_SLC Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_SLC));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_RECHK)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_RECHK Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_RECHK));
end
endgenerate
generate;
for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_state_keep_1_cycle: assert property(state_keep_1_cycle(i, SS_FAULT_SHOT_2)) 
        else `uvm_error("[ASSERT_ERROR]", $psprintf("Coreid=%d SS_FAULT_SHOT_2 Not keep 1 cycle", i));
    cov_state_keep_1_cycle: cover property(state_keep_1_cycle(i, SS_FAULT_SHOT_2));
end
endgenerate

`endif
`endif



