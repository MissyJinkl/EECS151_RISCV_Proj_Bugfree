`timescale 1ns/1ns

module bp_cache_tb;

  // Define signals
  reg clk;
  reg reset;
  reg [31:0] read_addr1, read_addr2;
  reg [31:0] write_addr;
  reg [31:0] write_data;
  reg write_en;
  wire [31:0] read_data1, read_data2;
  wire cache_hit1, cache_hit2;


  bp_cache dut (
    .clk(clk),
    .reset(reset),
    .ra0(read_addr1),
    .ra1(read_addr2),
    .wa(write_addr),
    .din(write_data),
    .we(write_en),
    .dout0(read_data1),
    .dout1(read_data2),
    .hit0(cache_hit1),
    .hit1(cache_hit2)
  );

  // Clock
  always begin
    #5 clk = ~clk;  // 100MHz clock
  end

  initial begin
    clk = 0;
    reset = 1;
    write_en = 0;
    read_addr1 = 32'b0;
    read_addr2 = 32'b0;
    write_addr = 32'b0;
    write_data = 32'b0;

    // Reset the cache
    #10 reset = 0;

    // Test 1: Read miss
    #10;
    read_addr1 = 32'hA0;  // First read address
    read_addr2 = 32'hB0;  // Second read address
    #10;
    $display("Read Addr1 = 0x%h, Data1 = 0x%h, Hit1 = %b", read_addr1, read_data1, cache_hit1);
    $display("Read Addr2 = 0x%h, Data2 = 0x%h, Hit2 = %b", read_addr2, read_data2, cache_hit2);

    // Test 2: Write to cache
    #10;
    write_addr = 32'hA0;
    write_data = 32'hDEAD_BEEF;  // Data to be written
    write_en = 1;
    #10;
    write_en = 0;
    $display("Write Addr = 0x%h, Data = 0x%h", write_addr, write_data);

    // Test 3: Read hit
    #10;
    read_addr1 = 32'hA0;
    #10;
    $display("Read Addr1 = 0x%h, Data1 = 0x%h, Hit1 = %b", read_addr1, read_data1, cache_hit1);

    // Test 4: Eviction
    #10;
    write_addr = 32'hA0;
    write_data = 32'h12345678;  // New data to be written
    write_en = 1;
    #10;
    write_en = 0;
    $display("Write Addr = 0x%h, Data = 0x%h", write_addr, write_data);

    // Test 5: Read miss after eviction
    #10;
    read_addr1 = 32'h1A0;  // same index with 32'hA0, but different tag
    #10;
    $display("Read Addr1 = 0x%h, Data1 = 0x%h, Hit1 = %b", read_addr1, read_data1, cache_hit1);


    // Test 6: Read hit after eviction and write
    #10;
    read_addr1 = 32'hA0;
    #10;
    $display("Read Addr1 = 0x%h, Data1 = 0x%h, Hit1 = %b", read_addr1, read_data1, cache_hit1);

    $finish;
  end

endmodule