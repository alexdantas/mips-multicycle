
module FlagBank (iCLK, iCLR, iFlag, iFlagWrite, iData, oFlags);

/*Definição I/O*/
input wire iCLK, iCLR, iFlagWrite, iData;
input wire [2:0] iFlag;
output reg [7:0] oFlags;

integer i;

initial begin
	for (i = 0; i < 8; i = i + 1)
	begin
		oFlags[i] <= 1'b0;
	end
end

/*Escrever a cada subida do clock*/
always @(posedge iCLK)
begin
	if (iCLR)
	begin
		for (i = 0; i < 7; i = i + 1)
		begin
			oFlags[i] = 1'b0;
		end
	end
	else if (iCLK && iFlagWrite)
	begin
		oFlags[iFlag] = iData;
	end
end

endmodule