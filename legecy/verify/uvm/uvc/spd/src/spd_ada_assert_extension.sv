// +FHDR----------------------------------------------------------------------------
// Project Name  : BTC_PRJ
// Author        : cxiang
// Email         : xiangchen@canaan-creative.com
// Created On    : 2024/10/22 11:39
// Last Modified : 2024/11/07 11:42
// File Name     : spd_ada_assert.sv
// Description   : assertion extention for ss half clock extensive features
//
// Copyright (c) 2024 Canaan Creative.
// ALL RIGHTS RESERVED
//
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2024/10/22   cxiang          1.0                     Original
// -FHDR----------------------------------------------------------------------------

`timescale 1ns / 10ps

import btc_pkg::*;
import uvm_pkg::*;

module spd_ada_assert_extension #(
    parameter logic [2:0] REAL_SPD[8] = '{default: '0}
) (
    input logic                           mid_clk_gated_ss2,
    input logic                           mid_rst_n,
    input logic                           REG_ss_pri,
    input logic                           c_clock_in_half_region,
    input logic      [               2:0] spd_sel_tmp,
    input logic      [               2:0] REG_SpdLow_tmp,
    input logic      [               2:0] REG_SpdHigh_tmp,
    input logic                           vld_reg_spd_sel,
    input logic                           REG_GlbSetVld,
    input logic                           ss_adaptive_half_clk_en,
    input ss_state_t                      ss_cur_state,
    input logic      [ `SPDLOW_WIDTH-1:0] REG_SpdLow,
    input logic      [`SPDHIGH_WIDTH-1:0] REG_SpdHigh
);
    localparam GATE = 0;
    localparam PLL0 = 1;
    localparam PLL1 = 2;
    localparam PLL2 = 3;
    localparam PLL3 = 4;
    localparam HALF_CLK_0 = 5;
    localparam HALF_CLK_1 = 6;
    localparam HALF_CLK_2 = 7;
    logic region_lock;

    `define step(
        spd1,
        spd2) ((REAL_SPD[spd1]>REAL_SPD[spd2]) ? (REAL_SPD[spd1]-REAL_SPD[spd2]) : (REAL_SPD[spd2]-REAL_SPD[spd1]))

    initial begin
        $assertoff(0, spd_ada_assert_extension);
        wait (mid_rst_n == 0);
        wait (mid_rst_n);
        $asserton(0, spd_ada_assert_extension);
    end


    always_ff @(posedge mid_clk_gated_ss2 or negedge mid_rst_n) begin
        if (!mid_rst_n) region_lock <= '0;
        else begin
            if (vld_reg_spd_sel) region_lock <= '0;
            else if ((spd_sel_tmp >= HALF_CLK_0) && ~REG_ss_pri) region_lock <= '1;
        end
    end

    sequence SW_inter;
        (vld_reg_spd_sel || REG_GlbSetVld) ##1 (spd_sel_tmp inside {GATE, HALF_CLK_0, HALF_CLK_1, HALF_CLK_2});
    endsequence


    property half_clk_unlock;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) ~ss_adaptive_half_clk_en |-> spd_sel_tmp < HALF_CLK_0;
    endproperty

    property lower_bound_adjust;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) ((ss_cur_state == SS_WORK) && ($past(
            ss_cur_state
        ) != SS_TRY_FAIL) && (spd_sel_tmp < HALF_CLK_0)) |-> ##1 (REG_SpdLow_tmp < HALF_CLK_0);
    endproperty

    property upper_bound_setting;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) REG_SpdHigh inside {GATE, PLL0, PLL1, PLL2, PLL3};
    endproperty

    property spd_exceed_upper_range;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) REAL_SPD[spd_sel_tmp] <= REAL_SPD[REG_SpdHigh];
    endproperty

    property spd_exceed_lower_range;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n)
            |spd_sel_tmp |-> (REAL_SPD[spd_sel_tmp] >= REAL_SPD[REG_SpdLow]);
    endproperty

    property lock_in_half_f_region_in_pwr_saving_mode;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) region_lock |-> (spd_sel_tmp >= HALF_CLK_0);
    endproperty

    property lower_upper_bound_in_correct_order;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) REAL_SPD[REG_SpdHigh_tmp] >= REAL_SPD[REG_SpdLow_tmp];
    endproperty

    property stay_in_idle;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n)
            SW_inter |-> ##1 ((ss_cur_state == SS_IDLE) throughout ((vld_reg_spd_sel || REG_GlbSetVld) [-> 1]));
    endproperty

    property change_spd_by_one_level;
        @(posedge mid_clk_gated_ss2) disable iff (!mid_rst_n) ($changed(
            spd_sel_tmp
        ) && ~($past(vld_reg_spd_sel) || $past(REG_GlbSetVld))) |->
        `step($past(spd_sel_tmp), spd_sel_tmp)
        == 1;
    endproperty

    ERROR_HALF_CLOCK_UNLOCK_BY_MISTAKE :
    assert property (half_clk_unlock)
    else `uvm_error("[ASSERT ERR]", $sformatf("ERROR_HALF_CLOCK_UNLOCK_BY_MISTAKE @ %m"));


    ERROR_LOWER_BOUND_ADJUSTED :
    assert property (lower_bound_adjust)
    else
        `uvm_error(
            "[ASSERT ERR]", $sformatf(
            "ERROR_LOWER_BOUND_ADJUSTED, spd_sel_tmp = %0d, REG_SpdLow_tmp = %0d @ %m", spd_sel_tmp, REG_SpdLow_tmp));


    ERROR_UPPER_BOUND_SETTING :
    assert property (upper_bound_setting)
    else `uvm_error("[ASSERT ERR]", $sformatf("ERROR_UPPER_BOUND_SETTING, REG_SpdHigh = %0d @ %m", REG_SpdHigh));


    ERROR_SPD_EXCEED_UPPER_RANGE :
    assert property (spd_exceed_upper_range)
    else
        `uvm_error(
            "[ASSERT ERR]", $sformatf(
            "ERROR_SPD_EXCEED_UPPER_RANGE spd_sel_tmp = %0d, REG_SpdHigh = %0d, @ %m", spd_sel_tmp, REG_SpdHigh));


    ERROR_SPD_EXCEED_LOWER_RANGE :
    assert property (spd_exceed_lower_range)
    else
        `uvm_error("[ASSERT ERR]", $sformatf(
                   "ERROR_SPD_EXCEED_LOWER_RANGE, spd_sel_tmp = %0d, REG_SpdLow = %0d, @ %m", spd_sel_tmp, REG_SpdLow));


    ERROR_NOT_LOCKED_IN_HALF_F_REGION_IN_PWR_SAVING_MODE :
    assert property (lock_in_half_f_region_in_pwr_saving_mode)
    else
        `uvm_error("[ASSERT ERR]", $sformatf(
                   "ERROR_NOT_LOCKED_IN_HALF_F_REGION_IN_PWR_SAVING_MODE, spd_sel_tmp = %d, @ %m", spd_sel_tmp));


    ERROR_UPPER_LOWER_BOUNDARY_REVERSED :
    assert property (lower_upper_bound_in_correct_order)
    else
        `uvm_error("[ASSERT ERRR]", $sformatf(
                   "ERROR_UPPER_LOWER_BOUNDARY_REVERSED, REG_SpdHigh_tmp = %0d, REG_SpdLow_tmp = %0d, @ %m",
                   REG_SpdHigh_tmp,
                   REG_SpdLow_tmp));

    ERROR_SS_CHANGE_BY_MISTAKE_AFTER_SW_INTERVENE :
    assert property (stay_in_idle)
    else
        `uvm_error("[ASSERT ERR]", $sformatf(
                   "ERROR_SS_CHANGE_BY_MISTAKE_AFTER_SW_INTERVENE, state = %0s, spd_sel_tmp= %0d, @%m",
                   ss_cur_state.name(),
                   spd_sel_tmp));

    ERROR_SS_SPD_CHANGE_HAVING_GAP :
    assert property (change_spd_by_one_level)
    else
        `uvm_error(
            "[ASSERT ERR]", $sformatf(
            "ERROR_SS_SPD_CHANGE_HAVING_GAP, past spd = %0d, current spd = %0d, @ %m", $past(spd_sel_tmp), spd_sel_tmp));


endmodule

