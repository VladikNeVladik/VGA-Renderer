// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// UART Controller            
//=============================================================================
// - Asyncronously reads instructions from outside
// - Parity Bit Enabled
// - Handles all instruction fetches from UART buffer
//=============================================================================
module UartController(
	input clk,

	input uart_rx,

	input            fetch_enable,
	input      [ 2:0]instr_addr,
	output reg [31:0]instr,
	output reg [31:0]seg7 = 0
);

// Bit rate is 48000000/192 = 250kbps
localparam CLK_PER_BIT = 192;
localparam START_SHIFT = 96;

// Initialization:
reg [31:0]uart_init_saturation = 0;
reg uart_initialized = 0;

always @(posedge clk) begin
	if (!uart_initialized && actual_rx) begin
		uart_init_saturation <= uart_init_saturation + 1;

		if (uart_init_saturation == 4800000) begin
			uart_initialized <= 1;
		end
	end
	if (!uart_initialized && !actual_rx) begin
		uart_init_saturation <= 0;
	end
end

// Uart RX debouncer:
reg actual_rx = 0;
reg [7:0]debouncer_saturation = 0;
always @(posedge clk) begin
	if (uart_rx && debouncer_saturation != 8'h32)
		debouncer_saturation <= debouncer_saturation + 1;

	if (!uart_rx && debouncer_saturation != 8'h0)
		debouncer_saturation <= debouncer_saturation - 1;

	if (debouncer_saturation >= 8'h28)
		actual_rx <= 1;

	if (debouncer_saturation <= 8'h4)
		actual_rx <= 0;
end

// Uart Input Buffer:
localparam UART_BUFFER_SIZE = 64;

reg uart_buffer_write_enable = 0;

reg [7:0]head = 0;
reg [7:0]tail = 0;

reg [31:0]uart_input_buffer[63:0];

// Hand-made frequency divider:
reg [9:0]cnt = 0;
wire uart_tick = (cnt == CLK_PER_BIT - 1);
always @(posedge clk) begin
    if (!actual_rx && bit_num == 4'hF) begin // start && idle
        cnt <= -START_SHIFT;
    end else if (uart_tick) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end

// Recieve procedure:
reg [31:0]cur_instr = 0;
reg [ 1:0]byte_num  = 0;

reg [7:0]cur_byte = 0;
reg [3:0]bit_num  = 4'hF;

reg parity_check_failed = 0;

always @(posedge clk) begin
	// Read start bit:
	if (uart_initialized && bit_num == 4'hF && !actual_rx) begin
		bit_num <= 0;
	end

	// Start recieving:
	if (uart_tick) begin
		// Read data bits:
		if (bit_num < 8) begin
			bit_num <= bit_num + 1;

			cur_byte[bit_num] <= actual_rx;
		end
		// Read parity bit:
		else if (bit_num == 8) begin
			bit_num <= bit_num + 1;

			// Drop instruction if parity check failed:
			if (actual_rx != cur_byte[0] ^ cur_byte[1] ^ cur_byte[2] ^ cur_byte[3] ^
			                 cur_byte[4] ^ cur_byte[5] ^ cur_byte[6] ^ cur_byte[7]) begin
				parity_check_failed <= 1;
			end

			// Save byte (assuming transmitter is little-endian):
			cur_instr[byte_num * 8 +: 8] <= cur_byte;
		end
		// Read stop bit:
		else if (bit_num == 9) begin
			bit_num <= 4'hF;
			byte_num <= byte_num + 1;

			// Save instruction:
			if (byte_num == 3) begin
				if ((head != tail + UART_BUFFER_SIZE) && !parity_check_failed) begin
					uart_input_buffer[head[5:0]] <= cur_instr;
					head <= head + 1;
				end

				parity_check_failed <= 0;
			end
		end
	end
end

// Fetch instruction:
always @(posedge clk) begin
	if (fetch_enable && !uart_tick && instr_addr == 3'b000 && tail != head) begin
		instr <= uart_input_buffer[tail[5:0]];
		tail  <= tail + 1;

		seg7 <= seg7 + 1;
	end
	else if (instr_addr == 3'b100) begin
		instr <= 32'hffdff06f; // JAL x0, -4
	end
	else begin
		instr <= 32'h00000013; // NOP
	end
end
endmodule
