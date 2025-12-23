`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 03:48:36 PM
// Design Name: 
// Module Name: top_tb
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
module top_tb;

    // Inputs
    reg clk;
    reg btnc;
    reg [15:0] sw;

    // Outputs
    wire [3:0] an;
    wire [6:0] seg;
    wire dp;

    // Instantiate DUT (Device Under Test)
    top uut (
        .clk(clk),
        .BTNC(btnc),
        .sw(sw),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        btnc = 0;
        sw   = 16'b0;

        // Apply reset
        btnc = 1;
        #10;
        btnc = 0;
        #50;

        // Write Mode (10): Write B[i] = 7 at address 5
        sw[15:14] = 2'b10;   // mode = write
        sw[13:4]  = 10'd5;   // address
        sw[3:0]   = 4'd7;    // data_in
        #200;

        // Read Mode (01): Display ROM, RAM0, RAM1
        sw[15:14] = 2'b01;
        #200;

        // Increment Mode (11): Increment B[5]
        sw[15:14] = 2'b11;
        #200;

        // Read Mode again (01): Check incremented value
        sw[15:14] = 2'b01;
        #200;

        // Write Mode (10): Write new data to address 10
        sw[15:14] = 2'b10;
        sw[13:4]  = 10'd10;
        sw[3:0]   = 4'd7;
        #200;

        // Trigger reset again
        btnc = 1;
        #50;
        btnc = 0;

        // Wait a bit to see reset display
        #5000;

        // End simulation
        $stop;
    end

endmodule