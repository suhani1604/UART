//////tb/////
module tb;

    logic clk;

    // Clock Generation
    always #5 clk = ~clk;

    // Interface
    uart_if vif(clk);

    // Environment
    environment env;

    // DUT
    UART dut(
        .clk(clk),
        .rst(vif.rst),
        .start(vif.start),
        .txin(vif.txin),
        .tx(vif.tx),
        .rx(vif.rx),
        .rxout(vif.rxout),
        .rxdone(vif.rxdone),
        .txdone(vif.txdone)
    );

    // Loopback Connection
    assign vif.rx = vif.tx;

    initial begin
      vif.rst = 1;

#20;

vif.rst = 0;

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        clk = 0;

        // Create Environment
        env = new(vif);

        // Initial Values
        vif.start = 0;
        vif.txin  = 0;

        // Start Verification
        env.run();

        // Run Simulation
        #1000000;

        $finish;
      
         end

   endmodule  
