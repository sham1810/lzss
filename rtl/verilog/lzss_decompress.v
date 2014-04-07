//---------------------------------------------------
//
//	Module: Lzss Compression 
//	Created by: Shreyank Amartya and Rohit Ranjan
//
//---------------------------------------------------


module lzss_decompress(

	input clk, 
	input rstn,
	input [8*4-1:0] input_data 

);


wire [7:0] incoming_data[0:3];
reg [7:0] buff[0:4096];


reg length_flag,offset_flag,literal_flag;
reg [0:7] marker;
reg [0:7]register[0:3];
reg stall;


integer k;
integer l;
reg found_marker;

// Fifo Interface registers
reg Write,Read;
reg [0:7]Wr_Data;

wire Full,Empty;
wire [0:7] Rd_Data;

// Output Buffer 
reg [0:7] get_offset,get_length;
reg [0:15]  curr,start_index;

// Stage 3/4 parameters
reg len_off;



assign	incoming_data[0][7:0] = input_data[7:0];	
assign	incoming_data[1][7:0] = input_data[15:8];	
assign	incoming_data[2][7:0] = input_data[23:16];
assign	incoming_data[3][7:0] = input_data[31:24];




//
//	Always block for Stage 1 of pipeline
//
always @(posedge clk)
begin
	if(~rstn)
	begin
		found_marker <= 0;
		stall <= 1'b1;
	end
	else
	begin 	
		if(~found_marker)
		begin
			marker <= incoming_data[0];
			found_marker <= 1;
			$display("Marker: 0x%x",incoming_data[j]);
		end
		else
		begin
    		register[0] <= incoming_data[0];
			register[1] <= incoming_data[1];
			register[2] <= incoming_data[2];
			register[3] <= incoming_data[3];
			
			

	 	end
    end
end


//
//	Always block for Stage 2 of pipeline
//
//
always @ (posedge clk)
begin
    
    if(~rstn)
	begin
		Write <= 1'b0;
		offset_flag <= 0;
		length_flag <= 0;
		curr <= 0;
		l <= 0;
	end
	else if(~stall)
    begin
        if(offset_flag)
            begin           
                // Push offset into queue
                Write <= 1'b1;
                Wr_Data <= register[l];
                $display("Push offset: 0x%x in FIFO",register[l]);
				offset_flag <= 1'b0;
        
            end
        else if(length_flag)
            begin
                offset_flag <= 1'b1;
                $display("Offset Flag set");
                // Push length into queue
                Write <= 1'b1;
                Wr_Data <= register[l];
				$display("Push length: 0x%x in FIFO ",register[l]);
                length_flag <= 1'b0;
				curr <= curr + register[l];
        
            end
        else if(register[l] == marker)
            begin
                
                length_flag <= 1'b1;
                $display("Found Marker, Length Flag set");
        
            end
        else
            begin
                buff[curr]<=register[l];
                curr<=curr+1;
                $display(" A literal: 0x%x in register %d memory location %d",register[l],l,curr);
        
            end
	
		l <= l + 1;
		
		if(l == 3)
			l <= 0;
    end
    
end

//
//	Always Block for Stage 3 of pipeline
//
//
always @(posedge clk)
begin
	if(~rstn)
	begin
		len_off <= 1'b0;
	end		

		if(Full or ~length_flag or ~offset_flag)
			Write <= 1'b0;

		if(!Empty)
    	begin
			Read <= 1'b1;
	
        	if(~len_off)
				len_off <= 1'b1;
			else
				len_off <= 1'b0;
		
    	end
		else
			Read <= 1'b0;
end



//
// Always Block for Stage 4 of pipeline
//

always @(posedge clk)
begin
	if(Read)
	begin	
		if(~len_off)
			get_length <= Rd_Data;
		else
		begin
			get_offset <= Rd_Data;
			start_index <= curr - Rd_Data;
		end
	end
end

// 
// 	Always Block for Stage 5 pipeline
//

always @(posedge clk)
begin

		for(k=0; k<get_length; k=k+1)
		begin
			buff[curr+k] <= buff[start_index+k];
		end
end




//always @(get_offset) // Cases not covered are 
//begin
//  if(get_length>=get_offset)
//  begin
 //      start_index<=curr-get_offset;
//      start_tracker<=curr-get_offset;
//      modulo <= get_length % get_offset;
//      
//      do  
//      begin
//          for(m=0;m<get_offset;m=m+1)
//          begin
//              buff[curr+m]<=buff[start_index+m];
//          end
//          n=n+get_offset;
//      end while   (get_length<n);
//      
//      curr<= curr+1;
//      modulo_gap<= curr-modulo;
//                for(d=0;d<modulo_gap;d=d+1)
//      buff[curr+d]<=buff[modulo_gap+d];
//          curr<= curr+1;
//
//  end
//  else
//  begin
//      start_index <= curr-get_offset;
//          for(k=0;k<get_lenght;k=k+1)
//                buff[curr+k]<=buff[start_index+k];
//                curr<=curr+1;
//        end
//end
         
     


//Instantiation of syn_fifo

sync_fifo #( .Dwidth(8), .Ddepth(4)) 
fifo( .WRITE(Write), .WR_DATA(Wr_Data), .READ(Read), .RD_DATA(Rd_Data), .FULL(Full) , .EMPTY(Empty) , .CLK(clk) , .RSTB(rstn));



endmodule
