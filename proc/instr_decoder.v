// No Copyrught. Vladislav Aleinik, 2020
module InstructionDecoder(
	input [31:0]instr,

	output reg [6:0]opcode,
	output reg [2:0]funct3,
	output reg [1:0]funct2,
	output reg [4:0]funct5,

	output reg [4:0]rd,
	output reg [4:0]rs1,
	output reg [4:0]rs2,
	output reg [31:0]imm,

	output reg reg_write_enable,
	output reg mem_write_enable,
	output reg [1:0]dst_data_source, // 0 = Memory, 1 = Flow Control, 2 = Alu, 3 = No Source

	output reg exception
);

// Decode immediates:
// U-type:
wire [31:0]u_type_imm;

assign u_type_imm[11: 0] = 12'b0;
assign u_type_imm[31:12] = instr[31:12];

// J-type:
wire [31:0]j_type_imm;

assign j_type_imm[    0] = 0;
assign j_type_imm[10: 1] = instr[30:21];
assign j_type_imm[   11] = instr[   20];
assign j_type_imm[19:12] = instr[19:12];
assign j_type_imm[31:20] = {11{instr[31]}};

// I-type:
wire [31:0]i_type_imm;

assign i_type_imm[10: 0] = instr[30:20];
assign i_type_imm[31:11] = {21{instr[31]}};

// B-type:
wire [31:0]b_type_imm;

assign b_type_imm[    0] =            0;
assign b_type_imm[ 4: 1] = instr[11: 8];
assign b_type_imm[10: 5] = instr[30:25];
assign b_type_imm[   11] = instr[    7];
assign b_type_imm[31:12] = {20{instr[31]}};

// S-type:
wire [31:0]s_type_imm;

assign s_type_imm[ 4: 0] = instr[11: 7];
assign s_type_imm[10: 5] = instr[30:25];
assign s_type_imm[31:11] = {21{instr[31]}};

// R-type:
wire [31:0]r_type_imm = 32'bx;

always @(*) begin
	// Decode opcode:
	opcode = instr[6:0];

	// Decode funct-x fields:
	funct3 = instr[14:12];
	funct2 = instr[26:25];
	funct5 = instr[31:27];

	// Decode registers:
	rd  = instr[11:7];
	rs1 = instr[19:15];
	rs2 = instr[24:20];

	// Decode immediate:
	casez (opcode[6:0])
		7'b0?10111: begin // U-type
			imm              = u_type_imm;
			reg_write_enable = 1;
			mem_write_enable = 0;
			dst_data_source  = 1; // Flow Control
			exception        = 0;
		end
		7'b1101111: begin // J-type
			imm              = j_type_imm;
			reg_write_enable = 1;
			mem_write_enable = 0;
			dst_data_source  = 1; // Flow Control
			exception        = 0;
		end
		7'b1100111: begin // I-type
			imm              = i_type_imm;
			reg_write_enable = 1;
			mem_write_enable = 0;
			dst_data_source  = 1; // Flow Control
			exception        = 0;
		end
		7'b1100011: begin // B-type
			imm              = b_type_imm;
			reg_write_enable = 0;
			mem_write_enable = 0;
			dst_data_source  = 1; // Flow Control
			exception        = 0;
		end
		7'b0000011: begin // I-type
			imm              = i_type_imm;
			reg_write_enable = 1;
			mem_write_enable = 0;
			dst_data_source  = 0; // Memory
			exception        = 0;
		end
		7'b0100011: begin // S-type
			imm              = s_type_imm;
			reg_write_enable = 0;
			mem_write_enable = 1;
			dst_data_source  = 3; // No Source
			exception        = 0;
		end
		7'b0010011: begin // I-type
			imm              = i_type_imm;
			reg_write_enable = 1;
			mem_write_enable = 0;
			dst_data_source  = 2; // Alu
			exception        = 0;
		end
		7'b0110011: begin // R-type
			imm              = r_type_imm;
			reg_write_enable = 1;
			mem_write_enable = 0;
			dst_data_source  = 2; // Alu
			exception        = 0;
		end
		7'b0001111: begin
			$display("[PROC-INSTR-DECODE] Sorry (^___^), FENCE and FENCE.I are unimplemented.");
			imm              = {32{1'bx}};
			reg_write_enable = 0;
			mem_write_enable = 0;
			dst_data_source  = 3; // No Source
			exception        = 1;
		end
		default: begin
			$display("[PROC-INSTR-DECODE] Unable to decode instruction!");
			imm              = 32'bx;
			reg_write_enable = 0;
			mem_write_enable = 0;
			dst_data_source  = 3; // No Source
			exception        = 1;
		end
	endcase
end

endmodule
