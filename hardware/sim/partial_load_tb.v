`timescale 1ns/1ns
`include "opcode.vh"

module partial_load_tb();
    reg [31:0] instruction;    // Input instruction
    reg [31:0] data_from_mem;  // Data from memory
    reg [31:0] mem_addr;       // Memory address
    wire [31:0] data_to_reg;   // Data to register
    integer error_count = 0;   // Error counter

    // Instantiate the partial_load module
    partial_load uut (
        .instruction(instruction),
        .data_from_mem(data_from_mem),
        .mem_addr(mem_addr),
        .data_to_reg(data_to_reg)
    );

    // Test procedure
    initial begin
        // Test Case 1: Load Byte (LB)
        #10 instruction = {25'b0, `FNC_LB, `OPC_LOAD}; // Opcode for LOAD with FNC_LB
        #50data_from_mem = 32'b00010010001101000101011001111000; // Binary for 0x12345678
        mem_addr = 32'b00000000000000000000000000000001; // Address (selects 2nd byte)
        #50 if (data_to_reg !== {{24{data_from_mem[15]}}, data_from_mem[15:8]}) begin
            $error("Test Case 1 (LB) Failed: instruction=%b, opcode=%b, funct3=%b, mem_addr=%b, data_to_reg=%b, expected=%b",
                   instruction, instruction[6:0], instruction[14:12], mem_addr, data_to_reg, {{24{data_from_mem[15]}}, data_from_mem[15:8]});
            error_count = error_count + 1;
        end

        // Test Case 2: Load Halfword (LH)
        #10 instruction = {25'b0, `FNC_LH, `OPC_LOAD}; // Opcode for LOAD with FNC_LH
        data_from_mem = 32'b10001001101010111100110111101111; // Binary for 0x89ABCDEF
        mem_addr = 32'b00000000000000000000000000000000; // Address (selects first halfword)
        #10 if (data_to_reg !== {{16{data_from_mem[15]}}, data_from_mem[15:0]}) begin
            $error("Test Case 2 (LH) Failed: instruction=%b, mem_addr=%b, data_to_reg=%b, expected=%b",
                   instruction, mem_addr, data_to_reg, {{16{data_from_mem[15]}}, data_from_mem[15:0]});
            error_count = error_count + 1;
        end

        // Test Case 3: Load Word (LW)
        #10 instruction = {25'b0, `FNC_LW, `OPC_LOAD}; // Opcode for LOAD with FNC_LW
        data_from_mem = 32'b00010010001101000101011001111000; // Binary for 0x12345678
        mem_addr = 32'b00000000000000000000000000000011; // Address (irrelevant for LW)
        #10 if (data_to_reg !== data_from_mem) begin
            $error("Test Case 3 (LW) Failed: instruction=%b, mem_addr=%b, data_to_reg=%b, expected=%b",
                   instruction, mem_addr, data_to_reg, data_from_mem);
            error_count = error_count + 1;
        end

        // Test Case 4: Invalid Opcode
        #10 instruction = 32'b00000000000000000000000000000000; // Invalid opcode
        data_from_mem = 32'b10000111011001010100001100100001; // Binary for 0x87654321
        mem_addr = 32'b00000000000000000000000000000000; // Address
        #10 if (data_to_reg !== data_from_mem) begin
            $error("Test Case 4 (Invalid Opcode) Failed: instruction=%b, mem_addr=%b, data_to_reg=%b, expected=%b",
                   instruction, mem_addr, data_to_reg, data_from_mem);
            error_count = error_count + 1;
        end

        // Test Case 5: Load Byte Unsigned (LBU)
        #10 instruction = {25'b0, `FNC_LBU, `OPC_LOAD}; // Opcode for LOAD with FNC_LBU
        data_from_mem = 32'b10001001101010111100110111101111; // Binary for 0x89ABCDEF
        mem_addr = 32'b00000000000000000000000000000010; // Address (selects 3rd byte)
        #10 if (data_to_reg !== {24'b0, data_from_mem[23:16]}) begin
            $error("Test Case 5 (LBU) Failed: instruction=%b, mem_addr=%b, data_to_reg=%b, expected=%b",
                   instruction, mem_addr, data_to_reg, {24'b0, data_from_mem[23:16]});
            error_count = error_count + 1;
        end

        // Test Case 6: Load Halfword Unsigned (LHU)
        #10 instruction = {25'b0, `FNC_LHU, `OPC_LOAD}; // Opcode for LOAD with FNC_LHU
        data_from_mem = 32'b10001001101010111100110111101111; // Binary for 0x89ABCDEF
        mem_addr = 32'b00000000000000000000000000000001; // Address (selects second halfword)
        #10 if (data_to_reg !== {16'b0, data_from_mem[31:16]}) begin
            $error("Test Case 6 (LHU) Failed: instruction=%b, mem_addr=%b, data_to_reg=%b, expected=%b",
                   instruction, mem_addr, data_to_reg, {16'b0, data_from_mem[31:16]});
            error_count = error_count + 1;
        end

        // Final results
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed!", error_count);
        end
        $finish();
    end
endmodule
