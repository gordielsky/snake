module score_to_display(
    output [89:0] score_display,
    input [6:0] score_input
);

wire [29:0] digit_2, digit_1, digit_0;
reg [3:0] value_2, value_1, value_0;

always @(*)
    begin
        value_2 <= (score_input / 100) % 10;
        value_1 <= (score_input / 10) % 10;
        value_0 <= score_input % 10 ;
    end

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

assign score_display = {value_2, value_1, value_0};

endmodule

module digit_decoder(
    output [29:0] OUT,
    input [3:0] IN
);
reg [5:0] pixels[4:0];

assign OUT[5:0] = pixels[0];
assign OUT[11:6] = pixels[1];
assign OUT[17:12] = pixels[2];
assign OUT[23:18] = pixels[3];
assign OUT[29:24] = pixels[4];

always @(*)
    begin
        case(IN[3:0])
            4'b0000: 
                begin
                    pixels[0] = 6'b001100;
                    pixels[1] = 6'b010010;
                    pixels[2] = 6'b010110;
                    pixels[3] = 6'b011010;
                    pixels[4] = 6'b001100;
                end
            4'b0001:
                begin
                    pixels[0] = 6'b001000;
                    pixels[1] = 6'b011000;
                    pixels[2] = 6'b001000;
                    pixels[3] = 6'b001000;
                    pixels[4] = 6'b011100;
                end
            4'b0010:
                begin
                    pixels[0] = 6'b001100;
                    pixels[1] = 6'b010010;
                    pixels[2] = 6'b000100;
                    pixels[3] = 6'b001000;
                    pixels[4] = 6'b011110;
                end
            4'b0011:
                begin
                    pixels[0] = 6'b001100;
                    pixels[1] = 6'b010010;
                    pixels[2] = 6'b000100;
                    pixels[3] = 6'b010010;
                    pixels[4] = 6'b001100;
                end
            4'b0100:
                begin
                    pixels[0] = 6'b000100;
                    pixels[1] = 6'b001100;
                    pixels[2] = 6'b010100;
                    pixels[3] = 6'b011110;
                    pixels[4] = 6'b000100;
                end
            4'b0101:
                begin
                    pixels[0] = 6'b011110;
                    pixels[1] = 6'b010000;
                    pixels[2] = 6'b001110;
                    pixels[3] = 6'b010001;
                    pixels[4] = 6'b001110;
                end
            4'b0110:
                begin
                    pixels[0] = 6'b001100;
                    pixels[1] = 6'b010000;
                    pixels[2] = 6'b011100;
                    pixels[3] = 6'b010010;
                    pixels[4] = 6'b001100;
                end
            4'b0111:
                begin
                    pixels[0] = 6'b011110;
                    pixels[1] = 6'b010010;
                    pixels[2] = 6'b000100;
                    pixels[3] = 6'b001000;
                    pixels[4] = 6'b001000;
                end
            4'b1000:
                begin
                    pixels[0] = 6'b001100;
                    pixels[1] = 6'b010010;
                    pixels[2] = 6'b001100;
                    pixels[3] = 6'b010010;
                    pixels[4] = 6'b001100;
                end
            4'b1001:
                begin
                    pixels[0] = 6'b011000;
                    pixels[1] = 6'b100100;
                    pixels[2] = 6'b011100;
                    pixels[3] = 6'b000100;
                    pixels[4] = 6'b011000;
                end
        endcase
    end
endmodule