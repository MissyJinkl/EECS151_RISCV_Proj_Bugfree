module reg32 (
    input [31:0] d,
    input clk,
    output reg [31:0] q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule

module reg32_with_enable (
    input [31:0] d,
    input clk,
    input en,
    output reg [31:0] q
);
    always @(posedge clk) begin
        q <= en ? d : q;
    end
endmodule