module score_text (
    output [209:0] OUT
    //input [0:0] SELECT
	);

	//reg [5:0] pixels;
	assign OUT[34:0] = 35'b01111100011111001111000111100011100;// 35'b00111000111100011110011111000111110;
	assign OUT[69:35] = 35'b00000100100001010000100100010000010;//35'b01000001000100100001010000100100000;
	assign OUT[104:70] = 35'b00011100011111010000100000010001100;//35'b00110001000000100001011111000111000;
	assign OUT[139:105] = 35'b00000100001001010000100000010010000;//35'b00001001000000100001010010000100000;
	assign OUT[174:140] = 35'b00000100010001010000100100010010000;//35'b00001001000100100001010001000100000;
	assign OUT[209:175] = 35'b01111100100001001111000111100001110;//35'b01110000111100011110010000100111110;

	//always @(*)
	//    begin
	////        case(IN[0])
	////            1'b1:
	////                begin
	//                    pixels[0] = 35'b00111000111100011110011111000111110;
	//                    pixels[1] = 35'b01000001000100100001010000100100000;
	//                    pixels[2] = 35'b00110001000000100001011111000111000;
	//                    pixels[3] = 35'b00001001000000100001010010000100000;
	//                    pixels[4] = 35'b00001001000100100001010001000100000;
	//                    pixels[5] = 35'b01110000111100011110010000100111110;
	////                end
	////        endcase
	//    end
endmodule