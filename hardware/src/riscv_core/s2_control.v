module s2_control(
    input [31:0] instruction_s2,
    //input breq, brlt,
    output [1:0] rs1_sel, rs2_sel,
    output brun, a_sel, b_sel, mem_wen,
    output reg [3:0] alu_sel,
);
    assign rs1_sel = 2'b10;
    assign rs2_sel = 2'b10;
    assign brun = instruction_s2[13];
    assign opcode = instruction_s2[6:0];
    assign func3 = instruction_s2[14:12];

    assign a_sel = ((opcode == `OPC_AUIPC) || (opcode == `OPC_JAL) || (opcode == `OPC_BRANCH)) ? 1'b1 : 1'b0;
    assign b_sel = (opcode == `OPC_ARI_RTYPE) ? 1'b0 : 1'b1;
    assign mem_wen = (opcode == `OPC_STORE) ? 1'b1 : 1'b0;
    always @(*) begin
        case(opcode)
            `OPC_CSR: alu_sel = 4'd0;
            `OPC_LUI: alu_sel = 4'd15;
            `OPC_AUIPC: alu_sel = 4'd0;
            `OPC_JAL: alu_sel = 4'd0;
            `OPC_JALR: alu_sel = 4'd0;
            `OPC_BRANCH: alu_sel = 4'd0;
            `OPC_STORE: alu_sel = 4'd0;
            `OPC_LOAD: alu_sel = 4'd0;
            `OPC_ARI_RTYPE: begin
                case(func3)
                    `FNC_ADD_SUB: alu_sel = instruction_s2[30] ? 4'd12 : 4'd0;
                    `FNC_SLL: alu_sel = 4'd1;
                    `FNC_SLT: alu_sel = 4'd2;
                    `FNC_SLTU: alu_sel = 4'd11;
                    `FNC_XOR: alu_sel = 4'd4;
                    `FNC_OR: alu_sel = 4'd6;
                    `FNC_AND: alu_sel = 4'd7;
                    `FNC_SRL_SRA: alu_sel = instruction_s2[30] ? 4'd13 : 4'd5;
                endcase
            end
            `OPC_ARI_ITYPE: begin
                case(func3)
                    `FNC_ADD_SUB: alu_sel = instruction_s2[30] ? 4'd12 : 4'd0;
                    `FNC_SLL: alu_sel = 4'd1;
                    `FNC_SLT: alu_sel = 4'd2;
                    `FNC_SLTU: alu_sel = 4'd11;
                    `FNC_XOR: alu_sel = 4'd4;
                    `FNC_OR: alu_sel = 4'd6;
                    `FNC_AND: alu_sel = 4'd7;
                    `FNC_SRL_SRA: alu_sel = instruction_s2[30] ? 4'd13 : 4'd5;
                endcase
            end
        endcase
    end
endmodule