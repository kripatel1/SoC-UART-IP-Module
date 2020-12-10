module reciever (
	input 		clk, 
	input 		reset,
	input 		rx_clk_enable,    // Baud rate enable multiple clocks long
	input [1:0] parityMode, 		// reads control reg
	input 		wordSize,	      // reads control reg
	
	
	output reg	PE,					// sends invalid parity error
	output reg	FE,					//	sends if not valid Stop bit
	input			clearPE,
	input			clearFE,

	input 		rxIn_pin,			// input data bits
	output reg	rxwr_request,	   // sends write signal to RXFifo
	output reg [8:0] rx_data,		// SEND data to rxFifo
	output reg [3:0] state
	
	//output			// testing signal-Can be removed
//	output reg [3:0 ]phase,
//	output reg bit7,
//	output reg bit8,
//	output reg bit9
	);
	
	
	
	parameter FINDFALLINGEDGE  = 4'd0, 		// runs of 1's FOUND-> find falling edge
				 VERIFYSTART	 	= 4'd1, 		// valid start
				 B0				   = 4'd2, 		// bit 0
				 B1					= 4'd3, 		// bit 1
				 B2					= 4'd4,		// bit 2
				 B3					= 4'd5, 		// bit 3
				 B4					= 4'd6, 		// bit 4
				 B5					= 4'd7, 		// bit 5 
				 B6					= 4'd8, 		// bit 6 
				 B7					= 4'd9, 		// bit 7 - Conditional 8 bit
				 BP					= 4'd10, 	// - Conditional parity
				 STOP 				= 4'd11, 	// stop bit when write to RXFIFO
				 IDLE					= 4'd12;		// IDLE-LOOKING FOR 1'S		 
	
	reg [3:0] nextstate;	
	// store read rxfifo data
	reg [8:0] latch_data;

	// edge detect 1 per Baud rate
	reg rx_enable_perBRD;	
	wire clk_enable;	
	always @ (posedge clk)
	begin 
		rx_enable_perBRD <= rx_clk_enable;		
	end
	assign clk_enable= rx_clk_enable & !rx_enable_perBRD;
	
	
	
	
	
	// phase counter
	reg [3:0] phase;
	// maority wins data
	reg bit7;
	reg bit8;
	reg bit9;
	always @ (posedge clk_enable or posedge reset)
	begin
		if(reset)
		begin
			state <= IDLE;
			nextstate = IDLE;
			phase <= 1'b0;
			rx_data <= 9'b0;
//			latch_data<= 9'b0;
//			rxwr_request <= 1'b0;
		end
		else
		begin
			state <= nextstate;
			case(state)
				IDLE:
				begin
					if(rxIn_pin)
						phase <= phase + 1'b1;
					else
						phase <= 1'b0;
					if(phase >= 4'd8)
						nextstate = FINDFALLINGEDGE;
				end
				FINDFALLINGEDGE:
				begin
					rxwr_request <= 1'b0;
					if(rxIn_pin == 0)
					begin
						nextstate = VERIFYSTART;
						phase <= 1'b0;
					end
				end
				VERIFYSTART: 
				begin 
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;
					if(phase == 4'd15)
					begin
						if( !((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
						begin
							nextstate = B0;									  // VALID START BIT ==0
							phase <= 4'd0;
						end
						else
							nextstate = IDLE;								    // not valid
					end
				end 
				B0:	
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[0] <= 1'b1;						  // bit0 = 1
						else
							rx_data[0] <= 1'b0;						  // bit0 = 0								  
						nextstate = B1;	
						phase <= 4'd0;
					end
				end
				B1: 
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[1] <= 1'b1;						  // bit1 = 1
						else
							rx_data[1] <= 1'b0;						  // bit1 = 0								  
						nextstate = B2;	
						phase <= 4'd0;
					end
				end
				B2: 
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[2] <= 1'b1;						  // bit2 = 1
						else
							rx_data[2] <= 1'b0;						  // bit2 = 0								  
						nextstate = B3;	
						phase <= 4'd0;
					end
				end
				B3:  
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[3] <= 1'b1;						  // bit3 = 1
						else
							rx_data[3] <= 1'b0;						  // bit3 = 0								  
						nextstate = B4;	
						phase <= 4'd0;
					end
				end
				B4:  
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[4] <= 1'b1;						  // bit4 = 1
						else
							rx_data[4] <= 1'b0;						  // bit4 = 0								  
						nextstate = B5;	
						phase <= 4'd0;
					end
				end
				B5: 
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[5] <= 1'b1;						  // bit5 = 1
						else
							rx_data[5] <= 1'b0;						  // bit5 = 0								  
						nextstate = B6;	
						phase <= 4'd0;
					end
				end
				B6: //state 8
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;	
						
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
						begin
							rx_data[6] <= 1'b1;						  // bit6= 1
						end
						else
						begin
							rx_data[6] <= 1'b0;						  // bit6 = 0	
						end
						phase <= 4'd0;
						//CONDITIONALS
						if((wordSize  == 0) && (parityMode == 0))  // 7 bit?
						begin 
							rx_data[7] <= 1'b0;							// no bit 7
							rx_data[8] <= 1'b0;							// no parity
							nextstate = STOP;								// TX Stop	
						end
						else if(wordSize)
						begin
							nextstate = B7; 
						end
						else if(parityMode)
						begin
							nextstate = BP; 
						end
						
					end
				end
				B7: // state 9
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
						begin
							rx_data[7] <= 1'b1;						     // bit7 = 1
							phase <= 4'd0;
							//CONDITIONALS
							if(parityMode) 
							begin
								nextstate = BP;							  // parity?
							end
							else
							begin
								rx_data[8] <= 1'b0;						  // no parity
								nextstate = STOP;			 				  // TX Stop
							end	
						end
						else
						begin
							rx_data[7] <= 1'b0;						     // bit7 = 0
							phase <= 4'd0;	
							if(parityMode) 
							begin
								nextstate = BP;							  // parity?
							end
							else
							begin
								rx_data[8] <= 1'b0;						  // no parity
								nextstate = STOP;			 				  // TX Stop
							end
						end					
					end
				end			 
				BP: // parity bit	state 10	
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							rx_data[8] <= 1'b1;						  // bit8 = 1
						else
							rx_data[8] <= 1'b0;						  // bit8 = 0								  
						nextstate = STOP;	
						phase <= 4'd0;
					end
				end				
				STOP:  // RX stop
				begin	
					phase <= phase + 1'b1;
					if(phase == 4'd7)
						bit7 <= rxIn_pin;
					if(phase == 4'd8)
						bit8 <= rxIn_pin;
					if(phase == 4'd9)
						bit9 <= rxIn_pin;					
					if(phase == 4'd15)
					begin
						if( ((bit7 & bit8) | (bit8 & bit9) | (bit9 & bit7)))
							nextstate = IDLE;
						else
							FE<= 1'b1;						  		// invalid stop bit								  
						nextstate = IDLE;	
						phase <= 4'd0;
						rxwr_request <= 1'b1;					// send data to rxfifo
					end
				end		
				default: nextstate = IDLE;
			endcase
		end
	end
endmodule


	
	