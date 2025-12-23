`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 02:43:36 PM
// Design Name: 
// Module Name: ss_display
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

module seven_seg_display(
    input clk,
    input [6:0] dis0, dis1, dis2, dis3,
    output [3:0] an,
    output [6:0] seg,
    output reg dp
);
    //registers

    reg [1:0] current_an = 2'b00;
    // multiplexing the display for swtiching btw the cathode
    reg [17:0] counter = 0; 
     // cathodes of the ss display
    reg [6:0] seg_reg;

    //always blocks 
    // Cycle through the 4 anodes 
    always @(posedge clk) begin
        counter <= counter + 1;
        if(counter[17]) begin 
            counter <= 0;
            current_an <= (current_an == 2'b11) ? 2'b00 : current_an + 1;
        end
    end

    always @(*) begin
        dp = 1'b1;                 // Decimal point is off always
        case (current_an)
            2'd0: seg_reg = dis0;
            2'd1: seg_reg = dis1;
            2'd2: seg_reg = dis2;
            2'd3: seg_reg = dis3;
        endcase
    end

    // assign statemnets 
    assign seg = seg_reg;
    assign an[0] = ~(current_an == 2'd0);
    assign an[1] = ~(current_an == 2'd1);
    assign an[2] = ~(current_an == 2'd2);
    assign an[3] = ~(current_an == 2'd3);
endmodule