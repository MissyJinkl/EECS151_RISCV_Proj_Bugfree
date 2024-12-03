module s3_control(
    input [31:0] instruction_s3, instruction_s2,
    input [31:0] addr,
    input rst, breq, brlt, is_jal,
    input  uart_rx_valid,
    input  uart_tx_ready,
    input  [7:0] uart_rx_out,
    input  [31:0] cyc_counter,
    input  [31:0] instr_counter,
    input  [31:0] br_instr_counter,
    input  [31:0] correct_br_counter,
    //input br_pred_taken,
    output reg [2:0] mem_sel,
    output reg [1:0] wb_sel, pc_sel,
    output reg reg_we,
    //output reg rx_data_out_ready,
    output [31:0] io_value
);
    wire [4:0] opcode5;
    wire [2:0] func3;
    wire [4:0] opcode5_s2;
    wire [2:0] func3_s2;
    assign opcode5 = instruction_s3[6:2];
    assign func3 = instruction_s3[14:12];
    assign opcode5_s2 = instruction_s2[6:2];
    assign func3_s2 = instruction_s2[14:12];

    always @(*) begin
        if (rst) pc_sel = 2'd3;
        //else if (is_jal) pc_sel = 2'd2;
        else if (opcode5_s2 == `OPC_JALR_5 || opcode5_s2 == `OPC_JAL_5) pc_sel = 2'd1; // if is jalr
        else if (opcode5_s2 == `OPC_BRANCH_5) begin
            if ((func3_s2 == `FNC_BEQ) && breq) pc_sel = 2'd1;
            else if ((func3_s2 == `FNC_BNE) && !breq) pc_sel = 2'd1;
            else if ((func3_s2 == `FNC_BLT) && brlt) pc_sel = 2'd1;
            else if ((func3_s2 == `FNC_BGE) && !brlt) pc_sel = 2'd1;
            else if ((func3_s2 == `FNC_BLTU) && brlt) pc_sel = 2'd1;
            else if ((func3_s2 == `FNC_BGEU) && !brlt) pc_sel = 2'd1;
            else pc_sel = 2'd0;
        end
        else pc_sel = 2'd0;
    end
    reg [31:0] counter_num;
    wire [31:0] uart_value;
    wire [31:0] uart_control = {30'b0, uart_rx_valid, uart_tx_ready};
    wire [31:0] uart_reciever_data = {24'b0, uart_rx_out};
    assign uart_value = (addr[2]) ? uart_reciever_data : uart_control;
    //assign counter_num = (addr[2]) ? instr_counter : cyc_counter;
    assign io_value = (addr[4]) ? counter_num : uart_value;
    always @(*) begin
        if (addr == 32'h80000010) counter_num = cyc_counter;
        else if (addr == 32'h80000014) counter_num = instr_counter;
        else if (addr == 32'h8000001c) counter_num = br_instr_counter;
        else if (addr == 32'h80000020) counter_num = correct_br_counter;
        else counter_num = 0;
    end

    always @(*) begin
        case(opcode5)
            `OPC_LUI_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            `OPC_AUIPC_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            `OPC_JAL_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd2;
                reg_we = 1'b1;
            end
            `OPC_JALR_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd2;
                reg_we = 1'b1;
            end
            `OPC_BRANCH_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd0;
                reg_we = 1'b0;
            end
            `OPC_STORE_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd0;
                reg_we = 1'b0;
            end
            `OPC_LOAD_5: begin
                //mem_sel = 3'd1;
                wb_sel = 2'd0;
                reg_we = 1'b1;
            end
            `OPC_ARI_RTYPE_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            `OPC_ARI_ITYPE_5: begin
                //mem_sel = 3'd0;
                wb_sel = 2'd1;
                reg_we = 1'b1;
            end
            5'b11100: begin
                //mem_sel = 3'd1;
                wb_sel = 2'd1;
                reg_we = 1'b0;
            end
            default: begin
                //mem_sel = 3'd1;
                wb_sel = 2'd1;
                reg_we = 1'b0;
            end
        endcase
    end
    always @(*) begin
        case(addr[31:30])
            2'b00: mem_sel = 3'd1; //choose dmem
            2'b01: mem_sel = 3'd0; //choode biosmem
            2'b10: mem_sel = 3'd2; //choose io
                //rx_data_out_ready = ((addr[4] == 1'b0) && (addr[2] == 1'b1));
            default: mem_sel = 3'd1;
            endcase
    end

endmodule