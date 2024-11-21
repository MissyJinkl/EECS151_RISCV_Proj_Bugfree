module s1_control(
    input [31:0] instruction_s1,
    input [31:0] pc,
    output nop_control,
);
    assign nop_control = 1'b0; //modify me
endmodule