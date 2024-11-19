module s1_control(
    input [31:0] instruction_s1,
    input [31:0] pc,
    output nop_control,
    output pc_30,
);
    assign pc_30 = pc[30];
    assign nop_control = 1'b0; //modify me
endmodule