/*
A cache module for storing branch prediction data.

Inputs: 2 asynchronous read ports and 1 synchronous write port.
Outputs: data and cache hit (for each read port)
*/

module bp_cache #(
    parameter AWIDTH=32,  // Address bit width
    parameter DWIDTH=32,  // Data bit width
    parameter LINES=128   // Number of cache lines
) (
    input clk,
    input reset,

    // IO for 1st read port
    input [AWIDTH-1:0] ra0,
    output [DWIDTH-1:0] dout0,
    output hit0,

    // IO for 2nd read port
    input [AWIDTH-1:0] ra1,
    output [DWIDTH-1:0] dout1,
    output hit1,

    // IO for write port
    input [AWIDTH-1:0] wa,
    input [DWIDTH-1:0] din,
    input we

);

    // TODO: Your code
    // 2 asynchronous read
    localparam index_size = $clog2(LINES);
    localparam tag_size = AWIDTH - $clog2(LINES); //no offset

	reg [tag_size-1:0] tag [0:LINES-1];
	reg [0:LINES-1] valid;
	reg [DWIDTH-1:0] data [0:LINES-1];

	assign hit0 = (valid[ra0[index_size-1:0]] == 1'b1) && (tag[ra0[index_size-1:0]] == ra0[AWIDTH-1:index_size]);
	assign hit1 = (valid[ra1[index_size-1:0]] == 1'b1) && (tag[ra1[index_size-1:0]] == ra1[AWIDTH-1:index_size]);
	assign dout0 = data[ra0[index_size-1:0]];
	assign dout1 = data[ra1[index_size-1:0]];

	// 1 synchronous write
	always @(posedge clk) begin
		if (reset) begin
			valid [0:LINES-1] <= 0;
		end
		else if (we) begin
			tag[wa[index_size-1:0]] <= wa[AWIDTH-1:index_size];
			valid[wa[index_size-1:0]] <= 1'b1;
			data[wa[index_size-1:0]] <= din;
		end
	end

endmodule
