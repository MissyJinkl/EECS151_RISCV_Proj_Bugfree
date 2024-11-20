`timescale 1ns/1ns
`include "opcode.vh"

module partial_store_tb();
    reg [31:0] instruction;     // Input instruction
    reg [31:0] data_from_reg;   // Data to be written to memory
    reg [31:0] mem_addr;        // Memory address
    reg mem_wen;                // Memory write enable
    wire [31:0] data_to_mem;    // Data written to memory
    wire [3:0] mem_write_mask;  // Write mask for memory
    integer error_count = 0;    // Error counter

    // Instantiate the partial_store module
    partial_store uut (
        .instruction(instruction),
        .data_from_reg(data_from_reg),
        .mem_addr(mem_addr),
        .mem_wen(mem_wen),
        .data_to_mem(data_to_mem),
        .mem_write_mask(mem_write_mask)
    );

    // Test procedure
    initial begin
        // Initialize signals
        mem_wen = 1'b0; // Default memory write disabled

        // Test Case 1: Store Byte (SB), address aligned to byte 0
        #10 instruction = {20'b0, `FNC_SB, 5'b0,`OPC_STORE}; // SB instruction
        mem_wen = 1'b1; // Enable write
        data_from_reg = 32'b00010010001101000101011001111000; // Data: 0x12345678
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned to byte 0
        #10 if (data_to_mem !== {{24{1'b0}}, data_from_reg[7:0]} || mem_write_mask !== 4'b0001) begin
            $error("Test Case 1 (SB) Failed: instruction=%b, mem_addr=%b, data_to_mem=%b, mem_write_mask=%b, expected_data=%b, expected_mask=4'b0001",
                   instruction, mem_addr, data_to_mem, mem_write_mask, {{24{1'b0}}, data_from_reg[7:0]});
            error_count = error_count + 1;
        end

        // Test Case 2: Store Halfword (SH), address aligned to halfword 0
        #10 instruction = {20'b0, `FNC_SH, 5'b0,`OPC_STORE}; // SH instruction
        data_from_reg = 32'b00010010001101000101011001111000; // Data: 0x12345678
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned to halfword 0
        #10 if (data_to_mem !== {{16{1'b0}}, data_from_reg[15:0]}|| mem_write_mask !== 4'b0011) begin
            $error("Test Case 2 (SH) Failed: instruction=%b, mem_addr=%b, data_to_mem=%b, mem_write_mask=%b, expected_data=%b, expected_mask=4'b0011",
                   instruction, mem_addr, data_to_mem, mem_write_mask, {{16{1'b0}}, data_from_reg[15:0]});
            error_count = error_count + 1;
        end

        // Test Case 3: Store Word (SW)
        #10 instruction = {20'b0, `FNC_SW, 5'b0,`OPC_STORE}; // SW instruction
        data_from_reg = 32'b10001001101010111100110111101111; // Data: 0x89ABCDEF
        mem_addr = 32'b00000000000000000000000000000100; // Address: aligned to word
        #10 if (data_to_mem !== data_from_reg || mem_write_mask !== 4'b1111) begin
            $error("Test Case 3 (SW) Failed: instruction=%b, mem_addr=%b, data_to_mem=%b, mem_write_mask=%b, expected_data=%b, expected_mask=4'b1111",
                   instruction, mem_addr, data_to_mem, mem_write_mask, data_from_reg );
            error_count = error_count + 1;
        end

        // Test Case 4: Store Byte (SB), address aligned to byte 2
        #10 instruction = {20'b0, `FNC_SB, 5'b0,`OPC_STORE}; // SB instruction
        data_from_reg = 32'b00010010001101000101011001111000; // Data: 0x12345678
        mem_addr = 32'b00000000000000000000000000000010; // Address: aligned to byte 2
        #10 if (data_to_mem !== {{8{1'b0}}, data_from_reg[7:0], {16{1'b0}}} || mem_write_mask !== 4'b0100) begin
            $error("Test Case 4 (SB) Failed: instruction=%b, mem_addr=%b, data_to_mem=%b, mem_write_mask=%b, expected_data=%b, expected_mask=4'b0100",
                   instruction, mem_addr, data_to_mem, mem_write_mask, {{8{1'b0}}, data_from_reg[7:0], {16{1'b0}}});
            error_count = error_count + 1;
        end

        // Test Case 5: Store Halfword (SH), address aligned to halfword 1
        #10 instruction = {20'b0, `FNC_SH, 5'b0,`OPC_STORE}; // SH instruction
        data_from_reg = 32'b00010010001101000101011001111000; // Data: 0x12345678
        mem_addr = 32'b00000000000000000000000000000010; // Address: aligned to halfword 1
        #10 if (data_to_mem !== {data_from_reg[15:0], {16{1'b0}}} || mem_write_mask !== 4'b1100) begin
            $error("Test Case 5 (SH) Failed: instruction=%b, mem_addr=%b, data_to_mem=%b, mem_write_mask=%b, expected_data=%b, expected_mask=4'b1100",
                   instruction, mem_addr, data_to_mem, mem_write_mask, {data_from_reg[15:0], {16{1'b0}}});
            error_count = error_count + 1;
        end

        // Test Case 6: Write Enable Disabled
        #10 instruction = {20'b0, `FNC_SW, 5'b0,`OPC_STORE}; // SW instruction
        mem_wen = 1'b0; // Disable write
        data_from_reg = 32'b10101010101010101010101010101010; // Data: 0xAAAAAAAA
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned
        #10 if (data_to_mem !== data_from_reg || mem_write_mask !== 4'b0000) begin
            $error("Test Case 6 (Write Disabled) Failed: instruction=%b, mem_addr=%b, data_to_mem=%b, mem_write_mask=%b, expected_data=%b, expected_mask=4'b0000",
                   instruction, mem_addr, data_to_mem, mem_write_mask, data_from_reg);
            error_count = error_count + 1;
        end

        // Final Results
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed!", error_count);
        end
        $finish();
    end
endmodule