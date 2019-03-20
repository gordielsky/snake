module random(clock, max_number, num_out);
/*
    Module that will generate a pseudorandom number
    A faster clock  will generate a "more" random number
    max_number is an 8 bit input, which dictates the maximum number that will be
    outputted from the module.
*/
input clock;
input [13:0]max_number;

output [13:0]num_out;

reg [13:0]counter;

assign num_out = counter;

always@(posedge clock)
begin
    if(counter == max_number)
    begin
        counter <= 8'd0;
    end
    else
    begin
        counter <= counter + 1'b1;
    end
end

endmodule