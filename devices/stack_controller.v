// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Stack Controller            
//=============================================================================
// - Allows for data read/write
//=============================================================================
module StackController(
	input clk,

	input [7:0]data_addr,
	input [31:0]data_in,
	
	input write_enable,
	input [1:0]window_size,

	output reg [31:0]data_out
);

reg [31:0]stack_memory[63:0];

genvar i;
generate
	for (i = 0; i < 64; i = i + 1) begin : stack_init
		// Set initial values to registers:
		initial stack_memory[i] = 32'b0;
	end
endgenerate

reg [31:0]prev_data         = 32'b0;
reg [ 7:0]prev_addr         = 8'b0;
reg       prev_write_enable = 1'b0; 

wire [31:0]word_from_memory = stack_memory[data_addr[7:2]];
wire [31:0]word_windowed;

WindowedWordWriter write_word(
	.word_from_cpu   (data_in         ),
	.word_from_memory(word_from_memory),
	.addr            (data_addr[1:0]  ),
	.window_size     (window_size     ),
	.write_enable    (write_enable    ), 
	.word_out        (word_windowed   )
);

always @(posedge clk) begin
	prev_data         <= word_windowed;
	prev_addr         <= data_addr;
	prev_write_enable <= write_enable;

	if (prev_write_enable) begin
		stack_memory[prev_addr[7:2]] <= prev_data;
	end

	if (prev_write_enable && prev_addr == data_addr) begin
				data_out <= prev_data;
	end
	else begin
		data_out <= word_from_memory;
	end
end

endmodule