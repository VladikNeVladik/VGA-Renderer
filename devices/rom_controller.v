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

	input [9:0] data_addr,
	input [9:0]instr_addr,

	output reg [31:0]data, 
	output reg [31:0]instr
);

reg [31:0]memory[255:0];
initial begin
    $readmemh(ROM_IMAGE, memory, 0, 255);
end

always @(posedge clk) begin
	data  <= memory[data_addr[9:2]];
	instr <= memory[instr_addr[9:2]];
end

endmodule

