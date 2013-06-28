// ALUcontrol.v: Arithmetic Logic Unit control module.
//
// This big file controls the ALU. It sends control signals to the ALU
// depending on:
//
// * `opcode` of the current instruction.
// * `funct` of the current instruction.
// * `signal` sent by the processor control module.
//
// The signal tells us what will we do. These are the options:
//
// ALUOp	|	Control signal
// -------------------------------------------
// 00		|	The ALU performs an add operation.
// 01		|	The ALU performs a subtract operation.
// 10		|	The funct field determines the ALU operation.
// 11		|	The opcode field determines the ALU operation.
//

module ALUcontrol (iFunct, iOpcode, iALUOp, oControlSignal);

`include "ALUOP.v"  // Names of the ALU operations.
`include "Funct.v"  // Translates funct --> operations
`include "OPCode.v" // Translates opcode -> operations


//  _    __  ___     __  _____  _     ____  ____
// | |  / / / / \   ( (`  | |  | | | | |_  | |_
// |_| /_/  \_\_/   _)_)  |_|  \_\_/ |_|   |_|
//
// I/O type definitions

input wire [5:0] iFunct,  // funct of the instruction.
                 iOpcode; // opcode of the instruction.

input wire [1:0] iALUOp; // The signal we received from control.

output reg [3:0] oControlSignal; // Signal we'll send to the ALU.


//  ____  _      ____  _     _____  __
// | |_  \ \  / | |_  | |\ |  | |  ( (`
// |_|__  \_\/  |_|__ |_| \|  |_|  _)_)
//
// Here's where the action happens!

// If any of those change, we will do this over again.
always @(iFunct, iOpcode, iALUOp)
begin
	case (iALUOp)
		2'b00:
			oControlSignal <=	OPADD;
		2'b01:
			oControlSignal <=	OPSUB;
		2'b10:

		begin
			case (iFunct)
				FUNSLL:
					oControlSignal <= 	OPSLL;
				FUNSRL:
					oControlSignal <= 	OPSRL;
				FUNSRA:
					oControlSignal <= 	OPSRA;
				FUNMFHI:
					oControlSignal <=	OPMFHI;
				FUNMFLO:
					oControlSignal <=	OPMFLO;
				FUNMULT:
					oControlSignal <=	OPMULT;
				FUNDIV:
					oControlSignal <=	OPDIV;
				FUNADD:
					oControlSignal <=	OPADD;
				FUNADDU:
					oControlSignal <=	OPADD;
				FUNSUB:
					oControlSignal <=	OPSUB;
				FUNSUBU:
					oControlSignal <=	OPSUB;
				FUNAND:
					oControlSignal <=	OPAND;
				FUNOR:
					oControlSignal <=	OPOR;
				FUNXOR:
					oControlSignal <=	OPXOR;
				FUNNOR:
					oControlSignal <=	OPNOR;
				FUNSLT:
					oControlSignal <=	OPSLT;
				FUNSLTU:
					oControlSignal <=	OPSLTU;
				default:
					oControlSignal <=	4'b0000;
			endcase // case (iFunct)
		end // case: 2'b10

		2'b11:
			case (iOpcode)
				OPCADDI:
					oControlSignal <= 	OPADD;
				OPCADDIU:
					oControlSignal <= 	OPADD;
				OPCSLTI:
					oControlSignal <= 	OPSLT;
				OPCSLTIU:
					oControlSignal <= 	OPSLTU;
				OPCANDI:
					oControlSignal <= 	OPAND;
				OPCORI:
					oControlSignal <= 	OPOR;
				OPCXORI:
					oControlSignal <= 	OPXOR;
				OPCLUI:
					oControlSignal <= 	OPLUI;
				default:
					oControlSignal <=	4'b0000;
			endcase // case (iOpcode)
	endcase // case (iALUOp)
end

endmodule // ALUcontrol

