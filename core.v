//------------------------------------------------------------------------------
// core.v – 8-bit accumulator CPU (fetch/execute FSM, 256×8 program + data memory)
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module core (
  input  wire        clk,      // system clock
  input  wire        rst,      // synchronous reset (active high)
  output reg  [7:0]  out_port  // drives 8 LEDs
);

  //-------------------------------------------------------------------------
  // 1) Instruction‐memory: 256×8, initialized from "prog.hex"
  //-------------------------------------------------------------------------
  reg [7:0] inst_mem [0:255];
  
  //-------------------------------------------------------------------------
  // 2) Data‐memory: 256×8, initialized to zero
  //-------------------------------------------------------------------------
  reg [7:0] data_mem [0:255];
  
  //-------------------------------------------------------------------------
  // 3) CPU registers & state
  //-------------------------------------------------------------------------
  reg [7:0] pc;     // Program Counter
  reg [7:0] acc;    // Accumulator
  reg [7:0] ir;     // Instruction Register (holds one opcode)
  reg       fetch;  // Phase: 1 = fetch, 0 = execute
  reg       halt;   // CPU halted flag
  
  //-------------------------------------------------------------------------
  // 4) Initial block: load program and reset state
  //-------------------------------------------------------------------------
  initial begin
    $readmemh("prog.hex", inst_mem);
    pc    = 8'h00;
    acc   = 8'h00;
    fetch = 1'b1;
    halt  = 1'b0;
    out_port = 8'h00;
    // data_mem will power‐on as all zeros by default
  end

  //-------------------------------------------------------------------------
  // 5) Two‐phase fetch/execute state‐machine
  //-------------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // synchronous reset
      pc    <= 8'h00;
      acc   <= 8'h00;
      fetch <= 1'b1;
      halt  <= 1'b0;
      out_port <= 8'h00;
    end
    else if (!halt) begin
      if (fetch) begin
        // PHASE 1: fetch the next opcode
        ir    <= inst_mem[pc];
        pc    <= pc + 1;
        fetch <= 1'b0;
      end
      else begin
        // PHASE 2: execute the instruction in IR
        case (ir)
          8'h00: begin
            // NOP: do nothing
          end

          // 0x10: LOAD_IMM → ACC = next_byte
          8'h10: begin
            acc <= inst_mem[pc];
            pc  <= pc + 1;
          end

          // 0x11: LOAD_MEM → ACC = data_mem[address]
          8'h11: begin
            acc <= data_mem[inst_mem[pc]];
            pc  <= pc + 1;
          end

          // 0x12: STORE_MEM → data_mem[address] = ACC
          8'h12: begin
            data_mem[inst_mem[pc]] <= acc;
            pc <= pc + 1;
          end

          // 0x20: ADD_IMM → ACC = ACC + next_byte
          8'h20: begin
            acc <= acc + inst_mem[pc];
            pc  <= pc + 1;
          end

          // 0x21: ADD_MEM → ACC = ACC + data_mem[address]
          8'h21: begin
            acc <= acc + data_mem[inst_mem[pc]];
            pc  <= pc + 1;
          end

          // 0x22: SUB_IMM → ACC = ACC – next_byte
          8'h22: begin
            acc <= acc - inst_mem[pc];
            pc  <= pc + 1;
          end

          // 0x23: SUB_MEM → ACC = ACC – data_mem[address]
          8'h23: begin
            acc <= acc - data_mem[inst_mem[pc]];
            pc  <= pc + 1;
          end

          // 0x24: AND_IMM → ACC = ACC & next_byte
          8'h24: begin
            acc <= acc & inst_mem[pc];
            pc  <= pc + 1;
          end

          // 0x25: AND_MEM → ACC = ACC & data_mem[address]
          8'h25: begin
            acc <= acc & data_mem[inst_mem[pc]];
            pc  <= pc + 1;
          end

          // 0x26: OR_IMM → ACC = ACC | next_byte
          8'h26: begin
            acc <= acc | inst_mem[pc];
            pc  <= pc + 1;
          end

          // 0x27: OR_MEM → ACC = ACC | data_mem[address]
          8'h27: begin
            acc <= acc | data_mem[inst_mem[pc]];
            pc  <= pc + 1;
          end

          // 0x30: JMP → PC = next_byte
          8'h30: begin
            pc <= inst_mem[pc];
          end

          // 0x31: JZ → if ACC == 0 then PC = next_byte else skip
          8'h31: begin
            if (acc == 8'h00)
              pc <= inst_mem[pc];
            else
              pc <= pc + 1;
          end

          // 0x32: JNZ → if ACC != 0 then PC = next_byte else skip
          8'h32: begin
            if (acc != 8'h00)
              pc <= inst_mem[pc];
            else
              pc <= pc + 1;
          end

          // 0x40: OUT → out_port = ACC
          8'h40: begin
            out_port <= acc;
          end

          // 0xFF: HALT → stop fetching/executing forever
          8'hFF: begin
            halt <= 1'b1;
          end

          default: begin
            // illegal/unused opcodes are treated as NOP
          end
        endcase

        // After any execute, return to fetch
        fetch <= 1'b1;
      end
    end
    // if halt==1, we do nothing: CPU is stuck on HALT
  end

endmodule
