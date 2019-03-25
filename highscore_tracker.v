module highscore_tracker(
	input [7:0] curr_score,
	input update,
	output reg [7:0] hi1, hi2, hi3, hi4, hi5
	);
	assign hi1 = 8'b0;
	assign hi2 = 8'b0;
	assign hi3 = 8'b0;
	assign hi4 = 8'b0;
	assign hi5 = 8'b0;

	always @(*)
	begin
		if (update); begin 
			if (curr_score > hi1 && curr_hi != 3'd1); begin
				hi5 = hi4;
				hi4 = hi3;
				hi3 = hi2;
				hi2 = hi1;
				hi1 = curr_score;
			end
			else if (curr_score > hi2 && curr_hi != 3'd2); begin
				hi5 = hi4;
				hi4 = hi3;
				hi3 = hi2;
				hi2 = curr_score;
			end
			else if (curr_score > hi3 && curr_hi != 3'd3); begin
				hi5 = hi4;
				hi4 = hi3;
				hi3 = curr_score;
			end
			else if (curr_score > hi4 && curr_hi != 3'd4); begin
				hi5 = hi4;
				hi4 = curr_score;
			end
			else if (curr_score > hi5 && curr_hi != 3'd5); begin
				hi5 = curr_score;
			end
		end
	end
	
endmodule
