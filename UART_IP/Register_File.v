module Register_File (writeData, readData,CLK, RST, RWA0, RWA1, WrEn);
		parameter N = 4;
		input [N-1:0] writeData;
		input CLK, RST, RWA0, RWA1, WrEn;
		
		output [N-1: 0] readData;
		
		wire [N-1:0] register_number;
		wire [N-1:0] Y [3:0]; // 4 buses, 4 bits wide
		

		Two2FourActiveHighDecoder #(.N(N)) decoder_inst
		(
			.A(RWA0),
			.B(RWA1),
			.E(WrEn),
			.y(register_number) // outputs 2 bit value corresponds to Reg number
		);
		// reg0
		NbitRegister_CE # (.N(N)) TXFIFO
		(
			.D(writeData),
			.CLK(CLK),
			.CLR(RST),
			.CE(register_number[0]),
			.Q(Y[0])
		);
		// reg1
		NbitRegister_CE # (.N(N)) W1CSTATUS
		(
			.D(writeData),
			.CLK(CLK),
			.CLR(RST),
			.CE(register_number[1]),
			.Q(Y[1])
		);
		// reg2
		NbitRegister_CE # (.N(N)) CONTROL
		(
			.D(writeData),
			.CLK(CLK),
			.CLR(RST),
			.CE(register_number[2]),
			.Q(Y[2])
		);
		// reg3
		NbitRegister_CE # (.N(N)) BRD
		(
			.D(writeData),
			.CLK(CLK),
			.CLR(RST),
			.CE(register_number[3]),
			.Q(Y[3])
		);
		four2oneMux # (.N(N)) four2oneMux_inst
		(
			.A(RWA0),
			.B(RWA1),
			.D0(Y[0]), 
			.D1(Y[1]), 
			.D2(Y[2]), 
			.D3(Y[3]),
			.Y(readData)
		);
	

endmodule 