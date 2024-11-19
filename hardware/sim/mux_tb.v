`timescale 1ns/1ns

module mux_tb();
    // Signals for testing
    reg [31:0] in0, in1, in2, in3, in4; // Inputs for multiplexers
    reg [2:0] sel;                     // Selection signal
    wire [31:0] out2to1, out3to1, out4to1, out5to1; // Outputs from multiplexers
    integer error_count = 0;           // Error counter

    // Instantiate mux2to1
    mux2to1 uut2to1 (
        .in0(in0),
        .in1(in1),
        .sel(sel[0]), // Only use the least significant bit
        .out(out2to1)
    );

    // Instantiate mux3to1
    mux3to1 uut3to1 (
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .sel(sel[1:0]), // Use 2 bits for selection
        .out(out3to1)
    );

    // Instantiate mux4to1
    mux4to1 uut4to1 (
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .sel(sel[1:0]), // Use 2 bits for selection
        .out(out4to1)
    );

    // Instantiate mux5to1
    mux5to1 uut5to1 (
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .in4(in4),
        .sel(sel[2:0]), // Use 3 bits for selection
        .out(out5to1)
    );

    // Test procedure
    initial begin
        // Initialize inputs
        in0 = 32'd0; // Pattern for input 0
        in1 = 32'd1; // Pattern for input 1
        in2 = 32'd2; // Pattern for input 2
        in3 = 32'd3; // Pattern for input 3
        in4 = 32'd4; // Pattern for input 4
        sel = 3'b000;        // Initialize selection signal

        // Test mux2to1
        #10 sel = 3'b000; // Select in0
        #10 
        if (out2to1 !== in0) begin
            $error("mux2to1 failed for sel=0, output=%h, expected=%h", out2to1, in0);
            error_count = error_count + 1;
        end

        #10 sel = 3'b001; // Select in1
        #10 
        if (out2to1 !== in1) begin
            $error("mux2to1 failed for sel=1, output=%h, expected=%h", out2to1, in1);
            error_count = error_count + 1;
        end

        // Test mux3to1
        #10 sel = 3'b000; // Select in0
        #10 
        if (out3to1 !== in0) begin
            $error("mux3to1 failed for sel=00, output=%h, expected=%h", out3to1, in0);
            error_count = error_count + 1;
        end

        #10 sel = 3'b001; // Select in1
        #10 
        if (out3to1 !== in1) begin
            $error("mux3to1 failed for sel=01, output=%h, expected=%h", out3to1, in1);
            error_count = error_count + 1;
        end

        #10 sel = 3'b010; // Select in2
        #10 
        if (out3to1 !== in2) begin
            $error("mux3to1 failed for sel=10, output=%h, expected=%h", out3to1, in2);
            error_count = error_count + 1;
        end

        // Test mux4to1
        #10 sel = 3'b000; // Select in0
        #10 
        if (out4to1 !== in0) begin
            $error("mux4to1 failed for sel=00, output=%h, expected=%h", out4to1, in0);
            error_count = error_count + 1;
        end

        #10 sel = 3'b001; // Select in1
        #10 
        if (out4to1 !== in1) begin
            $error("mux4to1 failed for sel=01, output=%h, expected=%h", out4to1, in1);
            error_count = error_count + 1;
        end

        #10 sel = 3'b010; // Select in2
        #10 
        if (out4to1 !== in2) begin
            $error("mux4to1 failed for sel=10, output=%h, expected=%h", out4to1, in2);
            error_count = error_count + 1;
        end

        #10 sel = 3'b011; // Select in3
        #10 
        if (out4to1 !== in3) begin
            $error("mux4to1 failed for sel=11, output=%h, expected=%h", out4to1, in3);
            error_count = error_count + 1;
        end

        // Test mux5to1
        #10 sel = 3'b000; // Select in0
        #10 
        if (out5to1 !== in0) begin
            $error("mux5to1 failed for sel=000, output=%h, expected=%h", out5to1, in0);
            error_count = error_count + 1;
        end

        #10 sel = 3'b001; // Select in1
        #10 
        if (out5to1 !== in1) begin
            $error("mux5to1 failed for sel=001, output=%h, expected=%h", out5to1, in1);
            error_count = error_count + 1;
        end

        #10 sel = 3'b010; // Select in2
        #10 
        if (out5to1 !== in2) begin
            $error("mux5to1 failed for sel=010, output=%h, expected=%h", out5to1, in2);
            error_count = error_count + 1;
        end

        #10 sel = 3'b011; // Select in3
        #10 
        if (out5to1 !== in3) begin
            $error("mux5to1 failed for sel=011, output=%h, expected=%h", out5to1, in3);
            error_count = error_count + 1;
        end

        #10 sel = 3'b100; // Select in4
        #10 
        if (out5to1 !== in4) begin
            $error("mux5to1 failed for sel=100, output=%h, expected=%h", out5to1, in4);
            error_count = error_count + 1;
        end

        // Check error count and display results
        #10 
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed!", error_count);
        end
        $finish();
    end
endmodule