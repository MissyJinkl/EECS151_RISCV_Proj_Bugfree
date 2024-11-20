`timescale 1ns/1ns
`include "opcode.vh"

module imm_gen_tb();
    reg [31:0] instruction;      // Input instruction
    wire [31:0] imm;             // Output immediate value
    integer error_count = 0;     // Error counter

    // Instantiate the imm_gen module
    imm_gen uut (
        .instruction(instruction),
        .imm(imm)
    );

    // Test procedure
    initial begin
        // Test Case 1: I-type (JALR/LOAD)
        instruction = {21'b111111111111111111111, 11'b00000000011}; // imm=0xFFFFFFFC
        #10 if (imm !== 32'hFFFFFFFC) begin
            $error("Test Case 1 (I-type) Failed: instruction=%b, imm=%h, expected=0xFFFFFFFC", instruction, imm);
            error_count = error_count + 1;
        end

        // Test Case 2: I-type Arithmetic (SRL/SRA)
        instruction = {27'b0, 5'b00011, 7'b0010011}; // imm=0x03
        #10 if (imm !== 32'h00000003) begin
            $error("Test Case 2 (I-type Arithmetic) Failed: instruction=%b, imm=%h, expected=0x00000003", instruction, imm);
            error_count = error_count + 1;
        end

        // Test Case 3: S-type
        instruction = {7'b1111111, 5'b00011, 5'b00101, 5'b00011, 7'b0100011}; // imm=0xFFFFFFFC
        #10 if (imm !== 32'hFFFFFFFC) begin
            $error("Test Case 3 (S-type) Failed: instruction=%b, imm=%h, expected=0xFFFFFFFC", instruction, imm);
            error_count = error_count + 1;
        end

        // Test Case 4: B-type
        instruction = {7'b1, 6'b100110, 5'b00011, 5'b00001, 4'b0010, 1'b0, 7'b1100011}; // imm=0x64
        #10 if (imm !== 32'h00000064) begin
            $error("Test Case 4 (B-type) Failed: instruction=%b, imm=%h, expected=0x00000064", instruction, imm);
            error_count = error_count + 1;
        end

        // Test Case 5: U-type (LUI)
        instruction = {20'b10000000000000000000, 12'b0}; // imm=0x80000000
        #10 if (imm !== 32'h80000000) begin
            $error("Test Case 5 (U-type) Failed: instruction=%b, imm=%h, expected=0x80000000", instruction, imm);
            error_count = error_count + 1;
        end

        // Test Case 6: J-type
        instruction = {1'b1, 10'b0000000101, 1'b0, 8'b00000011, 2'b01, 8'b10000001, 7'b1101111}; // imm=0x1234
        #10 if (imm !== 32'h00001234) begin
            $error("Test Case 6 (J-type) Failed: instruction=%b, imm=%h, expected=0x00001234", instruction, imm);
            error_count = error_count + 1;
        end

        // Test Case 7: CSR Instruction (CSRRWI)
        instruction = {7'b0, 5'b01010, 5'b00000, 3'b101, 5'b00000, 7'b1110011}; // imm=0x0A
        #10 if (imm !== 32'h0000000A) begin
            $error("Test Case 7 (CSR CSRRWI) Failed: instruction=%b, imm=%h, expected=0x0000000A", instruction, imm);
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
