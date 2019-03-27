module score_text (
    output [209:0] OUT
	);

	// pixel information to display the word score
	assign OUT[34:0] 		= 35'b01111100011111001111000111100011100;
	assign OUT[69:35] 	= 35'b00000100100001010000100100010000010;
	assign OUT[104:70] 	= 35'b00011100011111010000100000010001100;
	assign OUT[139:105] 	= 35'b00000100001001010000100000010010000;
	assign OUT[174:140] 	= 35'b00000100010001010000100100010010000;
	assign OUT[209:175] 	= 35'b01111100100001001111000111100001110;

endmodule

module highscore_text(
	output [489:0] OUT
	);
	
	// pixel information to display the word high
	assign OUT[34:0]		= 35'b00000100010001111001111100100010000;
	assign OUT[69:35]		= 35'b00000100010001001000010000100010000;
	assign OUT[104:70]	= 35'b00000100010000001000010000111110000;
	assign OUT[139:105]	= 35'b00000111110011101000010000100010000;
	assign OUT[174:140]	= 35'b00000100010001001000010000100010000;
	assign OUT[209:175]	= 35'b00000100010001111001111100100010000;
	
	//space in between the words
	assign OUT[244:210] 	= 35'b0;
	assign OUT[279:245] 	= 35'b0;
	
	// pixel information to display the word score
	assign OUT[314:280] 	= 35'b01111100011111001111000111100011100;
	assign OUT[349:315] 	= 35'b00000100100001010000100100010000010;
	assign OUT[384:350] 	= 35'b00011100011111010000100000010001100;
	assign OUT[419:385] 	= 35'b00000100001001010000100000010010000;
	assign OUT[454:420] 	= 35'b00000100010001010000100100010010000;
	assign OUT[489:455] 	= 35'b01111100100001001111000111100001110;
	
endmodule
