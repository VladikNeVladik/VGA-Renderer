// No Copyright. Vladislav Aleinik, 2020
module ArithmeticLogicUnit(
	input [6:0]opcode,
	input [2:0]funct3,
	input [1:0]funct2,
	input [4:0]funct5,

	input      [4:0]addr2,
	input      [31:0]src1,
	input      [31:0]src2,
	input      [31:0]imm,
	output reg [31:0]dst,

	output reg exception
);

always @(*) begin
	casez ({funct5, funct2, funct3, opcode})
		// Immediate operations:
		17'b?????_??_000_0010011: begin // ADDI
			dst = src1 + imm;
			exception = 0;
		end
		17'b?????_??_010_0010011: begin // SLTI
			dst = ($signed(src1) <= $signed(imm))? 32'b1 : 32'b0;
			exception = 0;
		end	
		17'b?????_??_011_0010011: begin // SLTIU
			dst = (src1 <= imm)? 32'b1 : 32'b0;
			exception = 0;
		end
		17'b?????_??_100_0010011: begin // XORI and XOR
			dst = src1 ^ imm;
			exception = 0;
		end	
		17'b?????_??_110_0010011: begin // ORI
			dst = src1 | imm;
			exception = 0;
		end	
		17'b?????_??_111_0010011: begin // ANDI
			dst = src1 & imm;
			exception = 0;
		end
		17'b00000_00_001_0010011: begin // SLLI
			dst = src1 << addr2;
			exception = 0;
		end
		17'b00000_00_101_0010011: begin // SRLI
			dst = src1 >> addr2;
			exception = 0;
		end
		17'b01000_00_101_0010011: begin // SRAI
			dst = src1 >>> addr2;
			exception = 0;
		end

		// Source-2 operations:
		17'b00000_00_000_0110011: begin // ADD
			dst = src1 + src2;
			exception = 0;
		end
		17'b01000_00_000_0110011: begin // SUB
			dst = src1 - src2;
			exception = 0;
		end
		17'b00000_00_001_0110011: begin // SLL
			dst = src1 << src2[4:0];
			exception = 0;
		end
		17'b00000_00_010_0110011: begin // SLT
			dst = ($signed(src1) <= $signed(src2))? 32'b1 : 32'b0;
			exception = 0;
		end	
		17'b00000_00_011_0110011: begin // SLTU
			dst = (src1 <= src2)? 32'b1 : 32'b0;
			exception = 0;
		end	
		17'b00000_00_100_0110011: begin // XOR
			dst = src1 ^ src2;
			exception = 0;
		end	
		17'b00000_00_101_0110011: begin // SRL
			dst = src1 >> src2[4:0];
			exception = 0;
		end
		17'b01000_00_101_0110011: begin // SRA
			dst = src1 >>> src2[4:0];
			exception = 0;
		end
		17'b00000_00_110_0110011: begin // OR
			dst = src1 | src2;
			exception = 0;
		end	
		17'b00000_00_111_0110011: begin // AND
			dst = src1 & src2;
			exception = 0;
		end
		// 17'b?????_??_???_0?10011: begin
		// 	dst = 32'bx;
		// 	exception = 1;
		// 	$display("[PROC-ALU] Unable to decode alu instruction!");
		// end
		default: begin
			dst = 32'bx;
			exception = 0;
		end
	endcase
end

endmodule
