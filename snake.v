module snake(
	input [17:0] SW,
	input [3:0] KEY,
	input CLOCK_50,
	
	output [17:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6,
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
	output [9:0] VGA_R, VGA_G, VGA_B
	);
	// VGA information for drawing
	wire [2:0] colour;
	wire [7:0] x; 
	wire [6:0] y;
	wire plot;
	
	wire clk;
	assign clk = CLOCK_50;
	
	// Directional buttons currently being pressed
	wire mv_left, mv_right, mv_down, mv_up;
	// Assign to keys until keyboard :)
	assign mv_left = ~KEY[3];
	assign mv_right = ~KEY[0];
	assign mv_down = ~KEY[2];
	assign mv_up = ~KEY[1];
	
	// Any button is being pressed to start the game
	wire press_button;
	assign press_button = mv_left || mv_right || mv_down || mv_up;
	
	// Controls for the datapath
	wire [1:0] direction;
	wire grow, dead;
	
	// Game info
	wire [1023:0] snake_x;
	wire [1023:0] snake_y;
	wire [7:0] snake_size;
	wire [7:0] apple_x;
	wire [6:0] apple_y;
	
	wire [14:0] counter;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	
	// Create the control and datapath
	control c0(
		.clk(clk),
		.press_button(press_button),
		
		.counter(counter),
		
		.mv_left(mv_left),
		.mv_right(mv_right),
		.mv_down(mv_down),
		.mv_up(mv_up),
		
		.snake_x(snake_x),
		.snake_y(snake_y),
		.snake_size(snake_size),
		
		.apple_x(apple_x),
		.apple_y(apple_y),
		
		.plot(plot),
		.grow(grow),
		.dead(dead),
		.direction(direction),
		.curr_state(LEDR[4:0])
		);
		
	datapath d0(
		.clk(clk),
		.direction(direction),
		.grow(grow),
		.dead(dead),
		
		.counter(counter),
		
		.snake_x(snake_x),
		.snake_y(snake_y),
		.snake_size(snake_size),
		
		.apple_x(apple_x),
		.apple_y(apple_y),
		
		.draw_x(x),
		.draw_y(y)
		);
	
endmodule

module control(
	input clk,
	// Input to start game / move between menus
	input press_button,
	// Ticks spent in current state (log(160 * 120) bits)
	input [14:0] counter,
	// Direction inputs
	input mv_left, mv_right, mv_down, mv_up,
	// Snake position, 8 bits per coordinate (piece of snake) 
	// head of snake is snake_x[7:0] , snake_y[7:0], second piece is [15:8], etc.
	input [1023:0] snake_x, 
	input [1023:0] snake_y,
	// Size of the snake
	input [7:0] snake_size,
	// Apple position
	input [7:0] apple_x,
	input [6:0] apple_y,
	// Randomly generated wall positions
	//input [num_random_walls * 8:0] wall_x,
	//input [num_random_walls * 8:0] wall_y,

	// Whether a pixel is being drawn this tick
	output plot,
	// Snake hits apple -> grow /// Snake hit wall or itself -> dead
	output grow, dead,
	// Left: 00 / Right: 01 / Down: 10 / Up: 11
	output [1:0] direction,
	// Current state (for testing purposes)
	// Has extra bit so that space can be used if needed
	output [4:0] curr_state
	);
	
	reg [4:0] current_state, next_state; 
	
	localparam 	S_MAIN_MENU 	= 5'd0, // menu state
				S_STARTING 		= 5'd1, // press start game button
				S_STARTING_WAIT = 5'd2, // stop pressing start game button
				S_LOAD_GAME		= 5'd3, // load initial snake pos, random walls
				S_MAKE_APPLE	= 5'd4, // load apple position
				S_CLR_SCREEN	= 5'd5, // clear the screen
				S_DRAW_WALLS	= 5'd6, // redraw each part of the game
				S_DRAW_APPLE	= 5'd7,
				S_DRAW_SNAKE 	= 5'd8,
				S_MOVING		= 5'd9, // take the next step in the game
				S_MUNCHING		= 5'd10,
				S_DEAD			= 5'd11,
				S_SCORE_MENU	= 5'd12;

	wire [15:0] CLR_SCREEN_MAX, DRAW_WALLS_MAX, DRAW_SNAKE_MAX;
	assign CLR_SCREEN_MAX = 15'd19_200; // 160 * 120
	assign DRAW_WALLS_MAX = 15'd1_104; // 4 * 160 + 4 * (120 - 4) - size of walls (add # randomly generated walls)
	assign DRAW_SNAKE_MAX = {7'b0, snake_size};
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
        case (current_state)
			S_MAIN_MENU: next_state = press_button ? S_STARTING : S_MAIN_MENU; // Stay on menu until start game
			S_STARTING: next_state = press_button ? S_STARTING_WAIT : S_STARTING; // Stay on starting while button is held
			S_STARTING_WAIT: next_state = press_button ? S_STARTING_WAIT : S_LOAD_GAME; // Switch to game when start game button is released
			S_LOAD_GAME: next_state = S_MAKE_APPLE;
			S_MAKE_APPLE: next_state = S_CLR_SCREEN;
			S_CLR_SCREEN: begin
				if (counter == CLR_SCREEN_MAX)
					next_state = S_DRAW_WALLs;
				else
					next_state = S_CLR_SCREEN;
				end
			S_DRAW_WALLS: begin
				if (counter == DRAW_WALLS_MAX)
					next_state = S_DRAW_APPLE;
				else
					next_state = S_DRAW_WALLS;
				end
			S_DRAW_APPLE: next_state = S_DRAW_SNAKE;
			S_DRAW_SNAKE: begin
				if (counter == DRAW_SNAKE_MAX)
					next_state = S_MOVING;
				else
					next_state = S_DRAW_SNAKE;
				end
			S_MOVING: begin
				// check if the snake head touched a wall or itself
				// need some way to check as the possible values
				if (1'b0 && (in wall || in self))	// set to always be false for now
					next_state = S_DEAD;
				else if (snake_x[7:0] == apple_x[7:0] && snake_y[7:0] == {1'b0, apple_y[6:0]}) 	// check the snake head touched the apple
					next_state = S_MUNCHING;
				else
					next_state = S_CLR_SCREEN;
				end
			S_MUNCHING: next_state = S_MAKE_APPLE;
			S_DEAD: next_state = S_SCORE_MENU;
			S_SCORE_MENU: next_state = press_button ? S_STARTING : S_SCORE_MENU; // Stay on menu until restart game
			default:     next_state = S_MAIN_MENU;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		plot = 1'b0;
		grow = 1'b0;
		dead = 1'b0;
		//direction = 2'b0; // don't wanna change direction constantly I guess

        case (current_state)
			S_CLR_SCREEN: begin
				plot = 1'b1;
				end
			S_DRAW_WALLS: begin
				plot = 1'b1;
				end
			S_DRAW_APPLE: begin
				plot = 1'b1;
				end
			S_DRAW_SNAKE: begin
				plot = 1'b1;
				end
			S_MOVING: begin
				// not sure if these checks should be done only in moving state
				// wondering if they'll register if you press the button at the wrong time
				if (mv_left)
					direction = 2'b00;
				else if (mv_right)
					direction = 2'b01;
				else if (mv_down)
					direction = 2'b10;
				else if (mv_up)
					direction = 2'b11;
				end
			S_MUNCHING: begin
				grow = 1'b1;
				end
			S_DEAD: begin
				dead = 1'b1;
				end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        current_state <= next_state;
    end // state_FFS
	
	// Output the current state to LEDs
	assign curr_state = current_state;
	
endmodule
	
module datapath(
	input clk,
	input [1:0] direction,
	input grow, dead,
	
	output [14:0] counter,
	
	output [1023:0] snake_x,
	output [1023:0] snake_y,
	output [7:0] snake_size,
	
	output [7:0] apple_x,
	output [6:0] apple_y,
	
	output [7:0] draw_x,
	output [6:0] draw_y
	);


	// Input logic based on grow / dead
    always@(posedge clk) begin
        if(grow)
           
        else if(dead)
           
        else
			
    end
endmodule
