module random_debug(LEDR, CLOCK_50, KEY);
/*
	Code example of how to use the random module.
	r_out will be a constant stream of numbers, changing at the speed of the clock input
	Therefore, you must make a register to store a given value indefinetely
*/
input CLOCK_50;
input [3:0]KEY;
output [7:0]LEDR;

reg [7:0]number;
wire [7:0]r_out;

assign LEDR = number;

	random random(
		.clock(CLOCK_50),
		.max_number(8'd255),
		.num_out(r_out)
	);
	
	
	always @(negedge ~KEY[0])
	begin
		number <= r_out;
	end



endmodule