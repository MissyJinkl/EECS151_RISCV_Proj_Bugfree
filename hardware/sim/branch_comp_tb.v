`timescale 1ns/1ns

module branch_comp_tb();
    // Signals for testing
    reg [31:0] brdata1, brdata2; // Inputs for branch comparison
    reg brun;                    // Run mode (unsigned or signed)
    wire breq, brlt;             // Outputs: equality and less-than comparison
    integer error_count = 0;     // Error counter

    // Instantiate the branch_comp module
    branch_comp uut (
        .brdata1(brdata1),
        .brdata2(brdata2),
        .brun(brun),
        .breq(breq),
        .brlt(brlt)
    );

    // Test procedure
    initial begin
        // Test Case 1: Equality Check (breq)
        #10 brdata1 = 32'd10; brdata2 = 32'd10; brun = 1'b0;
        #10 if (breq !== 1'b1) begin
            $error("Test Case 1 Failed: brdata1=%d, brdata2=%d, breq=%b, expected=%b",
                   brdata1, brdata2, breq, 1'b1);
            error_count = error_count + 1;
        end

        // Test Case 2: Less-than Unsigned (brlt)
        #10 brdata1 = 32'd10; brdata2 = 32'd20; brun = 1'b1;
        #10 if (brlt !== 1'b1) begin
            $error("Test Case 2 Failed: brdata1=%d, brdata2=%d, brun=%b, brlt=%b, expected=%b",
                   brdata1, brdata2, brun, brlt, 1'b1);
            error_count = error_count + 1;
        end

        // Test Case 3: Greater-than Unsigned (brlt)
        #10 brdata1 = 32'd30; brdata2 = 32'd20; brun = 1'b1;
        #10 if (brlt !== 1'b0) begin
            $error("Test Case 3 Failed: brdata1=%d, brdata2=%d, brun=%b, brlt=%b, expected=%b",
                   brdata1, brdata2, brun, brlt, 1'b0);
            error_count = error_count + 1;
        end

        // Test Case 4: Less-than Signed (brlt)
        #10 brdata1 = -32'd10; brdata2 = 32'd5; brun = 1'b0;
        #10 if (brlt !== 1'b1) begin
            $error("Test Case 4 Failed: brdata1=%d, brdata2=%d, brun=%b, brlt=%b, expected=%b",
                   brdata1, brdata2, brun, brlt, 1'b1);
            error_count = error_count + 1;
        end

        // Test Case 5: Greater-than Signed (brlt)
        #10 brdata1 = 32'd10; brdata2 = -32'd5; brun = 1'b0;
        #10 if (brlt !== 1'b0) begin
            $error("Test Case 5 Failed: brdata1=%d, brdata2=%d, brun=%b, brlt=%b, expected=%b",
                   brdata1, brdata2, brun, brlt, 1'b0);
            error_count = error_count + 1;
        end

        // Test Case 6: Equality Check with Different Values (breq)
        #10 brdata1 = 32'd15; brdata2 = 32'd20; brun = 1'b0;
        #10 if (breq !== 1'b0) begin
            $error("Test Case 6 Failed: brdata1=%d, brdata2=%d, breq=%b, expected=%b",
                   brdata1, brdata2, breq, 1'b0);
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
