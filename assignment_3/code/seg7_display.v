`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2025 01:33:57 PM
// Design Name: 
// Module Name: seg7_display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module seg7_display(
    input wire clk,                                // system clock runs with rising edge
    input wire sw10, sw11, sw12, sw13,             // control switches
    input wire [9:0] sw,                           // digit select bits (ze, on, tw... ni)
    output reg a, b, c, d, e, f, g,                // reg beacuse it is in always block
    output wire an0, an1, an2, an3                 // it is asign staement
);

    reg [9:0] dataout0, dataout1, dataout2, dataout3;    //memory for display
    reg [1:0] active_anode = 0;                          //2-bit register that keeps track of which digit is currently active in the multiplexing cycle.
    reg [16:0] counter = 0;                              //7-bit register that counts clock cycles to generate the 1 ms time slot for multiplexing.
    reg [9:0] current_digit;                             //It comes from one of dataout0..3 depending on active_anode.


    always @(posedge clk) begin
        if (sw10) begin
            dataout0[9:0] <= sw[9:0];
        end else if (sw11) begin
            dataout1[9:0] <= sw[9:0];
        end else if (sw12) begin
            dataout2[9:0] <= sw[9:0];
        end else if (sw13) begin
            dataout3[9:0] <= sw[9:0];
        end

    end

    always @(posedge clk) begin   
        counter <= counter + 1;
        if (counter == 17'd99999) begin 
            counter <= 0;
            active_anode <= (active_anode == 2'd3) ? 2'd0 : active_anode + 1;
        end
    end


    assign an0 = ~(active_anode == 2'd0);
    assign an1 = ~(active_anode == 2'd1);
    assign an2 = ~(active_anode == 2'd2);
    assign an3 = ~(active_anode == 2'd3);

 
    always @(*) begin
        case (active_anode)
            2'd0: current_digit = dataout0;
            2'd1: current_digit = dataout1;
            2'd2: current_digit = dataout2;
            2'd3: current_digit = dataout3;
            default: current_digit = 10'b0;
        endcase
    end


    always @(*) begin
       
        a = 1; b = 1; c = 1; d = 1; e = 1; f = 1; g = 1;

        if (current_digit[9]) begin 
            a=0; b=0; c=0; d=0; f=0; g=0;
        end else if (current_digit[8]) begin 
            a=0; b=0; c=0; d=0; e=0; f=0; g=0;
        end else if (current_digit[7]) begin 
            a=0; b=0; c=0;
        end else if (current_digit[6]) begin 
            a=0; c=0; d=0; e=0; f=0; g=0;
        end else if (current_digit[5]) begin 
            a=0; c=0; d=0; f=0; g=0;
        end else if (current_digit[4]) begin 
            b=0; c=0; f=0; g=0;
        end else if (current_digit[3]) begin 
            a=0; b=0; c=0; d=0; g=0;
        end else if (current_digit[2]) begin 
            a=0; b=0; d=0; e=0; g=0;
        end else if (current_digit[1]) begin 
            b=0; c=0;
        end else if (current_digit[0]) begin 
            a=0; b=0; c=0; d=0; e=0; f=0;
        end
    end

endmodule
