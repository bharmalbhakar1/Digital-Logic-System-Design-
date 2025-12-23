`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2025 01:29:56 PM
// Design Name: 
// Module Name: ANd_gate_tb
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


module ANd_gate_tb();
    reg a, b, c ,d ,e;
    wire x, y, z;
    // connecting testbench signals with AND_gate
    AND_gate UUT (
        .a (a),
        .b (b),
        .c (c),
        .d (d),
        .e (e),
        .x (x),
        .y (y),
        .z (z)
    );
    initial begin
    // inputs
    // 00 at 0 ns
        a = 0;
        b = 0;
        c = 0;
        d = 0;
        e = 0;
        // 01 at 20 ns, as b is 0 at 20 ns and a is changed to 1 at 20 ns
        #20 a = 1; d =1; e = 1;
        // 10 at 40 ns
        #20 b = 1; a = 0; d = 0; c = 1; e = 0;
        // 11 at 60 ns
        #20 a = 1; b = 1; d =1; c = 1; e = 1;
    end
endmodule
