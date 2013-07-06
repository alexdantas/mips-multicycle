/* FP ALU operations*/
parameter 	OPADDS	= 4'b0001,	//1
			OPSUBS	= 4'b0010,	//2
			OPMULS	= 4'b0011,	//3
			OPDIVS	= 4'b0100,	//4
			OPSQRT	= 4'b0101,	//5
			OPABS	= 4'b0110,	//6
			OPNEG	= 4'b0111,	//7
			OPCEQ	= 4'b1000,	//8
			OPCLT	= 4'b1001,	//9
			OPCLE	= 4'b1010,	//10
			OPCVTSW	= 4'b1011,	//11
			OPCVTWS	= 4'b1100;	//12
			