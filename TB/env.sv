/////////env/////
class environment;

    // Component Handles
    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard scb;

    // Mailboxes
    mailbox #(transaction) gen2drv;
    mailbox #(transaction) mon2scb;

    // Virtual Interface
    virtual uart_if vif;

    // Constructor
    function new(virtual uart_if vif);

        this.vif = vif;

        // Create Mailboxes
        gen2drv = new();
        mon2scb = new();

        // Create Components
        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);

    endfunction

    // Start all components
    task run();

        fork

            gen.run();
            drv.run();
            mon.run();
            scb.run();

        join_none

    endtask

endclass
