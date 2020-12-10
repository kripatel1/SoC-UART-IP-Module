module Eight2OneGatedMUX_Rates (divSelector,Y);
input [2:0] divSelector;
output reg [31:0] Y;
always begin
	case (divSelector)
		3'b000: Y = 32'b0000_0000_0000_0000_0000_0011_0110_0100;
		3'b001: Y = 32'b0000_0000_0000_0000_0000_0110_1100_1000;
		3'b010: Y = 32'b0000_0000_0000_0000_0000_1101_1001_0000;
		3'b011: Y = 32'b0000_0000_0000_0000_0001_1011_0010_0000;
		3'b100: Y = 32'b0000_0000_0000_0001_1011_0010_0000_0111;
		3'b101: Y = 32'b0000_0000_0000_0010_1000_1011_0000_1010;
		3'b110: Y = 32'b0000_0000_0001_0100_0101_1000_0101_0101;
		3'b111: Y = 32'b0000_0000_0010_1000_1011_0000_1010_1010;
	endcase
end
endmodule 
