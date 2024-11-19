module mux2to1 #(
    parameter Bit_Width = 32
)(
    input [Bit_Width-1:0] in0,
    input [Bit_Width-1:0] in1,
    input sel,
    output reg [Bit_Width-1:0] out
);
always @* begin
    case (sel)
        1'd0: out = in0;
        1'd1: out = in1;
        default: out = 0;
    endcase
end
endmodule

module mux3to1 #(
    parameter Bit_Width = 32
)(
    input [Bit_Width-1:0] in0,
    input [Bit_Width-1:0] in1,
    input [Bit_Width-1:0] in2,
    input [1:0] sel,
    output reg [Bit_Width-1:0] out
);
always @* begin
    case (sel)
        2'b00: out = in0;
        2'b01: out = in1;
        2'b10: out = in2;
        default: out = 0;
    endcase
end
endmodule

module mux4to1 #(
    parameter Bit_Width = 32
)(
    input [Bit_Width-1:0] in0,
    input [Bit_Width-1:0] in1,
    input [Bit_Width-1:0] in2,
    input [Bit_Width-1:0] in3,
    input [1:0] sel,
    output reg [Bit_Width-1:0] out
);
always @* begin
    case (sel)
        2'b00: out = in0;
        2'b01: out = in1;
        2'b10: out = in2;
        2'b11: out = in3;
        default: out = 0;
    endcase
end
endmodule

module mux5to1 #(
    parameter Bit_Width = 32
)(
    input [Bit_Width-1:0] in0,
    input [Bit_Width-1:0] in1,
    input [Bit_Width-1:0] in2,
    input [Bit_Width-1:0] in3,
    input [Bit_Width-1:0] in4,
    input [2:0] sel,
    output reg [Bit_Width-1:0] out
);
always @* begin
    case (sel)
        3'b000: out = in0;
        3'b001: out = in1;
        3'b010: out = in2;
        3'b011: out = in3;
        3'b100: out = in4;
        default: out = 0;
    endcase
end
endmodule