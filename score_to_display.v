module score_to_display(
    output [89:0] score_display,
    input [7:0] score_input
);

	wire [29:0] digit_2, digit_1, digit_0;
	reg [3:0] value_2, value_1, value_0;
	
	// get the value of each digit
	always @(*)
	begin
		 value_2 <= (score_input / 100) % 10;
		 value_1 <= (score_input / 10) % 10;
		 value_0 <= score_input % 10 ;
	end

	// get the pixel information for each digit
	digit_decoder decoder_2 (
		 .OUT(digit_2),
		 .IN(value_2)
	);

	digit_decoder decoder_1 (
		 .OUT(digit_1),
		 .IN(value_1)
	);

	digit_decoder decoder_0 (
		 .OUT(digit_0),
		 .IN(value_0)
	);

	// put all the digits together
	assign score_display = {digit_0, digit_1, digit_2};

endmodule

module digit_decoder(
		 output [29:0] OUT,
		 input [3:0] IN
	);
	reg [29:0] pixels;

	assign OUT[5:0] = pixels[5:0];
	assign OUT[11:6] = pixels[11:6];
	assign OUT[17:12] = pixels[17:12];
	assign OUT[23:18] = pixels[23:18];
	assign OUT[29:24] = pixels[29:24];

	// pixel information to make a 5x6 representation of each digit
	always @(*)
   begin
	  case(IN[3:0])
			4'b0000: // 0
				 begin
					  pixels[5:0] 		= 6'b001100;
					  pixels[11:6] 	= 6'b010010;
					  pixels[17:12] 	= 6'b011010;
					  pixels[23:18] 	= 6'b010110;
					  pixels[29:24] 	= 6'b001100;
				 end
			4'b0001: // 1
				 begin
					  pixels[5:0] 		= 6'b000100;
					  pixels[11:6] 	= 6'b000110;
					  pixels[17:12] 	= 6'b000100;
					  pixels[23:18] 	= 6'b000100;
					  pixels[29:24] 	= 6'b001110;
				 end
			4'b0010: // 2
				 begin
					  pixels[5:0] 		= 6'b001100;
					  pixels[11:6] 	= 6'b010010;
					  pixels[17:12] 	= 6'b001000;
					  pixels[23:18] 	= 6'b000100;
					  pixels[29:24] 	= 6'b011110;
				 end
			4'b0011: // 3
				 begin
					  pixels[5:0] 		= 6'b001100;
					  pixels[11:6] 	= 6'b010010;
					  pixels[17:12] 	= 6'b001000;
					  pixels[23:18] 	= 6'b010010;
					  pixels[29:24] 	= 6'b001100;
				 end
			4'b0100: // 4
				 begin
					  pixels[5:0] 		= 6'b001000;
					  pixels[11:6] 	= 6'b001100;
					  pixels[17:12] 	= 6'b001010;
					  pixels[23:18] 	= 6'b011110;
					  pixels[29:24] 	= 6'b001000;
				 end
			4'b0101: // 5
				 begin
					  pixels[5:0] 		= 6'b001110;
					  pixels[11:6] 	= 6'b000010;
					  pixels[17:12] 	= 6'b001100;
					  pixels[23:18] 	= 6'b010000;
					  pixels[29:24] 	= 6'b001100;
				 end
			4'b0110: // 6
				 begin
					  pixels[5:0] 		= 6'b001100;
					  pixels[11:6] 	= 6'b000010;
					  pixels[17:12] 	= 6'b001110;
					  pixels[23:18] 	= 6'b010010;
					  pixels[29:24] 	= 6'b001100;
				 end
			4'b0111: // 7
				 begin
					  pixels[5:0] 		= 6'b011110;
					  pixels[11:6] 	= 6'b010010;
					  pixels[17:12] 	= 6'b001000;
					  pixels[23:18] 	= 6'b000100;
					  pixels[29:24] 	= 6'b000100;
				 end
			4'b1000: // 8
				 begin
					  pixels[5:0] 		= 6'b001100;
					  pixels[11:6] 	= 6'b010010;
					  pixels[17:12] 	= 6'b001100;
					  pixels[23:18] 	= 6'b010010;
					  pixels[29:24] 	= 6'b001100;
				 end
			4'b1001: // 9
				 begin
					  pixels[5:0] 		= 6'b001100;
					  pixels[11:6] 	= 6'b010010;
					  pixels[17:12] 	= 6'b011100;
					  pixels[23:18] 	= 6'b010000;
					  pixels[29:24] 	= 6'b001100;
				 end
			default: pixels[29:0] 	= 29'b0;
		endcase
    end
endmodule