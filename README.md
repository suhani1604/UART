UART Verilog Implementation
________________________________________
📌 Overview
This project implements a UART (Universal Asynchronous Receiver Transmitter) in Verilog, supporting both data transmission (TX) and data reception (RX).
The design is based on finite state machines (FSMs) and includes a baud rate generator to ensure proper timing for serial communication.
________________________________________
⚙️ Features
•	Full UART TX and RX functionality
•	Configurable baud rate
•	FSM-based design
•	Supports 1 start bit, 8 data bits, and 1 stop bit
•	LSB-first data transmission
•	Mid-bit sampling in receiver
________________________________________
🧠 Design Parameters
•	clk_value = 100_000 → Clock scaling value (used for timing)
•	baud = 9600 → Baud rate
•	wait_count = clk_value / baud → Clock cycles per bit
________________________________________
🕒 Baud Rate Generator
•	Generates a bitDone signal after every bit duration
•	Used to synchronize both TX and RX operations
•	Based on calculated wait_count
________________________________________
📤 Transmitter (TX)
Operation
1.	Remains idle with tx = 1
2.	On start, loads data frame:
3.	{1'b1 (stop), txin[7:0], 1'b0 (start)}
4.	Transmits data LSB first
5.	Each bit is sent based on bitDone timing
TX States
•	idle
•	send
•	check
Outputs
•	tx → Serial output
•	txdone → Transmission complete signal
________________________________________
📥 Receiver (RX)
Operation
1.	Waits for start bit (rx = 0)
2.	Delays to mid-bit for accurate sampling
3.	Samples incoming bits using bitDone
4.	Shifts received bits into register
5.	Extracts 8-bit data
RX States
•	ridle
•	rwait
•	recv
Outputs
•	rxout[7:0] → Received data
•	rxdone → Reception complete signal
________________________________________
⚠️ Limitations
•	No parity bit support
•	No framing or error detection
•	Shared timing signal (bitDone) for TX and RX
•	Stop bit is not explicitly validated
________________________________________
📁 Project Structure
UART/
│── uart.v          # Main UART module
│── testbench.v     # Simulation testbench
│── README.md       # Documentation
________________________________________
▶️ Simulation Instructions
iverilog -o uart uart.v testbench.v
vvp uart
gtkwave output.vcd
________________________________________
🚀 Applications
•	FPGA serial communication
•	Embedded system interfaces
•	UART-based debugging
________________________________________
🔧 Future Improvements
•	Add parity bit support
•	Separate baud generators for TX and RX
•	Error detection (framing/parity errors)
•	FIFO buffers for data handling

