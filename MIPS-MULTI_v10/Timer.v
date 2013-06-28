module Timer(iCLK, iRST, qHI, qLO);

input wire iCLK, iRST;
output wire [31:0] qHI, qLO;

reg [63:0] q;

assign qHI = q[63:32];
assign qLO = q[31:0];

initial
begin
	q <= 64'b0;
end

always @(posedge iCLK)
begin
	if(iRST)
		q <= 64'b0;
	else
		q <= q+1;
end

endmodule