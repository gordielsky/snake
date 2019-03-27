module highscore_tracker(
	input [7:0] curr_score,
	input update,
	output reg [7:0] hi1, hi2, hi3, hi4, hi5
	);

	// initialize all highscores at 0
	initial begin
		hi1 = 8'd141;
		hi2 = 8'd33;
		hi3 = 8'd20;
		hi4 = 8'd15;
		hi5 = 8'd11;
	end

	always @(*)
	begin
		if (update); begin 
			// you got top score
			if (curr_score > hi1) begin
				hi5 = hi4;
				hi4 = hi3;
				hi3 = hi2;
				hi2 = hi1;
				hi1 = curr_score;
			end
			// got 2nd best score
			else if (curr_score > hi2) begin
				hi5 = hi4;
				hi4 = hi3;
				hi3 = hi2;
				hi2 = curr_score;
			end
			// got the bronze
			else if (curr_score > hi3) begin
				hi5 = hi4;
				hi4 = hi3;
				hi3 = curr_score;
			end
			// at least you made 4th!
			else if (curr_score > hi4) begin
				hi5 = hi4;
				hi4 = curr_score;
			end
			// bottom of the highscores buddy. at least you made it somewhere
			else if (curr_score > hi5) begin
				hi5 = curr_score;
			end
		end
	end
	
endmodule
