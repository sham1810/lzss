//--------------------------------------------------------
//
//	Module: Testbench for lzss decompressor
//	Created by: Shreyank Amartya
//
//--------------------------------------------------------



module tb_lzss_decompress;

parameter CLOCK_PERIOD = 4;

reg [7:0] input_buffer[1024:0];
integer input_fhandle;
reg [8*64:0] input_filename;	

integer i;
integer j;
integer k;

reg CLK;
reg RST;
reg [31:0] input_data;

initial 
begin
	
	k = 0;
	CLK = 1'b0;

	input_filename = "output.bin";	
	input_fhandle = $fopen(input_filename,"r");
	
	i = $fread(input_buffer,input_fhandle);	
	$display("Read %d characters from output.bin",i);
	
	reset;

	load_data;	

	#250 $finish;
	 
end

initial
begin
	clk_gen;
end

task clk_gen;
begin

CLK = 1'b0;	
forever	#(CLOCK_PERIOD/2) CLK = ~CLK;
end

endtask

task load_data;
begin

while(k<i)	
begin
	input_data[7:0] = input_buffer[k];
	$display("Loaded 0x%x into input_buffer",input_buffer[k]);
	@(posedge CLK) input_data[15:8] = input_buffer[k+1];
	$display("Loaded 0x%x into input_buffer",input_buffer[k+1]);
	@(posedge CLK) input_data[23:16] = input_buffer[k+2];
	$display("Loaded 0x%x into input_buffer",input_buffer[k+2]);
	@(posedge CLK) input_data[31:24] = input_buffer[k+3];
	$display("Loaded 0x%x into input_buffer",input_buffer[k+3]);
	@(posedge CLK);	
	
	k = k + 4;
end
	
end
endtask

task reset;
begin

	RST = 1'b1;
	repeat (2) @(posedge CLK);
	RST = 1'b0;
	repeat (2) @(posedge CLK);
	RST = 1'b1;	

end
endtask


// Instantiation of lzss_decompress module
lzss_decompress lzss(

	.clk(CLK),
	.rstn(RST),
	.input_data(input_data)
);


endmodule
