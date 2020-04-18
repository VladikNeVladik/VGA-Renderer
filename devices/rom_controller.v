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

	input [11:0] data_addr,
	input [11:0]instr_addr,

	output reg [31:0]data, 
	output reg [31:0]instr
);

reg [31:0]read_only_memory[1023:0];
initial begin
    $readmemh(ROM_IMAGE, read_only_memory, 0, 1023);
end

always @(posedge clk) begin
	data  <= read_only_memory[ data_addr[11:2]];
	instr <= read_only_memory[instr_addr[11:2]];
end

endmodule

