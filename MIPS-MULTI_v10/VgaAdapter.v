
//--- VGA Adapter Settings
/* The following settings adjust whether the VGA Adapter operates
 * in monochromatic or color mode. If the adapter is to operate in
 * color mode, the developer may specify the range of colors by
 * selecting the width of each color channel (i.e. RED, GREEN, BLUE).
 */

/* Color Modes:
 *	Comment the line below to enable color support 
 */
`define COLOR_MODE 1

module VgaAdapter(
			resetn,
			CLOCK_50,
			color_in,
			color_out,
			x, //0-319
			y, //0-239
			writeEn,
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK);

	// -- Parameters you can modify
//	parameter COLOR_CHANNEL_DEPTH = 2;
	/* Color Depth:
	 *	Specify the number of bits per color channel.
	 *	For example, a selection of 2 results in 2 bits per channel,
	 *	or 6 bits total. This results in 2^6=64 possible colors.
	 *	NOTE: This value changes the size of the color bus that you
	 *  are driving into the following adapter. The size of the bus
	 *	corresponds to the total number of bits for all of the channels.
	 */	
	parameter BACKGROUND_IMAGE = "display.mif";

	//--- Timing information
	/* Do not modify these values unless you know what you are doing.
	 * Incorrect values may cause harm to the monitor.
	 */
	parameter C_VERT_NUM_PIXELS  = 10'd480;
	parameter C_VERT_SYNC_START  = 10'd493;
	parameter C_VERT_SYNC_END    = 10'd494; //(C_VERT_SYNC_START + 2 - 1); 
	parameter C_VERT_TOTAL_COUNT = 10'd525;

	parameter C_HORZ_NUM_PIXELS  = 10'd640;
	parameter C_HORZ_SYNC_START  = 10'd659;
	parameter C_HORZ_SYNC_END    = 10'd754; //(C_HORZ_SYNC_START + 96 - 1); 
	parameter C_HORZ_TOTAL_COUNT = 10'd800;

	// Declare inputs and outputs.
	input resetn;
	input CLOCK_50;

/*
`ifdef COLOR_MODE // color
	input [(COLOR_CHANNEL_DEPTH*3-1):0] color_in;
	output [(COLOR_CHANNEL_DEPTH*3-1):0] color_out;
`else // black and white
	input [0:0] color;
`endif
*/

	input [7:0] color_in;
	output [7:0] color_out;

	input [8:0] x; //[7:0] x; //0-159  max 512
	input [7:0] y; //[6:0] y; //0-119  max 256
	input writeEn;
	
	output reg [9:0] VGA_R;
	output reg [9:0] VGA_G;
	output reg [9:0] VGA_B;
	output reg VGA_HS;
	output reg VGA_VS;
	output reg VGA_BLANK;
	output VGA_SYNC;
	output wire VGA_CLK;
	
	//--- Clock Generator
	/* The following module, provided by Quartus, declares a derived clock
	 * inside the FPGA. The following derived clock, operates at 25MHz, which is
	 * the frequency required for 640x480@60Hz.
	 */
	VgaPll xx (CLOCK_50, VGA_CLK);
	
	//--- CRT Controller (25 mhz)
	/* These counters are responsible for traversing the onscreen pixels and
	 * generating the approperiate sync and enable signals for the monitor.
	 */
	reg [9:0] xCounter, yCounter;
	
	//- Horizontal Counter
	wire xCounter_clear;
	assign xCounter_clear = (xCounter == (C_HORZ_TOTAL_COUNT-1));

	always @(posedge VGA_CLK or negedge resetn)
	begin
		if (!resetn)
			xCounter <= 10'd0;
		else if (xCounter_clear)
			xCounter <= 10'd0;
		else
		begin
			xCounter <= xCounter + 1'b1;
		end
	end
	
	//- Vertical Counter
	wire yCounter_clear;
	assign yCounter_clear = (yCounter == (C_VERT_TOTAL_COUNT-1)); 

	always @(posedge VGA_CLK or negedge resetn)
	begin
		if (!resetn)
			yCounter <= 10'd0;
		else if (xCounter_clear && yCounter_clear)
			yCounter <= 10'd0;
		else if (xCounter_clear)		//Increment when x counter resets
			yCounter <= yCounter + 1'b1;
	end
	
	//--- Frame buffer
	//Dual port RAM read at 25 MHz, written at 50 MHZ (synchronous with rest of circuit)
	wire [16:0] writeAddr; //19 -> 640
	wire [16:0] readAddr;// 19-> 640

/*	
`ifdef COLOR_MODE // color
	wire [(COLOR_CHANNEL_DEPTH*3)-1:0] readData;
`else // black and white
	wire [0:0] readData;
`endif
*/
	wire [7:0] readData;

	assign writeAddr = 12'd320*y+x;  // 640
	assign readAddr = 12'd320*yCounter[9:1]+xCounter[9:1];   // projetado para 640, logo decima por 2 para 320
//	assign writeAddr = {y[6:0], x[7:0]};
//	assign readAddr = {yCounter[8:2], xCounter[9:2]};
MemoryVGA memVGA (
	.address_a(readAddr),
	.address_b(writeAddr),
	.clock_a(VGA_CLK),
	.clock_b(CLOCK_50),
	.data_a(8'b0),
	.data_b(color_in),
	.wren_a(1'b0),
	.wren_b(writeEn),
	.q_a(readData),
	.q_b(color_out));

/*	
	altsyncram	frameBufferRam (
				.wren_a (writeEn),
				.clock0 (CLOCK_50), // write clock
				.clock1 (VGA_CLK), // read clock
				.address_a (writeAddr),
				.address_b (readAddr),
				.data_a (color), // data in
				.q_b (readData)	// data out
				);
	defparam
`ifdef COLOR_MODE // color
		frameBufferRam.width_a = COLOR_CHANNEL_DEPTH*3,
		frameBufferRam.width_b = COLOR_CHANNEL_DEPTH*3,
`else // black and white
		frameBufferRam.width_a = 1,
		frameBufferRam.width_b = 1,
`endif
		frameBufferRam.intended_device_family = "Cyclone II",
		frameBufferRam.operation_mode = "DUAL_PORT",
		frameBufferRam.widthad_a = 17,
		frameBufferRam.widthad_b = 17,
		frameBufferRam.outdata_reg_b = "CLOCK1",
		frameBufferRam.address_reg_b = "CLOCK1",
		frameBufferRam.clock_enable_input_a = "BYPASS",
		frameBufferRam.clock_enable_input_b = "BYPASS",
		frameBufferRam.clock_enable_output_b = "BYPASS",
		frameBufferRam.power_up_uninitialized = "FALSE",
		frameBufferRam.init_file = BACKGROUND_IMAGE;
*/
/*	//--- Output Color
`ifdef COLOR_MODE // color mode
	integer index;
	integer sub_index;
*/	
	always @(readData)
	begin		

/*		VGA_R <= 'b0;
		VGA_G <= 'b0;
		VGA_B <= 'b0;
		for (index = 10-COLOR_CHANNEL_DEPTH; index >= 0; index = index - COLOR_CHANNEL_DEPTH)
		begin
			for (sub_index = COLOR_CHANNEL_DEPTH - 1; sub_index >= 0; sub_index = sub_index - 1)
			begin
				VGA_R[sub_index+index] <= readData[sub_index + COLOR_CHANNEL_DEPTH*2];
				VGA_G[sub_index+index] <= readData[sub_index + COLOR_CHANNEL_DEPTH];
				VGA_B[sub_index+index] <= readData[sub_index];
			end
		end
*/	
		VGA_R <= {readData[2:0],7'b0}; // 3 bits R
		VGA_G <= {readData[5:3],7'b0}; // 3 bits G
		VGA_B <= {readData[7:6],8'b0}; // 2 bits B

	end

/*
`else // black and white mode
	integer index;
	
	always @(readData)
	begin
		integer index;
		for (index = 0; index < 10; index = index + 1)
		begin
			VGA_R[index] <= readData[0:0];
			VGA_G[index] <= readData[0:0];
			VGA_B[index] <= readData[0:0];
		end	
	end
`endif
*/
	//--- Output Display Sync and Enable
	/* The following outputs are delayed by two clock cycles total because
	 * of the ram. One cycle is added explicitly below and another cycle
	 * is added on the registered output.
	 */
	reg VGA_HS1;
	reg VGA_VS1;
	reg VGA_BLANK1;
	
	always @(posedge VGA_CLK)
	begin
		//- Sync Generator (ACTIVE LOW)
		VGA_HS1 <= ~((xCounter >= C_HORZ_SYNC_START) && (xCounter <= C_HORZ_SYNC_END));
		VGA_VS1 <= ~((yCounter >= C_VERT_SYNC_START) && (yCounter <= C_VERT_SYNC_END));
		
		//- Current X and Y is valid pixel range
		VGA_BLANK1 <= ((xCounter < C_HORZ_NUM_PIXELS) && (yCounter < C_VERT_NUM_PIXELS));	
	
		//- Add 1 cycle delay
		VGA_HS <= VGA_HS1;
		VGA_VS <= VGA_VS1;
		VGA_BLANK <= VGA_BLANK1;	
	end
	
	assign VGA_SYNC = 1'b1;

endmodule
	