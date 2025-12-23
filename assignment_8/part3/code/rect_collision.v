`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 01:23:55 PM
// Design Name: 
// Module Name: rect_collision
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


module rect_collision #(
    parameter integer W = 14,
    parameter integer H = 16
)(
    input  wire [9:0] ax, ay,   // top-left A (main car)
    input  wire [9:0] bx, by,   // top-left B (rival)
    output wire       collide
);
    wire [10:0] a_right  = ax + W - 1;
    wire [10:0] a_bottom = ay + H - 1;
    wire [10:0] b_right  = bx + W - 1;
    wire [10:0] b_bottom = by + H - 1;

    wire no_overlap = (a_right < bx) || (b_right < ax) || (a_bottom < by) || (b_bottom < ay);
    assign collide = ~no_overlap;
endmodule