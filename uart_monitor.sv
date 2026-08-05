/////monitorr////
class monitor;

    transaction tr;

    virtual uart_if vif;

    mailbox #(transaction) mon2scb;

    function new(virtual uart_if vif,
                 mailbox #(transaction) mb);

        this.vif = vif;
        mon2scb  = mb;

    endfunction


    task run();

        forever begin

            // Wait until transmission is complete
            @(posedge vif.txdone);

            tr = new();

            // Capture DUT signals
            tr.txin   = vif.txin;
            tr.start  = vif.start;
            tr.rx     = vif.rx;

            tr.tx     = vif.tx;
            tr.rxout  = vif.rxout;
            tr.txdone = vif.txdone;
            tr.rxdone = vif.rxdone;

            // Send transaction to scoreboard
            mon2scb.put(tr);

            tr.display("MONITOR");

        end

    endtask

endclass
