// No Copyright. Vladislav Aleinik, 2020
`timescale 1 ns / 100 ps
module testbench();

reg clk = 1'b0;
always begin
    #1 clk = ~clk;
end

top top(clk, DS_EN1, DS_EN2, DS_EN3, DS_EN4, DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G);

initial begin
	$display("Processor Testing Initiated!");
    $dumpvars;
    #1000 $finish;
end

endmodule