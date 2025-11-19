`timescale 1ns/1ps
// tb_combined_accel.sv
module tb_combined_accel;
  logic clk, rst_n;
  logic start;

  // accel_custom_top interface
  logic [15:0] op_a, op_b, bias;
  logic [15:0] add_out, mul_out, div_out, min_out, max_out, mac_out, vdot_out;
  logic [15:0] t00, t01, t10, t11;
  real det;
  real inv00, inv01, inv10, inv11;

  // instantiate accel_custom_top
  accel_custom_top uut (
    .clk(clk), .rst_n(rst_n), .start(start),
    .op_a(op_a), .op_b(op_b), .bias(bias),
    .add_out(add_out), .mul_out(mul_out), .div_out(div_out),
    .min_out(min_out), .max_out(max_out), .mac_out(mac_out),
    .vdot_out(vdot_out),
    .t00(t00), .t01(t01), .t10(t10), .t11(t11),
    .det(det), .inv00(inv00), .inv01(inv01), .inv10(inv10), .inv11(inv11)
  );

  // also instantiate some small primitives for direct comparison demos
  logic signed [31:0] A00, A01, A10, A11;
  logic signed [31:0] B00, B01, B10, B11;
  logic signed [63:0] mC00, mC01, mC10, mC11;
  logic signed [63:0] conv_out;
  logic signed [31:0] dv4_out, dv2_out;

  matmul2x2 mm (
    .A00(A00), .A01(A01), .A10(A10), .A11(A11),
    .B00(B00), .B01(B01), .B10(B10), .B11(B11),
    .C00(mC00), .C01(mC01), .C10(mC10), .C11(mC11)
  );

  conv2x2 conv (
    .A00(A00), .A01(A01), .A10(A10), .A11(A11),
    .B00(B00), .B01(B01), .B10(B10), .B11(B11),
    .C(conv_out)
  );

  dot4 d4 (
    .a0(op_a), .a1(16'd2), .a2(16'd3), .a3(16'd4),
    .b0(op_b), .b1(16'd6), .b2(16'd7), .b3(16'd8),
    .out(dv4_out)
  );

  dot2 d2 (
    .a0(op_a), .a1(op_b),
    .b0(bias), .b1(16'd1),
    .out(dv2_out)
  );

  // clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns period
  end

  initial begin
    // reset
    rst_n = 0; start = 0;
    op_a = 0; op_b = 0; bias = 0;
    A00=0; A01=0; A10=0; A11=0;
    B00=0; B01=0; B10=0; B11=0;
    #20;
    rst_n = 1;
    #20;

    // load test values
    op_a = 16'd12; op_b = 16'd3; bias = 16'd5;
    A00 = 1; A01 = 2; A10 = 3; A11 = 4;
    B00 = 5; B01 = 6; B10 = 7; B11 = 8;

    // pulse start
    start = 1; @(posedge clk); start = 0;

    // wait a few cycles for combinational/stored results
    #10;

    // display accel_custom_top outputs
    $display("=== accel_custom_top outputs ===");
    $display("add_out = %0d", add_out);
    $display("mul_out = %0d", mul_out);
    $display("div_out = %0d", div_out);
    $display("min_out = %0d", min_out);
    $display("max_out = %0d", max_out);
    $display("mac_out = %0d", mac_out);
    $display("vdot_out = %0d", vdot_out);
    $display("transpose = [%0d %0d; %0d %0d]", t00, t01, t10, t11);
    $display("det = %f", det);
    $display("inv = [%f %f; %f %f]", inv00, inv01, inv10, inv11);

    // display primitive module outputs
    #1;
    $display("=== Small primitives ===");
    $display("MATMUL 2x2: C00=%0d C01=%0d C10=%0d C11=%0d", mC00, mC01, mC10, mC11);
    $display("CONV2x2 (inner product) = %0d", conv_out);
    $display("DOT4 = %0d", dv4_out);
    $display("DOT2 = %0d", dv2_out);

    #20;
    $finish;
  end

endmodule
