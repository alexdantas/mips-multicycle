module ula_fp (iclock, idataa, idatab, icontrol, oresult, onan, ozero, ooverflow, ounderflow, oCompResult);

`include "FPALUOP.v"

input iclock;
input [31:0] idataa,idatab;
input [3:0] icontrol;
output reg [31:0] oresult;
output reg onan, ozero, ooverflow, ounderflow;
output wire oCompResult; //Usado no banco de flags

integer i;

// Para a operacao add
wire [31:0] resultadd;
wire nanadd,zeroadd,overflowadd,underflowadd;

// Para a operacao sub
wire [31:0] resultsub;
wire nansub,zerosub,overflowsub,underflowsub;

// Para a operacao mul
wire [31:0] resultmul;
wire nanmul,zeromul,overflowmul,underflowmul;

// Para a operacao div
wire [31:0] resultdiv;
wire nandiv,zerodiv,overflowdiv,underflowdiv;
	
// Para a operacao sqrt
wire [31:0] resultsqrt;
wire nansqrt,zerosqrt,overflowsqrt,underflowsqrt;

// Para a operacao abs
wire [31:0] resultabs;
wire nanabs,zeroabs,overflowabs,underflowabs;

// Para a operacao compara_equal
wire resultc_eq;

// Para a operacao compara_menor
wire resultc_lt;

// Para a operacao compara_menorigual
wire resultc_le;

// Para a operacao converte simples_word
wire [31:0] resultcvt_s_w;

// Para a operacao converte word_simples
wire [31:0] resultcvt_w_s;
wire nancvt_w_s,zerocvt_w_s,overflowcvt_w_s,underflowcvt_w_s;

always @(icontrol,idataa,idatab)  //cuidar ciclos de atraso
	begin
		case (icontrol) 
			OPADDS:		//soma
			begin
				oresult <= resultadd;
				onan <= nanadd;
				ozero <= zeroadd;
				ooverflow <= overflowadd;
				ounderflow <= underflowadd;
				oCompResult <= 1'b0;
			end

			// Outras operacoes
			OPSUBS:		//subtracao
			begin
				oresult <= resultsub;
				onan <= nansub;
				ozero <= zerosub;
				ooverflow <= overflowsub;
				ounderflow <= underflowsub;
				oCompResult <= 1'b0;
			end
			
			OPMULS:		//mult
			begin
				oresult <= resultmul;
				onan <= nanmul;
				ozero <= zeromul;
				ooverflow <= overflowmul;
				ounderflow <= underflowmul;
				oCompResult <= 1'b0;
			end

			OPDIVS:		//div
			begin
				oresult <= resultdiv;
				onan <= nandiv;
				ozero <= zerodiv;
				ooverflow <= overflowdiv;
				ounderflow <= underflowdiv;
				oCompResult <= 1'b0;
			end

			OPSQRT:		//sqrt
			begin
				oresult <= resultsqrt;
				onan <= nansqrt;
				ozero <= zerosqrt;
				ooverflow <= overflowsqrt;
				ounderflow <= underflowsqrt;
				oCompResult <= 1'b0;
			end

			OPABS:		//abs
			begin
				oresult <= resultabs;
				onan <= nanabs;
				ozero <= zeroabs;
				ooverflow <= overflowabs;
				ounderflow <= underflowabs;
				oCompResult <= 1'b0;
			end
			
			OPNEG:		//neg
			begin
				oresult[31] <= ~idataa[31];
				oresult[30:0] <= idataa[30:0];
				oCompResult <= 1'b0;
			end

			OPCEQ:		//c_eq
			begin
				oresult <= 32'b0;
				oCompResult <= resultc_eq;
			end

			OPCLT:		//c_lt
			begin
				oresult <= 32'b0;
				oCompResult <= resultc_lt;
			end
			
			OPCLE:		//c_le
			begin
				oresult <= 32'b0;
				oCompResult <= resultc_le;
			end

			OPCVTSW:		//cvt_s_w
			begin
				oresult <= resultcvt_s_w;
				oCompResult <= 1'b0;
			end

			OPCVTWS:		//cvt_w_s
			begin
				oresult <= resultcvt_w_s;
				onan <= nancvt_w_s;
				ozero <= zerocvt_w_s;
				ooverflow <= overflowcvt_w_s;
				ounderflow <= underflowcvt_w_s;
				oCompResult <= 1'b0;
				
			end

			default
			begin
				oresult <= 32'h0;
				onan <= 1'b0;
				ozero <= 1'b0;
				ooverflow <= 1'b0;
				ounderflow <= 1'b0;
				oCompResult <= 1'b0;
			end
		endcase
	end
	

add_sub add1 (	
	.add_sub(1'b1),	
	.clock(iclock),
	.dataa(idataa),
	.datab(idatab),
	.nan(nanadd),
	.overflow(overflowadd),
	.result(resultadd),
	.underflow(underflowadd),
	.zero(zeroadd));

add_sub sub1 (	
	.add_sub(1'b0),	
	.clock(iclock),
	.dataa(idataa),
	.datab(idatab),
	.nan(nansub),
	.overflow(overflowsub),
	.result(resultsub),
	.underflow(underflowsub),
	.zero(zerosub));
	
mul_s mul1 (
	.clock(iclock),
	.dataa(idataa),
	.datab(idatab),
	.nan(nanmul),
	.overflow(overflowmul),
	.result(resultmul),
	.underflow(underflowmul),
	.zero(zeromul));
	
div_s div1 (
	.clock(iclock),
	.dataa(idataa),
	.datab(idatab),
	.nan(nandiv),
	.overflow(overflowdiv),
	.result(resultdiv),
	.underflow(underflowdiv),
	.zero(zerodiv));

sqrt_s sqrt1 (
	.clock(iclock),
	.data(idataa),
	.nan(nansqrt),
	.overflow(overflowsqrt),
	.result(resultsqrt),
	.zero(zerosqrt));
	
abs_s abs1 (
	.data(idataa),
	.nan(nanabs),
	.overflow(overflowabs),
	.result(resultabs),
	.underflow(underflowabs),
	.zero(zeroabs));
	
c_eq_s c_eq1 (
	.clock (iclock),
	.dataa (idataa),
	.datab (idatab),
	.aeb (resultc_eq));

c_lt_s c_lt1 (
	.clock (iclock),
	.dataa (idataa),
	.datab (idatab),
	.alb (resultc_lt));

c_le_s c_le1 (
	.clock (iclock),
	.dataa (idataa),
	.datab (idatab),
	.aleb (resultc_le));

cvt_s_w cvt_s_w1 (
	.clock (iclock),
	.dataa (idataa),
	.result (resultcvt_s_w));
	
cvt_w_s cvt_w_s1 (
	.clock (iclock),
	.dataa (idataa),
	.nan (nancvt_w_s),
	.overflow (overflowcvt_w_s),
	.result (resultcvt_w_s),
	.underflow (underflowcvt_w_s));

endmodule
