//------------------------------------------------------------------------------
// tb_core.v – Simple testbench for the 8-bit CPU core (core.v)
//------------------------------------------------------------------------------
//
// Simulates the CPU for a few clock cycles, releases reset, and checks out_port.
//
// Usage (with Icarus Verilog):
//   iverilog -g2005-sv -o tb_core.vvp core.v tb_core.v
//   vvp tb_core.vvp
//   gtkwave tb_core.vcd         # if you include $dumpfile/$dumpvars
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_core;
  reg        clk;
  reg        rst;
  wire [7:0] out_port;

  // Instantiate the CPU core
  core uut (
    .clk      (clk),
    .rst      (rst),
    .out_port (out_port)
  );

  // Clock driver: 10 ns period → 100 MHz sim clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset and run for a while
  initial begin
    // Optional: dump waveform for GTKWave
    $dumpfile("tb_core.vcd");
    $dumpvars(0, tb_core);

    rst = 1;
    #20;         // hold reset for 20 ns
    rst = 0;

    // Let CPU run for, say, 200 ns, then finish
    #200;
    $finish;
  end

  // Monitor ACC and out_port every cycle (for debug)
  // Add in core.v: wires to expose ACC if you want to watch ACC directly.
  initial begin
    $display("Time\t fetch\t PC\t IR\t ACC\t out_port");
    $monitor("%0dns\t%b\t%02h\t%02h\t%02h\t%02h",
              $time, uut.fetch, uut.pc, uut.ir, uut.acc, out_port);
  end

endmodule
