/////driver/////
class driver;

    transaction tr;

    virtual uart_if vif;

    mailbox #(transaction) gen2drv;

    function new(virtual uart_if vif,
                 mailbox #(transaction) mb);

        this.vif = vif;
        gen2drv = mb;

    endfunction


    task run();

        // Initial values
        vif.start = 0;
        vif.txin  = 0;

        forever begin

            // Receive transaction
            gen2drv.get(tr);

            // Apply on next clock edge
            @(posedge vif.clk);

            vif.txin  <= tr.txin;
            vif.start <= tr.start;

            // Keep start high for one clock
            @(posedge vif.clk);

            vif.start <= 0;

            // Wait until transmission completes
            wait(vif.txdone);

            tr.display("DRIVER");

        end

    endtask

endclass
