module reg32 (
    input [31:0] d,
    input clk,
    output reg [31:0] q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule