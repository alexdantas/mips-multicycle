/*
 * ALU
 *
 * Arithmetic Logic Unit with control signals as defined by the COD book:
 *
 * Control lines	|	Function
 * ----------------------------------------------
 * 0000			|	AND
 * 0001			|	OR
 * 0010			|	add
 * 0110			|	subtract
 * 0111			|	set
 * 1100			|	NOR
 *
 * The aditional signals were added to this module to extend the capabilities
 * of the processor:
 *
 * Control lines	|	Function
 * ----------------------------------------------
 * 0011			|	MFHI
 * 0100			|	SLL
 * 0101			|	MFLO
 * 1000			|	SRL
 * 1001			|	SRA
 * 1010			|	XOR
 * 1011			|	SLTU
 * 1101			|	MULT
 * 1110			|	DIV
 * 1111			|	LUI
 */
module ALU (iCLK, iRST, iA, iB, iControlSignal, iShamt, oZero, oALUresult, oOverflow);

`include "ALUOP.v"

/* I/O type definition */
input wire iCLK, iRST;
input wire [31:0] iA, iB;
input wire [3:0] iControlSignal;
input wire [4:0] iShamt;
output wire oZero, oOverflow;
output reg [31:0] oALUresult;

reg [31:0] HI, LO;

wire [31:0] tmpA, tmpB, div, mod;
wire tmpComp;
wire [63:0] mult;
wire [63:0] digits, digits2;

/* Helps treating the signal in several of the operations */
assign tmpA	= (iA[31]) ? ~iA + 1 : iA;
assign tmpB	= (iB[31]) ? ~iB + 1 : iB;
assign tmpComp	= iA < iB ? 1'b1 : 1'b0;
assign mult	= tmpA*tmpB;
assign div = tmpA/tmpB;
assign mod = tmpA%tmpB;
assign digits = {31'b1,31'b0};
assign digits2 ={{32{iB[31]}},iB};

assign oZero = (oALUresult == 32'b0);
assign oOverflow = (iControlSignal==OPADD?((iA[31] == 0 && iB[31] == 0 &&  oALUresult[31] == 1) || (iA[31] == 1 && iB[31] == 1 && oALUresult[31] == 0)):
                   (iControlSignal==OPSUB?((iA[31] == 0 && iB[31] == 1 && oALUresult[31]== 1)|| (iA[31] == 1 && iB[31] == 0 && oALUresult[31] == 0)):1'b0)); 


initial
begin
	{HI,LO} <= 64'b0;
end

always @(iControlSignal, iA, iB)
begin
	case (iControlSignal)
		OPAND:
			oALUresult	<= iA & iB;
		OPOR:
			oALUresult	<= iA | iB;
		OPADD:
		   begin
			oALUresult	= iA + iB;
//			oOverflow = ((iA[31] == 0 && iB[31] == 0 &&  oALUresult[31] == 1) || (iA[31] == 1 && iB[31] == 1 && oALUresult[31] == 0)); 
		   end
		OPMFHI:
			oALUresult	<= HI;
		OPSLL:
			oALUresult	<= iB << iShamt;
		OPMFLO:
			oALUresult	<= LO;
		OPSUB:
		  begin
			oALUresult	= iA - iB;
//			oOverflow = ((iA[31] == 0 && iB[31] == 1 && oALUresult[31]== 1)|| (iA[31] == 1 && iB[31] == 0 && oALUresult[31] == 0));
		  end
		OPSLT:
		begin
			if ((iA[31] ^ iB[31]))
				oALUresult	<= {31'b0,~tmpComp};
			else
				oALUresult	<= {31'b0, tmpComp};
		end
		OPSRL:
			oALUresult	<= iB >> iShamt;
		OPSRA:
		begin
			if(iB[31] == 1'b0)
				oALUresult	<= iB >> iShamt;
			else
				oALUresult	<= (iB >> iShamt) | (digits2[31:0]);
		end
		OPXOR:
			oALUresult	<= iA ^ iB;
		OPSLTU:
			oALUresult	<= {31'b0, tmpComp};
		OPNOR:
			oALUresult	<= ~(iA | iB);
		OPLUI:
			oALUresult	<= {iB[15:0],16'b0};
// para testes de simulacao
		OPMULT:
			oALUresult	<= mult[31:0];
		OPDIV:
			oALUresult	<= div[31:0];
//
		default:
			oALUresult	<= 32'b0;
	endcase
end

always @(posedge iCLK)
begin
	if (iRST)
	begin
		{HI,LO}	<= 64'b0;
	end
	else
	begin
		case (iControlSignal)
			OPMULT:
			begin
				if (iA[31] ^ iB[31]) 
					{HI,LO}	<= ~mult + 1;
				else 
					{HI,LO}	<= mult;
			end
			OPDIV:
			begin
				if (iA[31] ^ iB[31])
					LO	<= ~div + 1;
				else
					LO	<= div;
				if (iA[31])
					HI	<= ~mod + 1;
				else
					HI	<= mod;
			end
			default:
				{HI,LO} <= {HI,LO};
		endcase
	end
end

endmodule

