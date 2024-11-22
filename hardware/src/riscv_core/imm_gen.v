`include "opcode.vh"
module imm_gen(
    input [31:0] instruction,
    output reg [31:0] imm
);
    always @(*) begin
        imm = 32'b0; 
        case(instruction[6:2])
            // I-type
            `OPC_JALR_5: imm = {{21{instruction[31]}}, instruction[30:20]};
            `OPC_LOAD_5: imm = {{21{instruction[31]}}, instruction[30:20]};
            // I*-type & arithmetic I
            `OPC_ARI_ITYPE_5: begin
                if ((instruction[14:12] == `FNC_SLL) || (instruction[14:12] == `FNC_SRL_SRA)) begin
                    imm = {{27{1'b0}}, instruction[24:20]}; 
                end 
                //else begin
                    //if((instruction[14:12] == `FNC_SLTU)) imm = {{20'b0}, instruction[31:20]};
                    else imm = {{21{instruction[31]}}, instruction[30:20]};
                // end
            end
            // S-type
            `OPC_STORE_5: imm = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
            // B-type
            `OPC_BRANCH_5: imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            // U-type
            `OPC_LUI_5 : imm = {instruction[31:12], {12{1'b0}}};
            `OPC_AUIPC_5: imm = {instruction[31:12], {12{1'b0}}};
            // J-type
            `OPC_JAL_5: imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            // CSR
            5'b11100: begin
                if (instruction[14:12] == 3'b101) imm = {{27{1'b0}}, instruction[19:15]}; //csrrwi, alu = 4'd15
                else if (instruction[14:12] == 3'b001) imm = 32'b0; //csrrw, alu = 4'd0
                else imm = 32'b0;
            end
            default: imm = 32'b0;

        endcase
    end

endmodule