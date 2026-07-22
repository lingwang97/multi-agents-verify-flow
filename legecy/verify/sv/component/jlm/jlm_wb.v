module jlm_wb(
input             JLM_CYC_I   ,
input             JLM_STB_I   ,
input             JLM_WE_I    ,
input             JLM_LOCK_I  ,
input  [2:0]      JLM_CTI_I   ,
input  [1:0]      JLM_BTE_I   ,
input  [5:0]      JLM_ADR_I   ,
input  [31:0]     JLM_DAT_I   ,
input  [3:0]      JLM_SEL_I   ,
output reg        JLM_ACK_O   ,
output            JLM_ERR_O   ,
output            JLM_RTY_O   ,
output reg [31:0] JLM_DAT_O   ,
input             CO          ,
input             CI          ,
input             clk         ,
output reg [1:0]  REG_IniCh   ,
output            REG_SetFlush,//clk2CO
output            REG_DiFRst  ,//clk
output            REG_DoFRst  ,//clk2CO
output            REG_SetRst  ,//clk2CO&CI
output reg        REG_DoF_push,//clk
output reg [31:0] REG_DoF     ,//clk
output reg        REG_DiF_pop ,//clk
input  [31:0]     REG_DiF     ,//clk
input             REG_DiFEpt  ,//clk
input             REG_DiFFull ,//clk
input  [7:0]      REG_DiFCnt  ,//clk
input             REG_DoFEpt  ,//clk
input             REG_DoFFull ,//clk
input  [7:0]      REG_DoFCnt  ,//clk
output reg [31:0] REG_Dly     ,//clk
output reg [7:0]  REG_CoPrd   ,//clk
output reg        REG_WrLog   ,//clk
output reg        REG_IniLog  ,//clk
output reg        REG_CoEn    ,//clk
input             get_vld     ,
input  [1:0]      get_ecc
);

reg [31:0] r_data;

assign JLM_ERR_O = 1'd0;
assign JLM_RTY_O = 1'd0;

wire is_ctrl = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h0;
wire is_dof  = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h4;
wire is_dif  = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h8;
wire is_fctrl= JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'hc;
wire is_dly  = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h10;
wire is_cfg  = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h14;
wire is_ecc0 = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h1c;
wire is_ecc1 = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h20;
wire is_ecc2 = JLM_STB_I && ~JLM_ACK_O && JLM_ADR_I == 6'h24;

always @ (posedge clk) begin
	JLM_ACK_O <= JLM_STB_I;
end

reg [15:0] r_REG_SetFlush;
reg [15:0] r_REG_DiFRst  ;
reg [15:0] r_REG_DoFRst  ;
reg [15:0] r_REG_SetRst  ;
always @ (posedge clk) begin
	if(is_ctrl && JLM_WE_I) begin
		REG_IniCh      <= JLM_DAT_I[5:4];
		r_REG_SetFlush <= {15'b0,JLM_DAT_I[3]};
		r_REG_DiFRst   <= {15'b0,JLM_DAT_I[2]};
		r_REG_DoFRst   <= {15'b0,JLM_DAT_I[1]};
		r_REG_SetRst   <= {15'b0,JLM_DAT_I[0]};
	end else begin
		r_REG_SetFlush <= {r_REG_SetFlush[14:0], 1'b0};
		r_REG_DiFRst   <= {r_REG_DiFRst  [14:0], 1'b0};
		r_REG_DoFRst   <= {r_REG_DoFRst  [14:0], 1'b0};
		r_REG_SetRst   <= {r_REG_SetRst  [14:0], 1'b0};
	end
end

assign REG_SetFlush = |r_REG_SetFlush;
assign REG_DiFRst   = |r_REG_DiFRst  ;
assign REG_DoFRst   = |r_REG_DoFRst  ;
assign REG_SetRst   = |r_REG_SetRst  ;

always @ (posedge clk) begin
	if(is_dof && JLM_WE_I) begin
		REG_DoF_push <= 1'b1;
		REG_DoF <= JLM_DAT_I;
	end else
		REG_DoF_push <= 1'b0;
end

always @ (posedge clk) begin
	REG_DiF_pop <= is_dif && ~JLM_WE_I;
end

always @ (posedge clk) begin
	if(is_dly && JLM_WE_I)
		REG_Dly <= JLM_DAT_I;
end

always @ (posedge clk) begin
	if(is_cfg && JLM_WE_I) begin
		REG_CoPrd   <= JLM_DAT_I[23:16];
		REG_WrLog   <= JLM_DAT_I[3];
		REG_IniLog  <= JLM_DAT_I[2];
		REG_CoEn    <= JLM_DAT_I[1];
	end
end

reg [31:0] REG_ECC0;
reg [31:0] REG_ECC1;
reg [31:0] REG_ECC2;
always @ (posedge clk) begin
	if(is_ecc0 && JLM_WE_I)
		REG_ECC0 <= 32'b0;
	else if(get_vld && get_ecc == 2'd0)
		REG_ECC0 <= REG_ECC0 + 32'b1;
end

always @ (posedge clk) begin
	if(is_ecc1 && JLM_WE_I)
		REG_ECC1 <= 32'b0;
	else if(get_vld && get_ecc == 2'd1)
		REG_ECC1 <= REG_ECC1 + 32'b1;
end

always @ (posedge clk) begin
	if(is_ecc2 && JLM_WE_I)
		REG_ECC2 <= 32'b0;
	else if(get_vld && get_ecc == 2'd2)
		REG_ECC2 <= REG_ECC2 + 32'b1;
end

always @ (posedge clk) begin
	case(1'b1)
	is_ctrl : JLM_DAT_O <= {26'b0,REG_IniCh,REG_SetFlush,REG_DiFRst,REG_DoFRst,REG_SetRst};
	is_dif  : JLM_DAT_O <= {REG_DiF[31:0]};
	is_fctrl: JLM_DAT_O <= {6'b0,REG_DiFEpt,REG_DiFFull,REG_DiFCnt[7:0],6'b0,REG_DoFEpt,REG_DoFFull,REG_DoFCnt[7:0]};
	is_dly  : JLM_DAT_O <= REG_Dly;
	is_cfg  : JLM_DAT_O <= {8'b0,REG_CoPrd[7:0],12'b0,REG_WrLog,REG_IniLog,REG_CoEn,1'b0};
	is_ecc0 : JLM_DAT_O <= REG_ECC0;
	is_ecc1 : JLM_DAT_O <= REG_ECC1;
	is_ecc2 : JLM_DAT_O <= REG_ECC2;
	endcase
end

endmodule
