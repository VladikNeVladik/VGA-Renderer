// No Copyright. Vladislav Aleinik, 2020
module FlowControl(
	input [6:0]opcode,
	input [2:0]funct3,

	input [31:0]src1,
	input [31:0]src2,
	input [31:0]imm,
	input [31:0]old_pc,

	output reg [31:0]dst,
	output reg [31:0]new_pc,

	output reg exception = 0
);

// 014000ef = 0000 0001 0100 0000 0000 0000 1
// opcode = 110 1111 JAL
// 

// 00008067 = 0000 0000 0000 0000 1000 
// opcode = 110 0111 JALR
// rd = 0000 0
// funct3 = 

always @(*) begin
	casez ({funct3, opcode})
		// PC-ralative addressing:
		10'b???_0110111: begin // LUI
			dst    = imm;
			new_pc = old_pc + 4;
			exception = 0;
		end
		10'b???_0010111: begin // AUIPC
			dst    = old_pc + imm;
			new_pc = old_pc + 4;
			exception = 0;
		end
		10'b???_1101111: begin // JAL
			dst    = old_pc + 4;
			new_pc = old_pc + imm;
			exception = 0;
		end
		10'b000_1100111: begin // JALR
			dst    = old_pc + 4;
			new_pc = (src1 + imm) & 32'hFFFFFFFE;
			exception = 0;
		end
		10'b000_1100011: begin // BEQ
			dst = 32'bx;
			exception = 0;
			if (src1 == src2) begin
				new_pc = old_pc + imm;
			end else begin
				new_pc = old_pc + 4;
			end
		end
		10'b001_1100011: begin // BNE
			dst = 32'bx;
			exception = 0;
			if (src1 != src2) begin
				new_pc = old_pc + imm;
			end else begin
				new_pc = old_pc + 4;
			end
		end
		10'b100_1100011: begin // BLT
			dst = 32'bx;
			exception = 0;
			if ($signed(src1) < $signed(src2)) begin
				new_pc = old_pc + imm;
			end else begin
				new_pc = old_pc + 4;
			end
		end
		10'b101_1100011: begin // BGE
			dst = 32'bx;
			exception = 0;
			if ($signed(src1) >= $signed(src2)) begin
				new_pc = old_pc + imm;
			end else begin
				new_pc = old_pc + 4;
			end
		end
		10'b110_1100011: begin // BLTU
			dst = 32'bx;
			exception = 0;
			if (src1 < src2) begin
				new_pc = old_pc + imm;
			end else begin
				new_pc = old_pc + 4;
			end
		end
		10'b111_1100011: begin // BGEU
			dst = 32'bx;
			exception = 0;
			if (src1 >= src2) begin
				new_pc = old_pc + imm;
			end else begin
				new_pc = old_pc + 4;
			end
		end
		10'b01?_1100011: begin
			dst       = 32'bx;
			new_pc    = 32'bx;
			exception = 1;
			$display("[PROC-FLOW-CONTROL] Unable to decode flow control instruction!");
		end
		default: begin
			dst       = 32'bx;
			new_pc    = old_pc + 4;
			exception = 0;
		end
	endcase

	if (new_pc[1:0] != 2'b00) begin
		exception = 1;
		$display("[PROC-FLOW-CONTROL] Invalid jump address!");
	end
end

endmodule