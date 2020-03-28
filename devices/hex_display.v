// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Hex Display Controller            
//=============================================================================
// - Renders 2 bytes on 7-segment display
//=============================================================================
module HexDisplay(
    input clk,

	input [ 1:0]data_addr,
	input [31:0]data_in,

	input write_enable,
	input [1:0]window_size,

	output reg [31:0]data_out,

	output [3:0]anodes,
	output reg [6:0]segments
);

// Internal data access:
reg [31:0]hex_data = 0;

wire [31:0]next_hex_data;

WindowedWordWriter write_word(
	.word_from_cpu   (data_in      ),
	.word_from_memory(hex_data     ),
	.addr            (data_addr    ),
	.window_size     (window_size  ),
	.write_enable    (write_enable ), 
	.word_out        (next_hex_data)
);

always @(posedge clk) begin
	hex_data <= next_hex_data;
	data_out <= next_hex_data;
end

// Clock division:
reg [15:0]counter_div = 0;
reg [ 1:0]counter     = 0;

always @(posedge clk) begin
	counter_div <= counter_div + 16'b1;

	if (counter_div == 0)
		counter <= counter + 2'b1;
end

// Visualisation:
assign anodes = {counter == 2'b11,
                 counter == 2'b10,
                 counter == 2'b01,
                 counter == 2'b00}; 

wire [3:0]cur_data = hex_data[4 * counter +: 4];
always @(*) begin
	case (cur_data)          /* abcdefg */
		4'h0: segments = 7'b1111110;
		4'h1: segments = 7'b0110000;
		4'h2: segments = 7'b1101101;
		4'h3: segments = 7'b1111001;
		4'h4: segments = 7'b0110011;
		4'h5: segments = 7'b1011011;
		4'h6: segments = 7'b1011111;
		4'h7: segments = 7'b1110000;
		4'h8: segments = 7'b1111111;
		4'h9: segments = 7'b1111011;
		4'hA: segments = 7'b1110111;
		4'hB: segments = 7'b0011111;
		4'hC: segments = 7'b1001110;
		4'hD: segments = 7'b0111101;
		4'hE: segments = 7'b1001111;
		4'hF: segments = 7'b1000111;
	endcase
end

endmodule

