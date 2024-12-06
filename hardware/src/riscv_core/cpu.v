`include "opcode.vh"
module cpu #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst,
    input bp_enable,
    input serial_in,
    output serial_out
);
    // BIOS Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    wire [11:0] bios_addra, bios_addrb;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    bios_mem bios_mem (
      .clk(clk),
      .ena(1'b1), //modify this?
      .addra(bios_addra), 
      .douta(bios_douta),
      .enb(1'b1),
      .addrb(bios_addrb),
      .doutb(bios_doutb)
    );

    // Data Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    wire [13:0] dmem_addr;
    wire [31:0] dmem_din, dmem_dout;
    wire [3:0] dmem_we;
    wire dmem_en;
    dmem dmem (
      .clk(clk),
      .en(1'b1), 
      .we(dmem_we), 
      .addr(dmem_addr), 
      .din(dmem_din),
      .dout(dmem_dout)
    );

    // Instruction Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    wire [31:0] imem_dina, imem_doutb;
    wire [13:0] imem_addra, imem_addrb;
    wire [3:0] imem_wea;
    wire imem_ena;
    imem imem (
      .clk(clk),
      .ena(imem_ena),
      .wea(imem_wea),
      .addra(imem_addra),
      .dina(imem_dina),
      .addrb(imem_addrb),
      .doutb(imem_doutb)
    );

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    wire reg_wen;
    wire [4:0] ra1, ra2, wa;
    wire [31:0] wb;
    wire [31:0] reg_rd1_s1, reg_rd2_s1;
    reg_file rf (
        .clk(clk),
        .we(reg_wen),
        .ra1(ra1), .ra2(ra2), .wa(wa),
        .wd(wb),
        .rd1(reg_rd1_s1), .rd2(reg_rd2_s1)
    );

    // On-chip UART
    //// UART Receiver
    wire [7:0] uart_rx_data_out;
    wire uart_rx_data_out_valid;
    wire uart_rx_data_out_ready;
    //// UART Transmitter
    wire [7:0] uart_tx_data_in;
    wire uart_tx_data_in_valid;
    wire uart_tx_data_in_ready;
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),

        .serial_in(serial_in),
        .data_out(uart_rx_data_out),
        .data_out_valid(uart_rx_data_out_valid),
        .data_out_ready(uart_rx_data_out_ready),

        .serial_out(serial_out),
        .data_in(uart_tx_data_in),
        .data_in_valid(uart_tx_data_in_valid),
        .data_in_ready(uart_tx_data_in_ready)
    );

    wire [31:0] tohost_csr;

    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around


    /* stage1: IFD */

    // pc_sel mux
    wire [31:0] pc_0_4, alu_result, pc_jal, pc_reset, pc_d, pc_br, pc_br_mi4;
    wire [31:0] pc_q;
    wire [2:0] pc_sel;
    assign pc_reset = RESET_PC;
    reg32 pc_br_mux (
      .clk(clk),
      .d(pc_q),
      .q(pc_br_mi4)
    );
    adder pc_br_adder (
      .in0(pc_br_mi4),
      .in1(32'h4),
      .out(pc_br)
    );
    mux5to1 pc_sel_mux (
      .in0(pc_0_4),
      .in1(alu_result),
      .in2(pc_jal),
      .in3(pc_reset),
      .in4(pc_br),
      .sel(pc_sel),
      .out(pc_d)
    );
    assign bios_addra = pc_d[13:2];
    assign imem_addrb = pc_d[15:2];

    // instuction reg between stage 1, 2
    wire [31:0] instruction_s1, instruction_s2, instruction_s3;
    reg32 ins_reg_12 (
      .clk(clk),
      .d(instruction_s1),
      .q(instruction_s2)
    );
    assign ra1 = instruction_s1[19:15];
    assign ra2 = instruction_s1[24:20];
    assign wa = instruction_s3[11:7];

    // pc_register
    
    reg32 pc_register (
      .clk(clk),
      .d(pc_d),
      .q(pc_q)
    );

    // jal adder and jal_br_sel mux
    wire [31:0] jal_label, br_label, jal_br_label;
    wire label_sel;
    assign jal_label = {{12{instruction_s1[31]}}, instruction_s1[19:12], instruction_s1[20], instruction_s1[30:21], 1'b0};
    assign br_label = {{20{instruction_s1[31]}}, instruction_s1[7], instruction_s1[30:25], instruction_s1[11:8], 1'b0};
    mux2to1 jal_br_mux (
      .in0(jal_label),
      .in1(br_label),
      .sel(label_sel),
      .out(jal_br_label)
    );
    adder jal_adder (
      .in0(jal_br_label),
      .in1(pc_q),
      .out(pc_jal)
    );

    // 0/4 mux and adder
    reg nop_control;
    reg br_taken_check;
    wire br_pred_taken_q, correct_br_ctr_ce;
    always @(*)begin
      if (instruction_s2[6:2] == 5'b11001) nop_control = 1'b1;
      else if(instruction_s2[6:2] == 5'b11000) begin // is branch
        if (bp_enable && (br_taken_check != br_pred_taken_q)) nop_control = 1'b1;
        else if (!bp_enable && br_taken_check) nop_control = 1'b1;
        else nop_control = 1'b0;
      end
      else nop_control = 1'b0;
    end
    
    wire [31:0] zero_or_4;
    mux2to1 zero_or_4_mux (
      .in0(32'd4),
      .in1(32'd4),
      .sel(nop_control),
      .out(zero_or_4)
    );
    adder pc_add4 (
      .in0(pc_q),
      .in1(zero_or_4),
      .out(pc_0_4)
    );

    // pc30_mux and nop_mux
    wire [31:0] ins_mem; //instruction from memory, selected by pc[30]
    mux2to1 pc30_mux (
      .in0(imem_doutb),
      .in1(bios_douta),
      .sel(pc_q[30]),
      .out(ins_mem)
    );
    mux2to1 nop_mux(
      .in0(ins_mem),
      .in1(32'h00000033),
      .sel(nop_control),
      .out(instruction_s1)
    );

    // immediate generater
    wire [31:0] imm_s1, imm_s2;
    imm_gen imm_gen_ins (
      .instruction(instruction_s1),
      .imm(imm_s1)
    );

    // pipeline registers between stage1 and stage2
    wire [31:0] reg_rd1_q, reg_rd2_q, pc_s2, reg_rs1, reg_rs2;
    reg32 pip_reg_s12_2 (
      .clk(clk),
      .d(reg_rs1),
      .q(reg_rd1_q)
    );
    reg32 pip_reg_s12_3 (
      .clk(clk),
      .d(reg_rs2),
      .q(reg_rd2_q)
    );
    reg32 pip_reg_s12_1 (
      .clk(clk),
      .d(pc_q),
      .q(pc_s2)
    );
    reg32 pip_reg_s12_4 (
      .clk(clk),
      .d(imm_s1),
      .q(imm_s2)
    );

    // stage 1 control unit
    wire hazard2_sel_1, hazard2_sel_2;
    s1_control s1_CU (
      .instruction_s1(instruction_s1),
      .instruction_s3(instruction_s3),
      .hazard2_sel_1(hazard2_sel_1),
      .hazard2_sel_2(hazard2_sel_2),
      .label_sel(label_sel),
      .bp_enable(bp_enable)
    );

    // 2 cycle hazard select mux
    mux2to1 hazard2_mux1 (
      .in0(wb),
      .in1(reg_rd1_s1),
      .sel(hazard2_sel_1),
      .out(reg_rs1)
    );

    mux2to1 hazard2_mux2 (
      .in0(wb),
      .in1(reg_rd2_s1),
      .sel(hazard2_sel_2),
      .out(reg_rs2)
    );

    /* stage2: EX */

    // instuction reg between stage 2, 3
    reg32 ins_reg_23 (
      .clk(clk),
      .d(instruction_s2),
      .q(instruction_s3)
    );

    // branch comparator
    wire brun, breq, brlt;
    wire [31:0] reg_rd1_s2, reg_rd2_s2;
    branch_comp branch_com_ins (
      .brdata1(reg_rd1_s2),
      .brdata2(reg_rd2_s2),
      .brun(brun),
      .breq(breq),
      .brlt(brlt)
    );
    
    // forwarding mux 1
    wire [1:0] forward_sel_1, forward_sel_2;
    wire [31:0] data_to_reg, alu_result_q;
    mux4to1 forwarding_mux1 (
      .in0(alu_result_q),
      .in1(data_to_reg),
      .in2(reg_rd1_q),
      .in3(wb),
      .sel(forward_sel_1),
      .out(reg_rd1_s2)
    );

    // forwarding mux 2
    mux4to1 forwarding_mux2 (
      .in0(alu_result_q),
      .in1(data_to_reg),
      .in2(reg_rd2_q),
      .in3(wb),
      .sel(forward_sel_2),
      .out(reg_rd2_s2)
    );

    // stage 2 control unit
    wire a_sel, b_sel, mem_wen, csr_we;
    wire [3:0] alu_sel;
    s2_control s2_CU (
      .instruction_s2(instruction_s2),
      .instruction_s3(instruction_s3),
      .pc(pc_s2),
      .alu_result(alu_result),
      .imem_ena(imem_ena),
      .forward_sel_1(forward_sel_1),
      .forward_sel_2(forward_sel_2),
      .brun(brun),
      .a_sel(a_sel),
      .b_sel(b_sel),
      .mem_wen(mem_wen),
      .csr_we(csr_we),
      .alu_sel(alu_sel)
    );

    // ALU A mux and B mux
    wire [31:0] alu_ina, alu_inb;
    mux2to1 alu_a_mux(
      .in0(reg_rd1_s2),
      .in1(pc_s2),
      .sel(a_sel),
      .out(alu_ina)
    );
    mux2to1 alu_b_mux(
      .in0(reg_rd2_s2),
      .in1(imm_s2),
      .sel(b_sel),
      .out(alu_inb)
    );

    // ALU
    alu alu_ins(
      .A(alu_ina),
      .B(alu_inb),
      .alu_sel(alu_sel),
      .alu_result(alu_result)
    );
    assign dmem_addr = alu_result[15:2];
    assign imem_addra = alu_result[15:2];
    assign bios_addrb = alu_result[13:2];
    assign uart_tx_data_in_valid = ((alu_result == 32'h80000008) && (instruction_s2[6:0] == `OPC_STORE));
    wire ctr_reset = (alu_result == 32'h80000018) && instruction_s2[6:0] == `OPC_STORE;
    //assign serial_in = 

    //partial_store
    wire [31:0] data_to_mem;
    wire [3:0] wea;
    //wire mem_wen;
    partial_store partial_store_ins(
      .instruction(instruction_s2),
      .data_from_reg(reg_rd2_s2),
      .mem_addr(alu_result),
      .mem_wen(mem_wen),
      .data_to_mem(data_to_mem),
      .mem_write_mask(wea)
    );
    assign dmem_we = wea;
    assign imem_wea = wea;
    assign dmem_din = data_to_mem;
    assign imem_dina = data_to_mem;
    assign uart_tx_data_in = data_to_mem[7:0];

    // pipeline registers between stage2 and stage3
    wire [31:0] pc_s3;
    reg32 pip_reg_s23_1 (
      .clk(clk),
      .d(alu_result),
      .q(alu_result_q)
    );
    reg32 pip_reg_s23_2 (
      .clk(clk),
      .d(pc_s2),
      .q(pc_s3)
    );

    // branch predictor
    wire is_br_guess, is_br_check, br_pred_taken;
    always @(*) begin  
      if ((instruction_s2[14:12] == `FNC_BEQ) && breq) br_taken_check = 1'b1;
      else if ((instruction_s2[14:12] == `FNC_BNE) && !breq) br_taken_check = 1'b1;
      else if ((instruction_s2[14:12] == `FNC_BLT) && brlt) br_taken_check = 1'b1;
      else if ((instruction_s2[14:12] == `FNC_BGE) && !brlt) br_taken_check = 1'b1;
      else if ((instruction_s2[14:12] == `FNC_BLTU) && brlt) br_taken_check = 1'b1;
      else if ((instruction_s2[14:12] == `FNC_BGEU) && !brlt) br_taken_check = 1'b1;
      else br_taken_check = 1'b0;
    end
    assign is_br_guess = instruction_s1[6:0] == `OPC_BRANCH;
    assign is_br_check = instruction_s2[6:0] == `OPC_BRANCH;
    branch_predictor branch_predictor_ins(
      .clk(clk),
      .reset(rst),
      .pc_guess(pc_q),
      .is_br_guess(is_br_guess),
      .pc_check(pc_s2),
      .is_br_check(is_br_check),
      .br_taken_check(br_taken_check),
      .br_pred_taken(br_pred_taken)
    );

    /* stage3: MEM & WB */

    // memory select mux
    wire [2:0] mem_sel;
    wire [31:0] data_from_mem;
    wire [31:0] io_value;
    mux5to1 mem_sel_mux(
      .in0(bios_doutb),                // modify these zeros
      .in1(dmem_dout),
      .in2(io_value),
      .in3(0),
      .in4(0),
      .sel(mem_sel),
      .out(data_from_mem)
    );
    
    // partial load
    partial_load partial_load_ins(
      .instruction(instruction_s3),
      .data_from_mem(data_from_mem),
      .mem_addr(alu_result_q),
      .data_to_reg(data_to_reg)
    );

    // pc + 4 
    wire [31:0] pc_add4_s3;
    adder adder_pc_4(
      .in0(pc_s3),
      .in1(32'd4),
      .out(pc_add4_s3)
    );
    
    // wb select mux
    wire [1:0] wb_sel;
    mux3to1 wb_sel_mux(
      .in0(data_to_reg),
      .in1(alu_result_q),
      .in2(pc_add4_s3),
      .sel(wb_sel),
      .out(wb)
    );

    // csr register
    reg_rst_ce csr_reg(
      .clk(clk),
      .d(alu_result),
      .ce(csr_we),
      .rst(rst),
      .q(tohost_csr)
    );
    
    wire ctr_rst = (alu_result == 32'h80000018) && instruction_s2[6:0] == `OPC_STORE;
    // Cycle Counter
    wire [31:0] cyc_counter_d;
    wire [31:0] cyc_counter_q;
    reg_rst cyc_ctr (.q(cyc_counter_q),
             .d(cyc_counter_d),
             .rst(rst || ctr_rst),
             .clk(clk));
    assign cyc_counter_d = cyc_counter_q + 1;

    // Instruction Counter
    wire [31:0] instr_counter_d;
    wire [31:0] instr_counter_q;
    reg_rst_ce instr_ctr (.q(instr_counter_q),
               .d(instr_counter_d),
               .rst(rst || ctr_rst),
               .ce(~nop_control),
               .clk(clk));
    assign instr_counter_d = instr_counter_q + 1;

    // Total branch instruction counter
    wire [31:0] br_instr_counter_d;
    wire [31:0] br_instr_counter_q;
    reg_rst_ce br_instr_ctr (.q(br_instr_counter_q),
               .d(br_instr_counter_d),
               .rst(rst || ctr_rst),
               .ce(is_br_guess),
               .clk(clk));
    assign br_instr_counter_d = br_instr_counter_q + 1;

    // Correct branch prediction counter
    wire [31:0] correct_br_counter_d;
    wire [31:0] correct_br_counter_q;
    reg_1 br_pred_taken_reg (
      .d(br_pred_taken),
      .q(br_pred_taken_q),
      .clk(clk),
      .rst(rst || ctr_rst)
    );
    assign correct_br_ctr_ce = (is_br_check && bp_enable && (br_pred_taken_q == br_taken_check)) || (!bp_enable && is_br_check && !br_taken_check);
    reg_rst_ce correct_br_ctr (.q(correct_br_counter_q),
               .d(correct_br_counter_d),
               .rst(rst || ctr_rst),
               .ce(correct_br_ctr_ce),
               .clk(clk));
    assign correct_br_counter_d = correct_br_counter_q + 1;

     // stage 3 control unit
    wire is_jal;
    s3_control s3_CU(
      .instruction_s3(instruction_s3),
      .instruction_s2(instruction_s2),
      .instruction_s1(instruction_s1),
      .addr(alu_result_q),
      .rst(rst),
      .breq(breq),
      .brlt(brlt),
      .br_pred_taken_q(br_pred_taken_q),
      .br_taken_check(br_taken_check),
      .uart_rx_valid(uart_rx_data_out_valid),
      .uart_tx_ready(uart_tx_data_in_ready),
      .uart_rx_out(uart_rx_data_out),
      .cyc_counter(cyc_counter_q),
      .instr_counter(instr_counter_q),
      .br_instr_counter(br_instr_counter_q),
      .correct_br_counter(correct_br_counter_q),
      .bp_enable(bp_enable),
      .br_pred_taken(br_pred_taken),
      .mem_sel(mem_sel),
      .is_jal(is_jal),
      .wb_sel(wb_sel),
      .pc_sel(pc_sel),
      .reg_we(reg_wen),
      //.rx_data_out_ready(uart_rx_data_out_ready),
      .io_value(io_value)
    );
    assign is_jal = (instruction_s1[6:2] == 5'b11011) ? 1 : 0; // if ins1 is jal
    assign uart_rx_data_out_ready = ((alu_result_q == 32'h80000004) && (instruction_s3[6:0] == `OPC_LOAD));

endmodule