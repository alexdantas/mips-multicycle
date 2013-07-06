module mono(clock, ctrl, clock_ctrl,rst);
input clock, ctrl;
output clock_ctrl;
input rst;

reg saida;
integer contador;

assign clock_ctrl = saida ? clock : 1'b0;

initial
	begin
		saida=0;
		contador=0;
	end
	
always @(posedge clock)
	begin

		if(rst)
			begin
				contador=0;
				saida=1;
			end
		
		if(saida)
			contador=contador+1;
		
		if(contador == 500000000)  //10 segundos
			begin
				saida=0;
				contador=0;
			end
		else
			if(ctrl)
				begin
					saida=1;
					contador = 0;
				end
	end
	
endmodule
