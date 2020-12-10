module Two2FourActiveHighDecoder #(parameter N=4)
		(
		input A,B,E,
		output reg[3:0] y);
		always @ (A,B,E)
			if (~E) y = 4'b0;
			else
			case({B,A})
				2'b00: y = 4'b0001;
				2'b01: y = 4'b0010;
				2'b10: y = 4'b0100;
				2'b11: y = 4'b1000;
			endcase
endmodule
