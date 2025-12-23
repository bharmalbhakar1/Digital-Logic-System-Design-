`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2025 03:20:43 PM
// Design Name: 
// Module Name: tb_linked_list_fsm
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

module tb_linked_list_fsm;

    // Parameters
    parameter MAX_NODES = 32;
    parameter ADDR_WIDTH = $clog2(MAX_NODES);
    parameter CLK_PERIOD = 10; // 100MHz clock (10ns period)

    // Inputs
    reg clk;
    reg BTNC;
    reg [7:0] SW_data;
    reg [2:0] SW_op;

    // Outputs
    wire LED0;
    wire LED1;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Unit Under Test (UUT)
    linked_list_fsm #(
        .MAX_NODES(MAX_NODES),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_DISPLAY_COUNT(100)  // Override for fast simulation
    ) uut (
        .clk(clk),
        .BTNC(BTNC),
        .SW_data(SW_data),
        .SW_op(SW_op),
        .LED0(LED0),
        .LED1(LED1),
        .seg(seg),
        .an(an)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize waveform dump
        $dumpfile("linked_list_fsm.vcd");
        $dumpvars(0, tb_linked_list_fsm);

        // Initialize inputs
        BTNC = 0;
        SW_data = 8'd0;
        SW_op = 3'b000;

        $display("\n=== Linked List FSM Testbench ===\n");

        // Apply reset
        $display("Time %0t: Applying Reset", $time);
        BTNC = 1;
        #(CLK_PERIOD * 10);
        BTNC = 0;
        #(CLK_PERIOD * 10);

        // Wait for reset display to complete (reduced for simulation)
        $display("Time %0t: Waiting for reset display...", $time);
        #(CLK_PERIOD * 100);

        // Test 1: Insert at Head - Insert value 10
        $display("\nTime %0t: TEST 1 - Insert at Head (Data = 10)", $time);
        SW_data = 8'd10;
        SW_op = 3'b100; // Insert at head
        #(CLK_PERIOD * 20);
        SW_op = 3'b000; // Return to idle
        #(CLK_PERIOD * 20);
        $display("Time %0t: Insert at head complete. LED0=%b, LED1=%b", $time, LED0, LED1);

        // Test 2: Insert at Head - Insert value 20
        $display("\nTime %0t: TEST 2 - Insert at Head (Data = 20)", $time);
        SW_data = 8'd20;
        SW_op = 3'b100;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 20);
        $display("Time %0t: Insert at head complete. LED0=%b, LED1=%b", $time, LED0, LED1);

       

        // Test 4: Traverse - Should show 30, 20, 10
        $display("\nTime %0t: TEST 4 - Traverse (Expected: 30 -> 20 -> 10)", $time);
        SW_op = 3'b111; // Traverse
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 500); // Wait to see traverse display
        $display("Time %0t: Traverse operation initiated", $time);

        // Test 5: Insert at Tail - Insert value 40
        $display("\nTime %0t: TEST 5 - Insert at Tail (Data = 40)", $time);
        SW_data = 8'd40;
        SW_op = 3'b101; // Insert at tail
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);
        $display("Time %0t: Insert at tail complete. LED0=%b, LED1=%b", $time, LED0, LED1);

        // Test 6: Insert at Tail - Insert value 50
        $display("\nTime %0t: TEST 6 - Insert at Tail (Data = 50)", $time);
        SW_data = 8'd50;
        SW_op = 3'b101;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);
        $display("Time %0t: Insert at tail complete. LED0=%b, LED1=%b", $time, LED0, LED1);

        // Test 7: Traverse - Should show 30, 20, 10, 40, 50
        $display("\nTime %0t: TEST 7 - Traverse (Expected: 30 -> 20 -> 10 -> 40 -> 50)", $time);
        SW_op = 3'b111;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 800);

        // Test 8: Delete node with value 20
        $display("\nTime %0t: TEST 8 - Delete (Data = 20)", $time);
        SW_data = 8'd20;
        SW_op = 3'b110; // Delete
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);
        $display("Time %0t: Delete complete. LED0=%b, LED1=%b", $time, LED0, LED1);

        // Test 9: Traverse - Should show 30, 10, 40, 50
        $display("\nTime %0t: TEST 9 - Traverse after delete (Expected: 30 -> 10 -> 40 -> 50)", $time);
        SW_op = 3'b111;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 700);

        // Test 10: Delete head node (30)
        $display("\nTime %0t: TEST 10 - Delete head (Data = 30)", $time);
        SW_data = 8'd30;
        SW_op = 3'b110;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);
        $display("Time %0t: Delete head complete. LED0=%b, LED1=%b", $time, LED0, LED1);

        // Test 11: Traverse - Should show 10, 40, 50
        $display("\nTime %0t: TEST 11 - Traverse (Expected: 10 -> 40 -> 50)", $time);
        SW_op = 3'b111;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 600);

        // Test 12: Delete tail node (50)
        $display("\nTime %0t: TEST 12 - Delete tail (Data = 50)", $time);
        SW_data = 8'd50;
        SW_op = 3'b110;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);

        // Test 13: Traverse - Should show 10, 40
        $display("\nTime %0t: TEST 13 - Traverse (Expected: 10 -> 40)", $time);
        SW_op = 3'b111;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 400);

        // Test 14: Delete non-existent node (99)
        $display("\nTime %0t: TEST 14 - Delete non-existent (Data = 99)", $time);
        SW_data = 8'd99;
        SW_op = 3'b110;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);
        $display("Time %0t: Delete non-existent complete. LED0=%b, LED1=%b", $time, LED0, LED1);

        // Test 15: Test underflow - Delete from empty list
        $display("\nTime %0t: TEST 15 - Delete all remaining nodes", $time);
        SW_data = 8'd10;
        SW_op = 3'b110;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);

        SW_data = 8'd40;
        SW_op = 3'b110;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);

        // Test 16: Try to delete from empty list (underflow)
        $display("\nTime %0t: TEST 16 - Delete from empty list (Underflow test)", $time);
        SW_data = 8'd10;
        SW_op = 3'b110;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);
        $display("Time %0t: Underflow test. LED0=%b, LED1=%b (LED1 should be 1)", $time, LED0, LED1);

        // Test 17: Traverse empty list
        $display("\nTime %0t: TEST 17 - Traverse empty list", $time);
        SW_op = 3'b111;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 200);

        // Test 18: Insert at tail in empty list
        $display("\nTime %0t: TEST 18 - Insert at tail in empty list (Data = 100)", $time);
        SW_data = 8'd100;
        SW_op = 3'b101;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 50);

        // Final traverse
        $display("\nTime %0t: TEST 19 - Final Traverse (Expected: 100)", $time);
        SW_op = 3'b111;
        #(CLK_PERIOD * 20);
        SW_op = 3'b000;
        #(CLK_PERIOD * 300);

        $display("\n=== Testbench Complete ===\n");
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | SW_op=%b | SW_data=%d | LED0=%b | LED1=%b | State=%d",
                 $time, SW_op, SW_data, LED0, LED1, uut.current_state);
    end

endmodule

   