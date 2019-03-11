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
	
	wire resetn;
	
	
	// current state of the game
	wire [4:0] state;
	// previous state of the game
	wire [4:0] prev_state;
	// for debugging, show current state on leds
	assign LEDR[4:0] = state;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(plot),
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
		.current_state(state),
		.prev_state(prev_state)
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
		.draw_y(y),
		.colour(colour),
		.current_state(state),
		.prev_state(prev_state)
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
	output reg plot,
	// Snake hits apple -> grow /// Snake hit wall or itself -> dead
	output reg grow, dead,
	// Left: 00 / Right: 01 / Down: 10 / Up: 11
	output reg [1:0] direction,
	// Current state (for testing purposes)
	// Has extra bit so that space can be used if needed
	output reg [4:0] current_state, prev_state
	);
	
	reg [4:0] next_state; 
	
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

	localparam 	LEFT = 2'b00,
				RIGHT = 2'b01,
				DOWN = 2'b10,
				UP = 2'b11;

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
					next_state = S_DRAW_WALLS;
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
				if (1'b0)	//&& (in wall || in self) // set to always be false for now
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
		// start off as going left
		direction = LEFT;
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
				if (mv_left && direction != RIGHT)
					direction = LEFT;
				else if (mv_right && direction != LEFT)
					direction = LEFT;
				else if (mv_down && direction != UP)
					direction = UP;
				else if (mv_up && direction != DOWN)
					direction = DOWN;
				end
			S_MUNCHING: begin
				grow = 1'b1;
				end
			S_DEAD: begin
				dead = 1'b1;
				end
        default: begin // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
				plot = 1'b0;
				grow = 1'b0;
				dead = 1'b0;
				direction = LEFT;
				end
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
		prev_state <= current_state;
        current_state <= next_state;
    end // state_FFS
	
endmodule
	
module datapath(
	input clk,
	input [1:0] direction,
	input grow, dead,
	input [4:0] current_state, prev_state,
	
	output reg [14:0] counter,
	
	output reg [1023:0] snake_x,
	output reg [1023:0] snake_y,
	output reg [7:0] snake_size,
	
	output reg [7:0] apple_x,
	output reg [6:0] apple_y,
	
	output reg [2:0] colour,
	output reg [7:0] draw_x,
	output reg [6:0] draw_y
	);


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

	localparam 	LEFT = 2'b00,
				RIGHT = 2'b01,
				DOWN = 2'b10,
				UP = 2'b11;

	// Used for drawing the snake, gets initialized to actual values then shifted down by 8 bits to get to the next coord per counter tick 
	reg [1023:0] snake_draw_x;
	reg [1023:0] snake_draw_y;

	 // Input logic
    always @(posedge clk)
    begin: enable_signals
        // By default make all our signals 0
		
		// if the state has changed, reset the counter
		if(prev_state != current_state)
			begin
			counter = 15'd0;
			snake_draw_x = snake_x;
			snake_draw_y = snake_y;
			end

        case (current_state)
			S_MAIN_MENU: begin
				end
			S_STARTING: begin
				end
			S_STARTING_WAIT: begin
				end
			S_LOAD_GAME: begin
				// setting snake head position
				snake_x[7:0] = 8'd30;
				snake_y[6:0] = 7'd20;
				// positionally load random walls 
				end
			S_MAKE_APPLE: begin
				// put random gen code here, static assignment for now
				apple_x[7:0] = 8'd50;
				apple_y[6:0] = 7'd50;
				end
			
			S_CLR_SCREEN: begin
				// set colour to black
				colour = 3'b000;
				// draw x / y for each value represented by the counter
				draw_x = counter[7:0];
				draw_y = counter[14:8]; 
				counter = counter + 1'b1;
				end
			S_DRAW_WALLS: begin
					// set colour to blue
					colour = 3'b001;
					// if the counter represents a value where the border wall should be drawn
					if(counter[7:0] < 8'd2 || counter[7:0] > 8'd158 || counter[14:8] < 7'd2 || counter[14:8] > 7'd118)
						begin
						draw_x = counter[7:0];
						draw_y = counter[14:8];
						end
					counter = counter + 1'b1;
				end
			S_DRAW_APPLE: begin
				// set colour to red
				colour = 3'b100;
				draw_x = apple_x;
				draw_y = apple_y;
				end
			S_DRAW_SNAKE: begin
				// set colour to white
				colour = 3'b111;
				// draw the first values of the register
				draw_x = snake_draw_x[7:0];
				draw_y = snake_draw_y[6:0];
				// shift by 8 bits to get the next snake block
				snake_draw_x = snake_draw_x >> 8;
				snake_draw_y = snake_draw_y >> 8;
				counter = counter + 1'b1;
				end
			S_MOVING: begin
				// not sure if these checks should be done only in moving state
				// wondering if they'll register if you press the button at the wrong time
				if (direction == LEFT)
					begin
					// move everything back one (lose the last saved coord)
					snake_x = snake_x << 8;
					snake_y = snake_y << 8;
					// decrease the head's x coord by 1 to go left
					snake_x[7:0] = snake_x[15:8] - 1'b1;
					snake_y[7:0] = snake_y[15:8];
					end
				else if (direction == RIGHT)
					begin
					// move everything back one (lose the last saved coord)
					snake_x = snake_x << 8;
					snake_y = snake_y << 8;
					// increase the head's x coord by 1 to go right
					snake_x[7:0] = snake_x[15:8] + 1'b1;
					snake_y[7:0] = snake_y[15:8];
					end
				else if (direction == DOWN)
					begin
					// move everything back one (lose the last saved coord)
					snake_x = snake_x << 8;
					snake_y = snake_y << 8;
					// increase the head's y coord by 1 to go down
					snake_x[7:0] = snake_x[15:8];
					snake_y[7:0] = snake_y[15:8] + 1'b1;
					end
				else if (direction == UP)
					begin
					// move everything back one (lose the last saved coord)
					snake_x = snake_x << 8;
					snake_y = snake_y << 8;
					// decrease the head's y coord by 1 to go up
					snake_x[7:0] = snake_x[15:8];
					snake_y[7:0] = snake_y[15:8] - 1'b1;
					end
				end
			S_MUNCHING: begin
					snake_size = snake_size + 1'b1;
				end
			S_DEAD: begin
				// currently cant die
				end
			S_SCORE_MENU: begin
				// scores not implemented
				end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
endmodule
