module uart (
clk, 
reset, 
address, 
chipselect, 
writedata, 
readdata, 
write, 
read, 
uart_clk_out, 
uart_rx, uart_tx,


ReadPtr_rxfifo, 
WritePtr_rxfifo,
states_rxfifo,
EMPTY_rxfifo,
OVERFULL_rxfifo,
FULL_rxfifo,
rx_states,
rx_write_Ack,		// sent by RECEIVER
rd_rx_fifo,			// sent TO rxFIFO
rx_states,
rx_data_toFifo,

ReadPtr_txfifo,
WritePtr_txfifo,
states_txfifo,
EMPTY_txfifo,
OVERFULL_txfifo,
FULL_txfifo,
tx_read_Ack,
rd_tx_fifo,
tx_states
 
);

    // Clock, reset, and interrupt
    input   clk, reset;

    // Avalon MM interface (8 word aperature)
    input            read, write, chipselect;
    input [2:0]      address;
    input [31:0]      writedata;
    output reg [31:0] readdata;

	
	 // uart interface
    // Conduit Signals
	 input        uart_rx;
	 output       uart_clk_out; 
	 output		  uart_tx;

    // internal    
    reg [31:0] latch_data;
	 reg [31:0]	STATUS;
	 reg [31:0] RXFO_TXFO_FE_PE_clear_request;	
	 reg [31:0] CONTROL;
	 reg [31:0] BRD;	
	 
	 // other
	 wire [8:0] transmitter_data;
	 wire	clk_enable;
	 

	 reg last_write;
	 reg last_read;
	 reg wrFIFO;
	 reg rdFIFO;
    wire	[8:0] read_latch_data;
	 
	 // TXFIFO
	 output [2:0] states_txfifo;
	 output [3:0] ReadPtr_txfifo; 
	 output [3:0] WritePtr_txfifo;
	 output 		  EMPTY_txfifo;
	 output 		  OVERFULL_txfifo;
	 output 		  FULL_txfifo;
	 //transmitter
	 output [3:0] tx_states;
	 
	 //RXFIFO
	 output [2:0] states_rxfifo;
	 output [3:0] ReadPtr_rxfifo; 
	 output [3:0] WritePtr_rxfifo;
	 output 		  EMPTY_rxfifo;
	 output		  OVERFULL_rxfifo;
	 output 		  FULL_rxfifo;
	 output [3:0] rx_states;
	 output reg [8:0] rx_data_toFifo;
	
// STATUS REGISTER	 
//	 reg			RXF0; // BIT 0
//	 reg			RXFF; // BIT 1
//	 reg			RXFE; // BIT 2
//	 reg			TXF0; // BIT 3
//	 reg			TXFF; // BIT 4
//	 reg			TXFE; // BIT 5
//	 reg			FE;	// BIT 6
//	 reg			PE;   // BIT 7
//	 reg			reserved // 15:8 --> Interrupts
//	 reg			DEBUG_IN // 31:16 --> DEBUG


    // register numbers
    parameter DATA_REG             = 3'b000;
    parameter STATUS_REG        	  = 3'b001;
    parameter CONTROL_REG          = 3'b010;
    parameter BRD_REG		        = 3'b011;
	
	always @ (posedge clk)
	begin 
		last_write <= write;		
	end
	
	always @ (posedge clk)
	begin 
		last_read  <= read;
	end
	 
	  // read register
   always @ (posedge clk)
   begin
      if(read && chipselect && (address == DATA_REG) && (!last_read))
		begin
			rdFIFO <= 1;
		end
		else if (rdFIFO ==1)
		begin
			readdata <= read_latch_data;
			rdFIFO 	<=0;
		end
		if(read && chipselect && (address == STATUS_REG) )	
		begin
			readdata <= STATUS;
		end
		if(read && chipselect && (address == CONTROL_REG) )	
		begin
			readdata <= CONTROL;
		end
		if(read && chipselect && (address == BRD_REG) )	
		begin
			readdata <= BRD;
		end		
   end        

	wire PE;
	wire FE;

	// status register	
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
			STATUS <= 32'b0;
		else if(RXFO_TXFO_FE_PE_clear_request != 32'b0)
		begin
			STATUS <= STATUS & ~RXFO_TXFO_FE_PE_clear_request;			
		end
		else
		begin
			STATUS[5:0] <= {states_txfifo,states_rxfifo};
			STATUS[6] <= FE;
			STATUS[7] <= PE;
		end
	
   end 


	// write register
	reg W1C_STROBE;
   always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			latch_data[31:0] <= 32'b0;
			CONTROL	 [31:0] <= 32'd0;
			BRD 	 	 [31:0] <= 32'b0;
			
			RXFO_TXFO_FE_PE_clear_request <= 32'b0;
			W1C_STROBE <= 1'b0;
		end
		else
		begin
			if (write && chipselect && (address == DATA_REG) && (!last_write))	// DATA REG
			begin
				latch_data <= writedata;	
				wrFIFO <= 1;
			end
			else
				wrFIFO <= 0;
			if (write && chipselect && (address == STATUS_REG) && (!W1C_STROBE)) // STATUS REG
			begin
				if(writedata[0] || writedata[3] || writedata[6] || writedata[7])
				begin
					RXFO_TXFO_FE_PE_clear_request <= writedata;
					W1C_STROBE	<= 1'b1;
				end
			end
			else
			begin
				RXFO_TXFO_FE_PE_clear_request  <= 32'b0; 
				W1C_STROBE <=1'B0;
			end
			if (write && chipselect && (address == CONTROL_REG))						// CONTROL REG
				CONTROL <= writedata;
			else
				CONTROL[4] <= uart_clk_out;
			if (write && chipselect && (address == BRD_REG))							// BRD REG
				BRD <= writedata;
		end
	end
	
	 
	BAUD_GEN baudGen
	(
		.clk			(clk),
		.enable		(CONTROL[3]),
		.reset		(reset),
		.BRD			(BRD),
		.Nout			(clk_enable)
	);
	assign uart_clk_out = clk_enable;

	
	// edge detect read_tx
	output tx_read_Ack;	// sent by Transmitter
	output reg rd_tx_fifo;	// sent to TXFIFO
	reg last_tx_read_Ack;// Edge detect
	always @ (posedge clk)
	begin 
		last_tx_read_Ack <= tx_read_Ack;		
	end
	
	always @ (posedge clk)	
	begin
		if (tx_read_Ack & !last_tx_read_Ack)
		begin
			rd_tx_fifo <= 1;
		end
		else
			rd_tx_fifo <= 0;
	end
	// edge detect write_rx
	output rx_write_Ack;		// sent by RECEIVER
	output reg rd_rx_fifo;	// sent to RXFIFO
	reg last_rx_write_Ack;	// Edge detect
	always @ (posedge clk)
	begin 
		last_rx_write_Ack <= rx_write_Ack;		
	end
	
	always @ (posedge clk)	
	begin
		if (rx_write_Ack & !last_rx_write_Ack)
		begin
			rd_rx_fifo <= 1;
		end
		else
			rd_rx_fifo <= 0;
	end

	
	transmitter tx
	(
		.clk					(clk),
		.reset				(reset),
		.tx_clk_enable		(clk_enable),
		.tx_request			(STATUS[5]),
		.tx_data				(transmitter_data),
		.parityMode			(CONTROL[2:1]),
		.wordSize			(CONTROL[0]),
		.tx_Ack				(tx_read_Ack),
		.tx_out				(uart_tx),
		.state				(tx_states),
		.txCLK				(tx_clk_test)
	);

	 FIFO txfifo
	 (
		.DataIn  (latch_data),
		.DataOut (transmitter_data),
		.write	(wrFIFO),
		.read		(rd_tx_fifo),
		.clk   	(clk),
		.reset   (reset),
		.states	(states_txfifo),
		.ReadPtr (ReadPtr_txfifo),
		.WritePtr(WritePtr_txfifo),
		.ClearOV	(RXFO_TXFO_FE_PE_clear_request[3])
	 );
	

	wire received;
	reciever rx
	(
		.clk					(clk),
		.reset				(reset),
		.rx_clk_enable		(clk_enable),
		.parityMode			(CONTROL[2:1]),
		.wordSize			(CONTROL[0]),
		.PE					(PE),
		.FE					(FE),
		.clearFE				(RXFO_TXFO_FE_PE_clear_request[6]),
		.clearPE				(RXFO_TXFO_FE_PE_clear_request[7]),
		.rxIn_pin			(uart_rx),
		.rxwr_request		(rx_write_Ack),
		.rx_data				(received),
		.state				(rx_states),

	);

	 FIFO rxfifo
	 (
		.DataIn  (received),						// sent by reciever
		.DataOut (read_latch_data),			// read data by avalon
		.write	(rd_rx_fifo),					// sent HIGH SIGNAL BY RECIEVER
		.read		(rdFIFO),						// sent by avalon
		.clk   	(clk),
		.reset   (reset),
		.states	(states_rxfifo),
		.ReadPtr (ReadPtr_rxfifo),
		.WritePtr(WritePtr_rxfifo),
		.ClearOV	(RXFO_TXFO_FE_PE_clear_request[0])
	 
	 );
	 

	 endmodule
	 