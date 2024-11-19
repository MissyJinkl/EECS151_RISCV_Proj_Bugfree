`timescale 1ns/1ns

module adder_tb();
    // Signals for testing
    reg [31:0] in0, in1;   // Inputs for the adder
    wire [31:0] out;       // Output from the adder
    integer error_count = 0; // Error counter

    // Instantiate the adder module
    adder uut (
        .in0(in0),
        .in1(in1),
        .out(out)
    );

    // Test procedure
    initial begin
        // Initialize inputs
        in0 = 32'b0;
        in1 = 32'b0;

        // Test Case 1: 0 + 0
        #10 in0 = 32'd0; in1 = 32'd0;
        #10 if (out !== 32'd0) begin
            $error("Test Case 1 Failed: in0=%d, in1=%d, output=%d, expected=%d", in0, in1, out, 32'd0);
            error_count = error_count + 1;
        end

        // Test Case 2: Positive numbers
        #10 in0 = 32'd15; in1 = 32'd10;
        #10 if (out !== 32'd25) begin
            $error("Test Case 2 Failed: in0=%d, in1=%d, output=%d, expected=%d", in0, in1, out, 32'd25);
            error_count = error_count + 1;
        end

        // Test Case 3: Negative numbers
        #10 in0 = -32'd20; in1 = -32'd30;
        #10 if (out !== -32'd50) begin
            $error("Test Case 3 Failed: in0=%d, in1=%d, output=%d, expected=%d", in0, in1, out, -32'd50);
            error_count = error_count + 1;
        end

        // Test Case 4: Mixed signs
        #10 in0 = 32'd50; in1 = -32'd20;
        #10 if (out !== 32'd30) begin
            $error("Test Case 4 Failed: in0=%d, in1=%d, output=%d, expected=%d", in0, in1, out, 32'd30);
            error_count = error_count + 1;
        end

        // Test Case 5: Large positive numbers
        #10 in0 = 32'h7FFFFFFF; in1 = 32'd1; // Maximum positive value + 1
        #10 if (out !== 32'h80000000) begin
            $error("Test Case 5 Failed: in0=%h, in1=%d, output=%h, expected=%h", in0, in1, out, 32'h80000000);
            error_count = error_count + 1;
        end

        // Test Case 6: Large negative numbers
        #10 in0 = -32'd1; in1 = -32'd1; // Negative 1 + Negative 1
        #10 if (out !== -32'd2) begin
            $error("Test Case 6 Failed: in0=%d, in1=%d, output=%d, expected=%d", in0, in1, out, -32'd2);
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
