`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2025 01:18:30 PM
// Design Name: 
// Module Name: Display_sprite
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

module Display_sprite_with_rival #(
    parameter pixel_counter_width = 10,
    parameter OFFSET_BG_X = 200,
    parameter OFFSET_BG_Y = 150
)(
    input  wire clk,
    input  wire btnL,
    input  wire btnR,
    input  wire btnC,
    output wire HS,
    output wire VS,
    output wire [11:0] vgaRGB
);

    
    localparam integer CAR_W          = 14;
    localparam integer CAR_H          = 16;
    localparam [11:0] PINK_COLOR      = 12'b101000001010;
    localparam integer MAIN_CAR_Y     = 300;
    localparam integer BG_WIDTH       = 160;
    localparam integer BG_HEIGHT      = 240;
    localparam integer SCROLL_STEP    = 1;
    localparam integer BG_RESET_Y     = 150;

    wire pixel_clock;
    wire [pixel_counter_width-1:0] hor_pix, ver_pix;
    wire [3:0] vgaRed, vgaGreen, vgaBlue;

    wire [pixel_counter_width-1:0] fsm_car_x;
    wire running_fsm;

    wire [9:0] rival_x, rival_y;
    wire rival_respawned;

    wire rival_collision_pixel;
    wire rival_collision_to_fsm;
    wire rival_enable;

    reg [9:0] bg_y_offset_reg;

    reg [15:0] bg_rom_addr;
    wire [11:0] bg_color;
    reg [7:0] car_rom_addr;
    wire [11:0] car_color;
    reg bg_on, car_on;
    wire [11:0] rival_color_from_rom;
    reg [7:0] rival_addr_r;
    reg in_rival_box_r;
    reg [11:0] rival_color_r;
    reg [11:0] bg_color_reg;
    reg [11:0] car_color_reg;
    reg [11:0] next_color;
    reg [11:0] output_color;

    reg [9:0] hor_pix_sync1, hor_pix_sync2;
    reg [9:0] ver_pix_sync1, ver_pix_sync2;
    always @(posedge clk) begin
        hor_pix_sync1 <= hor_pix;
        hor_pix_sync2 <= hor_pix_sync1;
        ver_pix_sync1 <= ver_pix;
        ver_pix_sync2 <= ver_pix_sync1;
    end
    wire [9:0] hor_pix_clk_domain = hor_pix_sync2;
    wire [9:0] ver_pix_clk_domain = ver_pix_sync2;

    wire frame_end_pc = (hor_pix == 10'd799) && (ver_pix == 10'd479);
    reg frame_end_sync1, frame_end_sync2;
    always @(posedge clk) begin
        frame_end_sync1 <= frame_end_pc;
        frame_end_sync2 <= frame_end_sync1;
    end
    wire frame_end_clk = frame_end_sync2; 
    reg [9:0] fsm_car_x_sync1_pc, fsm_car_x_sync2_pc;
    always @(posedge pixel_clock) begin
        fsm_car_x_sync1_pc <= fsm_car_x;
        fsm_car_x_sync2_pc <= fsm_car_x_sync1_pc;
    end
    wire [9:0] fsm_car_x_pc_domain = fsm_car_x_sync2_pc;

    reg collision_pc_to_clk_sync1, collision_pc_to_clk_sync2;
    always @(posedge clk) begin
        collision_pc_to_clk_sync1 <= rival_collision_pixel;
        collision_pc_to_clk_sync2 <= collision_pc_to_clk_sync1;
    end
    assign rival_collision_to_fsm = collision_pc_to_clk_sync2;

    reg running_sync1_pc, running_sync2_pc;
    always @(posedge pixel_clock) begin
        running_sync1_pc <= running_fsm;
        running_sync2_pc <= running_sync1_pc;
    end
    assign rival_enable = running_sync2_pc;

    always @(posedge clk) begin
        if (btnC) begin
            bg_y_offset_reg <= BG_RESET_Y; 
            end
         else if(running_fsm && frame_end_clk) begin 
            bg_y_offset_reg <= bg_y_offset_reg - SCROLL_STEP;

            if (bg_y_offset_reg <= (BG_RESET_Y)) begin
                bg_y_offset_reg <= BG_RESET_Y + BG_HEIGHT - SCROLL_STEP;
            end
        end
    end

    VGA_driver #(.WIDTH(pixel_counter_width)) display_driver (
        .clk(clk), .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue),
        .HS(HS), .VS(VS), .vgaRGB(vgaRGB),
        .pixel_clock(pixel_clock),
        .hor_pix(hor_pix), .ver_pix(ver_pix)
    );

    Car_control_FSM FSM_Inst (
        .clk(clk),
        .btnL(btnL), .btnR(btnR), .btnC(btnC),
        .rival_collision(rival_collision_to_fsm), 
        .reset(btnC),                          
        .current_car_x(fsm_car_x),
        .running(running_fsm)
    );

    rival_controller #(
        .BG_OFFSET_X(OFFSET_BG_X), .BG_OFFSET_Y(OFFSET_BG_Y),
        .RIVAL_X_MIN_REL(44), .RIVAL_X_MAX_REL(104),
        .CAR_W(CAR_W), .CAR_H(CAR_H),
        .ROAD_HEIGHT(BG_HEIGHT),        
        .FRAME_THRESHOLD(5), .DELTA_Y(3), .SEED(8'hC5)
    ) u_rival_controller (
        .clk(pixel_clock),
        .reset(btnC),
        .enable(rival_enable),          
        .hor_pix(hor_pix), .ver_pix(ver_pix),
        .rival_x(rival_x), .rival_y(rival_y),
        .respawned(rival_respawned)
    );

    rect_collision #(.W(CAR_W), .H(CAR_H)) u_rect_collision_pix (
        .ax({2'b00, fsm_car_x_pc_domain}), 
        .ay(MAIN_CAR_Y),
        .bx(rival_x), .by(rival_y),
        .collide(rival_collision_pixel)
    );

    
    bg_rom bg1_rom (.clka(clk), .addra(bg_rom_addr), .douta(bg_color));
    main_car_rom car1_rom (.clka(clk), .addra(car_rom_addr), .douta(car_color));
    rival_car_rom rival_car_mem_i (.clka(clk), .addra(rival_addr_r), .douta(rival_color_from_rom));

    wire [9:0] rom_relative_y = ver_pix_clk_domain - OFFSET_BG_Y;

    wire [9:0] final_y_address = (rom_relative_y + bg_y_offset_reg) % BG_HEIGHT;
    always @(posedge clk) begin
        if (hor_pix_clk_domain >= fsm_car_x && hor_pix_clk_domain < (fsm_car_x + CAR_W) &&
            ver_pix_clk_domain >= MAIN_CAR_Y && ver_pix_clk_domain < (MAIN_CAR_Y + CAR_H)) begin
            car_rom_addr <= (hor_pix_clk_domain - fsm_car_x) + (ver_pix_clk_domain - MAIN_CAR_Y) * CAR_W;
            car_on <= 1'b1;
        end else begin
            car_on <= 1'b0;
        end

        if (hor_pix_clk_domain >= OFFSET_BG_X && hor_pix_clk_domain < (OFFSET_BG_X + BG_WIDTH) &&
            ver_pix_clk_domain >= OFFSET_BG_Y && ver_pix_clk_domain < (OFFSET_BG_Y + BG_HEIGHT)) begin

            bg_rom_addr <= (hor_pix_clk_domain - OFFSET_BG_X) + (final_y_address * BG_WIDTH);
            bg_on <= 1'b1;
        end else begin
            bg_on <= 1'b0;
        end

        if ((hor_pix_clk_domain >= rival_x) && (hor_pix_clk_domain < (rival_x + CAR_W)) &&
            (ver_pix_clk_domain >= rival_y) && (ver_pix_clk_domain < (rival_y + CAR_H))) begin
            rival_addr_r <= ((ver_pix_clk_domain - rival_y) * CAR_W + (hor_pix_clk_domain - rival_x));
            in_rival_box_r <= 1'b1;
        end else begin
            rival_addr_r <= 8'd0;
            in_rival_box_r <= 1'b0;
        end

        rival_color_r <= rival_color_from_rom;
        car_color_reg <= car_color;
        bg_color_reg <= bg_color;
    end

    always @(posedge clk) begin
        if (car_on) begin
            if (car_color_reg == PINK_COLOR) begin
                if (in_rival_box_r && (rival_color_r != PINK_COLOR)) next_color <= rival_color_r;
                else if (bg_on) next_color <= bg_color_reg;
                else next_color <= 12'b0;
            end else begin
                next_color <= car_color_reg;
            end
        end else begin
            if (in_rival_box_r && (rival_color_r != PINK_COLOR)) next_color <= rival_color_r;
            else if (bg_on) next_color <= bg_color_reg;
            else next_color <= 12'b0;
        end
    end

    always @(posedge pixel_clock) begin
        output_color <= next_color;
    end

    assign vgaRed   = output_color[11:8];
    assign vgaGreen = output_color[7:4];
    assign vgaBlue  = output_color[3:0];

endmodule