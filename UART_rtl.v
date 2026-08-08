
`timescale 1ns / 1ps
module UART
(
    input              clk,
    input              rst,

    input              start,
    input      [7:0]   txin,

    output reg         tx,

    input              rx,

    output     [7:0]   rxout,
    output             txdone,
    output             rxdone
);

    //--------------------------------------------------
    // Parameters
    //--------------------------------------------------

    parameter CLKS_PER_BIT = 8;

    //--------------------------------------------------
    // State Encoding
    //--------------------------------------------------

    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;
      //--------------------------------------------------
    // TX Registers
    //--------------------------------------------------

    reg [7:0] tx_data;
    reg [3:0] tx_bit_index;
    reg [1:0] tx_state;
    reg [15:0] tx_clk_count;
    reg tx_busy;
    reg tx_done;

    //--------------------------------------------------
    // RX Registers
    //--------------------------------------------------

    reg [7:0] rx_data;
    reg [3:0] rx_bit_index;
    reg [1:0] rx_state;
    reg [15:0] rx_clk_count;
    reg rx_busy;
    reg rx_done;

    //--------------------------------------------------
    // Output Assignments
    //--------------------------------------------------

    assign rxout  = rx_data;
    assign txdone = tx_done;
    assign rxdone = rx_done;
  //--------------------------------------------------
// Baud Rate Generator - TX
//--------------------------------------------------

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        tx_clk_count <= 0;
    end
    else if (tx_busy)
    begin
        if (tx_clk_count == CLKS_PER_BIT-1)
            tx_clk_count <= 0;
        else
            tx_clk_count <= tx_clk_count + 1;
    end
    else
    begin
        tx_clk_count <= 0;
    end
end


//--------------------------------------------------
// Baud Rate Generator - RX
//--------------------------------------------------

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        rx_clk_count <= 0;
    end
    else if (rx_busy)
    begin
        if (rx_clk_count == CLKS_PER_BIT-1)
            rx_clk_count <= 0;
        else
            rx_clk_count <= rx_clk_count + 1;
    end
    else
    begin
        rx_clk_count <= 0;
    end
end
  //--------------------------------------------------
// UART Transmitter FSM
//--------------------------------------------------

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        tx           <= 1'b1;
        tx_state     <= IDLE;
        tx_busy      <= 1'b0;
        tx_done      <= 1'b0;
        tx_bit_index <= 4'd0;
        tx_data      <= 8'd0;
    end
    else
    begin
        // tx_done should be a one-clock pulse
        tx_done <= 1'b0;

        case(tx_state)

        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------
        IDLE:
        begin
            tx <= 1'b1;
            tx_busy <= 1'b0;

            if(start)
            begin
                tx_busy      <= 1'b1;
                tx_data      <= txin;
                tx_bit_index <= 0;
                tx_state     <= START;
            end
        end

        //--------------------------------------------------
        // START BIT
        //--------------------------------------------------
        START:
        begin
            tx <= 1'b0;

            if(tx_clk_count == CLKS_PER_BIT-1)
                tx_state <= DATA;
        end

        //--------------------------------------------------
        // DATA BITS
        //--------------------------------------------------
        DATA:
        begin
            tx <= tx_data[tx_bit_index];

            if(tx_clk_count == CLKS_PER_BIT-1)
            begin
                if(tx_bit_index == 7)
                    tx_state <= STOP;
                else
                    tx_bit_index <= tx_bit_index + 1;
            end
        end

        //--------------------------------------------------
        // STOP BIT
        //--------------------------------------------------
        STOP:
        begin
            tx <= 1'b1;

            if(tx_clk_count == CLKS_PER_BIT-1)
            begin
                tx_done      <= 1'b1;
                tx_busy      <= 1'b0;
                tx_bit_index <= 0;
                tx_state     <= IDLE;
            end
        end

        default:
            tx_state <= IDLE;

        endcase
    end
end
 //--------------------------------------------------
// UART Receiver FSM
//--------------------------------------------------

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        rx_state     <= IDLE;
        rx_busy      <= 1'b0;
        rx_done      <= 1'b0;
        rx_bit_index <= 4'd0;
        rx_data      <= 8'd0;
    end

    else
    begin

        // one clock pulse
        rx_done <= 1'b0;


        case(rx_state)


        //--------------------------------------------------
        // IDLE : Wait for start bit
        //--------------------------------------------------

        IDLE:
        begin
            rx_busy <= 1'b0;

            if(rx == 1'b0)
            begin
                rx_busy      <= 1'b1;
                rx_bit_index <= 4'd0;
                rx_state     <= START;
            end
        end



        //--------------------------------------------------
        // START BIT CHECK
        //--------------------------------------------------

        START:
        begin

            // sample middle of start bit
            if(rx_clk_count == (CLKS_PER_BIT/2)-1)
            begin

                if(rx == 1'b0)
                begin
                    rx_state <= DATA;
                end

                else
                begin
                    rx_state <= IDLE;
                    rx_busy  <= 1'b0;
                end

            end

        end



        //--------------------------------------------------
        // DATA BITS
        //--------------------------------------------------

        DATA:
        begin

            if(rx_clk_count == CLKS_PER_BIT-1)
            begin

                rx_data[rx_bit_index] <= rx;


                if(rx_bit_index == 7)
                begin
                    rx_state <= STOP;
                end

                else
                begin
                    rx_bit_index <= rx_bit_index + 1;
                end

            end

        end



        //--------------------------------------------------
        // STOP BIT
        //--------------------------------------------------

        STOP:
        begin

            if(rx_clk_count == CLKS_PER_BIT-1)
            begin

                rx_done <= 1'b1;
                rx_busy <= 1'b0;

                rx_state <= IDLE;

            end

        end



        default:
        begin
            rx_state <= IDLE;
            rx_busy  <= 1'b0;
        end


        endcase

    end

end

endmodule
   

