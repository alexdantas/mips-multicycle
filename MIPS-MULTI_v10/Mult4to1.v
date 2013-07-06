/*
 * Mult4to1
 *
 * 4 to 1 multiplexer.
 */
module Mult4to1 (i0, i1, i2, i3, iSelect, oSelected);

/* I/O type definition */
input wire [31:0] i0, i1, i2, i3;
input wire [1:0] iSelect;
output reg [31:0] oSelected;

/* Output selection */
always @(i0 or i1 or i2 or i3 or iSelect)
begin
	case (iSelect)
		2'b00:	oSelected <= i0;
		2'b01:	oSelected <= i1;
		2'b10:	oSelected <= i2;
		2'b11:	oSelected <= i3;
	endcase
end

endmodule

