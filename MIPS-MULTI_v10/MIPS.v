// MIPS: Implementacao do processador MIPS MULTICICLO
//
// Here, pretty much everything you'd expect from a normal MIPS
// processor is defined.
//
// Datapath Multicycle
// Processor datapath, as defined by Figure 5.28 of the COD.

// To ease things out, I've labeled each with a comment. So you
// can just skim through each one of them by looking for the string
// "// MUX"

// (As a Verilog sidenote, the things below are NOT "function
//  arguments" like in C.
//  They're simply Input AND Output nodes.  In other words, everything
//  that begins with "i" we're receiving from the outside world and
//  everything that begins with "o" we're sending to it)

module MIPS (
			 iCLK,
			 iCLK50,
			 iRST,
			 iRegA0,
			 iA0en,
			 oPC,
			 oALUOp,
			 oPCSource,
			 oALUSrcB,
			 oIRWrite,
			 oMemWrite,
			 oMemRead,
			 oIorD,
			 oPCWrite,
			 oALUSrcA,
			 oRegWrite,
			 oPCWriteBEQ,
			 oPCWriteBNE,
			 oRegDst,
			 iRegDispSelect,
			 oRegDisp,
			 owControlState,
			 owMemAddress,
			 owMemWriteData,
			 owMemReadData,
			 oOpcode,
			 oFunct,
			 oInstr,
			 oDebug,
			 iCLKMem,
			 iwAudioCodecData,
			 oFPRegDisp,
			 oFPUFlagBank
			 );
   /*
    * I/O type definition
    */
   input wire iCLK,
              iCLK50,
              iRST;             // Forces program reset
   input wire [4:0] iRegDispSelect;
   input wire [31:0] iRegA0;
   input wire	     iA0en;
   output wire [31:0] oPC,      // Outputs current Program Counter
                      oRegDisp,
                      owMemAddress, // Outputs current memory address.
                      owMemWriteData,
                      owMemReadData, // Will send the data read from the RAM memory.
                      oFPRegDisp;
   output wire [1:0]  oALUOp, oALUSrcA;
   output wire [2:0]  oALUSrcB, oPCSource;
   output wire	      oIRWrite, oMemWrite, oMemRead,
                      oIorD,
                      oPCWrite, oPCWriteBEQ, oPCWriteBNE,
					  oRegWrite, oRegDst;
   output wire [5:0]  owControlState;
   output wire [5:0]  oOpcode, oFunct;
   output wire [7:0]  oFPUFlagBank;
   output wire [31:0] oDebug, oInstr;
   input wire	      iCLKMem;
   input wire [31:0]  iwAudioCodecData;


   // Local registers
   //
   // The following registers are local, storing intermediate values
   // to be used on the next state.
   //
   // (you do remember that the Control is a finite-state machine, rigth?)
   //
   // Registers are named in camel case and use shortcuts to describe each word
   // in the full name as defined by the COD datapath.
   //
   // (call-of-duty datapad?)

   reg [31:0]         A, B,     	// The two intermediate registers
                      				// for storing values between
                                    // instruction phases.
                      MDR,          // Memory data register, temporarily stores
                                    // data from `lw`.
					  PC,			// Program counter, nothing new here.
					  ALUOut,		// ALU's output register.
					  RegTimerHI, // Timer's HI count
					  RegTimerLO, // Timer's LO count
 					  IR;         // Instruction Register, stores the instruction.

   // A wire linking the random number from the timer to the exit
   wire [31:0] 		  RandInt;    // For the random number generator

   reg [63:0] 		  StartTime;  // For the timer

   // Local FPU registers
   //
   // They serve the same purpose as the ones above.
   reg [31:0] 		  FP_A, FP_B, FPALUOut;

   // Local wires
   //
   // They connect one place to the other, unline registers that
   // actually store something.
   // It's a NIGHTMARE to follow them around.
   //
   // Wires are named after the named signals as defined by the COD.
   // Wires that are unnamed in the COD are named as 'w' followed by a short
   // description.

   // These connect the opcode and funct of the current instruction
   wire [5:0] 		  wOpcode,
                      wFunct;

   // Other components of the instruction (rs, rt, rd, shamt)
   wire [4:0] 		  wRS, wRT, wRD, wShamt,

                      wWriteRegister,
                      wRtorRd;

   // Those wires connect the Control module to everything else
   wire 			  IRWrite,
                      MemtoReg,
                      MemWrite,
                      MemRead,
                      IorD, // Tells if the address of the instruction
                            // we're going to get will be the PC or
                            // the exit of the ALU (`beq` for example)

                      PCWrite, PCWriteBEQ, PCWriteBNE,
					  RegWrite, RegDst,
                      wALUZero, // ALU flag that tells us the result was zero
                      SleepWrite, SleepDone, Random, RtorRd, ClearJAction,
					  JReset, wMARSDataAddress;
   wire [1:0] 		  ALUOp, ALUSrcA;
   wire [2:0] 		  ALUSrcB, PCSource, Store;
   wire [3:0] 		  wALUControlSignal;
   wire [31:0] 		  wALUMuxA, wALUMuxB, // ALU Multiplexers, tells what will be the ALU's two inputs (A and B)
					  wALUResult, wImmediate, wuImmediate, wLabelAddress,
					  wReadData1, wReadData2,	// Wires linking the two outputs of the register bank to A
                                				// and B. Just in case we want to read any registers.
					  wJumpAddress,
                      wRegWriteData, // Tells what data will store on the register bank
                      wMemorALU, wMemWriteData,
                      wMemReadData, // The memory read from the RAM
					  wMemAddress,
                      wPCMux,   // What will be stored on the PC (result of a multiplexer)
                      wRegA0, wRegV0,
                      wRandInt, // The random number generator is actually a wire that connects the
                                // timer and the PC
                      wTimerOutHI, wTimerOutLO, wMARSorALUOut;
   wire [63:0] 		  wTimerOut, wEndTime;


   // Local FP wires

   wire [7:0] 		  wFPUFlagBank;
   wire [4:0] 		  wFs, wFt, wFd, wFmt, wFPWriteRegister;
   wire [3:0] 		  wFPALUControlSignal;
   wire [2:0] 		  wBranchFlagSelector, wFPFlagSelector;
   wire [31:0] 		  wFPALUResult, wFPWriteData, wFPReadData1, wFPReadData2, wFPRegDisp;
   wire 			  wFPOverflow, wFPZero, wFPUnderflow, wSelectedFlagValue, wFPNan, wBranchTouF, wCompResult;

   // FPU Control Signal
   wire [1:0] 		  FPDataReg, FPRegDst;
   wire 			  FPPCWriteBc1t, FPPCWriteBc1f, FPRegWrite, FPU2Mem, FPFlagWrite;


   /*
    * Wires assignments
    *
    * 2 to 1 multiplexers are also handled here.
    */
   assign wOpcode	= IR[31:26];
   assign wRS		= IR[25:21];
   assign wRT		= IR[20:16];
   assign wRD		= IR[15:11];
   assign wShamt	= IR[10:6];
   assign wFunct		= IR[5:0];
   assign wImmediate	= {{16{IR[15]}}, IR[15: 0]};
   assign wuImmediate	= {16'b0, IR[15: 0]};
   assign wLabelAddress	= {{14{IR[15]}}, IR[15: 0], 2'b0};
   assign wJumpAddress	= {PC[31:28], IR[25:0], 2'b0}; // The jump address

   assign wEndTime = StartTime + ((32'd50000)*wRegA0);
   assign wTimerOut = {wTimerOutHI, wTimerOutLO};
   assign SleepDone = (wEndTime < wTimerOut);

   // This is kinda tricky. MARS's memory mapping is kinda different from
   // out MIPS implementation.
   // In order to make them here we have to do this little memory hack.
   // We check if the address is greater than the supported range.
   assign wMARSDataAddress = ALUOut >= 32'h10010000 && ALUOut < 32'h10014000;

   // If it is, we output a different address.
   assign wMARSorALUOut	= wMARSDataAddress ? {17'b0, 1'b1, ALUOut[13:0]} : ALUOut;

   assign wMemWriteData	= FPU2Mem ? FP_B : B;

   // Chooses between RT and RD according
   assign wRtorRd = RegDst ? wRD : wRT;

   // Decides on what will be written on the register bank: the MDR or ALU's output?
   assign wMemorALU = MemtoReg ? MDR : ALUOut;

   // This is the decision for fetching the instruction from the RAM.
   // Will we get it from the PC or the ALU output?
   //
   // Instead of creating a Multiplexer, we decide it inline.
   assign wMemAddress = IorD ? wMARSorALUOut : PC;

   // As said before, the random number generator gets "random" bits from the timer
   // and combines it with the PC.
   assign wRandInt[0] = wTimerOut[12];
   assign wRandInt[1] = wTimerOut[25];
   assign wRandInt[2] = wTimerOut[18];
   assign wRandInt[3] = wTimerOut[29];
   assign wRandInt[4] = wTimerOut[23];
   assign wRandInt[5] = wTimerOut[26];
   assign wRandInt[6] = wTimerOut[24];
   assign wRandInt[7] = wTimerOut[28];
   assign wRandInt[8] = wTimerOut[31];
   assign wRandInt[9] = wTimerOut[10];
   assign wRandInt[10] = wTimerOut[30];
   assign wRandInt[11] = wTimerOut[17];
   assign wRandInt[12] = wTimerOut[21];
   assign wRandInt[13] = wTimerOut[11];
   assign wRandInt[14] = wTimerOut[20];
   assign wRandInt[15] = wTimerOut[9];
   assign wRandInt[16] = wTimerOut[16];
   assign wRandInt[17] = wTimerOut[8];
   assign wRandInt[18] = wTimerOut[13];
   assign wRandInt[19] = wTimerOut[27];
   assign wRandInt[20] = wTimerOut[15];
   assign wRandInt[21] = wTimerOut[4];
   assign wRandInt[22] = wTimerOut[7];
   assign wRandInt[23] = wTimerOut[19];
   assign wRandInt[24] = wTimerOut[22];
   assign wRandInt[25] = wTimerOut[6];
   assign wRandInt[26] = wTimerOut[14];
   assign wRandInt[27] = wTimerOut[5];
   assign wRandInt[28] = wTimerOut[1];
   assign wRandInt[29] = wTimerOut[3];
   assign wRandInt[30] = wTimerOut[0];
   assign wRandInt[31] = wTimerOut[2];
   assign RandInt = wRandInt ^ PC; // Here it is!

   /* Floating Point wires assignments*/
   assign wFs = IR[15:11];
   assign wFt = IR[20:16];
   assign wFd = IR[10:6];
   assign wFmt = IR[25:21];
   assign wBranchFlagSelector = IR[20:18];
   assign wSelectedFlagValue = wFPUFlagBank[wBranchFlagSelector];
   assign wFPFlagSelector = IR[10:8];
   assign wBranchTouF = IR[16];

   // Output wires
   //
   // Mostly copying things from internal registers to output wires.
   assign oPC		= PC;
   assign oALUOp	= ALUOp;
   assign oPCSource	= PCSource;
   assign oALUSrcB	= ALUSrcB;
   assign oIRWrite	= IRWrite;
   assign oMemWrite	= MemWrite;
   assign oMemRead	= MemRead;
   assign oIorD	= IorD;
   assign oPCWrite	= PCWrite;
   assign oALUSrcA	= ALUSrcA;
   assign oPCWriteBEQ	= PCWriteBEQ;
   assign oPCWriteBNE	= PCWriteBNE;
   assign oRegWrite	= RegWrite;
   assign oRegDst	= RegDst;
   assign owMemAddress	= wMemAddress;
   assign owMemWriteData	= wMemWriteData;
   assign owMemReadData = wMemReadData;
   assign oOpcode = wOpcode;
   assign oFunct = wFunct;
   assign oInstr = IR;
   assign oDebug = wMemReadData;
   assign oFPUFlagBank = wFPUFlagBank;

   // Processor's initial state
   //
   // This gets executed only once at the beginning of the.. "program"..
   initial
     begin
		// "Zerando" everything
		PC <= 32'b0;
		IR <= 32'b0;
		ALUOut <= 32'b0;
		MDR <= 32'b0;
		A <= 32'b0;
		B <= 32'b0;
		FP_A <= 32'b0;
		FP_B <= 32'b0;
		FPALUOut <= 32'b0;
     end // initial begin

   //  __    _     ___   __    _     ____  ___
   // / /`  | |   / / \ / /`  | |_/ | |_  | | \
   // \_\_, |_|__ \_\_/ \_\_, |_| \ |_|__ |_|_/
   //  ____  _      ____  _     _____  __
   // | |_  \ \  / | |_  | |\ |  | |  ( (`
   // |_|__  \_\/  |_|__ |_| \|  |_|  _)_)
   //
   // Clocked events
   //
   // Registers that aren't in any module are specified here.

   // This happens every time the clock goes to a positive edge
   always @(posedge iCLK)
     begin
		if (iRST)               // If we pressed the Reset button then
		  begin					// we need to reset the whole program.
			 PC	<= 32'b0;
			 IR	<= 32'b0;
			 ALUOut	<= 32'b0;
			 MDR <= 32'b0;
			 A <= 32'b0;
			 B <= 32'b0;
			 FP_A <= 32'b0;
			 FP_B <= 32'b0;
			 FPALUOut <= 32'b0;
		  end // if (iRST)

		else                    // Most common situation, running the program.
		  begin
			 // Unconditional assignment, everything goes as smooth as it can.
			 ALUOut <= wALUResult;
			 A <= wReadData1;
			 B <= wReadData2;
			 MDR <= wMemReadData;

			 FPALUOut <= wFPALUResult;
			 FP_A <= wFPReadData1;
			 FP_B <= wFPReadData2;

			 // Conditional assignments

             // This checks if we can/will write on the PC for several reasons.
			 if ((PCWrite) ||
				 (PCWriteBEQ && wALUZero) ||
				 (PCWriteBNE && ~wALUZero) ||
				 (FPPCWriteBc1t && wSelectedFlagValue) ||
				 (FPPCWriteBc1f && ~wSelectedFlagValue))
			   begin
				  PC <= wPCMux; // Result of a "maroto" mux.
			   end

             // Tells if we're gonna write the data taken from the RAM
             // memory into the current Instruction Register.
			 if (IRWrite)
			   begin
				  IR <= wMemReadData;
			   end

			 if (Store == 3'd2)
			   RegTimerLO <= wTimerOutLO;

			 if (Store == 3'd3)
			   RegTimerHI <= wTimerOutHI;

			 if(SleepWrite)
			   begin
				  StartTime[31:0]  <= wTimerOutLO;
				  StartTime[63:32] <= wTimerOutHI;
			   end

		  end // else: !if(iRST)

     end // always @ (posedge iCLK)

   //   __    _     _
   //  / /\  | |   | |
   // /_/--\ |_|__ |_|__
   //  _      ___   ___   _     _     ____  __
   // | |\/| / / \ | | \ | | | | |   | |_  ( (`
   // |_|  | \_\_/ |_|_/ \_\_/ |_|__ |_|__ _)_)
   //
   // The main components of the processor are instantiated here.

   //  __    ___   _     _____  ___   ___   _
   // / /`  / / \ | |\ |  | |  | |_) / / \ | |
   // \_\_, \_\_/ |_| \|  |_|  |_| \ \_\_/ |_|__
   //
   // Controls a lot of stuff inside the processor.
   // It is now a big State Machine, now that we're multicycle!
   Control Cont0 (
				  .iCLK(iCLK),
				  .iRST(iRST),
				  .iOp(wOpcode),
				  .iFmt(wFmt),
				  .iFt(wBranchTouF),
				  .iFunct(wFunct),
				  .iV0(wRegV0[5:0]),
				  .iSleepDone(SleepDone),
				  .oIRWrite(IRWrite),
				  .oMemtoReg(MemtoReg),
				  .oMemWrite(MemWrite),
				  .oMemRead(MemRead),
				  .oIorD(IorD),
				  .oPCWrite(PCWrite),
				  .oPCWriteBEQ(PCWriteBEQ),
				  .oPCWriteBNE(PCWriteBNE),
				  .oPCSource(PCSource),
				  .oALUOp(ALUOp),
				  .oALUSrcB(ALUSrcB),
				  .oALUSrcA(ALUSrcA),
				  .oRegWrite(RegWrite),
				  .oRegDst(RegDst),
				  .oState(owControlState),
				  .oStore(Store),
				  .oSleepWrite(SleepWrite),
				  .oFPDataReg(FPDataReg),
				  .oFPRegDst(FPRegDst),
				  .oFPPCWriteBc1t(FPPCWriteBc1t),
				  .oFPPCWriteBc1f(FPPCWriteBc1f),
				  .oFPRegWrite(FPRegWrite),
				  .oFPFlagWrite(FPFlagWrite),
				  .oFPU2Mem(FPU2Mem)
				  );

   //  ___   ____  __    _   __  _____  ____  ___       ___    __    _      _
   // | |_) | |_  / /`_ | | ( (`  | |  | |_  | |_)     | |_)  / /\  | |\ | | |_/
   // |_| \ |_|__ \_\_/ |_| _)_)  |_|  |_|__ |_| \     |_|_) /_/--\ |_| \| |_| \
   //
   // All the "normal" registers.
   Registers Reg0 (
				   .iCLK(iCLK),
				   .iCLR(iRST),
				   .iReadRegister1(wRS),
				   .iReadRegister2(wRT),
				   .iWriteRegister(wWriteRegister), // On what register will I write?
				   .iWriteData(wRegWriteData),      // What data will I write?
				   .iRegWrite(RegWrite),            // Will I write data?
				   .oreaddata1(wReadData1),
				   .oReadData2(wReadData2),
				   .iRegDispSelect(iRegDispSelect),
				   .oRegDisp(oRegDisp),
				   .oRegA0(wRegA0),
				   .oRegV0(wRegV0),
				   .iRegA0(iRegA0),
				   .iA0en(iA0en)
				   );

   // MUX WriteRegister 8 to 1
   //
   // This selects on which register we will store data.
   Mult8to1 Mult8to1WriteReg (
							  .i0(wRtorRd),		// Most common
							  .i1(5'd31),		// For `jal`, we write on $ra (31 decimal)
							  .i2(5'd04),		// Store timer LO on $a0
							  .i3(5'd05),		// Store timer HI on $a1
							  .i4(5'd04),		// Store random integer on $a0
							  .i5(wRT),			// `mfc1` tells us where.
							  .i6(5'd00),		// Free slot
							  .i7(5'd00),		// Free slot
							  .iSelect(Store),
							  .oSelected(wWriteRegister)
							  );

   // MUX WriteData 8 to 1
   //
   // This selects what data will be written on the register bank.
   Mult8to1 Mult8to1WriteData (
							   .i0(wMemorALU),		// Most common, storing the result from the ALU
							   .i1(PC),				// For `jal`, when we store $ra
							   .i2(RegTimerLO),		// Store timer LO
							   .i3(RegTimerHI),		// Store timer HI
							   .i4(RandInt),		// Store random integer
							   .i5(FP_A),			// `mfc1` result
							   .i6(32'd0),			// Free slot
							   .i7(32'd0),			// Free slot
							   .iSelect(Store),
							   .oSelected(wRegWriteData)
							   );
   //   __    _     _
   //  / /\  | |   | | |
   // /_/--\ |_|__ \_\_/
   //
   // (Arithmetic Logic Unit)
   ALU ALU0 (
			 .iCLK(iCLK),
			 .iRST(iRST),
			 .iA(wALUMuxA),     // Input no 1
			 .iB(wALUMuxB),     // Input no 2
			 .iShamt(wShamt),
			 .iControlSignal(wALUControlSignal),
			 .oZero(wALUZero),
			 .oALUresult(wALUResult),
			 .oOverflow()
			 );

   //   __    _     _         __    ___   _     _____  ___   ___   _
   //  / /\  | |   | | |     / /`  / / \ | |\ |  | |  | |_) / / \ | |
   // /_/--\ |_|__ \_\_/     \_\_, \_\_/ |_| \|  |_|  |_| \ \_\_/ |_|__
   //
   // ALU (Arithmetic Logic Unit) control
   ALUcontrol ALUcont0 (
						.iFunct(wFunct),
						.iOpcode(wOpcode),
						.iALUOp(ALUOp),
						.oControlSignal(wALUControlSignal)
						);

   // MUX ALU input 'A' 4 to 1
   //
   // Tells what we'll send as first input to the ALU.
   Mult4to1 Mult4to1ALUA0 (
						   .i0(PC),				// Sending the PC
						   .i1(A),				// Sending A
						   .i2(32'd0), 			// Free slot
						   .i3(32'd0), 			// Free slot
						   .iSelect(ALUSrcA),
						   .oSelected(wALUMuxA)
						   );

   // ALU input 'B'8 to 1 multiplexer module
   //
   // Tells what we'll send as second input to the ALU.
   Mult8to1 Mult8to1ALUB0 (
						   .i0(B),				// Sendung B
						   .i1(32'd4),			// 4
						   .i2(wImmediate),		// The instruction immediate
						   .i3(wLabelAddress),	// The label address
						   .i4(wuImmediate),
						   .i5(32'd0), 			// Free slot
						   .i6(32'd0), 			// Free slot
						   .i7(32'd0), 			// Free slot
						   .iSelect(ALUSrcB),
						   .oSelected(wALUMuxB)
						   );

   // MUX Program Counter 8 to 1
   //
   // This tells us what we're going to write on the PC
   Mult8to1 Mult8to1PC0 (
						 .i0(wALUResult),		// For PC <= PC + 4
						 .i1(ALUOut),			// For BEQ, BNE, BC1T and BC1F
						 .i2(wJumpAddress),		// For `j` and `jal`
						 .i3(A),				// For `jr`
						 .i4(32'h14000),		// For `syscall` (prints) 0x5000 x 4
						 .i5(32'd0),			// Free slot
						 .i6(32'd0),			// Free slot
						 .i7(32'd0),			// Free slot
						 .iSelect(PCSource),
						 .oSelected(wPCMux)
						 );
   //  ___    __    _
   // | |_)  / /\  | |\/|
   // |_| \ /_/--\ |_|  |
   //
   // RAM Memory block module
   //
   // This contains all the instructions to be fetched.
   // Normally, PC comes in and instruction comes out.
   Memory MemRAM (
				  .iCLK(iCLK),
				  .iCLKMem(iCLKMem),
				  .iByteEnable(4'b1111),
				  .iAddress(wMemAddress), // Address to fetch instructions from (normally, PC)
				  .iWriteData(wMemWriteData),
				  .iMemRead(MemRead),
				  .iMemWrite(MemWrite),
				  .oMemData(wMemReadData), // Data read from the RAM memory.
				  .iwAudioCodecData(iwAudioCodecData)
				  );

   //  ____  ___       ___   ____  __    _   __  _____  ____  ___   __
   // | |_  | |_)     | |_) | |_  / /`_ | | ( (`  | |  | |_  | |_) ( (`
   // |_|   |_|       |_| \ |_|__ \_\_/ |_| _)_)  |_|  |_|__ |_| \ _)_)
   //
   // Floating Point register bank
   FPURegisters FPURegBank (
							.iCLK(iCLK),
							.iCLR(iRST),
							.iReadRegister1(wFs),
							.iReadRegister2(wFt),
							.iWriteRegister(wFPWriteRegister),
							.iWriteData(wFPWriteData),
							.iRegWrite(FPRegWrite),
							.oReadData1(wFPReadData1),
							.oReadData2(wFPReadData2),
							.iRegDispSelect(iRegDispSelect),
							.oRegDisp(oFPRegDisp)
							);

   // Register to be written - FPU Registers Bank
   Mult4to1 FPRegDstMultiplexer (
								 .i0(wFd),	//For normal, FR instructions
								 .i1(wFs),	//For mtc1
								 .i2(wFt),	//For lwc1
								 .i3(5'b0),
								 .iSelect(FPRegDst),
								 .oSelected(wFPWriteRegister)
								 );

   /* Data input - FPU Registers Bank*/
   Mult4to1 FPWriteDataMultiplexer (
									.i0(FPALUOut),
									.i1(MDR),
									.i2(B),
									.i3(FP_A),
									.iSelect(FPDataReg),
									.oSelected(wFPWriteData)
									);
   //  ____  ___        __    _     _
   // | |_  | |_)      / /\  | |   | | |
   // |_|   |_|       /_/--\ |_|__ \_\_/
   //
   // All the floating-point calculations.
   ula_fp FPALUUnit (
					 .iclock(iCLK50),
					 .idataa(FP_A),
					 .idatab(FP_B),
					 .icontrol(wFPALUControlSignal),
					 .oresult(wFPALUResult),
					 .onan(wFPNan),
					 .ozero(wFPZero),
					 .ooverflow(wFPOverflow),
					 .ounderflow(wFPUnderflow),
					 .oCompResult(wCompResult)
					 );

   // FPU Flag Bank
   //
   // Contains those useful flags used by test FP instructions.
   FlagBank FlagBankModule(
						   .iCLK(iCLK),
						   .iCLR(iRST),
						   .iFlag(wFPFlagSelector),
						   .iFlagWrite(FPFlagWrite),
						   .iData(wCompResult),
						   .oFlags(wFPUFlagBank)
						   );
   //  ____  ___        __    _     _         __    ___   _     _____  ___   ___   _
   // | |_  | |_)      / /\  | |   | | |     / /`  / / \ | |\ |  | |  | |_) / / \ | |
   // |_|   |_|       /_/--\ |_|__ \_\_/     \_\_, \_\_/ |_| \|  |_|  |_| \ \_\_/ |_|__
   //
   // Floating Point ALU Control
   FPALUControl FPALUControlUnit (
								  .iFunct(wFunct),
								  .oControlSignal(wFPALUControlSignal)
								  );

   // _____  _   _      ____  ___
   //  | |  | | | |\/| | |_  | |_)
   //  |_|  |_| |_|  | |_|__ |_| \
   //
   // Timer block module
   Timer Time0 (
				.iCLK(iCLK50),
				.iRST(iRST),
				.qHI(wTimerOutHI),
				.qLO(wTimerOutLO)
				);

endmodule // MIPS

