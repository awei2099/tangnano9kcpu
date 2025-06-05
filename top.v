//------------------------------------------------------------------------------
// top.v – Top‐level wrapper for Tang Nano 9K
//------------------------------------------------------------------------------
// Connects the on-board 25 MHz clock & reset button to the CPU core,
// and routes the 8-bit "out_port" to eight LEDs.
//
// Physical pin assignments are in ../constraints/tangnano9k.pcf
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module top (
  input  wire        clk25m,  // 25 MHz oscillator on Tang Nano 9K
  input  wire        rst_n,   // Active-low pushbutton
  output wire [7:0]  led      // 8 user LEDs
);

  // Invert rst_n (active low) → internal active-high reset
  wire rst = ~rst_n;

  // Use the 25 MHz clock directly for the CPU
  wire cpu_clk = clk25m;

  // Wire from CPU: 8-bit output port
  wire [7:0] out_port;

  // Instantiate the CPU core
  core cpu0 (
    .clk      (cpu_clk),
    .rst      (rst),
    .out_port (out_port)
  );

  // Drive the 8 LEDs with the CPU's out_port
  assign led = out_port;

endmodule
