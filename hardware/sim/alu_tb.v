`timescale 1ns/1ns

module alu_tb();
    // 信号声明
    reg [31:0] A, B;           // ALU 的输入信号
    reg [3:0] alu_sel;         // ALU 操作选择信号
    wire [31:0] alu_result;    // ALU 输出信号
    integer error_count = 0;   // 错误计数器

    // 实例化 ALU 模块
    alu uut (
        .A(A),
        .B(B),
        .alu_sel(alu_sel),
        .alu_result(alu_result)
    );

    // 初始化和测试用例
    initial begin
        // 初始化输入信号
        A = 32'b0;
        B = 32'b0;
        alu_sel = 4'd0;

        // 测试用例 1: ADD 操作
        #10;
        A = 32'h0000_0005; // A = 5
        B = 32'h0000_0003; // B = 3
        alu_sel = 4'd0;    // ADD
        #10;
        if (alu_result !== 32'h0000_0008) begin
            $error("ADD Test Failed: Expected 8, Got %d", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 2: SLL 操作
        #10;
        A = 32'h0000_0001; // A = 1
        B = 32'h0000_0002; // B[4:0] = 2
        alu_sel = 4'd1;    // SLL
        #10;
        if (alu_result !== 32'h0000_0004) begin
            $error("SLL Test Failed: Expected 4, Got %d", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 3: SLT 操作
        #10;
        A = 32'hFFFF_FFFF; // A = -1 (signed)
        B = 32'h0000_0000; // B = 0
        alu_sel = 4'd2;    // SLT
        #10;
        if (alu_result !== 32'h0000_0001) begin
            $error("SLT Test Failed: Expected 1, Got %d", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 4: XOR 操作
        #10;
        A = 32'hAAAA_AAAA;
        B = 32'h5555_5555;
        alu_sel = 4'd4;    // XOR
        #10;
        if (alu_result !== 32'hFFFF_FFFF) begin
            $error("XOR Test Failed: Expected FFFFFFFF, Got %h", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 5: SRL 操作
        #10;
        A = 32'h0000_00F0;
        B = 32'h0000_0004; // B[4:0] = 4
        alu_sel = 4'd5;    // SRL
        #10;
        if (alu_result !== 32'h0000_000F) begin
            $error("SRL Test Failed: Expected F, Got %d", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 6: OR 操作
        #10;
        A = 32'hAAAA_0000;
        B = 32'h0000_5555;
        alu_sel = 4'd6;    // OR
        #10;
        if (alu_result !== 32'hAAAA_5555) begin
            $error("OR Test Failed: Expected AAAA5555, Got %h", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 7: AND 操作
        #10;
        A = 32'hAAAA_FFFF;
        B = 32'h5555_0000;
        alu_sel = 4'd7;    // AND
        #10;
        if (alu_result !== 32'h0000_0000) begin
            $error("AND Test Failed: Expected 00000000, Got %h", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 8: SUB 操作
        #10;
        A = 32'h0000_000A; // A = 10
        B = 32'h0000_0003; // B = 3
        alu_sel = 4'd12;   // SUB
        #10;
        if (alu_result !== 32'h0000_0007) begin
            $error("SUB Test Failed: Expected 7, Got %d", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 9: SRA 操作
        #10;
        A = 32'hFFFF_FFFF; // A = -1 (signed)
        B = 32'h0000_0001; // B[4:0] = 1
        alu_sel = 4'd13;   // SRA
        #10;
        if (alu_result !== 32'hFFFF_FFFF) begin
            $error("SRA Test Failed: Expected FFFFFFFF, Got %h", alu_result);
            error_count = error_count + 1;
        end

        // 测试用例 10: BSEL 操作
        #10;
        B = 32'h1234_5678; // B = 12345678
        alu_sel = 4'd15;   // BSEL
        #10;
        if (alu_result !== 32'h1234_5678) begin
            $error("BSEL Test Failed: Expected 12345678, Got %h", alu_result);
            error_count = error_count + 1;
        end

        // 测试完成
        if (error_count == 0) begin
            $display("All Test Cases Passed!");
        end else begin
            $display("%d Test Cases Failed!", error_count);
        end
        $finish();
    end
endmodule
