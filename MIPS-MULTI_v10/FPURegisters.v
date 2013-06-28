/*
 * Registers.v
 *
 * Coprocessor 1 register bank testbench.
 * Stores information in 32-bit registers. 32 registers are available for
 * writing and 32 are available for reading.
 * Also allows for two simultaneous data reads, has a write enable signal
 * input, is clocked and has an asynchronous reset signal input.
 */
module FPURegisters (iCLK, iCLR, iReadRegister1, iReadRegister2, iWriteRegister,
	iWriteData, iRegWrite, oReadData1, oReadData2, iRegDispSelect, oRegDisp);

/* I/O type definition */
input wire [4:0] iReadRegister1, iReadRegister2, iWriteRegister, iRegDispSelect;
input wire [31:0] iWriteData;
input wire iCLK, iCLR, iRegWrite;
output wire [31:0] oReadData1, oReadData2, oRegDisp;

/* Local register bank */
reg [31:0] registers[31:0];

integer i;

initial
begin
	for (i = 0; i <= 31; i = i + 1)
	begin
		registers[i] = 32'b0;
	end
end

/* Output definition */
assign oReadData1 =	registers[iReadRegister1];
assign oReadData2 =	registers[iReadRegister2];

assign oRegDisp =	registers[iRegDispSelect];

/* Main block for writing and reseting */
always @(posedge iCLK)
begin
	if (iCLR)
	begin
		for (i = 0; i <= 31; i = i + 1)
		begin
			registers[i] = 32'b0;
		end
	end
	else if (iCLK && iRegWrite)
	begin
		registers[iWriteRegister] =	iWriteData;
	end
	
end

endmodule
