module LCDStateMachine (iCLK, iRST, LCD_DATA, LCD_RW, LCD_EN, LCD_RS,
	iMemAddress, iMemWriteData, iMemWrite, oLeitura);

parameter LIMPA  = 32'h70000020;  //Endereco de limpar tudo
parameter LINHA1 = 32'h70000000;
parameter LINHA2 = 32'h70000010;
/*
 * I/O type definition
 */
/* Host Side */
input iCLK, iRST, iMemWrite;
input [31:0] iMemAddress, iMemWriteData;
/* LCD Side */
output [7:0] LCD_DATA, oLeitura;
output LCD_RW, LCD_EN, LCD_RS;

/* Internal Wires/Registers */
reg [1:0] mLCD_ST;
reg [17:0] mDLY;
reg mLCD_Start, mLCD_RS, mLCD_Done, Busy;
reg [7:0] mLCD_DATA;

/* Registers and parameters to aid in the initialization */
reg mRESET_ST;
reg [5:0] mINIT_CONT_POS;
parameter INIT_CONT_SIZE = 36;

/* Data source selection */
wire [8:0] content;
assign content = mRESET_ST ? mINIT_CONT(mINIT_CONT_POS)
	: ContentDisplay;

reg [7:0] MemContentDisplay [0:31];
reg	Modified, ModifiedAux, Verified;
reg	Clean;
integer Position;

reg [8:0] ContentDisplay;
reg [2:0] State;
reg	Activate;

integer i;

initial
begin
	mLCD_ST		<=	0;
	mDLY		<=	0;
	mLCD_Start	<=	0;
	mLCD_DATA	<=	0;
	mLCD_RS		<=	0;
	Busy	<=  1'b1;
	/* We start in the reset state */
	mRESET_ST	<=	1;
	mINIT_CONT_POS	<=	0;

	State		<= 0;
	Activate	<= 1'b0;
	ContentDisplay	<= 8'b0;
	for (i = 0; i < 32; i=i+1)
	begin
		MemContentDisplay[i] <= 8'h20;
	end
	Modified	<= 1'b0;
	ModifiedAux	<= 1'b0;
	Clean		<= 1'b0;
	Verified	<= 1'b0;
end

assign	oLeitura = MemContentDisplay[iMemAddress[4:0]];

always@(posedge iCLK)
begin
	if(iRST)
	begin
		mRESET_ST <=1'b1;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
		Busy	<=  1'b1;
		mRESET_ST	<=	1;
		mINIT_CONT_POS	<=	0;
	end
	else
	case(mLCD_ST)
		0:
		begin
			if (mRESET_ST || Activate)
			begin
				Busy	<=  1'b1;
				mLCD_DATA	<=	content[7:0];
				mLCD_RS		<=	content[8];
				mLCD_Start	<=	1;
				mLCD_ST		<=	1;
			end
		end
		1:
		begin
			if(mLCD_Done)
			begin
				mLCD_Start	<=	0;
				mLCD_ST		<=	2;
			end
		end
		2:
		begin
			if(mDLY<18'h3FFFE)
				mDLY	<=	mDLY + 18'b1;
			else
			begin
				mDLY	<=	0;
				mLCD_ST	<=	3;
			end
		end
		3:
		begin
			/* Checks if we just finished initializing */
			if ((mRESET_ST)&&(mINIT_CONT_POS < INIT_CONT_SIZE))
			begin
				mINIT_CONT_POS <= mINIT_CONT_POS + 6'b1;
			end
			else
			begin
				mRESET_ST	<= 1'b0;
				Busy	<= 1'b0;
			end
			mLCD_ST	<= 0;
		end
	endcase
end

always @(posedge iCLK)
begin
	if(iRST)
	begin
		State		<= 0;
		Activate	<= 1'b0;
		ContentDisplay	<= 8'b0;
		end
	else
	if (!Busy)
	begin
		case (State)
			0: begin // Estado inicial
				if (Clean)
				begin
					Modified	<= ModifiedAux;
					State		<= 1;
					ContentDisplay	<= 9'h001;
					Activate	<= 1'b1;
				end
				else if (Modified != ModifiedAux)
				begin
					Modified	<= ModifiedAux;
					State		<= 2;
					Activate	<= 1'b1;
					ContentDisplay	<= 9'h006; // Define a direção do cursor
					Position		<= 0;
				end
			end
			1: begin // Estado auxiliar de limpeza de tela
				Activate <= 1'b0;
				State		<= 0;
			end
			2: begin
				ContentDisplay	<= 9'h080; // Posição da primeira linha
				Activate	<= 1'b1;
				State		<= 3;
			end
			3: begin // Estado de escrita da primeira linha
				if (Position < 16)
				begin
					Position		<= Position + 1;
					ContentDisplay	<= {1'b1,MemContentDisplay[Position[4:0]]};
					Activate	<= 1'b1;
				end
				else
				begin
					// Muda de linha
					ContentDisplay	<= 9'h0C0; // Posição da segunda linha
					Activate	<= 1'b1;
					State		<= 4;
				end
			end
			4: begin // Estado de escrita da segunda linha
				if (Position < 32)
				begin
					Position		<= Position + 1;
					ContentDisplay	<= {1'b1,MemContentDisplay[Position[4:0]]};
					Activate	<= 1'b1;
				end
				else
				begin
					// Termina a gravação
					Activate	<= 1'b0;
					State		<= 0;
				end
			end
			default: State	<= 0;
		endcase
	end
end

// Define os registradores de gravação
always @(posedge iCLK)
begin
	if(iRST)
	begin
		for (i = 0; i < 32; i=i+1)
		begin
			MemContentDisplay[i] <= 8'h20;
		end
		ModifiedAux	<= 1'b0;
		Clean		<= 1'b0;
		Verified	<= 1'b0;
		end
	else
	if (iMemWrite && !Verified)
	begin
		Verified <= 1'b1;
		if (iMemAddress == LIMPA)
		begin
			Clean <= 1'b1;
			// Se vamos Clean o display, não vamos escrever em cima!
			for (i = 0; i < 32; i=i+1)
			begin
				MemContentDisplay[i] <= 8'h20;
			end
		end
		else if (iMemAddress >= LINHA1 && iMemAddress < LIMPA)
		begin
			MemContentDisplay[iMemAddress[4:0]] <= iMemWriteData[7:0];
			if (Modified == ModifiedAux)
				ModifiedAux	<=	~ModifiedAux;
			// Se vamos escrever, não vamos Clean!
			Clean <= 1'b0;
		end
	end
	else
	begin
		Verified <= 1'b0;
	end
end

/* Initialization table */
function [8:0] mINIT_CONT;
	input [5:0] mINIT_CONT_POS;
	case(mINIT_CONT_POS)
	//	Initial
	0:	mINIT_CONT =	9'h038; // Function set: Datalength = 8-bit, 2 lines, 5x8 dots
	1:	mINIT_CONT =	9'h00C; // Display cursor ON
	//	UnB logo definition
	2:	mINIT_CONT =	9'h040; // Set CGRAM Address to 0
	//	First part
	3:	mINIT_CONT =	9'h11F;
	4:	mINIT_CONT =	9'h107;
	5:	mINIT_CONT =	9'h119;
	6:	mINIT_CONT =	9'h11E;
	7:	mINIT_CONT =	9'h11F;
	8:	mINIT_CONT =	9'h11F;
	9:	mINIT_CONT =	9'h11F;
	10:	mINIT_CONT =	9'h100;
	//	Second part
	11:	mINIT_CONT =	9'h11F;
	12:	mINIT_CONT =	9'h11F;
	13:	mINIT_CONT =	9'h11F;
	14:	mINIT_CONT =	9'h10F;
	15:	mINIT_CONT =	9'h110;
	16:	mINIT_CONT =	9'h11F;
	17:	mINIT_CONT =	9'h11F;
	18:	mINIT_CONT =	9'h100;
	//	Third part
	19:	mINIT_CONT =	9'h11F;
	20:	mINIT_CONT =	9'h11F;
	21:	mINIT_CONT =	9'h11F;
	22:	mINIT_CONT =	9'h11E;
	23:	mINIT_CONT =	9'h101;
	24:	mINIT_CONT =	9'h11F;
	25:	mINIT_CONT =	9'h11F;
	26:	mINIT_CONT =	9'h100;
	//	Fourth part
	27:	mINIT_CONT =	9'h11F;
	28:	mINIT_CONT =	9'h11C;
	29:	mINIT_CONT =	9'h113;
	30:	mINIT_CONT =	9'h10F;
	31:	mINIT_CONT =	9'h11F;
	32:	mINIT_CONT =	9'h11F;
	33:	mINIT_CONT =	9'h11F;
	34:	mINIT_CONT =	9'h100;
	//	Continuing with the display configuration
	35:	mINIT_CONT =	9'h001; // Clear display
	36:	mINIT_CONT =	9'h00C; // Sets the cursor ON (9'h00F) or OFF (9'h000) 
	default: mINIT_CONT = 	9'h000;
	endcase
endfunction

/* Module instantiation */
LCDController LCDCont0 (
	.iDATA(mLCD_DATA),
	.iRS(mLCD_RS),
	.iStart(mLCD_Start),
	.oDone(mLCD_Done),
	.iCLK(iCLK),
	.LCD_DATA(LCD_DATA),
	.LCD_RW(LCD_RW),
	.LCD_EN(LCD_EN),
	.LCD_RS(LCD_RS)
	);

endmodule
