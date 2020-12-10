module BAUD_GEN(clk,enable, BRD, reset, Nout, count,target );
	input clk, reset,enable;
	input [31:0] BRD;
	output Nout;	
	
	output [31:0] count;
	output [31:0] target;

	wire clk_enable;
	assign clk_enable = clk & enable;
	ClockGenNM baudGen
	(
		.clock(clk_enable),
		.reset(reset),
		.N(BRD),
		.Nout(Nout),
		.count(count),
		.target(target)
	);
endmodule

	
	
