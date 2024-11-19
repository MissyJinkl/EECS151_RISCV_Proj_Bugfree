module branch_comp(
    input [31:0] brdata1,
    input [31:0] brdata2,
    input brun,
    output breq,
    output brlt
);
    assign breq = (brdata1 == brdata2);
    assign brlt = brun ? (brdata1 < brdata2) : ($signed(brdata1) < $signed(brdata2));

endmodule