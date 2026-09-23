//----------------------------------------------------------------------------------------
// soc_stub: placeholder DUT for local open-source (Verilator) bring-up only.
// The real design database replaces this file when hdl/ lands (see verify/CLAUDE.md).
// Port set mirrors the generated UVC interfaces: active-high rst, card_sel frame,
// one 32-bit control bus in / one 32-bit status bus out.
//----------------------------------------------------------------------------------------
`timescale 1ns/1ps

module soc_stub (
    input  logic        clk,
    input  logic        rst,
    input  logic        card_sel,
    input  logic [31:0] reg_ctrl,
    output logic [31:0] reg_status
);

    logic [31:0] ctrl_q;

    always_ff @(posedge clk) begin
        if (rst) begin
            ctrl_q <= 32'h0;
        end else if (card_sel) begin
            ctrl_q <= reg_ctrl;
        end
    end

    assign reg_status = ctrl_q;

endmodule : soc_stub
