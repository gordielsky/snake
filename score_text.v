module score_text (
    output [209:0] OUT,
    input [0:0] SELECT
)

reg [5:0] pixels;
assign OUT[34:0] = pixels[0];
assign OUT[69:35] = pixels[1];
assign OUT[104:70] = pixels[2];
assign OUT[139:71] = pixels[3];
assign OUT[174:140] = pixels[4];
assign OUT[209:175] = pixels[5];

always @(*)
    begin
        case(IN[0])
            1'b1:
                begin
                    pixels[0] = 35'b00111000111100011110011111000111110;
                    pixels[1] = 35'b01000001000100100001010000100100000;
                    pixels[2] = 35'b00110001000000100001011111000111000;
                    pixels[3] = 35'b00001001000000100001010010000100000;
                    pixels[4] = 35'b00001001000100100001010001000100000;
                    pixels[5] = 35'b01110000111100011110010000100111110;
                end
        endcase
    end
endmodule


