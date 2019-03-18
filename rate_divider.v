module rate_divider(enable, par_load, max_ticks, clk);
    input par_load, clk;
    input [27:0] max_ticks;
    output reg enable;
    
    reg [27:0] tick; // declare q
    always @(posedge clk) // triggered every time clock rises
    begin
        enable <= 0; // always make enable 0 unless counter is down to 0
        if (par_load == 1'b1) // check if parallel load
            tick <= max_ticks; // reload the tick counter to max value
        else if (tick == 0) // ...otherwise if q is the minimum counter value
        begin
            tick <= max_ticks; // reset q to 0
            enable <= 1; // update enable value
        end
        else // otherwise decrement the count
            tick <= tick - 1'b1;
    end
endmodule
