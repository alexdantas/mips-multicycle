// Names of all possible ALU operations.
//
// (think of them as #defines)

parameter	OPAND	= 4'b0000,	// 0
			OPOR	= 4'b0001,	// 1
			OPADD	= 4'b0010,	// 2
			OPMFHI	= 4'b0011,	// 3
			OPSLL	= 4'b0100,	// 4
			OPMFLO	= 4'b0101,	// 5
			OPSUB	= 4'b0110,	// 6
			OPSLT	= 4'b0111,	// 7
			OPSRL	= 4'b1000,	// 8
			OPSRA	= 4'b1001,	// 9
			OPXOR	= 4'b1010,	// 10
			OPSLTU 	= 4'b1011,	// 11
			OPNOR	= 4'b1100,	// 12
			OPMULT	= 4'b1101,	// 13
			OPDIV	= 4'b1110,	// 14
			OPLUI	= 4'b1111;	// 15

