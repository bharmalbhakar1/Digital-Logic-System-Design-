`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2025 01:25:05 PM
// Design Name: 
// Module Name: AND_gate
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


module AND_gate(
    input a,
    input b,
    input c,
    input d,
    input e,
    output x,
    output y,
    output z);
assign x = a & b;
assign y = d | c;
assign z = ~e;
endmodule

