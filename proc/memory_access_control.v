// No Copyright. Vladislav Aleinik, 2020
module MemoryAccessControl(
	input [6:0]opcode,
	input [2:0]funct3,

	input [31:0]src1,
	input [31:0]src2,
	input [31:0]imm,

	output [31:0]mem_addr,
	output [31:0]mem_data,

	output reg [1:0]window_size,
	output zero_extension,

	output reg exception = 0
);

assign mem_addr       = src1 + imm;
assign mem_data       = src2; 
assign zero_extension = funct3[2];

always @(*) begin
	casez ({funct3, opcode})
		10'b000_0000011, // LB
		10'b001_0000011, // LH
		10'b010_0000011, // LW
		10'b100_0000011, // LBU
		10'b101_0000011, // LHU
		10'b000_0100011, // SB
		10'b001_0100011, // SH
		10'b010_0100011: // SW
		begin 
			window_size = funct3[1:0];
			exception = 0;
		end
		10'b011_0?00011,
		10'b10?_0100011,
		10'b11?_0?00011: begin
			window_size = 2'b11;	
			exception = 1;
			$display("[PROC-MEMORY-ACCESS-CONTROL] Unable to decode instruction!");
		end
		default: begin
			 // Window size of 11 means that no memory access is performed:
			window_size = 2'b11;
			exception   = 0;
		end
	endcase
end

endmodule