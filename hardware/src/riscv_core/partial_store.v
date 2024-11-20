module partial_store (
    input [31:0] instruction,
    input [31:0] data_from_reg,
    input [31:0] mem_addr,
    input mem_wen,
    output reg [31:0] data_to_mem,
    output reg [3:0] mem_write_mask
);

    wire opcode, func3;
    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];

    always @(*) begin
        if ((opcode != `OPC_STORE) || (mem_wen == 1'b0)) begin
            mem_write_mask = 4'b0000;
            data_to_mem = data_from_reg;
        end else begin
            case(func3)
                `FNC_SB: begin
                    case(mem_addr[1:0])
                        2'b00: begin
                            data_to_mem = {{24{1'b0}}, data_from_reg[7:0]};
                            mem_write_mask = 4'b0001;
                        end

                        2'b01: begin
                            data_to_mem = {{16{1'b0}}, data_from_reg[7:0], {8{1'b0}}};
                            mem_write_mask = 4'b0010;
                        end

                        2'b10: begin
                            data_to_mem = {{8{1'b0}}, data_from_reg[7:0], {16{1'b0}}};
                            mem_write_mask = 4'b0100;
                        end

                        2'b11: begin
                            data_to_mem = {data_from_reg[7:0], {24{1'b0}}};
                            mem_write_mask = 4'b1000;
                        end
                    endcase
                end
                
                `FNC_SH: begin
                    case(mem_addr[1:0])
                        2'b00: begin
                            data_to_mem = {{16{1'b0}}, data_from_reg[15:0]};
                            mem_write_mask = 4'b0011;
                        end

                        2'b10: begin
                            data_to_mem = {data_from_reg[15:0], {16{1'b0}}};
                            mem_write_mask = 4'b1100;
                        end
                    endcase
                end

                `FNC_SW: begin
                    data_to_mem = data_from_reg;
                    mem_write_mask = 4'b1111;
                end

            endcase
        end
    end
endmodule