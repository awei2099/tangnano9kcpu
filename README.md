# FPGA-Tang Nano 9K 8-Bit CPU

This repository implements a minimal 8-bit accumulator-based CPU in Verilog, synthesized onto a Sipeed /Tang Nano 9K (Lattice ECP5) FPGA. It supports a tiny 8-bit ISA (arithmetic, memory, conditional branches, and an `OUT` instruction to drive LEDs). You can use this as a starting point for learning CPU design, verifying it in simulation, and flashing it onto the Tang Nano 9K.

---
- **CPU Core (`core.v`)**  
  - 8-bit accumulator (`ACC`)  
  - 8-bit Program Counter (`PC`)  
  - 256 × 8 bits of *program memory* (initialized from `prog.hex`)  
  - 256 × 8 bits of *data memory* (initialized to zero)  
  - Tiny 8-bit ISA (single‐byte opcodes + optional immediate/address byte)  
  - Two-phase FSM:  
    1. **Fetch**: read an 8-bit opcode from `inst_mem[PC]`, increment PC  
    2. **Execute**: do the operation (some instructions read a second byte from memory); write result into `ACC`, possibly change `PC`, possibly write to `data_mem[…]`, or set `out_port`

- **Top Level (`top.v`)**  
  - Takes the on-board 25 MHz oscillator (`clk25m`) and active-low pushbutton (`rst_n`)  
  - Feeds `clk25m` + `rst` into the CPU core  
  - Wires the CPU’s 8-bit `out_port` to eight LEDs (`led[7:0]`)

- **Example Program (`prog.hex`)**  
  - A tiny test that:  
    1. `LOAD_IMM 0x05` → ACC = 0x05  
    2. `OUT`            → `out_port` = ACC (LEDs display 0x05)  
    3. `HALT`           → CPU stops advancing  
  - You can edit `prog.hex` (in hex) to try your own test code.

- **Pin Constraints (`tangnano9k.pcf`)**  
  - Example mappings from logical signals (`clk25m`, `rst_n`, `led[0]…led[7]`) to physical Tang Nano 9K pins.  
  - You must update these pin names to match your board’s silkscreen/revision if they differ.

- **Testbench (`tb_core.v`)**  
  - Simple 2-phase handshake style testbench that toggles `clk` + `rst` for simulation.  
  - You can run this in ModelSim/QuestaSim/Verilator to watch `ACC`, `PC`, `out_port`, and verify basic program flow.
