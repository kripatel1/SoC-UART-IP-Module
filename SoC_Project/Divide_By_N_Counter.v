module Divide_By_N_Counter (clk, reset,OUT, COUNT);
   parameter N = 4'd16;
	input clk, reset;
	output reg[3:0] COUNT;
	output reg OUT;

	always @ (posedge clk or posedge reset) begin
	   if (reset) COUNT <= 4'b0;
         else
         begin
			   if(COUNT == N-2'd2) begin 
				   OUT <= 1'b1;
				   COUNT <= N-1'd1;
					end
			   else if (COUNT == N-1'd1) begin
				   OUT <= 1'b0;
				   COUNT <= 4'b0;
				   end
				else begin 
				   OUT <= 1'b0;
				   COUNT <= COUNT + 1'b1;
               end
			end
	end
			
endmodule
