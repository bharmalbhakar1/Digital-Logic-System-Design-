`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2025 02:11:50 PM
// Design Name: 
// Module Name: tb_vec_dot_product
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



module tb_vec_dot_product;

    // Inputs
    reg [7:0] sw;
    reg sw8, sw9;
    reg sw12, sw13;
    reg sw14, sw15;
    reg clk;
    reg BTNC;

    // Outputs
    wire a, b, c, d, e, f, g;
    wire an0, an1, an2, an3;
    wire [15:0] led;

    // Instantiate the vec_dot_product module
    vec_dot_product uut (
        .sw(sw),
        .sw8(sw8),
        .sw9(sw9),
        .sw12(sw12),
        .sw13(sw13),
        .sw14(sw14),
        .sw15(sw15),
        .clk(clk),
        .BTNC(BTNC),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .an0(an0),
        .an1(an1),
        .an2(an2),
        .an3(an3),
        .led(led)
    );

    // Clock Generation
    always begin
        #5 clk = ~clk; 
    end

   
    initial begin
        // Initialize signals
        clk = 0;
        BTNC = 1;
        sw = 8'd0;
        sw8 = 0;
        sw9 = 0;
        sw12 = 0;
        sw13 = 0;
        sw14 = 0;
        sw15 = 0;
        
        // Apply reset
        #10 BTNC = 0; 
        #10 BTNC = 1; 
        #10 BTNC = 0;

        // Load Vector A
        sw12 = 1;            // Enable writing to vecA
        sw8 = 0;             // Write to vecA[0]
        sw9 = 0;
        sw = 8'd3;           // vecA[0] = 3
        #10 sw = 8'd5;       // vecA[1] = 5
        sw8 = 1;             // Write to vecA[1]
        #10 sw = 8'd7;       // vecA[2] = 7
        sw9 = 1; sw8 = 0;    // Write to vecA[2]
        #10 sw = 8'd9;       // vecA[3] = 9
        sw9 = 1;  sw8 = 1;   // Write to vecA[3]
        #10 sw12 = 0;        // Disable writing to vecA

        // Load Vector B
        sw13 = 1;            // Enable writing to vecB
        sw8 = 0;             // Write to vecB[0]
        sw9 = 0;
        sw = 8'd2;           // vecB[0] = 2
        #10 sw = 8'd4;       // vecB[1] = 4
        sw8 = 1;             // Write to vecB[1]
        #10 sw = 8'd6;       // vecB[2] = 6
        sw9 = 1; sw8 = 0;    // Write to vecB[2]
        #10 sw = 8'd8;       // vecB[3] = 8
        sw9 = 1; sw8 = 1;    // Write to vecB[3]
        #10 sw13 = 0;        // Disable writing to vecB

        // Start Dot Product Calculation
        #10 sw14 = 1;        // Start calculation
        sw15 = 1;            // Enable dot product display
        #50 sw14 = 0;        // Disable calculation after a few cycles

        // Observe the results
        #50 $finish; // End the simulation
    end

    // Monitor the results
    initial begin
        $monitor("Time = %t, led = %h, a = %b, b = %b, c = %b, d = %b, e = %b, f = %b, g = %b", 
                 $time, led, a, b, c, d, e, f, g);
    end

endmodule
