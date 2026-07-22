module jlm_dic(
input             clk       ,
input             rst       ,
input             CI        ,
input             DI        ,
input             REG_WrLog ,
input             REG_IniLog,
output            get_vld   ,
output reg [31:0] get_data  ,
output reg [1:0]  get_ecc   ,
input  [3:0]      onehot    ,
output reg        di_idle   
);
wire err_detect;
wire err_multpl;
wire [31:0] correct_data;
reg [50:0] di_f;
parameter IDLE = 0;
parameter CMD  = 1;
parameter DAT  = 2;
reg [1:0] cur_state;
reg [1:0] nxt_state;
wire is_mode_rd ;
wire is_mode_wr ;
wire is_mode_ini;
reg r_is_mode_rd ;
reg r_is_mode_ini;

DW_ecc #(.width(32),.chkbits(7),.synd_sel(0)) DW_ecc_dec(
/*input                 */ .gen       (1'b0        ),
/*input                 */ .correct_n (1'b0        ),
/*input [width-1 : 0]   */ .datain    (di_f[42:11] ),
/*input [chkbits-1 : 0] */ .chkin     (di_f[7:1]   ),
/*output                */ .err_detect(err_detect  ),
/*output                */ .err_multpl(err_multpl  ),
/*output [width-1 : 0]  */ .dataout   (correct_data),
/*output [chkbits-1 : 0]*/ .chkout    (            )
);

reg [5:0] ci_cnt;
wire start_detect = di_f == {43'b0, 8'h33};
wire reset_detect = di_f == {43'b0, 8'h00};
reg ack_cycle;
reg nack_cycle;

always @ (posedge CI) begin
	di_f <= {di_f[49:0], DI};
end

always @ (posedge CI) begin
	if(ci_cnt >= 6'd42 || start_detect)
		ci_cnt <= 6'b0;
	else
		ci_cnt <= ci_cnt + 6'b1;
end

reg CI_get_vld;
vld_cdc vld_cdc(.aclk(CI),.avld(CI_get_vld),.bclk(clk),.bvld(get_vld));

always @ (posedge CI) begin
	ack_cycle <= ci_cnt == 6'd41 && DI;
	nack_cycle <= ci_cnt == 6'd41 && ~DI;
end

wire [1:0] chsel = onehot == 4'b0001 ? 2'd0 :
		   onehot == 4'b0010 ? 2'd1 :
		   onehot == 4'b0100 ? 2'd2 : 2'd3;
always @ (posedge CI) begin
	if((cur_state == CMD && nxt_state == DAT           ) ||
	   (cur_state == DAT && ack_cycle                  ) ||
	   (cur_state == DAT && nack_cycle && r_is_mode_rd ) ||
	   (cur_state == DAT && nack_cycle && r_is_mode_ini)
	) begin
		get_data <= (cur_state == CMD && nxt_state == DAT) ? 
			    ({correct_data & 32'hff3f_ffff} | chsel << 22) : correct_data;
		CI_get_vld <= 1'b1;
		get_ecc <= ~err_detect ? 2'd0 : (err_detect && ~err_multpl) ? 2'd1 : 2'd2;
	end else begin
		CI_get_vld <= 1'b0;
	end
end

//-----------------------------
// FSM
//-----------------------------
assign is_mode_rd  = correct_data[21:16] == `JLM_RD;
assign is_mode_wr  = correct_data[21:16] == `JLM_WR && REG_WrLog;
assign is_mode_ini = correct_data[21:16] == `JLM_INI && REG_IniLog;

always @ (posedge CI) begin
	if(cur_state == CMD && nxt_state == DAT) begin
		r_is_mode_rd  <= is_mode_rd ;
		r_is_mode_ini <= is_mode_ini;
	end
end


always @ (posedge CI) begin
	cur_state <= nxt_state;
end

always @ (*) begin
	nxt_state = cur_state;
	case(cur_state)
	IDLE   :if(start_detect)
			nxt_state = CMD;
	CMD    :if((is_mode_rd || is_mode_wr || is_mode_ini) && ack_cycle)
			nxt_state = DAT;
		else if(ack_cycle || nack_cycle)
			nxt_state = IDLE;
	DAT    :if(nack_cycle)
			nxt_state = IDLE;
	default: nxt_state = IDLE;
	endcase
end

always @ (posedge CI) begin
	di_idle <= cur_state == IDLE;
end
endmodule
