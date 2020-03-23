// No Copyright. Vladislav Aleinik, 2020
module RegisterFile(
	input clk,

	input [ 4:0]dst_addr,
	input [31:0]dst_data,
	input write_enable,

	input [4:0]src_addr_1,
	input [4:0]src_addr_2,

	output [31:0]src_data_1,
	output [31:0]src_data_2
);

// Registers x0-x31:
reg [31:0]regs[31:0];

genvar i;
generate
	for (i = 0; i < 32; i = i + 1) begin : reg_init
		// Set initial values to registers:
		initial regs[i] = 32'b0;
	end
endgenerate

// Delayed write shows up here: write first, read next
assign src_data_1 = (src_addr_1 == dst_addr && write_enable && dst_addr != 0)? dst_data : regs[src_addr_1];
assign src_data_2 = (src_addr_2 == dst_addr && write_enable && dst_addr != 0)? dst_data : regs[src_addr_2];

// Write:
always @(posedge clk) begin
	if (write_enable && dst_addr != 0) begin
		regs[dst_addr] <= dst_data;
	end

	// $strobe("[PROC-REGISTERS]: x00: %h x08: %h  x16: %h x24: %h",    regs[00],  regs[08],   regs[16],  regs[24]);
	// $strobe("[PROC-REGISTERS]: x01: %h x09: %h  x17: %h x25: %h",    regs[01],  regs[09],   regs[17],  regs[25]);
	// $strobe("[PROC-REGISTERS]: x02: %h x10: %h  x18: %h x26: %h",    regs[02],  regs[10],   regs[18],  regs[26]);
	// $strobe("[PROC-REGISTERS]: x03: %h x11: %h  x19: %h x27: %h",    regs[03],  regs[11],   regs[19],  regs[27]);
	// $strobe("[PROC-REGISTERS]: x04: %h x12: %h  x20: %h x28: %h",    regs[04],  regs[12],   regs[20],  regs[28]);
	// $strobe("[PROC-REGISTERS]: x05: %h x13: %h  x21: %h x29: %h",    regs[05],  regs[13],   regs[21],  regs[29]);
	// $strobe("[PROC-REGISTERS]: x06: %h x14: %h  x22: %h x30: %h",    regs[06],  regs[14],   regs[22],  regs[30]);
	// $strobe("[PROC-REGISTERS]: x07: %h x15: %h  x23: %h x31: %h\n",  regs[07],  regs[15],   regs[23],  regs[31]);
end

endmodule

