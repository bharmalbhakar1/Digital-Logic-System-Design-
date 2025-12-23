`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 01:52:46 PM
// Design Name: 
// Module Name: tb_Display_sprite
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

module tb_Display_sprite;

    reg clk;            // System clock input
    reg btnL, btnR;     // Car movement buttons
    reg btnC;           // Game restart button (equivalent to BTNC in assignment)

    wire HS, VS;        // VGA sync signals
    wire [11:0] vgaRGB; // 12-bit color output

    wire [7:0] rival_prng_out;
    // b. Coordinates and collision
    wire [9:0] main_car_x, main_car_y;
    wire [9:0] rival_car_x, rival_car_y;
    wire collision_flag;

    wire [2:0] fsm_current_state;
 
    parameter COLLIDE_STATE = 3'd3; // <-- CHANGE THIS TO YOUR ACTUAL COLLIDE STATE ENCODING

     Display_sprite_with_rival UUT (
        .clk(clk),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .HS(HS),
        .VS(VS),
        .vgaRGB(vgaRGB)
    );

    assign rival_prng_out  = UUT.u_rival_controller.u_lfsr_inst.q;
    assign main_car_x      = UUT.FSM_Inst.current_car_x;
    assign main_car_y      = UUT.FSM_Inst.running;
    assign rival_car_x     = UUT.u_rival_controller.rival_x;
    assign rival_car_y     = UUT.u_rival_controller.rival_y;
    assign collision_flag  = UUT.FSM_Inst.rival_collision;
    assign fsm_current_state = UUT.FSM_Inst.current_state;

    parameter CLK_PERIOD = 10; // 10ns period for 100MHz clock
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        btnL = 1'b0;
        btnR = 1'b0;
        btnC = 1'b0; // BTNC acts as the reset/restart trigger

        $display("Time %t: Asserting BTNC to force START state / Reset Game.", $time);
        btnC = 1'b1;
        #(CLK_PERIOD * 10);
        btnC = 1'b0;
        $display("Time %t: Releasing BTNC. Game should be in START or IDLE.", $time);

        $display("Time %t: Observing PRNG Output (rival_prng_out) over 50 cycles.", $time);
        #(CLK_PERIOD * 50);
        $display("Time %t: PRNG value settled to %d", $time, rival_prng_out);

        $display("Time %t: Moving main car (btnR) to force overlap with rival_car_x=%d.", $time, rival_car_x);
        btnR = 1'b1;
      
        #(CLK_PERIOD * 2000);
        btnR = 1'b0;

        $display("Time %t: Collision flag should now be HIGH, FSM state is %d.", $time, fsm_current_state);

        $display("Time %t: Post-Collision Check - Initial Rival Y: %d, Main X: %d, Collision: %b.", $time, rival_car_y, main_car_x, collision_flag);

        $display("Time %t: Waiting for 2 frames (approx 8.4ms) to confirm coordinate freeze...", $time);
        #(CLK_PERIOD * 840000); // Wait for 2 full VGA frames

        $display("Time %t: After wait - Final Rival Y: %d. Should be same as initial Y.", $time, rival_car_y);

        $display("Time %t: Asserting BTNC to re-start game.", $time);
        btnC = 1'b1;
        #(CLK_PERIOD * 10);
        btnC = 1'b0;
        $display("Time %t: Game should be restarted. Rival car may have a new X position.", $time);

        // End Simulation
        #(CLK_PERIOD * 100);
        $finish;
    end

endmodule