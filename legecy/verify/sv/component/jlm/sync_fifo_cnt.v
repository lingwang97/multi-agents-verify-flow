module sync_fifo_cnt #(parameter DSIZE = 40,
    parameter ASIZE = 2)(
	input   clk,
	input   soft_rst,
	input   wen,
	input   ren,
	input   [DSIZE-1:0] din,
	output  [DSIZE-1:0] dout,
	output  full,
	output  empty,
	output  reg [ASIZE:0] cnt 
);

reg [ASIZE:0]   waddr;
reg [ASIZE:0]   raddr;

fifomem #(.DATASIZE(DSIZE), .ADDRSIZE(ASIZE)) u_fifomem(
    .rdata(dout),
    .wdata(din),
    .waddr(waddr[ASIZE-1:0]),
    .raddr(raddr[ASIZE-1:0]),
    .wclken(wen),
    .wfull(full),
    .wclk(clk) 
);

always@(posedge clk)begin
    if(soft_rst)
        waddr <= 0;
    else if(wen)
        waddr <= waddr + 1;
end

always@(posedge clk)begin
    if(soft_rst)
        raddr <= 0;
    else if(ren)
        raddr <= raddr + 1;
end

always@(posedge clk)begin
	if(soft_rst)
		cnt <= 0;
	else if(wen && !ren)
		cnt <= cnt + 1;
	else if(!wen && ren)
		cnt <= cnt - 1;
end

assign empty = (raddr == waddr);
assign full = (raddr[ASIZE-1:0] == waddr[ASIZE-1:0]) & (raddr[ASIZE] != waddr[ASIZE]);
endmodule

