/*
 * Memory.v
 *
 * Main processor memory bank.
 * Stores information in 4K 32-bits.
 */
module Memory (iCLK,
			   iCLKMem, 
			   iAddress, // Endereco em bytes
			   iByteEnable,
			   iWriteData, 
			   iMemRead, 
			   iMemWrite, 
			   oMemData,
			   iwAudioCodecData
			   );

/* I/O type definition */
input wire iCLK, iCLKMem, iMemRead, iMemWrite;
input [3:0] iByteEnable;
input wire [31:0] iAddress, iWriteData;
output wire [31:0] oMemData;
input wire [31:0] iwAudioCodecData;

wire [31:0] Address;
assign Address = {2'b0,iAddress[31:2]};  //Endereco em Words, Cuidar alinhamento!!
 

reg MemWrited;
wire wMemWrite, wMemWriteMB0, wMemWriteMB1;
wire [31:0] wMemDataMB0, wMemDataMB1;
wire sysmem,usermem,iodevices;

initial
	MemWrited = 1'b0;

always @(iCLK)
begin
	MemWrited <= iCLK;
end

assign iodevices = iAddress>=32'h10000000;
assign usermem = Address>=32'h00000000 && Address<32'h00002000 &&~iodevices;
assign sysmem = Address>=32'h00005000 && Address<32'h00005C00 &&~iodevices;


assign wMemWriteMB0 = ~MemWrited && iMemWrite && usermem;
assign wMemWriteMB1 = ~MemWrited && iMemWrite && sysmem;

assign oMemData = iodevices? iwAudioCodecData: 
					sysmem? wMemDataMB1: 
						usermem? wMemDataMB0:
									32'b0;

MemoryBlock MB0 (
	.address(Address[12:0]),
	.byteena(iByteEnable),
	.clock(iCLKMem),
	.data(iWriteData),
	.wren(wMemWriteMB0),  //wMemWriteMB0
	.q(wMemDataMB0)
	);

MemoryBlockSys MB1 (
	.address(Address[11:0]),
	.byteena(iByteEnable),
	.clock(iCLKMem),
	.data(iWriteData),
	.wren(wMemWriteMB1),
	.q(wMemDataMB1)
	);


endmodule

