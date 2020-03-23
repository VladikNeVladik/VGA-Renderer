// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Window Size Managers
//=============================================================================
// - All loads pass through a Windowed Word Reader module
// - All stores pass are performed through Windowed Word Writer module
//=============================================================================
module WindowedWordReader(
	input [31:0]word_in,
	input [ 1:0]addr,

	input [1:0]window_size,
	input zero_extension,

	output reg [31:0]word_out
);

wire [ 7:0]word_08 = word_in[ 8*addr    +:  8];
wire [15:0]word_16 = word_in[16*addr[1] +: 16];

always @(*) begin
	case (window_size)
		2'b00: begin
			word_out = {{24{!zero_extension & word_08[7]}}, word_08};
		end
		2'b01: begin
			word_out = {{16{!zero_extension & word_16[15]}}, word_16};
		end
		2'b10: begin
			word_out = word_in;
		end
		2'b11: begin
			word_out = 32'bx;
		end
	endcase
end
endmodule

module WindowedWordWriter(
	input [31:0]word_from_cpu,
	input [31:0]word_from_memory,
	input [ 1:0]addr,

	input [1:0]window_size,
	input write_enable,

	output reg [31:0]word_out
);

wire [ 7:0]word_08 = word_from_cpu[ 7:0];
wire [15:0]word_16 = word_from_cpu[15:0];

always @(*) begin
	if (write_enable) begin
		case (window_size)
			2'b00: begin
				case (addr)
					2'b00: word_out = {word_from_memory[31: 8], word_08                        };
					2'b01: word_out = {word_from_memory[31:16], word_08, word_from_memory[ 7:0]};
					2'b10: word_out = {word_from_memory[31:24], word_08, word_from_memory[15:0]};
					2'b11: word_out = {                         word_08, word_from_memory[23:0]};	
				endcase
			end
			2'b01: begin
				case (addr[1])
					1'b0: word_out = {word_from_memory[31:16], word_16};
					1'b1: word_out = {word_16, word_from_memory[15:0]};
				endcase
			end
			2'b10: begin
				word_out = word_from_cpu;
			end
			2'b11: begin
				word_out = word_from_memory;
			end
		endcase
	end
	else word_out = word_from_memory;
end
endmodule