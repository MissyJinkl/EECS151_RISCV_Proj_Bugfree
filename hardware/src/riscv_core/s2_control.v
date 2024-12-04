module s2_control(
    input [31:0] instruction_s2, instruction_s3, alu_result, pc,
    output brun, a_sel, b_sel, mem_wen, csr_we, imem_ena,
    output reg [3:0] alu_sel,
    output reg forward_sel_1, forward_sel_2
);

    assign brun = instruction_s2[13];
    assign imem_ena = (alu_result[31:29] == 3'b001 && pc[30] == 1'b1);
    //assign imem_ena = 1'b1;

    wire [6:0] opcode, opcode_s3;
    wire [2:0] func3, func3_s3;
    assign opcode = instruction_s2[6:0];
    assign func3 = instruction_s2[14:12];

    assign a_sel = ((opcode == `OPC_AUIPC) || (opcode == `OPC_JAL) || (opcode == `OPC_BRANCH)) ? 1'b1 : 1'b0;
    assign b_sel = (opcode == `OPC_ARI_RTYPE) ? 1'b0 : 1'b1;
    assign mem_wen = (opcode == `OPC_STORE) ? 1'b1 : 1'b0;
    always @(*) begin
        case(opcode)
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
                    default: alu_sel = 4'd0;
                endcase
            end
            `OPC_ARI_ITYPE: begin
                case(func3)
                    `FNC_ADD_SUB: alu_sel = 4'd0;
                    `FNC_SLL: alu_sel = 4'd1;
                    `FNC_SLT: alu_sel = 4'd2;
                    `FNC_SLTU: alu_sel = 4'd11;
                    `FNC_XOR: alu_sel = 4'd4;
                    `FNC_OR: alu_sel = 4'd6;
                    `FNC_AND: alu_sel = 4'd7;
                    `FNC_SRL_SRA: alu_sel = instruction_s2[30] ? 4'd13 : 4'd5;
                    default: alu_sel = 4'd0;
                endcase
            end
            `OPC_CSR: begin
                case(func3)
                    3'b001: alu_sel = 4'd8; //csrrw
                    3'b101: alu_sel = 4'd15; //csrrwi
                    default: alu_sel = 4'd0;
                endcase
            end
            default: alu_sel = 4'd0;
        endcase
    end

    assign csr_we = (opcode == `OPC_CSR) ? 1'b1 : 1'b0;

    // handle hazard
    assign opcode_s3 = instruction_s3[6:0];
    assign func3_s3 = instruction_s3[14:12];

    wire [4:0] rs1_2, rs1_3, rs2_2, rs2_3, rd_2, rd_3;
    assign rs1_2 = instruction_s2[19:15];
    assign rs1_3 = instruction_s3[19:15];
    assign rs2_2 = instruction_s2[24:20];
    assign rs2_3 = instruction_s3[24:20];
    assign rd_2 = instruction_s2[11:7];
    assign rd_3 = instruction_s3[11:7];


    always @(*) begin
    if ((opcode_s3 == `OPC_ARI_RTYPE) || (opcode_s3 == `OPC_ARI_ITYPE) || (opcode_s3 == `OPC_AUIPC) || (opcode_s3 == `OPC_LUI)) begin
        if (opcode == `OPC_ARI_RTYPE || opcode == `OPC_STORE || opcode == `OPC_BRANCH) begin
            forward_sel_1 = (rs1_2 == rd_3) ? 1'b0 : 1'b1;
            forward_sel_2 = (rs2_2 == rd_3) ? 1'b0 : 1'b1;
        end
        else if (opcode == `OPC_ARI_ITYPE || opcode == `OPC_LOAD || opcode == `OPC_JALR || opcode == `OPC_CSR) begin
            forward_sel_1 = (rs1_2 == rd_3) ? 1'b0 : 1'b1;
            forward_sel_2 = 1'b1;
        end
        else begin
            forward_sel_1 = 1'b1;
            forward_sel_2 = 1'b1;
        end
    end /*else if (opcode_s3 == `OPC_LOAD) begin
        if (opcode == `OPC_ARI_RTYPE || opcode == `OPC_STORE || opcode == `OPC_BRANCH) begin
            forward_sel_1 = (rs1_2 == rd_3 && rd_3 != 0) ? 2'b01 : 2'b10;
            forward_sel_2 = (rs2_2 == rd_3 && rd_3 != 0) ? 2'b01 : 2'b10;
        end
        else if (opcode == `OPC_ARI_ITYPE || opcode == `OPC_LOAD || opcode == `OPC_JALR || opcode == `OPC_CSR) begin
            forward_sel_1 = (rs1_2 == rd_3 && rd_3 != 0) ? 2'b01 : 2'b10;
            forward_sel_2 = 2'b10;
        end
        else begin
            forward_sel_1 = 2'b10;
            forward_sel_2 = 2'b10;
        end
    end else if (opcode_s3 == `OPC_JAL) begin
        if (opcode == `OPC_ARI_RTYPE || opcode == `OPC_STORE || opcode == `OPC_BRANCH) begin
            forward_sel_1 = (rs1_2 == rd_3 && rd_3 != 0) ? 2'b11 : 2'b10;
            forward_sel_2 = (rs2_2 == rd_3 && rd_3 != 0) ? 2'b11 : 2'b10;
        end
        else if (opcode == `OPC_ARI_ITYPE || opcode == `OPC_LOAD || opcode == `OPC_JALR || opcode == `OPC_CSR) begin
            forward_sel_1 = (rs1_2 == rd_3 && rd_3 != 0) ? 2'b11 : 2'b10;
            forward_sel_2 = 2'b10;
        end
        else begin
            forward_sel_1 = 2'b10;
            forward_sel_2 = 2'b10;
        end
    end*/ else begin
        forward_sel_1 = 1'b1;
        forward_sel_2 = 1'b1;
    end
    end

endmodule