`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 02:42:21 PM
// Design Name: 
// Module Name: top
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

//defining the module
module top(
    input clk,
    input BTNC,
    input [15:0] sw,
    output [3:0] an,
    output [6:0] seg,
    output dp
);
    // wires 

    // Signal declarations from switches
    wire [3:0] data_in = sw[3:0];
    wire [9:0] address = sw[13:4];
    wire [1:0] mode = sw[15:14];

    //signal which maintains the current sum which is given in the ram1
    wire [4:0] curr_sum = {1'b0, rom_out} + {1'b0, ram0_out};

    // Memory interface wires ouput from ram and roms
    wire [3:0] rom_out;
    wire [3:0] ram0_out;
    wire [4:0] ram1_out;

    //registers
    //input to given to ram0 and ram1
    reg [3:0] ram0_in;
    reg [4:0] ram1_in;
    //digits to be displayed on the ss display
    reg [6:0] digit3, digit2, digit_1, digit0;
    //debounced reset buttun
    reg debounced_reset = 1'b0;
    reg [19:0] debounce_counter; 
    reg reset;
    //timer to show reset for 5 secs
    reg [29:0] counter; 
    reg [3:0] final_data_in;
    reg [1:0] final_mode;
    reg [1:0] mode_prev;
    //write enables for ram0 and ram1
    reg  ram0_we;
    reg  ram1_we;

    //parameters to show reset and blank
    parameter BLANK = 7'b1111111, dash = 7'b0111111, r = 7'b0101111, S = 7'b0010010, t = 7'b0000111;
    
    // instantiations of the IP ports 
    vector_A_rom inst_vecA(
        .clk(clk),
        .a(address),
        .qspo(rom_out)
    );
    vector_B_ram0 inst_vecB(
        .clk(clk),
        .we(ram0_we),
        .a(address),
        .d(ram0_in), 
        .qspo(ram0_out)
    );
    vector_C_ram1 inst_vecC(
        .clk(clk), 
        .we(ram1_we), 
        .a(address), 
        .d(ram1_in), 
        .qspo(ram1_out)
    );

    //always blocks - core structure of module
    //debouncing of the reset button
    always @(posedge clk) begin
        if (debounced_reset == BTNC) begin
            debounce_counter <= 0;
        end else begin
            debounce_counter <= debounce_counter + 1;
            if (debounce_counter[19]) begin
                debounced_reset <= BTNC;
            end
        end
    end

    //shows reset for 5 secs
    always @(posedge clk) begin
        if (debounced_reset) begin
            reset <= 1'b1;
            counter <= 0;
        end else if (reset) begin
            counter <= counter + 1;
            if (counter[29]) begin 
                reset <= 1'b0;
            end
        end
    end

    //giving values and the commands to the ram1 and ram0
    always @(posedge clk) begin
        final_data_in <= data_in;
        final_mode <= mode;
        mode_prev <= final_mode;
        
        // Default to not writing
        ram0_we <= 1'b0;
        ram1_we <= 1'b0;

        if ((final_mode == 2'b10) && (mode_prev != 2'b10)) begin  
            ram0_we <= 1'b1;
            ram0_in <= final_data_in; 
            ram1_we <= 1'b1;
            ram1_in <= {1'b0, rom_out} + {1'b0, final_data_in};
        
        end else if ((final_mode == 2'b11) && (mode_prev != 2'b11)) begin  
            ram0_we <= 1'b1;
            ram0_in <= ram0_out + 1;
            ram1_we <= 1'b1;
            ram1_in <= {1'b0, rom_out} + ({1'b0, ram0_out} + 1);
        end
    end 

    //decides what will be shown on the display
    always @(*) begin
        if (reset) begin
            digit3 = dash ; digit2 = r; digit_1 = S; digit0 = t;
        end else if (mode == 2'b01) begin 
            
            digit3 = ssd_display({3'b0, curr_sum[4]});
            digit2 = ssd_display(curr_sum[3:0]);
            digit_1 = ssd_display(ram0_out);
            digit0 = ssd_display(rom_out);
        end else begin
            digit3 = BLANK; digit2 = BLANK; digit_1 = BLANK; digit0 = BLANK;
        end
    end

    // instantiation of the ss display for the displaying of the values on the displays
    seven_seg_display disp_ctrl(
        .clk(clk),
        .dis0(digit0), 
        .dis1(digit_1), 
        .dis2(digit2), 
        .dis3(digit3),
        .an(an), 
        .seg(seg), 
        .dp(dp)
    );

    //function which dicides what to give to the ss driver module to show as the output
    function [6:0] ssd_display;
        input [3:0] val;
        case(val)
            4'h0: ssd_display = 7'b1000000; 
            4'h1: ssd_display = 7'b1111001;
            4'h2: ssd_display = 7'b0100100; 
            4'h3: ssd_display = 7'b0110000;
            4'h4: ssd_display = 7'b0011001; 
            4'h5: ssd_display = 7'b0010010;
            4'h6: ssd_display = 7'b0000010; 
            4'h7: ssd_display = 7'b1111000;
            4'h8: ssd_display = 7'b0000000; 
            4'h9: ssd_display = 7'b0010000;
            4'hA: ssd_display = 7'b0001000; 
            4'hB: ssd_display = 7'b0000011;
            4'hC: ssd_display = 7'b1000110; 
            4'hD: ssd_display = 7'b0100001;
            4'hE: ssd_display = 7'b0000110; 
            4'hF: ssd_display = 7'b0001110;
            default: ssd_display= BLANK;
        endcase
    endfunction
endmodule