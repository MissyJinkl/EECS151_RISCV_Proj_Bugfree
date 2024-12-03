// Register with reset and clock enable
module reg_rst(q, d, rst, clk);
    parameter N = 32;
    input [N-1:0] d;
    input rst, clk;
    initial q = {N{1'b0}};
    output reg [N-1:0] q;
    
    always @(posedge clk)
        if (rst) q <= {N{1'b0}};
        else q <= d;
endmodule

// Register with reset and enable
module reg_rst_ce(q, d, rst, ce, clk);
    parameter N = 32;
    input [N-1:0] d;
    input rst, ce, clk;
    initial q = {N{1'b0}};
    output reg [N-1:0] q;
    
    always @(posedge clk)
        if (rst) q <= {N{1'b0}};
        else if (ce) q <= d;
endmodule // REGISTER_R_CE

module reg_1(q, d, clk, rst);
    input d;
    input clk, rst;
    initial q = 1'b0;
    output reg q;
    
    always @(posedge clk)
        if (rst) q <= 1'b0;
        else q <= d;
endmodule