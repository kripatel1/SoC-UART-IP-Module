module ClockGenNM(clock, reset, N, Nout, count, target);
	input clock, reset;
	input [31:0] N;

	output reg Nout;
	output reg [31:0] count;
	output reg [31:0] target;
		always @ (posedge clock, posedge reset )
			begin
				if (reset)
					begin
						Nout <= 1'b0;
						count <= 32'b0;
						target <= N;
					end
				else
				begin
					count <= count + 8'b10000000;
						if (count[31:7] == target[31:7])
						begin
							target <= target + N;
							Nout <= ~Nout;
						end
						else
						Nout<= Nout;
				end
			end
endmodule
