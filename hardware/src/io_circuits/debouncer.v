module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output reg [WIDTH-1:0] debounced_signal
);
    // TODO: Fill in the necessary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One global wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for resetting, clock enable, etc.
    // Refer to the block diagram in the spec

    
    reg [WRAPPING_CNT_WIDTH-1:0] wrapping_counter = 0;
    wire sample_signal;
    reg [WIDTH-1:0] debounced_signal = 0;
    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];

    always@(posedge clk)begin
        if(wrapping_counter == SAMPLE_CNT_MAX - 1) wrapping_counter <= 0;
        else wrapping_counter = wrapping_counter + 1;
    end

    assign sample_signal = (wrapping_counter == SAMPLE_CNT_MAX - 1);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : debounce_logic
            
            always @(posedge clk) begin
                if (sample_signal) begin
                    if (glitchy_signal[i]) begin
                        if (saturating_counter[i] < PULSE_CNT_MAX - 1) begin
                            saturating_counter[i] <= saturating_counter[i] + 1;
                        end
                    end else begin
                        saturating_counter[i] <= 0;
                    end
                end

                if (saturating_counter[i] == PULSE_CNT_MAX - 1) begin
                    debounced_signal[i] <= 1'b1;
                end else begin
                    debounced_signal[i] <= 1'b0;
                end

            end
        end

    endgenerate

endmodule