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
        if ((opcode == `OPC_LOAD)) begin
        //if ((1 ==1)) begin
            case(func3)
                `FNC_LB: begin
                    case(mem_addr[1:0])
                        2'b00: begin
                            data_to_reg = {{24{data_from_mem[7]}}, data_from_mem[7:0]};
                        end

                        2'b01: begin
                            data_to_reg = {{24{data_from_mem[15]}}, data_from_mem[15:8]};
                        end

                        2'b10: begin
                            data_to_reg = {{24{data_from_mem[23]}}, data_from_mem[23:16]};
                        end

                        2'b11: begin
                            data_to_reg = {{24{data_from_mem[31]}}, data_from_mem[31:24]};
                        end
                    endcase
                end
                
                `FNC_LH: begin
                    case(mem_addr[1:0])
                        2'b00: begin
                            data_to_reg = {{16{data_from_mem[15]}}, data_from_mem[15:0]};
                        end

                        2'b01: begin
                            data_to_reg = {{16{data_from_mem[23]}}, data_from_mem[23:8]};
                        end

                        2'b10: begin
                            data_to_reg = {{16{data_from_mem[31]}}, data_from_mem[31:16]};
                        end
                    endcase
                end

                `FNC_LW: begin
                    data_to_reg = data_from_mem;
                end

            endcase
        end else begin 
            data_to_reg = data_from_mem;
            //data_to_reg = 0;
        end
    end
endmodule