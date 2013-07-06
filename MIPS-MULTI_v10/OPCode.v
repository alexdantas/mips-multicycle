// "#defines" to simplify the naming of the opcode field.
//
// They translate an opcode to a instruction name.

parameter	OPCRFMT		= 6'h00, // R-format instruction
			OPCJMP		= 6'h02, // j
			OPCJAL		= 6'h03, // jal
			OPCBEQ		= 6'h04, // beq
			OPCBNE		= 6'h05, // you can figure out the rest
			OPCADDI 	= 6'h08,
			OPCADDIU 	= 6'h09,
			OPCSLTI		= 6'h0A,
			OPCSLTIU 	= 6'h0B,
			OPCANDI		= 6'h0C,
			OPCORI		= 6'h0D,
			OPCXORI		= 6'h0E,
			OPCLUI		= 6'h0F,
//			OPCJRCLR	= 6'h1C,
			OPCLW		= 6'h23,
			OPCSW		= 6'h2B,
			OPCLWC1		= 6'h31,
			OPCSWC1		= 6'h39,
			OPCFLT		= 6'h11; // Floating Point Instructions
