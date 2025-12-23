`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2025 01:54:29 PM
// Design Name: 
// Module Name: MAC_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: S
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MAC_tb; 

    reg clk;
    reg BTNC;
    reg sw10, sw11, sw12;
    reg [7:0] sw;
    wire a, b, c, d, e, f, g;
    wire an0, an1, an2, an3;
    wire [15:0] led;

   
    MAC uut (
        .clk(clk),
        .BTNC(BTNC),
        .sw10(sw10), .sw11(sw11), .sw12(sw12),
        .sw(sw),
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .an0(an0), .an1(an1), .an2(an2), .an3(an3),
        .led(led)
    );

  
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

   
    task bounce_signal(input integer bounces, output reg signal);
        integer i;
        begin
            for(i=0; i<bounces; i=i+1) begin
                signal = 1; #5;
                signal = 0; #2;
            end
            signal = 1; 
            #10;
            signal = 0; 
        end
    endtask

   
    initial begin
       
        BTNC = 0; sw10 = 0; sw11 = 0; sw12 = 0; sw = 8'd0;

       
        $dumpfile("MAC_tb.vcd");
        $dumpvars(0, MAC_tb);

        
        $display("Time\tReset\tB\tC\tA (led)\tOverflow Display");
        $monitor("%0t\t%b\t%d\t%d\t%d\t{%b%b%b%b%b%b%b}", 
                  $time, BTNC, uut.store_B, uut.store_C, led,
                  a,b,c,d,e,f,g);

       
        #20;
        $display("Applying reset...");
        bounce_signal(2, BTNC);
        #200;

       
        sw = 8'd10; sw10 = 1; #20; sw10 = 0;

              
        sw = 8'd20; sw11 = 1; #20; sw11 = 0;

        
        $display("Triggering accumulation...");
        bounce_signal(2, sw12);
        #200;

        
        sw = 8'd200; sw10 = 1; #20; sw10 = 0;

        sw = 8'd200; sw11 = 1; #20; sw11 = 0;

       
        repeat(5) begin
            bounce_signal(2, sw12);
            #200;
        end

       
        #1000;
        $finish;
    end

endmodule
