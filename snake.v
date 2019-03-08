module snake(
				input [17:0] SW,
				input [3:0] KEY,
				input CLOCK_50,
				
				output [17:0] LEDR,
				output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6,
				output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
				output [9:0] VGA_R, VGA_G, VGA_B
				);
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire plot;
	
endmodule
