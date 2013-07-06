/*
 * VGAAdapterInterface
 *
 * CPU interface module to the VGA Adapter.
 */
module VgaAdapterInterface (iRST, iCLK_50, iCLK, iMemWrite, iwMemAddress,
	iwMemWriteData, oMemReadData, oVGA_R, oVGA_G, oVGA_B, oVGA_HS, oVGA_VS, oVGA_BLANK,
	oVGA_SYNC, oVGA_CLK);

/* I/O type definition */
input wire iRST, iCLK_50, iCLK, iMemWrite;
input wire [31:0] iwMemAddress, iwMemWriteData;
output wire [31:0] oMemReadData;
output wire oVGA_CLK, oVGA_HS, oVGA_VS, oVGA_BLANK, oVGA_SYNC;
output wire [9:0] oVGA_R, oVGA_G, oVGA_B;

reg MemWrited;
wire [8:0] wX;
wire [7:0] wY;
wire [7:0] wColor_in, wColor_out;
wire wMemWrite;

/*
 * Avoids writing twice in a CPU cycle, since the memory is not necessarily
 * synchronous.*/
 
always @(iCLK)
begin
	MemWrited <= iCLK;
end


assign wMemWrite = (iMemWrite && ~MemWrited && (iwMemAddress >= 32'h80000000)); //Endereco em bytes!
assign wColor_in = iwMemWriteData[7:0];
assign wX = iwMemAddress[8:0]; // 0x123 (12) para 9 bits (320 de 512)
assign wY = iwMemAddress[19:12]; // 0x123 (12) para 8 bits (240 de 256)
assign oMemReadData = {24'b0,wColor_out};

VgaAdapter VGAAd0 (
	.resetn(iRST),
	.CLOCK_50(iCLK_50),
	.color_in(wColor_in),
	.color_out(wColor_out),
	.x(wX),
	.y(wY),
	.writeEn(wMemWrite),
	.VGA_R(oVGA_R),
	.VGA_G(oVGA_G),
	.VGA_B(oVGA_B),
	.VGA_HS(oVGA_HS),
	.VGA_VS(oVGA_VS),
	.VGA_BLANK(oVGA_BLANK),
	.VGA_SYNC(oVGA_SYNC),
	.VGA_CLK(oVGA_CLK));


endmodule
