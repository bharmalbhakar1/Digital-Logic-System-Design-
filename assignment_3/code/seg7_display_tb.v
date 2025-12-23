`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2025 01:36:49 PM
// Design Name: 
// Module Name: seg7_display_tb
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

module seg7_display_tb;

  
    reg clk;
    reg sw10, sw11, sw12, sw13;
    reg [9:0] sw;
    wire a, b, c, d, e, f, g;
    wire an0, an1, an2, an3;


    seg7_display uut (
        .clk(clk),
        .sw10(sw10),
        .sw11(sw11),
        .sw12(sw12),
        .sw13(sw13),
        .sw(sw),
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .an0(an0), .an1(an1), .an2(an2), .an3(an3)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 0;
        sw10 = 0; sw11 = 0; sw12 = 0; sw13 = 0;
        sw = 10'b0;

        #50;

        sw = 10'b0000000010; 
        sw10 = 1; #10; sw10 = 0;

    
        #50;
        sw = 10'b0000000100; 
        sw11 = 1; #10; sw11 = 0;

        
        #50;
        sw = 10'b0000001000;
        sw12 = 1; #10; sw12 = 0;

        
        #50;
        sw = 10'b0000010000; 
        sw13 = 1; #10; sw13 = 0;

        
        #1000000; 

        $stop;
    end

endmodule
