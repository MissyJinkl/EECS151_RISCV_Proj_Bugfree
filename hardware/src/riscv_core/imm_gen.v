module imm_gen(
    input [31:0] instruction;
    input [2:0] imm_sel;
    output reg [31:0] imm;
);
    always @(*) begin
        case(imm_sel)
            // I-type
            3'b000: imm = {{21{instruction[31]}}, instruction[30:20]};
            // S-type
            3'b001: imm = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
            // B-type
            3'b010: imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            // U-type
            3'b011: imm = {instruction[31:12], {12{1'b0}}};
            // J-type
            3'b100: imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        endcase
    end

endmodule