// Names of the funct field operations.
//
// This eases the naming scheme of the operations.
// Basically, it translates the value of the `funct` into an operation.
//
// Format: FUN(operation)
//
// Example: FUNOR: operation OR

parameter	FUNSLL	= 6'h00,
			FUNSRL	= 6'h02,
			FUNSRA	= 6'h03,
			FUNJR	= 6'h08,
			FUNSYS	= 6'h0C,
			FUNMFHI	= 6'h10,
			FUNMFLO	= 6'h12,
			FUNMULT	= 6'h18,
			FUNDIV	= 6'h1A,
			FUNADD	= 6'h20,
			FUNADDU = 6'h21,
			FUNSUB	= 6'h22,
			FUNSUBU = 6'h23,
			FUNAND	= 6'h24,
			FUNOR	= 6'h25,
			FUNXOR	= 6'h26,
			FUNNOR	= 6'h27,
			FUNSLT	= 6'h2A,
			FUNSLTU = 6'h2B,

// Below are funct from Floating-Point operations.
			FUNADDS = 6'h0,
			FUNSUBS = 6'h1,
			FUNMULS = 6'h2,
			FUNDIVS = 6'h3,
			FUNSQRT = 6'h4,
			FUNABS  = 6'h5,
			FUNMOV	= 6'h6,
			FUNNEG  = 6'h7,
			FUNCEQ  = 6'h32,
			FUNCLT  = 6'h3c,
			FUNCLE  = 6'h3e,
			FUNCVTSW = 6'h20,
			FUNCVTWS = 6'h24;

