`timescale 1ns/1ns

module imm_gen_tb();
    // Signals for testing
    reg [31:0] instruction;   // Input instruction
    reg [2:0] imm_sel;        // Immediate selection signal
    wire [31:0] imm;          // Output immediate
    integer error_count = 0;  // Error counter

    // Instantiate the imm_gen module
    imm_gen uut (
        .instruction(instruction),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    // Test procedure
    initial begin
        // Initialize signals
        instruction = 32'd0;
        imm_sel = 3'd0;

        // Test Case 1: I-type immediate
        #10 instruction = 32'b111111111111_00000_000_00001_0010011; // Addi instruction
        imm_sel = 3'd0; // I-type
        #10 if (imm !== {{21{instruction[31]}}, instruction[30:20]}) begin
            $error("I-type Test Failed: instruction=%b, imm_sel=%d, output=%b, expected=%b",
                   instruction, imm_sel, imm, {{21{instruction[31]}}, instruction[30:20]});
            error_count = error_count + 1;
        end

        // Test Case 2: S-type immediate
        #10 instruction = 32'b1111111_00001_00010_010_00011_0100011; // Store instruction
        imm_sel = 3'd1; // S-type
        #10 if (imm !== {{21{instruction[31]}}, instruction[30:25], instruction[11:7]}) begin
            $error("S-type Test Failed: instruction=%b, imm_sel=%d, output=%b, expected=%b",
                   instruction, imm_sel, imm, {{21{instruction[31]}}, instruction[30:25], instruction[11:7]});
            error_count = error_count + 1;
        end

        // Test Case 3: B-type immediate
        #10 instruction = 32'b1111111_00001_00010_110_11110_1100011; // Branch instruction
        imm_sel = 3'd2; // B-type
        #10 if (imm !== {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}) begin
            $error("B-type Test Failed: instruction=%b, imm_sel=%d, output=%b, expected=%b",
                   instruction, imm_sel, imm, {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0});
            error_count = error_count + 1;
        end

        // Test Case 4: U-type immediate
        #10 instruction = 32'b11111111_11111111_1111_00000_0110111; // LUI instruction
        imm_sel = 3'd3; // U-type
        #10 if (imm !== {instruction[31:12], {12{1'b0}}}) begin
            $error("U-type Test Failed: instruction=%b, imm_sel=%d, output=%b, expected=%b",
                   instruction, imm_sel, imm, {instruction[31:12], {12{1'b0}}});
            error_count = error_count + 1;
        end

        // Test Case 5: J-type immediate
        #10 instruction = 32'b1111111111111111111_00000_1101111; // JAL instruction
        imm_sel = 3'd4; // J-type
        #10 if (imm !== {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}) begin
            $error("J-type Test Failed: instruction=%b, imm_sel=%d, output=%b, expected=%b",
                   instruction, imm_sel, imm, {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0});
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
