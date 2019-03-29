module game_overlay(
    output [2699:0] OUT, // adjust this accordingly
    input is_high_score,
    input is_win,
    input clock
);

    wire [699:0] game_over_text_wire, motivation_text_wire;
    wire [499:0] high_score_winner_wire;
    wire [199:0] line_break;

    assign line_break = 300'd0;

    game_over_text game_over (
        .OUT(game_over_text_wire)
    );

    high_score_winner_text high_score_winner (
        .OUT(high_score_winner_wire),
        .is_high_score(is_high_score),
        .is_win(is_win),
        .clock(clock)
    );

    motivation_text motivation (
        .OUT(motivation_text_wire),
        .is_high_score(is_high_score),
        .is_win(is_win),
        .clock(clock)
    );

    assign OUT = {high_score_winner_wire, line_break, motivation_text_wire, line_break, game_over_text_wire};

    
endmodule

module game_over_text(
    output [699:0] OUT
);

    assign OUT[99:0] 	= 100'b0000000000000000000000000000000000000000011111000000000000000000000000000000111110000000000000000000;
    assign OUT[199:100] = 100'b0000000000000000000000000000000000000000111111100000000000000000000000000000111111000000000000000000;
    assign OUT[299:200] = 100'b0000000000000000001111001111000000000000100000100000011100001110111000111100000001000000000000000000;
    assign OUT[399:300] = 100'b0000000000000000010011001000100110001000100000100000010010010011001001000000110001000000000000000000;
    assign OUT[499:400] = 100'b0000000000000000000011000111100110001000100000100000001110010011001001111000100001000000000000000000;
    assign OUT[599:500] = 100'b0000000000000000000011000000100001010000100000100000000010010011001001000100100001000000000000000000;
    assign OUT[699:600] = 100'b0000000000000000000011001111000000100000011111000000011100010011001001111000011110000000000000000000;

endmodule

module high_score_winner_text(
    output reg [499:0] OUT,
    input is_high_score,
    input is_win,
    input clock
);

    wire clear = 500'd0;

    always@(*)
    begin
        if(is_win)
            begin
                OUT[99:0] 		= 100'b0000000000000000000000000000000000000111101111010011010011010100010000000000000000000000000000000000;
                OUT[199:100] 	= 100'b0000000000000000000000000000000000001000100001010101010101010100010000000000000000000000000000000000;
                OUT[299:200] 	= 100'b0000000000000000000000000000000000000111100011011001011001010101010000000000000000000000000000000000;
                OUT[399:300] 	= 100'b0000000000000000000000000000000000000100100001010001010001010110110000000000000000000000000000000000;
                OUT[499:400] 	= 100'b0000000000000000000000000000000000001000101111010001010001010100010000000000000000000000000000000000;
            end
        else if(is_high_score)
            begin
                OUT[99:0] 		= 100'b0000000000000000000000011110001111001111000111000111000010001011110001001000100000000000000000000000;
                OUT[199:100] 	= 100'b0000000000000000000000000010010001010000101000100000100010001000001001001000100000000000000000000000;
                OUT[299:200] 	= 100'b0000000000000000000000001110001001010000100000100011000011111010001001001111100000000000000000000000;
                OUT[399:300] 	= 100'b0000000000000000000000000010010001010000101000100100000010001010001001001000100000000000000000000000;
                OUT[499:400] 	= 100'b0000000000000000000000011110100001001111000111000111100010001001110001001000100000000000000000000000;
            end
			else
				OUT = clear;
    end
endmodule

module motivation_text(
    output reg [699:0] OUT,
    input is_high_score,
    input is_win,
    input clock
);
    wire [1:0] random_3;

    random generator(
        .clock(clock),
        .max_number(2'b10),
        .num_out(random_3)
    );

    wire [699:0] motivation_1, motivation_2, motivation_3;
    wire [699:0] success_1, success_2, success_3;
    wire [699:0] win;

    // You're almost there!
    assign motivation_1[99:0] 	= 100'd0;
    assign motivation_1[199:100] = 100'b0000000000001000000000000000001001000001001100000000000001000000000000000010000000000010100000000000;
    assign motivation_1[299:200] = 100'b0000000000001011100111011100101011100011100010010001111101001110001110111010100100110001000000000000;
    assign motivation_1[399:300] = 100'b0000000000001011110001011101011001000001000100101010100101011100001110001000100101001001000000000000;
    assign motivation_1[499:400] = 100'b0000000000000010010001010101001001000001001000101010100101010010001010001000100101001001000000000000;
    assign motivation_1[599:500] = 100'b0000000000001011100001011101001010000010000110010010100101011100001110001000111000110001000000000000;
    assign motivation_1[699:600] = 100'd0;

    // Keep going!
    assign motivation_2[99:0] 	= 100'b0000000000000000000000000000100000000000010000000000000000000000000010010000000000000000000000000000;
    assign motivation_2[199:100] = 100'b0000000000000000000000000000100111000111000011001110000011101100111001010000000000000000000000000000;
    assign motivation_2[299:200] = 100'b0000000000000000000000000000100100101001010100101001000101101010101000110000000000000000000000000000;
    assign motivation_2[399:300] = 100'b0000000000000000000000000000000111001001010100101110000100100010001001010000000000000000000000000000;
    assign motivation_2[499:400] = 100'b0000000000000000000000000000100100001001010011001000000011101100111010010000000000000000000000000000;
    assign motivation_2[599:500] = 100'b0000000000000000000000000000000100000000000000001001000000100000000000000000000000000000000000000000;
    assign motivation_2[699:600] = 100'b0000000000000000000000000000000011000000000000000110000000000000000000000000000000000000000000000000;

    // You've got this!
    assign motivation_3[99:0] 	= 100'b000000000000000000000000010011001000100100001000000000000000000000000000000000010100000000000000000000000000;
    assign motivation_3[199:100] = 100'b000000000000000000000000010000100000101110011101001100001110000000010100100110001000000000000000000000000000;
    assign motivation_3[299:200] = 100'b000000000000000000000000010001001011100100001010101010001111010001000100101001001000000000000000000000000000;
    assign motivation_3[399:300] = 100'b000000000000000000000000000010001010100100001010101100001001001010000100101001001000000000000000000000000000;
    assign motivation_3[499:400] = 100'b000000000000000000000000010001101010101000010001001000001110000100000111000110001000000000000000000000000000;
    assign motivation_3[599:500] = 100'b000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000;
    assign motivation_3[699:600] = 100'b000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000;

    // Fantastic!
    assign success_1[99:0] 	= 100'd0;
    assign success_1[199:100] = 100'b0000000000000000000000000000010000001000000000000000000000000000000111110000000000000000000000000000;
    assign success_1[299:200] = 100'b0000000000000000000000000000010000000001001110000000010000000000000000010000000000000000000000000000;
    assign success_1[399:300] = 100'b0000000000000000000000000000010011001011100001001110111001111001110001110000000000000000000000000000;
    assign success_1[499:400] = 100'b0000000000000000000000000000010000101001000110011100010011001011100000010000000000000000000000000000;
    assign success_1[599:500] = 100'b0000000000000000000000000000000000101001001000010010010011001010010000010000000000000000000000000000;
    assign success_1[699:600] = 100'b0000000000000000000000000000010011001010000111011100100011001011100000010000000000000000000000000000;

    // Amazing!
    assign success_2[99:0] 	= 100'b0000000000000000000000000000000010000000000010000000000000000000110000000000000000000000000000000000;
    assign success_2[199:100] = 100'b0000000000000000000000000000000010011000111000111001110011011101001000000000000000000000000000000000;
    assign success_2[299:200] = 100'b0000000000000000000000000000000010010101001010100010000100100101111000000000000000000000000000000000;
    assign success_2[399:300] = 100'b0000000000000000000000000000000000011001001010001010010100100101001000000000000000000000000000000000;
    assign success_2[499:400] = 100'b0000000000000000000000000000000010010001001010111011100100100101001000000000000000000000000000000000;
    assign success_2[599:500] = 100'b0000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000;
    assign success_2[699:600] = 100'b0000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000;

    // Great!
    assign success_3[99:0] 	= 100'd0;
    assign success_3[199:100] = 100'b0000000000000000000000000000000000000100000000000000000000111110000000000000000000000000000000000000;
    assign success_3[299:200] = 100'b0000000000000000000000000000000000000100010000000000000000000001000000000000000000000000000000000000;
    assign success_3[399:300] = 100'b0000000000000000000000000000000000000100111011101110011110110001000000000000000000000000000000000000;
    assign success_3[499:400] = 100'b0000000000000000000000000000000000000100010111001111000010100001000000000000000000000000000000000000;
    assign success_3[599:500] = 100'b0000000000000000000000000000000000000000010100100001000010100001000000000000000000000000000000000000;
    assign success_3[699:600] = 100'b0000000000000000000000000000000000000100100111001110000010011110000000000000000000000000000000000000;

    // Unbelievable
    assign win[99:0] 	= 100'd0;
    assign win[199:100] = 100'b0000000000000000000000100000001000001000000000000000000101000000000010000001001000000000000000000000;
    assign win[299:200] = 100'b0000000000000000000000100000001000001000000000000000000001000000000010000001001000000000000000000000;
    assign win[399:300] = 100'b0000000000000000000000100111001001101001111000000011100101011100011010011101001000000000000000000000;
    assign win[499:400] = 100'b0000000000000000000000100111101010011011110010001011110101011110100110100101001000000000000000000000;
    assign win[599:500] = 100'b0000000000000000000000000000101010001010001001010000010101000010100010100101001000000000000000000000;
    assign win[699:600] = 100'b0000000000000000000000100111001001111011110000100011100101011100011110100100110000000000000000000000;

    always @(*)
    begin
        if (is_win == 1'b1)
            OUT = win;
        else if (is_high_score == 1'b1)
            case(random_3[1:0])
                2'b00: OUT = success_1;
                2'b01: OUT = success_2;
                2'b10: OUT = success_3;
					 default: OUT = success_1;
            endcase
        else
            case(random_3[1:0])
                2'b00: OUT = motivation_1;
                2'b01: OUT = motivation_2;
                2'b10: OUT = motivation_3;
					default: OUT = motivation_1;
            endcase
    end
endmodule
