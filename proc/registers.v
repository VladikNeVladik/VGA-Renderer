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
assign src_data_1 = (write_enable && dst_addr == src_addr_1 && dst_addr != 0)? dst_data : regs[src_addr_1];
assign src_data_2 = (write_enable && dst_addr == src_addr_2 && dst_addr != 0)? dst_data : regs[src_addr_2];

// Write:
always @(posedge clk) begin
	if (write_enable && dst_addr != 0) begin
		regs[dst_addr] <= dst_data;
	end

end

endmodule

