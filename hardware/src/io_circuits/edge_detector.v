module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: Implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' starting at the next clock edge

    reg [WIDTH-1:0] prev_signal_in;
    always @(posedge clk) begin
        prev_signal_in <= signal_in;
    end
    assign edge_detect_pulse = signal_in & ~prev_signal_in;
endmodule
