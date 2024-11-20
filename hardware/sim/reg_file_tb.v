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

        // Test Case 1: Store Byte (SB), address aligned to byte 0 (0b00)
        #10 instruction = {25'b0, 3'b000, 7'b0100011}; // SB instruction
        mem_wen = 1'b1; // Enable write
        data_from_reg = 32'b00010010001101000101011001111000; // Data: 0x12345678
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned to byte 0
        #10 if (data_to_mem !== 32'b00000000000000000000000001111000 || mem_write_mask !== 4'b0001) begin
            $error("Test Case 1 (SB) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 2: Store Byte (SB), address aligned to byte 1 (0b01)
        #10 mem_addr = 32'b00000000000000000000000000000001; // Address: aligned to byte 1
        #10 if (data_to_mem !== 32'b00000000000000000000000000000000 || mem_write_mask !== 4'b0010) begin
            $error("Test Case 2 (SB) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 3: Store Byte (SB), address aligned to byte 2 (0b10)
        #10 mem_addr = 32'b00000000000000000000000000000010; // Address: aligned to byte 2
        #10 if (data_to_mem !== 32'b00000000000000000000000000000000 || mem_write_mask !== 4'b0100) begin
            $error("Test Case 3 (SB) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 4: Store Byte (SB), address aligned to byte 3 (0b11)
        #10 mem_addr = 32'b00000000000000000000000000000011; // Address: aligned to byte 3
        #10 if (data_to_mem !== 32'b00000000000000000000000000000000 || mem_write_mask !== 4'b1000) begin
            $error("Test Case 4 (SB) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 5: Store Halfword (SH), address aligned to halfword 0 (0b00)
        #10 instruction = {25'b0, 3'b001, 7'b0100011}; // SH instruction
        data_from_reg = 32'b00010010001101000101011001111000; // Data: 0x12345678
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned to halfword 0
        #10 if (data_to_mem !== 32'b00000000000000000101011001111000 || mem_write_mask !== 4'b0011) begin
            $error("Test Case 5 (SH) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 6: Store Halfword (SH), address aligned to halfword 1 (0b10)
        #10 mem_addr = 32'b00000000000000000000000000000010; // Address: aligned to halfword 1
        #10 if (data_to_mem !== 32'b00010010001101000101011001111000 || mem_write_mask !== 4'b1100) begin
            $error("Test Case 6 (SH) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 7: Store Word (SW)
        #10 instruction = {25'b0, 3'b010, 7'b0100011}; // SW instruction
        data_from_reg = 32'b10001001101010111100110111101111; // Data: 0x89ABCDEF
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned to word
        #10 if (data_to_mem !== 32'b10001001101010111100110111101111 || mem_write_mask !== 4'b1111) begin
            $error("Test Case 7 (SW) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
            error_count = error_count + 1;
        end

        // Test Case 8: Write Enable Disabled
        #10 mem_wen = 1'b0; // Disable write
        instruction = {25'b0, 3'b010, 7'b0100011}; // SW instruction
        data_from_reg = 32'b00000000000000000000000000000000; // Data: 0x0
        mem_addr = 32'b00000000000000000000000000000000; // Address: aligned
        #10 if (data_to_mem !== data_from_reg || mem_write_mask !== 4'b0000) begin
            $error("Test Case 8 (Write Disabled) Failed: data_to_mem=%b, mem_write_mask=%b", data_to_mem, mem_write_mask);
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
