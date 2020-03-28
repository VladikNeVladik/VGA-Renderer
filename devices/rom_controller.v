// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Read Only Memory             
//=============================================================================
// - Stores Visualization Scripts To Be Called From Uart Buffer
//=============================================================================
module ReadOnlyMemory #(
	parameter ROM_IMAGE = ""
) (
	input clk,

	input [8:0] data_addr,
	input [8:0]instr_addr,

	output reg [31:0]data, 
	output reg [31:0]instr
);

reg [31:0]read_only_memory[127:0];
initial begin
    $readmemh(ROM_IMAGE, read_only_memory, 0, 127);
end

always @(posedge clk) begin
	data  <= read_only_memory[data_addr[8:2]];
	instr <= read_only_memory[instr_addr[8:2]];
end

endmodule

