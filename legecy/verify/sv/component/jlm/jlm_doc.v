module jlm_doc(
input             clk       ,
input             rst       ,
output reg        CO        ,
output            DO        ,
input      [1:0]  REG_IniCh ,
input      [31:0] REG_Dly   ,
input      [7:0]  REG_DoFCnt,
input      [7:0]  REG_CoPrd ,
input             REG_CoEn  ,
output            fifo_pop  ,
input      [31:0] dout      ,
output reg [3:0]  onehot    ,
input             di_idle   ,
output reg        now_rd    ,
output reg        now_wr    ,
output reg        now_ini    
);

reg [7:0] co_cnt;
always @ (posedge clk) begin
	if(co_cnt >= REG_CoPrd)
		co_cnt <= 8'b0;
	else
		co_cnt <= co_cnt + 8'b1;
end

always @ (posedge clk) begin
	if(co_cnt == REG_CoPrd)
		CO <= !CO;
end

parameter IDLE = 0;
parameter DLY  = 1;
parameter HEAD = 2;
parameter SEND = 3;
reg [1:0] cur_state;
reg [1:0] nxt_state;
reg [1:0] work_ChSel;
reg [5:0] work_Mode;
wire      work_NeedDly = dout[10];
reg [9:0] work_TranLen;
reg [31:0] dly_cnt;
reg [6:0] bit_cnt;
reg [9:0] word_cnt;
wire is_last_bit = bit_cnt == 7'd42;

always @ (posedge CO) begin
	if(rst)
		onehot <= REG_IniCh == 2'd0 ? 4'b0001 :
			  REG_IniCh == 2'd1 ? 4'b0010 :
			  REG_IniCh == 2'd2 ? 4'b0100 : 4'b1000;
	else if(cur_state == IDLE && nxt_state == DLY)
		onehot <= dout[23:22] == 2'd0 ? 4'b0001 :
			  dout[23:22] == 2'd1 ? 4'b0010 :
			  dout[23:22] == 2'd2 ? 4'b0100 : 4'b1000 ;
end

always @ (posedge CO) begin
	if(rst)
		cur_state <= IDLE;
	else
		cur_state <= nxt_state;
end

wire [9:0] is_work_len_rd  = 10'd3;
wire [9:0] is_work_len_wr  = dout[9:0] + 10'd3;
wire [9:0] is_work_len_ini = 10'd4;

wire is_work_rd  = ({2'b0, REG_DoFCnt} >= is_work_len_rd ) && dout[21:16] == `JLM_RD;
wire is_work_wr  = ({2'b0, REG_DoFCnt} >= is_work_len_wr ) && dout[21:16] == `JLM_WR;
wire is_work_ini = ({2'b0, REG_DoFCnt} >= is_work_len_ini) && dout[21:16] == `JLM_INI;

reg [2:0] di_idle_f;
always @ (posedge CO) begin
	di_idle_f <= {di_idle_f[1:0], di_idle};
end

always @ (*) begin
	nxt_state = cur_state;
	case(cur_state)
	IDLE: if(di_idle_f[2:1] == 2'b11 && (is_work_rd || is_work_wr || is_work_ini))
			nxt_state = DLY;
	DLY : if(dly_cnt == 32'd0)
			nxt_state = HEAD;
	HEAD: if(is_last_bit)
			nxt_state = SEND;
	SEND: if(word_cnt == work_TranLen && is_last_bit)
			nxt_state = IDLE;
	default: nxt_state = IDLE;
	endcase
end
assign di_enable = cur_state != IDLE;

always @ (posedge CO) begin
	if(cur_state == IDLE && nxt_state == DLY) begin
		work_ChSel   <= dout[23:22];
		work_Mode    <= dout[21:16];
		work_TranLen <= is_work_rd ? is_work_len_rd :
				is_work_wr ? is_work_len_wr : is_work_len_ini;
	end
end

always @ (posedge CO) begin
	if(rst)
		dly_cnt <= 32'b0;
	else if(cur_state == IDLE && nxt_state == DLY && work_NeedDly)
		dly_cnt <= REG_Dly;
	else if(cur_state == IDLE && nxt_state == DLY && !work_NeedDly)
		dly_cnt <= 32'd100;
	else if(|dly_cnt)
		dly_cnt <= dly_cnt - 32'b1;
end

always @ (posedge CO) begin
	if(cur_state == DLY && nxt_state == HEAD)
		bit_cnt <= 7'd0;
	else if(!is_last_bit)
		bit_cnt <= bit_cnt + 7'd1;
	else
		bit_cnt <= 7'd0;
end

reg [42:0] do_buf;
assign fifo_pop = (cur_state == HEAD && nxt_state == SEND) ||
	          (is_last_bit && |word_cnt && word_cnt < work_TranLen);
always @ (posedge CO) begin
	if(cur_state == IDLE)
		word_cnt <= 10'b0;
	else if(fifo_pop)
		word_cnt <= word_cnt + 10'd1;
end

wire [6:0] ecc_enc;
always @ (posedge CO) begin
	if(cur_state == DLY && nxt_state == HEAD)
		do_buf <= 43'h33;
	else if(cur_state == IDLE && nxt_state == DLY)
		do_buf <= 43'h0;
	else if(fifo_pop && (work_Mode == `JLM_WR || work_Mode == `JLM_INI))
		do_buf <= {dout[31:0],2'b11,1'b0,ecc_enc,1'b1} `JLM_ERROR_INJECT;
	else if(fifo_pop && work_Mode == `JLM_RD && word_cnt != work_TranLen - 10'd1)
		do_buf <= {dout[31:0],2'b11,1'b0,ecc_enc,1'b1} `JLM_ERROR_INJECT;
	else if(fifo_pop && (word_cnt == work_TranLen - 10'd1))
		do_buf <= {dout[31:0],2'b11,1'b0,ecc_enc,1'b0} `JLM_ERROR_INJECT;
	else if(is_last_bit && work_Mode == `JLM_RD && cur_state != DLY)
		do_buf <= {32'h0,2'b11,8'h0,1'b0};
	else
		do_buf <= {do_buf[41:0],1'b0};
end
assign DO = do_buf[42];

always @ (posedge CO) begin
	if(cur_state == DLY && nxt_state == HEAD) begin
		now_rd <= dout[21:16] == `JLM_RD;
		now_wr <= dout[21:16] == `JLM_WR;
		now_ini<= dout[21:16] == `JLM_INI;
	end
end

DW_ecc #(.width(32),.chkbits(7),.synd_sel(0)) DW_ecc_enc(
/*input                 */ .gen       (1'b1   ),
/*input                 */ .correct_n (1'b0   ),
/*input  [width-1 : 0]  */ .datain    (dout   ),
/*input  [chkbits-1 : 0]*/ .chkin     (7'b0   ),
/*output                */ .err_detect(       ),
/*output                */ .err_multpl(       ),
/*output [width-1 : 0]  */ .dataout   (       ),
/*output [chkbits-1 : 0]*/ .chkout    (ecc_enc)
);

endmodule
