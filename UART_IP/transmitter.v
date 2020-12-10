module transmitter (
	input 		clk, 
	input 		reset,
	
	input 		tx_clk_enable,    // Baud rate enable multiple clocks long
	input 		tx_request,	      // NOT empty flag in txfifo
	input [8:0] tx_data,				// get data from txFifo
	input [1:0] parityMode, 		// reads control reg
	input 		wordSize,	      // reads control reg
	
	output reg 	tx_Ack,		      // Sends READ Signal to txfifo
	output reg	tx_out,				// send them on conduit
	output clk_enable,
	
	output reg [3:0] state,
	
	output	  txCLK
	);
	
	
	
	parameter START=4'd0, 		// start bit
				 A=4'd1, 		// bit 0
				 B=4'd2, 		// bit 1
				 C=4'd3,  		// bit 2
				 D=4'd4,			// bit 3
				 E=4'd5, 		// bit 4
				 F=4'd6, 		// bit 5
				 G=4'd7, 		// bit 6 
				 H=4'd8, 		// bit 7- Conditional 8 bit 
				 I=4'd9, 		// - Conditional parity
				 J=4'd10, 		// stop bit
				 IDLE = 4'd11; // IDLE-when FIFO EMPTY
				 
	
	
	reg [3:0] nextstate;	
	// store read txfifo data
	reg [8:0] latch_data;
	// edge detect 1 per Baud rate
	reg tx_enable_perBRD;
	wire clk_enableDiv16In;
	
	always @ (posedge clk)
	begin 
		tx_enable_perBRD <= tx_clk_enable;		
	end
	assign clk_enableDiv16In= tx_clk_enable & !tx_enable_perBRD;
	
	
		
	Divide_By_N_Counter div16
	(
		.clk			(clk_enableDiv16In),
		.reset		(reset),
		.OUT			(clk_enable),
	);
		assign txCLK = clk_enable;
		
	always @ (posedge clk or posedge reset)
	begin
		if(reset)
		begin
			state <= IDLE;
			nextstate <= IDLE;
			latch_data<= 9'b0;
			tx_Ack <= 1'b0;
		end
		else if(clk_enable)
		begin
			state <= nextstate;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(!tx_request) 
					begin
						nextstate <= START;
						tx_Ack <= 1'b1;
					end
				end
				START: 
				begin 
					tx_out <= 1'B0; 
					latch_data <= tx_data; 									  // start
					nextstate = A;
				end 
				A:	begin	tx_out <= latch_data[0]; nextstate = B; end // b0
				B: begin	tx_out <= latch_data[1]; nextstate = C; end // b1
				C: begin	tx_out <= latch_data[2]; nextstate = D; end // b2
				D: begin	tx_out <= latch_data[3]; nextstate = E; end // b3
				E: begin	tx_out <= latch_data[4]; nextstate = F; end // b4
				F: begin	tx_out <= latch_data[5]; nextstate = G; end // b5
				G: begin	
					tx_out <= latch_data[6]; 						        // b6
						if(wordSize) 										     // 7 bit?
							nextstate = H;  
						else if(parityMode != 2'b0) 
							nextstate = I;									     // parity?
						else
							nextstate = J;									     // TX Stop
					end
				H: 
				begin	
					tx_out <= latch_data[7]; 								  // bit 7
						if(parityMode != 2'b0) 
							nextstate = I;										  // parity?
						else
							nextstate = J;					 					  // TX Stop
				end  		  
				I: begin tx_out <= latch_data[8]; nextstate= J;	end  // parity bit			
				J: begin	tx_out <= 1'b1; nextstate = IDLE; tx_Ack <= 1'b0;end 		  // TX stop
				default: nextstate = IDLE;
			endcase
		end
	end
endmodule


	
	