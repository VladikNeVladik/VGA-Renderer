// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// RISC-V Processor Core                
//=============================================================================
// - Implements RISC-V RV32I ISA without FENCE and FENCE.I instructions        
// - Executes Instructions From UART Controller and Read-Only Memory           
//=============================================================================
module Processor #(
	parameter INIT_PC = 32'h00002000
) (
	input clk,

	input [31:0]cur_instr,

	input [31:0]data_in,

	output [31:0]data_out,
	output [31:0]data_addr,

	output mem_write_enable,
	output [1:0]window_size,
	output zero_extension,

	output [31:0]next_pc,

	output [3:0]exceptions
);

//-----------------//
// Processor State //
//-----------------//

// Program Counter:
reg [31:0]cur_pc = INIT_PC - 4;

// Dest Register Info:
reg       prev_clk_reg_write_enable = 0; // Write Disabled
reg [ 4:0]prev_clk_dst_addr         = 0; // Zero register
reg [ 1:0]prev_clk_dst_data_source  = 0; // Memory 
reg [31:0]prev_clk_dst_flow_control = 0;
reg [31:0]prev_clk_dst_alu          = 0;

//--------------------//
// Instruction Decode //
//--------------------//

// Out:
wire [6:0]opcode;
wire [2:0]funct3;
wire [1:0]funct2;
wire [4:0]funct5;

wire [4:0]dst_addr;
wire [4:0]src_addr_1;
wire [4:0]src_addr_2;
wire [31:0]immediate;

wire reg_write_enable;
wire [1:0]dst_data_source;

InstructionDecoder instr_decoder(
	.instr(cur_instr),
	
	.opcode(opcode),
	.funct3(funct3),
	.funct2(funct2),
	.funct5(funct5),

	.rd (dst_addr),
	.rs1(src_addr_1),
	.rs2(src_addr_2),
	.imm(immediate),

	.reg_write_enable(reg_write_enable),
	.mem_write_enable(mem_write_enable),
	.dst_data_source (dst_data_source),

	.exception(exceptions[0])
);

//----------------------//
// Register File Access //
//----------------------//

// In:
reg [31:0]prev_clk_dst_data;

always @(*) begin
	case (prev_clk_dst_data_source)
		0: prev_clk_dst_data = data_in;
		1: prev_clk_dst_data = prev_clk_dst_flow_control;
		2: prev_clk_dst_data = prev_clk_dst_alu;
		3: prev_clk_dst_data = 32'bx;
	endcase
end

// Out:
wire [31:0]src_data_1;
wire [31:0]src_data_2;

RegisterFile reg_file(
	.clk(clk),

	.dst_addr    (prev_clk_dst_addr),
	.dst_data    (prev_clk_dst_data),
	.write_enable(prev_clk_reg_write_enable),

	.src_addr_1(src_addr_1),
	.src_addr_2(src_addr_2),

	.src_data_1(src_data_1),
	.src_data_2(src_data_2)
);

//-----------------------//
// Memory Access Control //
//-----------------------//

MemoryAccessControl mem_access_control(
	.opcode(opcode),
	.funct3(funct3),

	.src1(src_data_1),
	.src2(src_data_2),
	.imm (immediate),

	.mem_addr(data_addr),
	.mem_data(data_out),

	.window_size   (window_size),
	.zero_extension(zero_extension),

	.exception(exceptions[1])
);

//--------------//
// Flow Control //
//--------------//

// Out:
wire [31:0]dst_flow_control;

FlowControl flow_control(
	.opcode(opcode),
	.funct3(funct3),

	.src1  (src_data_1),
	.src2  (src_data_2),
	.imm   (immediate),
	.old_pc(cur_pc),

	.dst(dst_flow_control),
	.new_pc(next_pc),

	.exception(exceptions[2])
);

//-----------------------//
// Arithmetic Logic Unit //
//-----------------------//

// Out:
wire [31:0]dst_alu;

ArithmeticLogicUnit alu(
	.opcode(opcode),
	.funct3(funct3),
	.funct2(funct2),
	.funct5(funct5),

	.addr2(src_addr_2),
	.src1 (src_data_1),
	.src2 (src_data_2),
	.imm  (immediate),
	.dst  (dst_alu),

	.exception(exceptions[3])
);

//------------------------//
// Processor State Update //
//------------------------//

// Program Counter Update:
always @(posedge clk) begin
	cur_pc <= next_pc;
end

// Dest Register Update:
always @(posedge clk) begin
	prev_clk_reg_write_enable <= reg_write_enable;
	prev_clk_dst_addr         <= dst_addr;
	prev_clk_dst_data_source  <= dst_data_source;
	prev_clk_dst_flow_control <= dst_flow_control;
	prev_clk_dst_alu          <= dst_alu;
end


endmodule