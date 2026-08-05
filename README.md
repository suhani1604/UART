UART Verification using SystemVerilog
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
A self-checking SystemVerilog testbench for a UART (Universal Asynchronous Receiver Transmitter), built around a mailbox-based verification environment with internal loopback checking.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

Overview

This project implements a UART transmitter and receiver in Verilog RTL, and verifies them using a layered SystemVerilog testbench (Generator, Driver, Monitor, Scoreboard, Environment). The TX and RX modules are connected in loopback, so every byte driven into the transmitter is checked against what the receiver reconstructs.

The goal was to build a complete, functioning verification flow end to end — from RTL through a randomized, self-checking environment — rather than just simulate a design and eyeball the waveform.

Design Under Test

The UART is split into two independent blocks:

1.Transmitter (TX) — converts 8-bit parallel data into a serial stream: 1 start bit, 8 data bits (LSB first), 1 stop bit. Asserts txdone on completion.

2.Receiver (RX) — detects the start bit on the serial line, samples incoming bits at the configured baud rate, reconstructs the byte, and asserts rxdone once reception is complete.

Both blocks are driven by a parameterized baud-rate generator and run on independent FSMs, connected in loopback (tx → rx) for functional checking.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
         
Verification Environment

The testbench follows a standard component-based structure:

## Verification Environment

The testbench follows a standard component-based verification architecture.

| Component | Role |
|-----------|------|
| `uart_if` | Interface bundling DUT signals for the testbench |
| `transaction` | Randomized transaction object containing UART stimulus |
| `generator` | Produces a stream of randomized transactions |
| `driver` | Drives transactions onto the DUT through the virtual interface |
| `monitor` | Samples DUT outputs after UART reception completes |
| `scoreboard` | Compares transmitted and received data and reports PASS/FAIL |
| `environment` | Instantiates and connects the generator, driver, monitor, and scoreboard |
| `tb` | Top-level testbench that instantiates the DUT, generates clock/reset, and starts the verification environment |

Communication between components uses SystemVerilog mailboxes. Each transaction generated is independently driven, monitored, and checked — the scoreboard flags a mismatch immediately if received data doesn't match what was sent.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


Simulated on : ModelSim/QuestaSim and EDA Playground, with waveform inspection via EPWave.

vlog RTL/UART.v TB/*.sv
vsim -c tb -do "run -all"
Sample Output
GENERATOR -> DRIVER -> MONITOR -> SCOREBOARD

SCB: PASS
Expected = AC
Actual   = AC
Waveform
<img width="1415" height="475" alt="uart waveform" src="https://github.com/user-attachments/assets/c18386b0-8331-46ce-aa87-461b37902b92" />



(EPWave screenshot — Waveform/uart_waveform.png)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

Signals of interest: clock, reset, start pulse, tx, rx, TX/RX FSM states, txdone, rxdone, received data byte.

Next Steps
Functional coverage (covergroups on data, baud config)
SystemVerilog Assertions (SVA) for protocol checks — start/stop bit timing, bit ordering
Negative/error-injection tests (framing errors, glitched start bit)
Multi baud-rate support
Migrate environment to UVM
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

Author

Suhani Deshmukh

Electronics & Telecommunication Engineering |Design Verification | VLSI

 Skills:Verilog SystemVerilog UVM Digital Design Verification
