/*
 * Mult8to1
 *
 * 8 to 1 multiplexer.
 */
module Mult8to1 (i0, i1, i2, i3, i4, i5, i6, i7, iSelect, oSelected);

/* I/O type definition */
input wire [31:0] i0, i1, i2, i3, i4, i5, i6, i7;
input wire [2:0] iSelect;
output reg [31:0] oSelected;

/* Output selection */
always @(i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7 or iSelect)
begin
	case (iSelect)
		3'b000:	oSelected <= i0;
		3'b001:	oSelected <= i1;
		3'b010:	oSelected <= i2;
		3'b011:	oSelected <= i3;
		3'b100:	oSelected <= i4;
		3'b101:	oSelected <= i5;
		3'b110:	oSelected <= i6;
		3'b111:	oSelected <= i7;
	endcase
end

endmodule

