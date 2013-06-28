// TopDE: Top Level para processador MIPS MULTICICLO v10.
//
// A maioria dos comentários estão em inglês. Por exemplo...
// This file interfaces between the MIPS processor and the DE2-70 board
// (switches, LEDs, VGA...).
//
// Changelog:
//
// v0: Top Level para processador MIPS MULTICICLO baseado no processador desenvolvido por
// David A. Patterson e John L. Hennessy
// Computer Organization and Design
// 3a Ediзгo
//
// v01: Top Level para processador MIPS MULTICICLO baseado no processador desenvolvido por
// Alexandre Lins	09/40097
// Daniel Dutra		09/08436
// Yuri Maia		09/16803
// em 2010/1 na disciplina OAC
//
// v1: Top Level para processador MIPS UNICICLO v1 baseado no processador desenvolvido por
// Emerson Grzeidak							0993514
// Gabriel Calache Cozendey						09/47946
// Glauco Medeiros Volpe						10/25091
// Luiz Henrique Dias Navarro						10/00748
// Waldez Azevedo Gomes Junior						10/08617
// em 2011/1 na disciplina OAC
//
//  Top Level para processador MIPS UNICICLO v2 baseado no processador desenvolvido por
// Antonio Martino Neto – 09/89886
// Bruno de Matos Bertasso – 08/25590
// Carolina S. R. de Oliveira – 07/45006
// Herman Ferreira M. de Asevedo – 09/96319
// Renata Cristina – 09/0130600
// em 2011/2 na disciplina OAC
//
//  Top Level para processador MIPS MULTICICLO v9 baseado no processador desenvolvido por
// Andrй Franзa - 10/0007457
// Felipe Carvalho Gules - 08/29137
// Filipe Tancredo Barros - 10/0029329
// Guilherme Ferreira - 12/0051133
// Vitor Coimbra de Oliveira - 10/0021832
// em 2012/1 na disciplina OAC
//
//  Adaptado para a placa de desenvolvimento DE2-70.
//  Prof. Marcus Vinicius Lamar	  2012/1

// These are all wires from the DE2-70 Board
module TopDE (iCLK_50, iCLK_28,
			  iKEY,
			  oHEX0_D, oHEX0_DP,
			  oHEX1_D, oHEX1_DP,
			  oHEX2_D, oHEX2_DP,
			  oHEX3_D, oHEX3_DP,
			  oHEX4_D, oHEX4_DP,
			  oHEX5_D, oHEX5_DP,
			  oHEX6_D, oHEX6_DP,
			  oHEX7_D, oHEX7_DP,
			  oLEDG,
			  oLEDR,
			  iSW,
			  oVGA_CLOCK, oVGA_HS, oVGA_VS, oVGA_BLANK_N, oVGA_SYNC_N,
			  oVGA_R, oVGA_G, oVGA_B,
			  GPIO_0,
			  oLCD_ON, oLCD_BLON, LCD_D, oLCD_RW, oLCD_EN, oLCD_RS,
			  oTD1_RESET_N,
			  I2C_SDAT, oI2C_SCLK,
			  AUD_ADCLRCK, iAUD_ADCDAT, AUD_DACLRCK, oAUD_DACDAT, AUD_BCLK, oAUD_XCK,
			  PS2_KBCLK, PS2_KBDAT, oOUTPUT);

   // We're going to define them here based on their use
   // I/O
   input iCLK_50, iCLK_28;
   input [3:0] iKEY;
   output [6:0] oHEX0_D, oHEX1_D, oHEX2_D, oHEX3_D, oHEX4_D, oHEX5_D, oHEX6_D, oHEX7_D;
   output	oHEX0_DP, oHEX1_DP, oHEX2_DP, oHEX3_DP, oHEX4_DP, oHEX5_DP, oHEX6_DP, oHEX7_DP;
   output [8:0] oLEDG;
   output [17:0] oLEDR;
   input [17:0]	 iSW;

   // GPIO_0
   input [31:0]	 GPIO_0 ;

   //VGA interface
   output	 oVGA_CLOCK, oVGA_HS, oVGA_VS, oVGA_BLANK_N, oVGA_SYNC_N;
   output [9:0]	 oVGA_R, oVGA_G, oVGA_B;

   // TV Decoder
   output	 oTD1_RESET_N; // TV Decoder Reset

   // I2C
   inout	 I2C_SDAT; // I2C Data
   output	 oI2C_SCLK; // I2C Clock

   // Audio CODEC
   inout	 AUD_ADCLRCK; // Audio CODEC ADC LR Clock
   input	 iAUD_ADCDAT;  // Audio CODEC ADC Data
   inout	 AUD_DACLRCK; // Audio CODEC DAC LR Clock
   output	 oAUD_DACDAT;  // Audio CODEC DAC Data
   inout	 AUD_BCLK;    // Audio CODEC Bit-Stream Clock
   output	 oAUD_XCK;     // Audio CODEC Chip Clock

   // PS2 Keyborad
   inout	 PS2_KBCLK;
   inout	 PS2_KBDAT;

   //	Mуdulo LCD 16X2
   inout [7:0]	 LCD_D;	//	LCD Data bus 8 bits
   output	 oLCD_ON;		//	LCD Power ON/OFF
   output	 oLCD_BLON;	//	LCD Back Light ON/OFF
   output	 oLCD_RW;		//	LCD Read/Write Select, 0 = Write, 1 = Read
   output	 oLCD_EN;		//	LCD Enable
   output	 oLCD_RS;		//	LCD Command/Data Select, 0 = Command, 1 = Data


   //para simulacao por forma de onda
   output [31:0] oOUTPUT;

   // CLK signals ctrl
   reg		 CLKManual, CLKAutoSlow, CLKSelectAuto, CLKSelectFast, CLKAutoFast;
   wire		 CLK, clock50_ctrl;
   reg [7:0]	 CLKCount2;
   reg [25:0]	 CLKCount;
   wire [7:0]	 wcountf;

   // Local wires
   wire [31:0]	 PC, wRegDisp, wFPRegDisp, wRegA0, wMemAddress, wMemWriteData, wMemReadData, extOpcode,
		 extFunct,wInstr, wOutput, wDebug, wMemReadVGA;
   wire [1:0]	 ALUOp, ALUSrcA;
   wire [2:0]	 ALUSrcB, PCSource;
   wire		 IRWrite, MemWrite, MemRead, IorD, PCWrite, PCWriteBEQ, PCWriteBNE, RegWrite, RegDst;
   wire [5:0]	 wControlState;
   wire [4:0]	 wRegDispSelect;
   wire [5:0]	 wOpcode, wFunct;
   wire [7:0]	 flagBank;


   // Reset synchronous with the Clock
   // Only works at the clock's positive edge.
   // Checks for the rightmost blue key.
   wire Reset;
   always @(posedge CLK)
     Reset <= ~iKEY[0];

   // Wire assignment

   // LEDs
   assign oLEDG[7:0] =	PC[9:2];
   assign oLEDG[8] =	CLK;
   assign oLEDR[2:0] =	PCSource;
   assign oLEDR[5:3] =	ALUSrcB[2:0];
   assign oLEDR[6] =	ALUSrcA[0];
   assign oLEDR[7] =	PCWrite;
   assign oLEDR[8] =	RegWrite;
   assign oLEDR[9] =	IorD;
   assign oLEDR[10] =	MemWrite;
   assign oLEDR[11] =	MemRead;
   assign oLEDR[17:12] =	wControlState;

   assign extOpcode = {26'b0,wOpcode};
   assign extFunct = {26'b0,wFunct};

   assign oOUTPUT = wOutput; //Para debug com simulacao

   /* 7 segment display content selection */
   assign wRegDispSelect =	iSW[17:13];

   /* $a0 initial content, with signal extention */
   assign wRegA0 =	{{24{iSW[7]}},iSW[7:0]};
   assign wcountf = iSW[7:0];  // usado para o divisor de frequencia fast

   assign wOutput	= iSW[12] ?
			  (iSW[17] ?
			   PC :
			   (iSW[16] ?
			    wInstr :
			    (iSW[15] ?
			     extOpcode :
			     (iSW[14] ?
			      extFunct :
			      (iSW[13]?
			       wDebug:
			       {3'b0, flagBank[7], 3'b0, flagBank[6], 3'b0, flagBank[5], 3'b0, flagBank[4],
				3'b0, flagBank[3], 3'b0, flagBank[2], 3'b0, flagBank[1], 3'b0, flagBank[0]})
			      )
			     )
			    )
			   ) : iSW[11] ? wFPRegDisp : wRegDisp;


   /* Clocks */
   always @(posedge clock50_ctrl)
     CLK <= CLKSelectAuto?(CLKSelectFast?CLKAutoFast:CLKAutoSlow):CLKManual;

   /* Clock events definitions */
   initial
     begin
	CLKManual	<= 1'b0;
	CLKAutoSlow	<= 1'b0;
	CLKSelectAuto	<= 1'b0;
	CLKSelectFast	<= 1'b0;
	CLKCount2<=4'b0;
	CLKCount<=26'b0;
     end

   always @(posedge clock50_ctrl)    //clock manual sincrono com iCLK_50
     CLKManual <= iKEY[3];

   always @(posedge iKEY[2])
     CLKSelectAuto <= ~CLKSelectAuto;

   always @(posedge iKEY[1])
     CLKSelectFast <= ~CLKSelectFast;


   always @(posedge clock50_ctrl)
     begin

	if (CLKCount == 26'h1000000) //Clock Slow
	  begin
	     CLKAutoSlow <= ~CLKAutoSlow;
	     CLKCount <= 4'b0;
	  end
	else
	  CLKCount <= CLKCount + 1'b1;

	if (CLKCount2 == wcountf) //8'hFF) //Clock Fast
	  begin
	     CLKAutoFast <= ~CLKAutoFast;
	     CLKCount2 <= 8'b0;
	  end
	else
	  CLKCount2 <= CLKCount2 + 1'b1;

     end

   /* Mono estбvel 10 segundos */
   mono Mono1 (iCLK_50,~iSW[10],clock50_ctrl,Reset);

   // MIPS Processor instantiation
   // Probably the most important part here. The file MIPS.v defines the processor
   // and here we use it with the DE2-70 board.
   //
   // As you can see, on the left we have the MIPS's internal wires and on the
   // right, our (TopDE) wires from the board.
   MIPS Processor (.iCLK(CLK),
		   .iCLK50(clock50_ctrl),
		   .iRST(Reset),
		   .iRegA0(wRegA0),
		   .iA0en(iSW[8]),
		   .oPC(PC),
		   .owControlState(wControlState),
		   .oALUOp(ALUOp),
		   .oPCSource(PCSource),
		   .oALUSrcB(ALUSrcB),
		   .oIRWrite(IRWrite),
		   .oMemWrite(MemWrite),
		   .oMemRead(MemRead),
		   .oIorD(IorD),
		   .oPCWrite(PCWrite),
		   .oALUSrcA(ALUSrcA),
		   .oPCWriteBEQ(PCWriteBEQ),
		   .oPCWriteBNE(PCWriteBNE),
		   .oRegWrite(RegWrite),
		   .oRegDst(RegDst),
		   .iRegDispSelect(wRegDispSelect),
		   .oRegDisp(wRegDisp),
		   .owMemAddress(wMemAddress),
		   .owMemWriteData(wMemWriteData),
		   .owMemReadData(wMemReadData),
		   .oOpcode(wOpcode),
		   .oFunct(wFunct),
		   .oInstr(wInstr),
		   .oDebug(wDebug),
		   .iCLKMem(clock50_ctrl),
		   .iwAudioCodecData(wAudioCodecData),
		   .oFPRegDisp(wFPRegDisp),
		   .oFPUFlagBank(flagBank)
		   );

   // Instantiations of the 7-segment displays
   // (those funny red Hex numbers on the board)

   // These are the dots from the numbers.
   // (remember that if they're 1 they will be turned off)
   assign oHEX0_DP=1'b1;
   assign oHEX1_DP=1'b1;
   assign oHEX2_DP=1'b1;
   assign oHEX3_DP=1'b1;
   assign oHEX4_DP=1'b1;
   assign oHEX5_DP=1'b1;
   assign oHEX6_DP=1'b1;
   assign oHEX7_DP=1'b1;

   // To access a display we're gonna need a decoder.
   // We send the binary number we want to show and the decoder
   // is responsible for showing the right parts of it onscreen.
   // Now, the decoders of each single 7-segment display
   Decoder7 Dec0 (
		  .In(wOutput[3:0]),
		  .Out(oHEX0_D)
		  );

   Decoder7 Dec1 (
		  .In(wOutput[7:4]),
		  .Out(oHEX1_D)
		  );

   Decoder7 Dec2 (
		  .In(wOutput[11:8]),
		  .Out(oHEX2_D)
		  );

   Decoder7 Dec3 (
		  .In(wOutput[15:12]),
		  .Out(oHEX3_D)
		  );

   Decoder7 Dec4 (
		  .In(wOutput[19:16]),
		  .Out(oHEX4_D)
		  );

   Decoder7 Dec5 (
		  .In(wOutput[23:20]),
		  .Out(oHEX5_D)
		  );

   Decoder7 Dec6 (
		  .In(wOutput[27:24]),
		  .Out(oHEX6_D)
		  );

   Decoder7 Dec7 (
		  .In(wOutput[31:28]),
		  .Out(oHEX7_D)
		  );

   // VGA Interface

   parameter VGAADDRESS = 32'h80000000; //em bytes

   VgaAdapterInterface VGAAI0 (
			       .iRST(~Reset),
			       .iCLK_50(iCLK_50),
			       .iCLK(CLK),
			       .iMemWrite(MemWrite),
			       .iwMemAddress(wMemAddress),
			       .iwMemWriteData(wMemWriteData),
			       .oMemReadData(wMemReadVGA),
			       .oVGA_R(oVGA_R),
			       .oVGA_G(oVGA_G),
			       .oVGA_B(oVGA_B),
			       .oVGA_HS(oVGA_HS),
			       .oVGA_VS(oVGA_VS),
			       .oVGA_BLANK(oVGA_BLANK_N),
			       .oVGA_SYNC(oVGA_SYNC_N),
			       .oVGA_CLK(oVGA_CLOCK));


   //  Audio In/Out Interface

   // reset delay gives some time for peripherals to initialize
   wire DLY_RST;
   Reset_Delay r0(	.iCLK(iCLK_50),.oRESET(DLY_RST) );

   assign	oTD1_RESET_N = 1'b1;  // Enable 27 MHz

   wire AUD_CTRL_CLK;

   VGA_Audio_PLL	p1 (
				.areset(~DLY_RST),
				.inclk0(iCLK_28),
				.c0(),
				.c1(AUD_CTRL_CLK),
				.c2()
				);

   I2C_AV_Config u3(
			//	Host Side
			.iCLK(iCLK_50),
			.iRST_N(~Reset),
			//	I2C Side
			.I2C_SCLK(oI2C_SCLK),
			.I2C_SDAT(I2C_SDAT)
			);

   assign	AUD_ADCLRCK	=	AUD_DACLRCK;
   assign	oAUD_XCK	=	AUD_CTRL_CLK;

   audio_clock u4(
			//	Audio Side
			.oAUD_BCK(AUD_BCLK),
			.oAUD_LRCK(AUD_DACLRCK),
			//	Control Signals
			.iCLK_18_4(AUD_CTRL_CLK),
			.iRST_N(DLY_RST)
			);


   /* CODEC AUDIO */

   audio_converter u5(
		      // Audio side
		      .AUD_BCK(AUD_BCLK),	// Audio bit clock
		      .AUD_LRCK(AUD_DACLRCK), // left-right clock
		      .AUD_ADCDAT(iAUD_ADCDAT),
		      .AUD_DATA(oAUD_DACDAT),
		      // Controller side
		      .iRST_N(DLY_RST),	 // reset
		      .AUD_outL(audio_outL),
		      .AUD_outR(audio_outR),

		      .AUD_inL(audio_inL),
		      .AUD_inR(audio_inR)
		      );

   wire [15:0] audio_inL, audio_inR;
   reg [15:0]  audio_outL,audio_outR;
   reg [31:0]  wAudioCodecData;

   reg [31:0]  waudio_inL ,waudio_inR;
   reg [31:0]  waudio_outL, waudio_outR;
   reg [31:0]  Ctrl1,Ctrl2;

   /* Endereco dos registradores do CODEC na memoria*/
   parameter	INRDATA=32'h40000000,  INLDATA=32'h40000004,
     OUTRDATA=32'h40000008, OUTLDATA=32'h4000000c,
     CTRL1=32'h40000010,    CTRL2=32'h40000014;
   initial
     begin
	waudio_inL<=32'b0;
	waudio_inR<=32'b0;
	waudio_outL<=32'b0;
	waudio_outR<=32'b0;
	Ctrl1<=32'b0;
	Ctrl2<=32'b0;
     end

   always @(negedge AUD_DACLRCK)
     begin
	if(Ctrl2[0]==0)
	  begin
	     waudio_inR<= {16'b0,audio_inR};
	     audio_outR = waudio_outR[15:0];
	     Ctrl1[0]<=1'b1;
	  end
	else
	  Ctrl1[0]<=1'b0;
     end

   always @(posedge AUD_DACLRCK)
     begin
	if(Ctrl2[1]==0)
	  begin
	     waudio_inL = {16'b0,audio_inL};
	     audio_outL = waudio_outL[15:0];
	     Ctrl1[1]<=1'b1;
	  end
	else
	  Ctrl1[1]<=1'b0;
     end


   always @(posedge CLK)
     if(MemWrite) //Escrita no dispositivo de бudio
       begin
	  case (wMemAddress)
	    OUTRDATA: waudio_outR <= wMemWriteData;
	    OUTLDATA: waudio_outL <= wMemWriteData;
	    CTRL2:    Ctrl2 <= wMemWriteData;
	  endcase
       end


   // Teclado PS2

   wire [7:0] PS2scan_code;
   reg [7:0]  PS2history[1:8]; // buffer de 8 bytes
   wire	      PS2read, PS2scan_ready;


   /* Enderecos na memуria do Buffer de leitura do Teclado */
   parameter	BUFFER0=32'h40000020,
     BUFFER1=32'h40000024;

   oneshot pulser(
		  .pulse_out(PS2read),
		  .trigger_in(PS2scan_ready),
		  .clk(iCLK_50)
		  );

   keyboard kbd(
		.keyboard_clk(PS2_KBCLK),
		.keyboard_data(PS2_KBDAT),
		.clock50(iCLK_50),
		.reset(Reset),
		.read(PS2read),
		.scan_ready(PS2scan_ready),
		.scan_code(PS2scan_code)
		);

   always @(posedge PS2scan_ready, posedge Reset)
     begin
	if(Reset)
	  begin
	     PS2history[8] <= 0;
	     PS2history[7] <= 0;
	     PS2history[6] <= 0;
	     PS2history[5] <= 0;
	     PS2history[4] <= 0;
	     PS2history[3] <= 0;
	     PS2history[2] <= 0;
	     PS2history[1] <= 0;
	  end
	else
	  begin
	     PS2history[8] <= PS2history[7];
	     PS2history[7] <= PS2history[6];
	     PS2history[6] <= PS2history[5];
	     PS2history[5] <= PS2history[4];
	     PS2history[4] <= PS2history[3];
	     PS2history[3] <= PS2history[2];
	     PS2history[2] <= PS2history[1];
	     PS2history[1] <= PS2scan_code;
	  end
     end


   // LCD

   parameter LIMPA  = 32'h70000020;  //Endereco de limpar o display
   parameter LINHA1 = 32'h70000000;
   parameter LINHA2 = 32'h70000010;

   /*	LCD ON */
   assign	oLCD_ON		=	1'b1;
   assign	oLCD_BLON	=	1'b1;

   wire [7:0] oLeituraLCD;

   LCDStateMachine LCDSM0 (
			   .iCLK(iCLK_50),
			   .iRST(Reset),
			   .LCD_DATA(LCD_D),
			   .LCD_RW(oLCD_RW),
			   .LCD_EN(oLCD_EN),
			   .LCD_RS(oLCD_RS),
			   .iMemAddress(wMemAddress),
			   .iMemWriteData(wMemWriteData),
			   .iMemWrite(MemWrite),
			   .oLeitura(oLeituraLCD)
			   );



   /* acesso para leitura dos endereзos da memуria  MMIO
    a gravaзгo eh feita no proprio dispositivo acima */

   // This always happens, during every moment possible.
   always @(*)
     if(MemRead)  //Leitura dos dispositivos
       if(wMemAddress>=VGAADDRESS)
	 //VGA
	 wAudioCodecData <= wMemReadVGA;
       else
	 if(wMemAddress>=LINHA1 && wMemAddress <LIMPA)
	   //LCD
	   wAudioCodecData<={24'b0,oLeituraLCD};
	 else
	   begin
	      case (wMemAddress)
		//Audio
		INRDATA:  wAudioCodecData <= waudio_inR;
		OUTRDATA: wAudioCodecData <= waudio_outR;
		INLDATA:  wAudioCodecData <= waudio_inL;
		OUTLDATA: wAudioCodecData <= waudio_outL;
		CTRL1:	  wAudioCodecData <= Ctrl1;
		CTRL2:	  wAudioCodecData <= Ctrl2;
		//PS2
		BUFFER0:  wAudioCodecData <= {PS2history[4],PS2history[3],PS2history[2],PS2history[1]};
		BUFFER1:  wAudioCodecData <= {PS2history[8],PS2history[7],PS2history[6],PS2history[5]};
		default:  wAudioCodecData <= 32'b0;
	      endcase
	   end
     else
       wAudioCodecData <= 32'b0;


endmodule
