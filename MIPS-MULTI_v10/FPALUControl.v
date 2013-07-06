module FPALUControl (iFunct, oControlSignal);

`include "FPALUOP.v"
`include "OPCode.v"
`include "Funct.v"

/* I/O type definition */
input wire [5:0] iFunct;
output reg [3:0] oControlSignal;

always @(iFunct)
begin
	case (iFunct)
			FUNADDS:
				oControlSignal <= 	OPADDS;
			FUNSUBS:
				oControlSignal <= 	OPSUBS;
			FUNMULS:
				oControlSignal <= 	OPMULS;
			FUNDIVS:
				oControlSignal <=	OPDIVS;
			FUNSQRT:
				oControlSignal <=	OPSQRT;
			FUNABS:
				oControlSignal <=	OPABS;
			FUNNEG:
				oControlSignal <=	OPNEG;
			FUNCEQ:
				oControlSignal <=	OPCEQ;
			FUNCLT:
				oControlSignal <=	OPCLT;
			FUNCLE:
				oControlSignal <=	OPCLE;
			FUNCVTSW:
				oControlSignal <=	OPCVTSW;
			FUNCVTWS:
				oControlSignal <=	OPCVTWS;
			default:
				oControlSignal <=	4'b0000;
		endcase
end

endmodule