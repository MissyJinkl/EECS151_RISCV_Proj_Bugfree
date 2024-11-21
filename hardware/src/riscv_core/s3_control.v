module s3_control(
    input [31:0] instruction_s3,
    input rst, breq, brlt,
    output reg [2:0] mem_sel,
    output reg [1:0] wb_sel, pc_sel,
    output reg reg_we
);
    wire [4:0] opcode5;
    wire [2:0] func3;
    assign opcode5 = instruction_s3[6:2];
    assign func3 = instruction_s3[14:12];

    always @(*) begin
        if (rst) pc_sel = 2'd3;
        else if (opcode5 == `OPC_JAL_5) pc_sel = 2'd1;
        else if (opcode5 == `OPC_JALR_5) pc_sel = 2'd1;
        // we are not using jal forwarding now, modify later
        else if (opcode5 == `OPC_BRANCH_5) begin
            if ((func3 == `FNC_BEQ) && breq) pc_sel = 2'd1;
            if ((func3 == `FNC_BNE) && !breq) pc_sel = 2'd1;
            if ((func3 == `FNC_BLT) && brlt) pc_sel = 2'd1;
            if ((func3 == `FNC_BGE) && !brlt) pc_sel = 2'd1;
            if ((func3 == `FNC_BLTU) && brlt) pc_sel = 2'd1;
            if ((func3 == `FNC_BGEU) && !brlt) pc_sel = 2'd1;
        end
        else pc_sel = 2'd0;
    end

    

    always @(*) begin
        case(opcode5)
            `OPC_LUI_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            `OPC_AUIPC_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            `OPC_JAL_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd2;
                reg_we = 1'b1;
            end
            `OPC_JALR_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd2;
                reg_we = 1'b1;
            end
            `OPC_BRANCH_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd0;
                reg_we = 1'b0;
            end
            `OPC_STORE_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd0;
                reg_we = 1'b0;
            end
            `OPC_LOAD_5: begin
                mem_sel = 3'd1;
                wb_sel = 2'd0;
                reg_we = 1'b1;
            end
            `OPC_ARI_RTYPE_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            `OPC_ARI_ITYPE_5: begin
                mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            5'b11100: begin
                mem_sel = 3'd1;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
        endcase
    end

endmodule