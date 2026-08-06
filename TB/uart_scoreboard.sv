////////scoreboard////
class scoreboard;

    mailbox #(transaction) mon2scb;

    function new(mailbox #(transaction) mb);

        mon2scb = mb;

    endfunction


    task run();

        transaction tr;

        forever begin

            // Receive transaction from monitor
            mon2scb.get(tr);

            // Check only after reception is complete
            if (tr.rxdone) begin

                if (tr.txin == tr.rxout)

                    $display("SCB PASS  Expected=%h  Actual=%h",
                              tr.txin, tr.rxout);

                else

                    $display("SCB FAIL  Expected=%h  Actual=%h",
                              tr.txin, tr.rxout);

            end

        end

    endtask

endclass
