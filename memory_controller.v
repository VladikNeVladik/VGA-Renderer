// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Memory Controller                    
//=============================================================================
// - All data to and from devices passes through Memory Controller 
// - Converts physical address to device id and local device address
// - Performs checks to read/write/execute code from device memory
//=============================================================================
module MemoryController(
	input [31:0] data_addr,
	input [31:0]instr_addr,

	input write_enable,
	input [1:0]window_size,

	output reg [31:0]data_addr_local,
	output reg [ 2:0]data_device,

	output reg [31:0]instr_addr_local,
	output reg [ 2:0]instr_device,

	output reg [3:0]exceptions
);

//==================//
// Read Only Memory //
//==================//
// Mapped at 0x00002000 - 0x000023FF 
// Device Id = 1
// Read      = Yes
// Write     = No
// Execute   = Yes

wire [9:0]rom_addr_data  =  data_addr[9:0];
wire [9:0]rom_addr_instr = instr_addr[9:0];

//=============//
// Hex Display //
//=============//
// Mapped at 0x00000100 - 0x00000101
// Device Id = 2
// Read      = Yes
// Write     = Yes
// Execute   = No

wire hex_addr_data  =  data_addr[0];
wire hex_addr_instr = instr_addr[0];

//===================//
// Uart Input Buffer //
//===================//
// Mapped at 0x00000200 - 0x000002FF
// Device Id = 3
// Read      = No
// Write     = No
// Execute   = Yes

wire [7:0]uart_addr_data  =  data_addr[7:0];
wire [7:0]uart_addr_instr = instr_addr[7:0];

//==========================//
// VGA 320x240 Video Memory //
//==========================//
// Mapped at 0xEEE00000 - 0xEEE12BFF
// Device Id = 4
// Read      = No 
// Write     = Yes
// Execute   = No 

wire [17:0]vga_addr_data  =  data_addr[17:0];
wire [17:0]vga_addr_instr = instr_addr[17:0];

//=======//
// Stack //
//=======//
// Mapped at 0xFFFFF000 - 0xFFFFFFFF
// Device Id = 5
// Read      = Yes
// Write     = Yes
// Execute   = No

wire [11:0]stack_addr_data  =  data_addr[11:0];
wire [11:0]stack_addr_instr = instr_addr[11:0];

always @(*) begin
//---------------------------//
// Perform Read/Write Checks //
//---------------------------//
	// ROM:
	if ((data_addr & 32'hFFFFFC00) == 32'h00002000) begin
		data_device     = 1;
		data_addr_local = rom_addr_data;

		if (write_enable && window_size != 2'b11) begin
			exceptions[0] = 1;
			$display("[MEMORY-CONTROLLER] ROM write forbidden!");
		end
		else exceptions[0] = 0;
	end

	// Hex Display:
	else if ((data_addr & 32'hFFFFFFFE) == 32'h00000100) begin
		data_device     = 2;
		data_addr_local = hex_addr_data;

		exceptions[0] = 0;
	end

	// Uart Input Buffer:
	else if ((data_addr & 32'hFFFFFF00) == 32'h00000200) begin
		data_device     = 3;
		data_addr_local = uart_addr_data;

		if (window_size != 2'b11) begin
			exceptions[0] = 1;
			$display("[MEMORY-CONTROLLER] UART input buffer read/write forbidden!");
		end
		else exceptions[0] = 0;
	end

	// VGA Video Memory:
	else if (32'hEEE00000 <= data_addr && data_addr < 32'hEEE12C00) begin
		data_device     = 4;
		data_addr_local = vga_addr_data;

		if (!write_enable && window_size != 2'b11) begin
			exceptions[0] = 1;
			$display("[MEMORY-CONTROLLER] VGA memory read forbidden!");
		end
		else exceptions[0] = 0;
	end

	// Stack:
	else if ((data_addr & 32'hFFFFF000) == 32'hFFFFF000) begin
		data_device     = 5;
		data_addr_local = stack_addr_data;

		exceptions[0] = 0;
	end

	// Default case:
	else begin
		exceptions[0]   = 0;
		data_device     = 0;
		data_addr_local = 0;
	end
	
	// Check for data access address alignment:
	if (data_addr[1:0] != 0 && window_size == 2'b00 ||
		data_addr[  0] != 0 && window_size == 2'b01) begin
		exceptions[1] = 1;
		$display("[MEMORY-CONTROLLER] Unaligned data read/write!");
	end
	else exceptions[1] = 0;

//--------------------------//
// Perform Execution Checks //
//--------------------------//
	// ROM:
	if ((instr_addr & 32'hFFFFFC00) == 32'h00002000) begin
		instr_device     = 1;
		instr_addr_local = rom_addr_instr;

		exceptions[2] = 0;
	end

	// Hex Display:
	else if ((instr_addr & 32'hFFFFFFFE) == 32'h00000100) begin
		instr_device     = 2;
		instr_addr_local = hex_addr_instr;

		exceptions[2] = 1;
		$display("[MEMORY-CONTROLLER] Hex Display instruction fetch forbidden!");
	end

	// Uart Input Buffer:
	else if ((instr_addr & 32'hFFFFFF00) == 32'h00000200) begin
		instr_device     = 3;
		instr_addr_local = uart_addr_instr;

		exceptions[2] = 0;
	end

	// VGA Video Memory:
	else if (32'hEEE00000 <= instr_addr && instr_addr < 32'hEEE12C00) begin
		instr_device     = 4;
		instr_addr_local = vga_addr_instr;

		exceptions[2] = 1;
		$display("[MEMORY-CONTROLLER] VGA memory instruction fetch forbidden!");
	end

	// Stack:
	else if ((instr_addr & 32'hFFFFF000) == 32'hFFFFF000) begin
		instr_device     = 5;
		instr_addr_local = stack_addr_instr;

		exceptions[2] = 1;
		$display("[MEMORY-CONTROLLER] Stack instruction fetch forbidden!");
	end

	// Default case:
	else begin
		exceptions[2]    = 1;
		instr_device     = 0;
		instr_addr_local = 0;
	end

	// Check for instruction fetch address alignment:
	if (instr_addr[1:0] != 0) begin
		exceptions[3] = 1;
		$display("[MEMORY-CONTROLLER] Unaligned instruction fetch!");
	end
	else exceptions[3] = 0;
end

endmodule