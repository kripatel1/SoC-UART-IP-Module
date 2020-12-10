module FIFO(
		output reg [8:0] DataOut,
		output Full, Empty, OV,
		input [8:0] DataIn,
		input read, write, clk, reset, ClearOV,
		
		output [2:0] states,
		output reg turnOff = 4'b0000,
		output reg [3:0] ReadPtr, WritePtr
	
		);
		
		reg [4:0] PtrDiff;			 //Pointer difference
		reg [8:0] Stack [15:0];		 //Storage array
		
		assign Empty = (PtrDiff == 1'b0) ? 1'b1: 1'b0;  //Empty?
		assign Full = (PtrDiff >= 5'd16) ? 1'b1: 1'b0;	//Full?
		assign OV = (PtrDiff >= 5'd17) ? 1'b1 : 1'b0;	//Overflow?
		assign states = {Empty,Full,OV};
		assign  LEDR = ClearOV;
		
		always @ (posedge clk, posedge reset) 
				begin	//Data transfers
				if(reset) begin		//Test for Reset
						DataOut  <= 1'b0;		//Reset data out buffer
						ReadPtr  <= 1'b0;		//Reset read pointer
						WritePtr <= 1'b0;		//Reset write pointer
						PtrDiff 	<= 1'b0;		//Reset pointer difference
						
				end

				else begin
					if(read && write && !OV) begin//-------simultaneous READ WRITE IMPLEMENTATION---------
						if(!Empty) begin									// Not Empty
							DataOut = Stack[ReadPtr];	 				// read 1st	
							ReadPtr <= ReadPtr + 1'b1;			
							PtrDiff <= PtrDiff - 1'b1;
							
							Stack[WritePtr] = DataIn; 					// write	
							WritePtr <= WritePtr + 1'b1;
							PtrDiff <= PtrDiff + 1'b1;
							end
						else begin
							if (OV) begin								// Overflown
								DataOut = Stack[ReadPtr]; 			// read1st  
								ReadPtr <= ReadPtr + 1'b1; 		 
								PtrDiff <= PtrDiff - 2'b10; 	
						
								Stack[WritePtr] = DataIn; 			// write 1st	
								WritePtr <= WritePtr + 1'b1;
								PtrDiff <= PtrDiff + 1'b1;		
							end
							else begin										// Regular
								Stack[WritePtr] = DataIn; 				// write 1st
								WritePtr <= WritePtr + 1'b1;
								PtrDiff <= PtrDiff + 1'b1;
								
								DataOut = Stack[ReadPtr];	 			// read	
								ReadPtr <= ReadPtr + 1'b1;			
								PtrDiff <= PtrDiff - 1'b1;
								end
						end
						
						
					end					//Begin read or write operations
					if(read && !Empty)							//Check for read
						if(!OV) begin
							DataOut <= Stack[ReadPtr];	 		//Transfer data to output
							ReadPtr <= ReadPtr + 1'b1;			//Update read pointer
							PtrDiff <= PtrDiff - 1'b1;			//update pointer difference
						end
						else begin
							DataOut <= Stack[ReadPtr]; 		//Transfer data to output
							ReadPtr <= ReadPtr + 1'b1; 		//Update read pointer
							PtrDiff <= PtrDiff - 2'b10; 		//update pointer difference
						end
					else if (write)//Check for write
							if (!Full) begin 					//Check for Full
									Stack[WritePtr] <= DataIn; //If not full store data in stack
									WritePtr <= WritePtr + 1'b1; //Update write pointer
									PtrDiff <= PtrDiff + 1'b1; //Update pointer difference
							end
							else begin
									PtrDiff <= 5'd17; //Update pointer difference
							end
					else if (ClearOV && OV) begin
							DataOut <= Stack[ReadPtr]; 		//Transfer data to output
							ReadPtr <= ReadPtr + 1'b1; 		//Update read pointer
							PtrDiff <= PtrDiff - 2'b10; 		//update pointer difference
						end
					end
					
						
			end
			
endmodule
							