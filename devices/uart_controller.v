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
	output reg [31:0]instr
);

// Uart Input Buffer:
reg uart_buffer_write_enable = 0;

wire [31:0]instr_from_buffer;

UartBufferRam uart_input_buffer(
	.clock(clk),

	.data     (cur_instr),
	.wraddress(head[5:0]),
	.wren     (uart_buffer_write_enable),

	.rdaddress(tail[5:0]),
	.q        (instr_from_buffer)
);

// Hand-made frequency divider:
reg [12:0]cnt = 13'b0;
wire uart_tick = (cnt == 5208);
always @(posedge clk) begin
    if (!uart_rx && bit_num == 4'hF) // start && idle
        cnt <= 13'b0;
    else if (uart_tick)
        cnt <= 13'b0;
    else
        cnt <= cnt + 13'b1;
end

// Recieve procedure:
reg [7:0]head = 0;
reg [7:0]tail = 0;

reg  [31:0]cur_instr = 0;
reg  [ 1:0]byte_num  = 0;

reg  [7:0]cur_byte = 0;
reg  [3:0]bit_num  = 0;

reg parity_bit = 0;

always @(posedge clk) begin
	// Start recieving:
	if (!uart_rx && bit_num == 4'hF)
		bit_num <= 4'h0;
	else if (uart_tick) begin
		// Read data bit:
		if (bit_num  < 8) begin
			bit_num <= bit_num + 4'b1;

			cur_byte[bit_num] <= uart_rx;
		end
		// Read parity bit:
		else if (bit_num == 8) begin
			bit_num <= bit_num + 4'b1;

			parity_bit <= uart_rx;
		end
		// Read stop bit:
		else if (bit_num == 9) begin
			bit_num <= bit_num + 4'b1;

			// Drop instruction if parity check failed:
			if (parity_bit != cur_byte[0] ^ cur_byte[1] ^ cur_byte[2] ^ cur_byte[3] ^
			                  cur_byte[4] ^ cur_byte[5] ^ cur_byte[6] ^ cur_byte[7]) begin
				byte_num <= 0;
			end
			// Otherwise save everything:
			else begin
				// Save byte:
				cur_instr[(3 - byte_num) * 8 +: 8] <= cur_byte;

				// Save instruction:
				if (byte_num == 0 && head - tail > 0) begin
					uart_buffer_write_enable <= 1;
				end

				byte_num <= byte_num + 2'b1;
			end
		end
		else if (bit_num == 10) begin
			bit_num <= 4'hF;

			if (uart_buffer_write_enable) begin
				uart_buffer_write_enable <= 0;

				head <= head + 8'b1;
			end
		end
	end
end

// Fetch instruction:
always @(posedge clk) begin
	if (fetch_enable && instr_addr == 3'b000 && tail != head) begin
		instr <= instr_from_buffer;
		tail <= tail + 8'b1;
	end
	else if (instr_addr == 3'b100) begin
		instr <= 32'hfa9ef06f; // JAL x0, -4
	end
	else begin
		instr <= 32'h00000013; // NOP
	end
end

endmodule