module s1_control(
    input [31:0] instruction_s1, instruction_s3,
    output reg hazard2_sel_1, hazard2_sel_2
);
    // handle 2 cycle hazard
    wire [6:0] opcode_s1, opcode_s3;
    wire [2:0] func3_s1, func3_s3;
    assign opcode_s1 = instruction_s1[6:0];
    assign func3_s1 = instruction_s1[14:12];
    assign opcode_s3 = instruction_s3[6:0];
    assign func3_s3 = instruction_s3[14:12];

    wire [4:0] rs1_1, rs1_3, rs2_1, rs2_3, rd_3;
    assign rs1_1 = instruction_s1[19:15];
    assign rs1_3 = instruction_s3[19:15];
    assign rs2_1 = instruction_s1[24:20];
    assign rs2_3 = instruction_s3[24:20];
    assign rd_3 = instruction_s3[11:7];


    always @(*) begin
    if ((opcode_s3 == `OPC_ARI_RTYPE) || (opcode_s3 == `OPC_ARI_ITYPE) || (opcode_s3 == `OPC_AUIPC) || (opcode_s3 == `OPC_LUI)) begin
        if (opcode_s1 == `OPC_ARI_RTYPE || opcode_s1 == `OPC_STORE || opcode_s1 == `OPC_BRANCH) begin
            hazard2_sel_1 = (rs1_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
            hazard2_sel_2 = (rs2_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
        end
        else if (opcode_s1 == `OPC_ARI_ITYPE || opcode_s1 == `OPC_LOAD || opcode_s1 == `OPC_JALR || opcode_s1 == `OPC_CSR) begin
            hazard2_sel_1 = (rs1_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
            hazard2_sel_2 = 1'b1;
        end
        else begin
            hazard2_sel_1 = 1'b1;
            hazard2_sel_2 = 1'b1;
        end
    end else if (opcode_s3 == `OPC_LOAD) begin
        if (opcode_s1 == `OPC_ARI_RTYPE || opcode_s1 == `OPC_STORE || opcode_s1 == `OPC_BRANCH) begin
            hazard2_sel_1 = (rs1_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
            hazard2_sel_2 = (rs2_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
        end
        else if (opcode_s1 == `OPC_ARI_ITYPE || opcode_s1 == `OPC_LOAD || opcode_s1 == `OPC_JALR || opcode_s1 == `OPC_CSR) begin
            hazard2_sel_1 = (rs1_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
            hazard2_sel_2 = 1'b1;
        end
        else begin
            hazard2_sel_1 = 1'b1;
            hazard2_sel_2 = 1'b1;
        end
    end else if (opcode_s3 == `OPC_JALR || opcode_s3 == `OPC_JAL) begin
        if (opcode_s1 == `OPC_ARI_RTYPE || opcode_s1 == `OPC_STORE || opcode_s1 == `OPC_BRANCH) begin
            hazard2_sel_1 = (rs1_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
            hazard2_sel_2 = (rs2_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
        end
        else if (opcode_s1 == `OPC_ARI_ITYPE || opcode_s1 == `OPC_LOAD || opcode_s1 == `OPC_JALR || opcode_s1 == `OPC_CSR) begin
            hazard2_sel_1 = (rs1_1 == rd_3 && rd_3 != 0) ? 1'b0 : 1'b1;
            hazard2_sel_2 = 1'b1;
        end
        else begin
            hazard2_sel_1 = 1'b1;
            hazard2_sel_2 = 1'b1;
        end
    end else begin
        hazard2_sel_1 = 1'b1;
        hazard2_sel_2 = 1'b1;
    end
    end
    
endmodule