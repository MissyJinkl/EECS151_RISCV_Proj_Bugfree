`include "opcode.vh"

module partial_load (
    input [31:0] instruction,
    input [31:0] data_from_mem,
    input [31:0] mem_addr,
    output reg [31:0] data_to_reg
);

    wire [6:0] opcode;
    wire [2:0] func3;
    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];

    always @(*) begin
        data_to_reg = 32'b0;
        if ((opcode == `OPC_LOAD)) begin
            case(func3)
                // Load Byte (LB): 符号扩展
                `FNC_LB: begin
                    case(mem_addr[1:0])
                        2'b00: data_to_reg = {{24{data_from_mem[7]}}, data_from_mem[7:0]};
                        2'b01: data_to_reg = {{24{data_from_mem[15]}}, data_from_mem[15:8]};
                        2'b10: data_to_reg = {{24{data_from_mem[23]}}, data_from_mem[23:16]};
                        2'b11: data_to_reg = {{24{data_from_mem[31]}}, data_from_mem[31:24]};
                    endcase
                end

                // Load Halfword (LH): 符号扩展
                `FNC_LH: begin
                    case(mem_addr[1:0])
                        2'b00: data_to_reg = {{16{data_from_mem[15]}}, data_from_mem[15:0]};
                        2'b01: data_to_reg = {{16{data_from_mem[23]}}, data_from_mem[23:8]};
                        2'b10: data_to_reg = {{16{data_from_mem[31]}}, data_from_mem[31:16]};
                        default: data_to_reg = 32'b0; // 非法地址，默认返回0
                    endcase
                end

                // Load Word (LW): 无需扩展
                `FNC_LW: begin
                    data_to_reg = data_from_mem;
                end

                // Load Byte Unsigned (LBU): 零扩展
                `FNC_LBU: begin
                    case(mem_addr[1:0])
                        2'b00: data_to_reg = {24'b0, data_from_mem[7:0]};
                        2'b01: data_to_reg = {24'b0, data_from_mem[15:8]};
                        2'b10: data_to_reg = {24'b0, data_from_mem[23:16]};
                        2'b11: data_to_reg = {24'b0, data_from_mem[31:24]};
                    endcase
                end

                // Load Halfword Unsigned (LHU): 零扩展
                `FNC_LHU: begin
                    case(mem_addr[1:0])
                        2'b00: data_to_reg = {16'b0, data_from_mem[15:0]};
                        2'b01: data_to_reg = {16'b0, data_from_mem[23:8]};
                        2'b10: data_to_reg = {16'b0, data_from_mem[31:16]};
                        default: data_to_reg = 32'b0; // 非法地址，默认返回0
                    endcase
                end

                // 默认情况：返回0，防止未定义的 func3 值
                default: data_to_reg = 32'b0;

            endcase
        end else begin
            // 非 LOAD 指令，直接返回从内存中加载的原始数据
            data_to_reg = data_from_mem;
        end
    end
endmodule
