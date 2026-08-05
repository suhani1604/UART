////interface////
interface uart_if(input logic clk);
     logic rst;
    logic start;
    logic [7:0] txin;
    logic rx;

    logic tx;
    logic [7:0] rxout;
    logic txdone;
    logic rxdone;

endinterface
