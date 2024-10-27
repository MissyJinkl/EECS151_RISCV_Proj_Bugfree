module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output reg [WIDTH-1:0] edge_detect_pulse
);
    // TODO: Implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' starting at the next clock edge

    // Register to store the previous state of signal_in
    reg [WIDTH-1:0] signal_in_d;
    reg [WIDTH-1:0] edge_detect_pulse = 0;
    always @(posedge clk) begin
        // Generate a pulse when a rising edge is detected (signal_in goes from 0 to 1)
        edge_detect_pulse <= signal_in & ~signal_in_d;

        // Store the current state of signal_in for comparison in the next cycle
        signal_in_d <= signal_in;
    end
endmodule