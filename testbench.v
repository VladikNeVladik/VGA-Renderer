// No Copyright. Vladislav Aleinik, 2020
`timescale 1 ns / 100 ps
module testbench();

reg clk = 1'b0;
always begin
    #1 clk = ~clk;
end

wire [4:0]V_R;
wire [5:0]V_G;
wire [4:0]V_B;

top top(clk, RXD, DS_EN1, DS_EN2, DS_EN3, DS_EN4, DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G, H_SYNC, V_SYNC, V_R, V_G, V_B);

initial begin
	$display("Processor Testing Initiated!");
    $dumpvars;
    #5000 $finish;
end

endmodule