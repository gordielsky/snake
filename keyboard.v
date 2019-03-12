/* 
    Keyboard INPUT
    • PS/2 Clock -> PS2_KBCLK
    • PS/2 Data -> PS2_KBDAT

    Keyboard OUTPUT (bit mapping)
    • UP -> 8'b0001
    • DOWN -> 8'b0010
    • LEFT -> 8'b0100
    • RIGHT -> 8'b1000
*/

module keyboard(mapped_key, kb_clock, kb_data, LEDR);
    input kb_clock, kb_data;
    output [7:0] mapped_key;
	 output [8:0] LEDR;

    // Codes
    reg [10:0] make_code;
    reg [8:0] scan_code;
    reg [7:0] prev_scan_code;
    
    // Counter
	 localparam ZERO = 5'd0, KEY_BITS = 5'd11; 
    reg [5:0] counter = ZERO;
    
    localparam ESCAPE = 8'hE0;

    always@(negedge kb_clock)
    begin: input_detectionprev_scan_code = 
        make_code[counter] = kb_data;
        counter = counter + 1'd1;
        if (counter == KEY_BITS)
            begin
                if (prev_scan_code == ESCAPE)
						begin
                    scan_code <= {1'b1, make_code[8:1]}; // Exclude start, stop, and parity bits
						  prev_scan_code <= make_code[8:1];
						end
                else if (prev_scan_code != ESCAPE && make_code[8:1] != ESCAPE)
						begin
                    scan_code <= {1'b0, make_code[8:1]};
						  prev_scan_code <= make_code[8:1];
						end
                else
                    prev_scan_code <= make_code[8:1];
                counter = ZERO;
            end
    end
	 
	 assign LEDR[8:0] = scan_code;

    // 'data' input maps to specific scan codes (source: https://techdocs.altium.com/display/FPGA/PS2+Keyboard+Scan+Codes)
    // UP -> E075
    // DOWN -> E072
    // LEFT -> E06B
    // RIGHT -> E074
    // W -> 1D
    // A -> 1C
    // S -> 1B
    // D -> 23

    localparam KEY_UP = {1'b1, 8'h75},
            KEY_DOWN = {1'b1, 8'h72},
            KEY_LEFT = {1'b1, 8'h6B},
            KEY_RIGHT = {1'b1, 8'h74},
            KEY_W = {1'b0, 8'h1D},
            KEY_A = {1'b0, 8'h1C},
            KEY_S = {1'b0, 8'h1B},
            KEY_D = {1'b0, 8'h23};

    localparam OUT_UP = 8'b0001,
            OUT_DOWN = 8'b0010,
            OUT_LEFT = 8'b0100,
            OUT_RIGHT = 8'b1000,
            OUT_NONE = 8'h0;

	 reg [7:0] mapped_key;
    always@(*)
    begin
		  mapped_key = OUT_NONE;
        case(scan_code)
            KEY_UP: mapped_key = OUT_UP;
            KEY_W: mapped_key = OUT_UP;
            KEY_DOWN: mapped_key = OUT_DOWN;
            KEY_S: mapped_key = OUT_DOWN;
            KEY_LEFT: mapped_key = OUT_LEFT;
            KEY_A: mapped_key = OUT_LEFT;
            KEY_RIGHT: mapped_key = OUT_RIGHT;
            KEY_D: mapped_key = OUT_RIGHT;
            default: mapped_key = mapped_key;
        endcase
    end
endmodule