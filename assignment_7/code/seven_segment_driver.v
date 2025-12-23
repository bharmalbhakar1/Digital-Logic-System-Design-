`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 01:06:30 PM
// Design Name: 
// Module Name: seven_segment_driver
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


module seven_segment_driver(
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    output reg [6:0] seg,
    output reg [3:0] an
);
    localparam S_NORMAL_DISPLAY   = 1'b0;
    localparam S_RESET_DISPLAY    = 1'b1;
    parameter FIVE_SECONDS_COUNT = 29'd500_000_000; 

    reg state;
    reg [28:0] reset_timer;
    reg [17:0] refresh_counter;                       
    // Combined sequential logic for FSM, timers, and counters
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (reset) begin
            state <= S_RESET_DISPLAY;
            reset_timer <= 0;
            refresh_counter <= 0;                     
        end else if (state == S_RESET_DISPLAY) begin
            if (reset_timer < FIVE_SECONDS_COUNT) begin
                reset_timer <= reset_timer + 1;
            end else begin
                state <= S_NORMAL_DISPLAY; 
            end
        end
    end

    wire [1:0] digit_select = refresh_counter[17:16];
    reg [4:0] digit_data;

    always @(*) begin
        an = 4'b1111;
        digit_data = 5'hF;

        case(digit_select)
            2'b00: begin 
                an = 4'b1110;
                if (state == S_RESET_DISPLAY) digit_data = 5'h10; 
                else                          digit_data = data_in[3:0];
            end
            2'b01: begin 
                an = 4'b1101;
                if (state == S_RESET_DISPLAY) digit_data = 5'h11; 
                else                          digit_data = data_in[7:4];
            end
            2'b10: begin 
                an = 4'b1011;
                if (state == S_RESET_DISPLAY) digit_data = 5'h12; 
                else                          digit_data = 5'hF;
            end
            2'b11: begin
                an = 4'b0111;
                if (state == S_RESET_DISPLAY) digit_data = 5'h13; 
                else                          digit_data = 5'hF;
            end
        endcase

        case(digit_data)
            5'h0: seg = 7'b1000000;
            5'h1: seg = 7'b1111001;
            5'h2: seg = 7'b0100100;
            5'h3: seg = 7'b0110000;
            5'h4: seg = 7'b0011001;
            5'h5: seg = 7'b0010010;
            5'h6: seg = 7'b0000010;
            5'h7: seg = 7'b1111000;
            5'h8: seg = 7'b0000000;
            5'h9: seg = 7'b0010000;
            5'hA: seg = 7'b0001000;
            5'hB: seg = 7'b0000011; 
            5'hC: seg = 7'b1000110; 
            5'hD: seg = 7'b0100001; 
            5'hE: seg = 7'b0000110; 
            5'h10: seg = 7'b0000111; 
            5'h11: seg = 7'b0010010; 
            5'h12: seg = 7'b0101111; 
            5'h13: seg = 7'b0111111;
            default: seg = 7'b1111111;
        endcase
    end
endmodule