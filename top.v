// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// VGA Renderer SoC       
//=============================================================================
// - Is used as a VGA screen driver for a STM32-based space invaders game      
//=============================================================================
module top(
    input CLK,

    // 7-SEGMENT INDICATOR
    output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G,

    // VGA
    output H_SYNC,
    output V_SYNC,
    output [4:0]V_R,
    output [5:0]V_G,
    output [4:0]V_B
);

//=======================//
// Microcontroller State //
//=======================//

wire [31:0]data_to_cpu;
reg  [31:0]cur_instr = 32'h00000013; // NOP

//=========================//
// Central Processing Unit //
//=========================//

// Out:
wire [31:0]data_to_memory;
wire [31:0]data_addr_global;

wire write_enable;
wire [1:0]window_size;
wire zero_extension;

wire [31:0]instr_addr_global;

wire [7:0]exceptions;

Processor #(
//	.INIT_PC(32'h00000200) // UART Buffer Starting Position
	.INIT_PC(32'h00002000) // Rom Starting Position
) cpu(
	.clk(CLK),

	.cur_instr(cur_instr),
	
	.data_in (data_to_cpu),

	.data_out (data_to_memory),
	.data_addr(data_addr_global),

	.mem_write_enable(write_enable),
	.window_size     (window_size),
	.zero_extension  (zero_extension),

	.next_pc(instr_addr_global),

	.exceptions(exceptions[3:0])
);

//===================//
// Memory Controller //
//===================//

// Out:
wire [ 2:0]data_device;
wire [31:0]data_addr_local;

wire [ 2:0]instr_device;
wire [31:0]instr_addr_local;

MemoryController mem_ctrl(
	.data_addr (data_addr_global),
	.instr_addr(instr_addr_global),
	
	.write_enable(write_enable),
	.window_size (window_size),

	.data_device    (data_device),
	.data_addr_local(data_addr_local),

	.instr_device    (instr_device),
	.instr_addr_local(instr_addr_local),
	
	.exceptions(exceptions[7:4])
);

// Device #1
//==================//
// Read Only Memory //
//==================//

// Out:
wire [31:0] data_from_rom;
wire [31:0]instr_from_rom;

ReadOnlyMemory #(
	.ROM_IMAGE("samples/vga_test.mem")
) rom(
	.clk(CLK),

	.data_addr ( data_addr_local[8:0]),
	.instr_addr(instr_addr_local[8:0]),

	.data ( data_from_rom),
	.instr(instr_from_rom)
);

// Device #2
//================//
// Hex Controller //
//================//

// In:
wire write_enable_hex = (data_device == 2) & write_enable;

// Out:
wire [31:0] data_from_hex;

// 7-SEG Anodes Output:
wire [3:0]anodes;
assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4} = ~anodes;

// 7-SEG Segments Output:
wire [6:0]segments;
assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = segments;

HexDisplay hex_display(
	.clk(CLK),

	.data_addr(data_addr_local[1:0]),
	.data_in  (data_to_memory),
	
	.write_enable(write_enable_hex),
	.window_size (window_size),

	.data_out(data_from_hex),

	.anodes  (anodes),
	.segments(segments)
);

// Device #3
//=================//
// UART Controller //
//=================//

wire [31:0]instr_from_uart = 32'bx;

// Device #4
//================//
// VGA Controller //
//================//

// In:
wire write_enable_vga = (data_device == 4) & write_enable;

// VGA Cable Output:
wire [2:0]rgb;
assign V_R = {5{rgb[0]}};
assign V_G = {6{rgb[1]}};
assign V_B = {5{rgb[2]}};

VgaController vga_controller(
	.clk(CLK),

	.data_addr(data_addr_local[14:0]),
	.data_in  (data_to_memory[2:0]),

	.write_enable(write_enable_vga),

	.rgb(rgb),
	.h_sync(H_SYNC),
	.v_sync(V_SYNC)	
);

// Device #5
//=======//
// Stack //
//=======//

wire [31:0]data_from_stack = 32'bx;

// Device #6 (Not Mapped)
//=====================//
// Instruction Counter //
//=====================//

reg [31:0]clock_counter = 0;

always @(posedge CLK) begin
	clock_counter <= clock_counter + 1;
end

//===========================================//
// Demultiplex data and instruction fetch    //
// Apply window size and zero/sign extension //
//===========================================//

reg [31:0]data_to_cpu_unwindowed = 0;

always @(*) begin
	if (window_size != 2'b11) begin
		case (data_device)
			1: data_to_cpu_unwindowed = data_from_rom;
			2: data_to_cpu_unwindowed = data_from_hex;
			5: data_to_cpu_unwindowed = data_from_stack;
			default: begin
				data_to_cpu_unwindowed = 32'bx;
				$display("[VGA-RENDERER] Read/Write access to unknown device!");
			end
		endcase
	end
	else data_to_cpu_unwindowed = 32'bx;

	case (instr_device)
		1: cur_instr = instr_from_rom; 
		3: cur_instr = instr_from_uart;
		default: begin
			cur_instr = instr_from_rom;
			$display("[VGA-RENDERER] Instruction fetch from unknown device!");
		end
	endcase
end

WindowedWordReader word_reader(
	.word_in(data_to_cpu_unwindowed),
	.addr(data_addr_local[1:0]),

	.window_size(window_size),
	.zero_extension(zero_extension),

	.word_out(data_to_cpu)
);

endmodule