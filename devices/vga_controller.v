// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// VGA Controller                 
//=============================================================================
// - Handles All Writes To Video Memory 
// - Asyncronously Renders Video Memory Through VGA in 160x120
//=============================================================================
module VgaController(
	input clk, // 48 MHz

	input [14:0]data_addr,
	input [ 2:0]data_in,

	input write_enable,

	output [2:0]rgb,
	output h_sync, v_sync
);

//-------------------------//
// Create 25.175 MHz Clock //
//-------------------------//

// In:
wire vga_clk;

PllClockMultiplier pll_clk_mul(.inclk0(clk), .c0(vga_clk));

//---------------------//
// VGA Screen Passover //
//---------------------//

// Out:
wire [14:0]pos_x;
wire [14:0]pos_y;

wire vga_read_enable;

VgaSync vga_sync(
	.clk(vga_clk),

	.pos_x(pos_x),
	.pos_y(pos_y),

	.h_sync(h_sync),
	.v_sync(v_sync),

	.active_zone(vga_read_enable)
);

//--------------//
// Video Memory //
//--------------//

// In:
wire [14:0]vga_read_address = vga_read_enable? (pos_x[14:2] + pos_y[14:2] * 160) : 15'b0;

// Out:
wire [2:0]stored_rgb;

assign rgb = stored_rgb;

VideoMemory video_memory(
	// Write at 48 MHz
	.wraddress(data_addr),
	.data     (data_in),
	.wren     (write_enable),
	.wrclock  (clk),

	// Read at 25.175 MHz
	.rdaddress(vga_read_address),
	.rden     (vga_read_enable),
	.rdclock  (vga_clk),
	.q        (stored_rgb)
);

endmodule

//=============================================================================
// VGA Sync                
//=============================================================================
// - Generates Ray X and Y, H_SYNC, V_SYNC from plain clock 
//=============================================================================
module VgaSync(
	input clk,

	output [14:0]pos_x,
	output [14:0]pos_y,

	output reg h_sync,
	output reg v_sync,

	output active_zone
);

parameter [14:0]H_BACK   = 48;
parameter [14:0]H_ACTIVE = 640;
parameter [14:0]H_FRONT  = 16;
parameter [14:0]H_SYNC   = 96;
parameter [14:0]H_TOTAL  = H_FRONT + H_SYNC + H_BACK + H_ACTIVE;

parameter [14:0]V_BACK   = 33;
parameter [14:0]V_ACTIVE = 480;
parameter [14:0]V_FRONT  = 10;
parameter [14:0]V_SYNC   = 2;
parameter [14:0]V_TOTAL  = V_FRONT + V_SYNC + V_BACK + V_ACTIVE;

// | BACK PORCH | ACTIVE ZONE | FRONT PORCH | H_SYNC |

// |++++++++++++|+++++++++++++|+++++++++++++|--------|
// |++++++++++++|+++++++++++++|+++++++++++++|--------| BACK PORCH
// |++++++++++++|+++++++++++++|+++++++++++++|--------|
// |++++++++++++|#############|+++++++++++++|--------|
// |++++++++++++|#############|+++++++++++++|--------|
// |++++++++++++|#############|+++++++++++++|--------| ACTIVE ZONE
// |++++++++++++|#############|+++++++++++++|--------|
// |++++++++++++|#############|+++++++++++++|--------|
// |++++++++++++|+++++++++++++|+++++++++++++|--------|
// |++++++++++++|+++++++++++++|+++++++++++++|--------| FRONT PORCH
// |++++++++++++|+++++++++++++|+++++++++++++|--------|
// |------------|-------------|-------------|--------|
// |------------|-------------|-------------|--------| V_SYNC
// |------------|-------------|-------------|--------|

reg [14:0]h_pos = 0;
reg [14:0]v_pos = 0;

assign pos_x = h_pos - H_BACK;
assign pos_y = v_pos - V_BACK;

initial h_sync = 1;
initial v_sync = 1;

assign active_zone = (pos_x < 640) & (pos_y < 480);

always @(posedge clk) begin
	// Leaving active zone
	if (h_pos == H_BACK + H_ACTIVE + H_FRONT - 1)
    	h_sync <= 0;

    // Horizontal flipover
	if (h_pos == H_TOTAL - 1) begin
    	h_pos  <= 0;
    	h_sync <= 1;

    	// Leaving active zone
    	if (v_pos == V_BACK + V_ACTIVE + V_FRONT - 1)
    		v_sync <= 0;

    	// Vertical flipover
    	if (v_pos == V_TOTAL - 1) begin
    		v_pos  <= 0;
    		v_sync <= 1;
    	end
    	else v_pos <= v_pos + 10'b1;

    end
    else h_pos <= h_pos + 10'b1;
end
endmodule
