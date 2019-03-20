module delay_calc(
	input [7:0] snake_size,
	input [27:0] base_ticks,
	output [27:0] delay_max
	);

	assign delay_max = base_ticks - (snake_size * 40_000);
	
endmodule
