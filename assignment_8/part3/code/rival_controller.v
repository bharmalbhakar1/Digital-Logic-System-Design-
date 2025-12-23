`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 01:24:19 PM
// Design Name: 
// Module Name: rival_controller
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
module rival_controller #(
    parameter integer BG_OFFSET_X     = 200,
    parameter integer BG_OFFSET_Y     = 150,
    parameter integer RIVAL_X_MIN_REL = 44,
    parameter integer RIVAL_X_MAX_REL = 104,
    parameter integer CAR_W = 14,
    parameter integer CAR_H = 16,
    parameter integer ROAD_HEIGHT = 240,
    parameter integer FRAME_THRESHOLD = 1,
    parameter integer DELTA_Y = 5,
    parameter [7:0] SEED = 8'hA5
)(
    input  wire        clk,                            // pixel clock domain
    input  wire        reset,                          // synchronous active-high reset (btnC)
    input  wire        enable,                         // when 0 -> pause movement and LFSR
    input  wire [9:0]  hor_pix,                        // pixel counters (for frame detection)
    input  wire [9:0]  ver_pix,
    output reg  [9:0]  rival_x,                        // top-left absolute X
    output reg  [9:0]  rival_y,                        // top-left absolute Y
    output reg         respawned                       // 1-cycle pulse when respawn happens
);

   
    wire [7:0] lfsr_q_out;

    lfsr8 #(.SEED(SEED)) u_lfsr_inst (
        .clk(clk),
        .reset(reset), // Reset forces the LFSR to the initial SEED
        .q(lfsr_q_out)
    );

    
    reg [7:0] lfsr_q_frozen;

    
    always @(posedge clk) begin
        if (reset) begin
            // On reset, read the first random value (lfsr_q_out)
            lfsr_q_frozen <= lfsr_q_out;
        end else if (enable) begin
            // Only update the frozen register when running
            lfsr_q_frozen <= lfsr_q_out;
        end
        
    end

    localparam integer RIVAL_RANGE = (RIVAL_X_MAX_REL - RIVAL_X_MIN_REL + 1); 
    wire [6:0] rand7 = lfsr_q_frozen[6:0]; // Use the frozen output
    wire [13:0] mult = rand7 * RIVAL_RANGE;
    wire [6:0] scaled = mult[13:7];
    wire [9:0] spawn_x_rel = RIVAL_X_MIN_REL + scaled;
    wire [9:0] spawn_x_abs = BG_OFFSET_X + spawn_x_rel;

    wire frame_end = (hor_pix == 10'd799) && (ver_pix == 10'd479);
    localparam integer BOTTOM_Y_THRESH = BG_OFFSET_Y + ROAD_HEIGHT - CAR_H;
    reg [15:0] frame_reg_count;

    always @(posedge clk) begin
        if (reset) begin
          
            rival_x <= spawn_x_abs;
            rival_y <= BG_OFFSET_Y;
            frame_reg_count <= 0;
            respawned <= 1'b1;
        end else begin
            respawned <= 1'b0;
            if (enable) begin
                
                if (~frame_end) begin
                    if (frame_reg_count >= FRAME_THRESHOLD - 1) begin
                        frame_reg_count <= 0;
                        rival_y <= rival_y + DELTA_Y;
                    end else begin
                        frame_reg_count <= frame_reg_count + 1;
                    end
                end

        
                if (rival_y > BOTTOM_Y_THRESH) begin
                    rival_x <= spawn_x_abs; // Use newly available random position
                    rival_y <= BG_OFFSET_Y;
                    frame_reg_count <= 0;
                    respawned <= 1'b1;
                end
            end
          
        end
    end

endmodule
