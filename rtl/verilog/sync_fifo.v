//===========================================================================
module sync_fifo #(parameter Dwidth = 16, Ddepth = 2)(
	input               WRITE ,
	input  [Dwidth-1:0] WR_DATA ,
	input               READ ,  
	output [Dwidth-1:0] RD_DATA ,
	output              FULL , 
	output              EMPTY ,
	input               CLK , 
	input               RSTB
);
//===========================================================================
//===========================================================================
reg	 [Ddepth-1:0]   wr_addr, nwr_addr;
reg	 [Ddepth-1:0]   rd_addr, nrd_addr;
reg	 [Ddepth  :0]   count, ncount;
reg	 [Dwidth-1:0]	fiforeg [0:2^Ddepth-1];
//===========================================================================
//===========================================================================
always @(WRITE or READ or count) begin
	if (WRITE && ~READ) ncount = count + 1;
	else if (~WRITE & READ) ncount = count - 1;
	else ncount = count;
end
//===========================================================================
//===========================================================================
always @( WRITE or wr_addr or READ or rd_addr ) begin
	nwr_addr = wr_addr;
	if (WRITE) begin
		nwr_addr = wr_addr + 1;
	end 
end
//===========================================================================
always @( WRITE or wr_addr or READ or rd_addr ) begin
	nrd_addr = rd_addr;
	if (READ) begin
		nrd_addr = rd_addr + 1;
	end 
end
//===========================================================================
//===========================================================================
always @(posedge CLK or negedge RSTB) begin
    if (~RSTB) begin
		wr_addr			<= 0;
		rd_addr			<= 0;
		count			<= 0;
    end
    else begin
		wr_addr			<= nwr_addr;
		rd_addr			<= nrd_addr;
		count			<= ncount;
    end
end
//===========================================================================
always @(posedge CLK) begin
	if (WRITE) begin
    	fiforeg[wr_addr]	<= WR_DATA;
	end
end
//===========================================================================
//===========================================================================
assign	FULL		= count[Ddepth] ? 1'b1 : 1'b0;
assign	EMPTY		= (count == 0)  ? 1'b1 : 1'b0;
assign  RD_DATA     = fiforeg[rd_addr];
//===========================================================================
//===========================================================================
endmodule
//===========================================================================
