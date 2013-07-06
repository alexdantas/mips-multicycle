/*
 * Control
 *
 * Datapath control module as defined by the COD book in figures C.3.6, C.3.7
 * and C.3.8 from Appendix C of the third edition.
 */
module Control (iCLK, iRST, iOp, iFmt, iFt, iFunct, iV0, iSleepDone, oIRWrite, oMemtoReg,
				oMemWrite, oMemRead, oIorD, oPCWrite, oPCWriteBEQ, oPCWriteBNE, oPCSource, oALUOp,
				oALUSrcB, oALUSrcA, oRegWrite, oRegDst, oState, oStore, oSleepWrite, oFPDataReg, oFPRegDst,
				oFPPCWriteBc1t, oFPPCWriteBc1f, oFPRegWrite, oFPFlagWrite, oFPU2Mem);

`include "ALUOP.v"
`include "Funct.v"
`include "OPCode.v"
`include "Fmt.v"
`include "Ft.v"
`include "SYSOP.v"


   /* I/O type definition */
   input wire	iCLK, // Clock
  				iRST, // Reset
			  	iSleepDone;

   input wire [5:0] iOp, iFunct, iV0; // Instruction's components.

   input wire [4:0] iFmt;
   input wire		iFt;

   // Output wires that controls everything outside.
   output wire		oIRWrite, oMemtoReg, oMemWrite, oMemRead, oIorD, oPCWrite, oPCWriteBEQ, oPCWriteBNE,
					oRegWrite, oRegDst, oSleepWrite, oFPPCWriteBc1t, oFPPCWriteBc1f, oFPRegWrite, oFPFlagWrite, oFPU2Mem;

   output wire [1:0] oALUOp, oALUSrcA, oFPDataReg, oFPRegDst;

   output wire [2:0] oALUSrcB, oPCSource, oStore;

   output wire [5:0] oState; // Current state

   reg [34:0]	 word;
   reg [5:0]	 pr_state, // Previous state
                 nx_state; // Next state

   // All possible states of the control
   parameter
     FETCH	= 6'b000000,
	 DECODE	= 6'b000001,
	 LWSW	= 6'b000010,
	 LW		= 6'b000011,
	 LW2	= 6'b000100,
	 SW		= 6'b000101,
	 RFMT	= 6'b000110,
	 RFMT2	= 6'b000111,
	 SHIFT	= 6'b001000,
	 IFMTL	= 6'b001001,
	 IFMTA	= 6'b001010,
	 IFMT2	= 6'b001011,
	 BEQ	= 6'b001100,
	 BNE	= 6'b001101,
	 JUMP	= 6'b001110,
	 JAL	= 6'b001111,
	 JR		= 6'b010000,
	 PRINT	= 6'b100000,
	 TIME	= 6'b100001,
	 TIME2	= 6'b100010,
	 SLEEP	= 6'b100011,
	 SLEEP2	= 6'b100100,
	 RANDOM	= 6'b100101,

	 // All possible FPU states
	 FPUFR	= 6'b100110,
	 FPUFR2	= 6'b100111,
	 FPUMOV	= 6'b101000,
	 FPUMFC1	= 6'b101001,
	 FPUMTC1	= 6'b101010,
	 FPUBC1T	= 6'b101011,
	 FPUBC1F	= 6'b101100,
	 FPULWC1	= 6'b101101,
	 FPUSWC1	= 6'b101110,
	 FPUCOMP = 6'b110000,

	 //			JOY		= 6'b100110,
	 //			JRCLR	= 6'b100111;
	 ERRO	 = 6'b111111;

   assign	oFPRegDst = word[34:33];
   assign	oFPDataReg = word[32:31];
   assign	oFPRegWrite = word[30];
   assign	oFPPCWriteBc1t = word[29];
   assign	oFPPCWriteBc1f = word[28];
   assign	oFPFlagWrite = word[27];
   assign	oFPU2Mem = word[26];
   //assign	oClearJAction = word[25]; //Disponivel
	   //assign	oJReset		= word[24];	 //Disponivel
	   assign  oSleepWrite = word[23];
   assign	oStore		= word[22:20];
   assign	oPCWrite	= word[19];
   assign  oPCWriteBNE	= word[18];
   assign	oPCWriteBEQ	= word[17];
   assign	oIorD		= word[16];
   assign	oMemRead	= word[15];
   assign	oMemWrite	= word[14];
   assign	oIRWrite	= word[13];
   assign	oMemtoReg	= word[12];
   assign	oPCSource	= word[11:9];
   assign	oALUOp		= word[8:7];
   assign	oALUSrcB	= word[6:4];
   assign	oALUSrcA	= word[3:2];
   assign	oRegWrite	= word[1];
   assign	oRegDst		= word[0];
   assign	oState		= pr_state;

   // This gets run once at the beginning of the execution.
   initial
	 begin
		pr_state <= FETCH;
	 end

   // Main control block
   always @(posedge iCLK)
	 begin
		if (iRST)
		  pr_state	<= FETCH;
		else
		  pr_state	<= nx_state;
	 end

   //
   // This is the main decision block and you should know it from
   // "cabo a rabo".
   //
   // Here's where the states gets switched from one to another.
   //
   // Remember them? The one's every instruction has in common are
   // 1) FETCH
   // 2) DECODE
   //
   // After that, each instruction has it's own special treatment.
   always @(pr_state)
	 begin

		case (pr_state)
		  FETCH:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000010001010000000010000;
			   nx_state	<= DECODE;
			end

		  DECODE:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000000110000;
			   case (iOp)
				 OPCRFMT:
				   if (iFunct == FUNJR)
					 nx_state	<= JR;
				   else if(iFunct == FUNSLL || iFunct == FUNSRL || iFunct == FUNSRA)
					 nx_state	<= SHIFT;
				   else if(iFunct == FUNSYS)
					 begin
						case (iV0)
						  SYSPRTINT:
							nx_state	<= PRINT;
						  SYSPRTSTR:
							nx_state	<= PRINT;
						  SYSPRTCHR:
							nx_state	<= PRINT;
						  SYSTIME:
							nx_state	<= TIME;
						  SYSSLEEP:
							nx_state	<= SLEEP;
						  SYSRNDINT:
							nx_state	<= RANDOM;
						  default :
							nx_state	<= PRINT; //outros v0 manda para PRINT
						endcase // case (iV0)

					 end // if (iFunct == FUNSYS)

				   else
					 nx_state	<= RFMT;
				 OPCJMP:
				   nx_state	<= JUMP;
				 OPCBEQ:
				   nx_state	<= BEQ;
				 OPCBNE:
				   nx_state	<= BNE;
				 OPCJAL:
				   nx_state	<= JAL;
				 OPCLW,
				   OPCSW,
				   OPCLWC1,	//Load e Store da FPU
				   OPCSWC1:
					 nx_state	<= LWSW;
				 OPCANDI,
				   OPCORI,
				   OPCXORI:
					 nx_state	<= IFMTL;
				 /*				OPCJRCLR:
				  nx_state	<= JRCLR;*/
				 OPCADDI,
				   OPCADDIU,
				   OPCSLTI,
				   OPCSLTIU,
				   OPCLUI:
					 nx_state	<= IFMTA;

				 OPCFLT:
				   case (iFmt)
					 FMTMTC1:
					   nx_state <= FPUMTC1;
					 FMTMFC1:
					   nx_state <= FPUMFC1;
					 FMTBC1:
					   if (iFt)
						 nx_state <= FPUBC1T;
					   else
						 nx_state <= FPUBC1F;
					 FMTCVTSW,
					   FMTFR:
						 case(iFunct)
						   FUNMOV:
							 nx_state	<= FPUMOV;
						   FUNCEQ,
							 FUNCLT,
							 FUNCLE:
							   nx_state	<= FPUCOMP;

						   default:
							 nx_state	<= FPUFR;

						 endcase // case (iFunct)

					 default:
					   nx_state <= ERRO;

				   endcase // case (iFmt)

				 default:
				   nx_state	<= ERRO;

			   endcase // case (iOp)

			end // case: DECODE


		  FPUMTC1:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b01101000000000000000000000000000000;
			   nx_state	<= FETCH;
			end

		  FPUMFC1:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000010100000000000000000010;
			   nx_state <= FETCH;
			end

		  FPUBC1T:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000100000000000000000001000000000;
			   nx_state <= FETCH;
			end

		  FPUBC1F:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000010000000000000000001000000000;
			   nx_state <= FETCH;
			end

		  FPUMOV:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00111000000000000000000000000000000;
			   nx_state <= FETCH;
			end

		  FPUCOMP:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000001000000000000000000000000000;
			   nx_state <= FETCH;
			end

		  FPUFR:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000000000000;
			   nx_state <= FPUFR2;
			end

		  FPUFR2:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00001000000000000000000000000000000;
			   nx_state <= FETCH;
			end

		  LWSW:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000000100100;
               // No more "duvida aqui".
			   case (iOp)
				 OPCLW,
				 OPCLWC1:
				   nx_state	<= LW;
				 OPCSW:
				   nx_state	<= SW;
				 OPCSWC1:
				   nx_state	<= FPUSWC1;
				 default:
				   nx_state	<= ERRO;
			   endcase // case (iOp)

			end // case: LWSW

		  LW:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000011000000000000000;
			   case (iOp)
				 OPCLW:
				   nx_state	<= LW2;
				 OPCLWC1:
				   nx_state	<= FPULWC1;
				 default:
				   nx_state	<= ERRO;
			   endcase // case (iOp)

			end // case: LW

		  FPULWC1:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b10011000000000000000000000000000000;
			   nx_state	<= FETCH;
			end
		  FPUSWC1:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000100000000010100000000000000;
			   nx_state	<= FETCH;
			end
		  LW2:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000001000000000010;
			   nx_state	<= FETCH;
			end
		  SW:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000010100000000000000;
			   nx_state	<= FETCH;
			end

		  RFMT:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000100000100;
			   case (iFunct)
				 FUNMULT,
				 FUNDIV:
				   nx_state	<= FETCH;
				 default:
				   nx_state	<= RFMT2;
			   endcase
			end // case: RFMT

		  RFMT2:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000000000011;
			   nx_state	<= FETCH;
			end
		  SHIFT:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000100001000;
			   nx_state	<= RFMT2;
			end
		  IFMTL:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000111000100;
			   nx_state	<= IFMT2;
			end
		  IFMTA:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000110100100;
			   nx_state	<= IFMT2;
			end
		  IFMT2:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000000000010;
			   nx_state	<= FETCH;
			end
		  BEQ:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000100000001010000100;
			   nx_state	<= FETCH;
			end
		  BNE:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000001000000001010000100;
			   nx_state	<= FETCH;
			end
		  JUMP:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000010000000010000000000;
			   nx_state	<= FETCH;
			end
		  JAL:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000110000000010000000010;
			   nx_state	<= FETCH;
			end
		  JR:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000010000000011000000000;
			   nx_state	<= FETCH;
			end
		  PRINT:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000110000000100000000010;
			   nx_state	<= FETCH;
			end
		  TIME:
			  begin
				 //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
				 word[34:0]	<= 35'b00000000000001000000000000000000010;
				 nx_state	<= TIME2;
			  end
		  TIME2:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000001100000000000000000010;
			   nx_state	<= FETCH;
			end
		  SLEEP:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000100000000000000000000000;
			   nx_state	<= SLEEP2;
			end
		  SLEEP2:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]	<= 35'b00000000000000000000000000000000000;
			   if(iSleepDone)
				 nx_state	<= FETCH;
			   else
				 nx_state <= SLEEP2;
			end
		  RANDOM:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]  <= 35'b00000000000010000000000000000000010;
			   nx_state	<= FETCH;
			end

		  ERRO:
			begin
			   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
			   word[34:0]  <= 35'b00000000000000000000000000000000001;
			   nx_state	<= ERRO;
			end
		  /*		JOY:
		   begin
		   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
		   word[34:0]	<= 35'b00000000010010110000000101000000010;
		   nx_state	<= FETCH;
		end
		   JRCLR:
		   begin
		   //FPRegDst[2], FPDataReg[2], FPRegWrite, FPPCWriteBc1t, FPPCWriteBc1f, FPFlagWrite, FPU2Mem, ClearJAction, JReset, SleepWrite, Store[3], PCWrite, PCWriteBNE, PCWriteBEQ, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource[3], ALUop[2], ALUSrcB[3], ALUSrcA[2], RegWrite, RegDst
		   word[34:0]	<= 35'b00000000001000010000000011000000000;
		   nx_state	<= FETCH;
		end*/

          // Unknown state, things are messed up.
		  default:
			begin
			   word[34:0]	<= 35'b0;
			   nx_state	<= ERRO;
			end

		endcase // case (pr_state)
	 end

   // Thank Satan it's over!

endmodule

