module alu #(
    parameter Bit_Width = 32
)(
    input [Bit_Width-1:0] A,
    input [Bit_Width-1:0] B,
    input [3:0] alu_sel,
    output reg [Bit_Width-1:0] alu_result
);
always @* begin
    case (alu_sel)
        // add
        4'd0: alu_result = A + B;
        // sll
        4'd1: alu_result = A << B[4:0];
        // slt
        4'd2: alu_result = ($signed(A) < $signed(B)) ? 1 : 0;
        // xor
        4'd4: alu_result = A ^ B;
        // srl
        4'd5: alu_result = A >> B[4:0];
        // or
        4'd6: alu_result = A | B;
        // and
        4'd7: alu_result = A & B;
        // asel
        4'd8: alu_result = A;
        // mulh
        //4'd9: alu_result = ($signed(A) * $signed(B)) >> 32;
        // sltu
        4'd11: alu_result = (A < B) ? 1 : 0;
        // sub
        4'd12: alu_result = A - B;
        // sra
        4'd13: alu_result = $signed(A) >>> B[4:0];
        // bsel
        4'd15: alu_result = B;
        // default
        default: alu_result = 0;
    endcase
end
endmodule