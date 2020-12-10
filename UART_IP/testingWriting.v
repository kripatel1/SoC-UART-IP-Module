module testingWriting( clk, write,last_write, receivedSignal,short_write);

input clk, write;
output short_write;

output reg last_write;
output receivedSignal;

always @ (posedge clk)
	begin
		last_write <= write;
	end

	assign short_write = write && ! last_write;
	
	 
	 testingClk testingClk1
	 (
		.clk(clk),
		.write_signal(short_write),
		.writeOut(receivedSignal),
	);

endmodule


