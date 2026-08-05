/////generator////
class generator;

    transaction tr;

    mailbox #(transaction) gen2drv;

    function new(mailbox #(transaction) mb);

        gen2drv = mb;

    endfunction

    task run();

        repeat (20) begin

            tr = new();

            assert(tr.randomize())
                else $fatal("Randomization Failed");

            tr.start = 1'b1;

            gen2drv.put(tr);

            tr.display("GENERATOR");

            #20;

        end

    endtask

endclass
