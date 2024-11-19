`timescale 1ns/1ns

module reg_file_tb();
    // Signals for testing
    reg clk;
    reg we;
    reg [4:0] ra1, ra2, wa;    // Read and write addresses
    reg [31:0] wd;             // Write data
    wire [31:0] rd1, rd2;      // Read data
    integer error_count = 0;   // Error counter

    // Instantiate the reg_file module
    reg_file uut (
        .clk(clk),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    // Test procedure
    initial begin
        // Initialize signals
        we = 0;
        ra1 = 5'b0;
        ra2 = 5'b0;
        wa = 5'b0;
        wd = 32'b0;

        // Test Case 1: Write to register and read back
        #10 wa = 5'd1; wd = 32'hDEADBEEF; we = 1; // Write 0xDEADBEEF to register 1
        #10 we = 0; ra1 = 5'd1;                  // Read from register 1
        #10 if (rd1 !== 32'hDEADBEEF) begin
            $error("Test Case 1 Failed: wa=%d, wd=%h, rd1=%h, expected=%h", wa, wd, rd1, 32'hDEADBEEF);
            error_count = error_count + 1;
        end

        // Test Case 2: Write to register 2 and read from register 2
        #10 wa = 5'd2; wd = 32'hCAFEBABE; we = 1; // Write 0xCAFEBABE to register 2
        #10 we = 0; ra2 = 5'd2;                  // Read from register 2
        #10 if (rd2 !== 32'hCAFEBABE) begin
            $error("Test Case 2 Failed: wa=%d, wd=%h, rd2=%h, expected=%h", wa, wd, rd2, 32'hCAFEBABE);
            error_count = error_count + 1;
        end

        // Test Case 3: Attempt to write to register 0
        #10 wa = 5'd0; wd = 32'h12345678; we = 1; // Attempt to write to register 0
        #10 we = 0; ra1 = 5'd0;                  // Read from register 0
        #10 if (rd1 !== 32'b0) begin
            $error("Test Case 3 Failed: wa=%d, wd=%h, rd1=%h, expected=%h", wa, wd, rd1, 32'b0);
            error_count = error_count + 1;
        end


        // Test Case 4: Write to multiple registers and read back
        #10 wa = 5'd5; wd = 32'hABCD1234; we = 1; // Write 0xABCD1234 to register 5
        #10 wa = 5'd6; wd = 32'h56789ABC; we = 1; // Write 0x56789ABC to register 6
        #10 we = 0; ra1 = 5'd5; ra2 = 5'd6;       // Read from registers 5 and 6
        #10 if (rd1 !== 32'hABCD1234 || rd2 !== 32'h56789ABC) begin
            $error("Test Case 4 Failed: rd1=%h, expected=%h; rd2=%h, expected=%h", rd1, 32'hABCD1234, rd2, 32'h56789ABC);
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