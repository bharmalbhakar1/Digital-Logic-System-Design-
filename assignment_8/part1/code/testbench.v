`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2025 01:32:51 PM
// Design Name: 
// Module Name: testbench
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

module testbench;

    parameter CLK_TB = 10;

    reg clk;
    wire HS, VS;
    wire [11:0] vgaRGB;

    reg [31:0] hs_counter = 0;
    reg [31:0] vs_counter = 0;
    reg hs_measured = 0;
    reg vs_measured = 0;

    Display_sprite DUT (
        .clk(clk),
        .HS(HS),
        .VS(VS),
        .vgaRGB(vgaRGB)
    );

    // Clock generation (100 MHz)
    initial begin
        clk = 0;
        forever #(CLK_TB / 2) clk = ~clk;
    end

    // Measurement logic
    always @(posedge clk) begin
        // Horizontal sync gap measurement
        if (!hs_measured) begin
            if (HS) begin
                if (hs_counter == 0)
                    hs_counter <= 1;
                else
                    hs_measured <= 1;
            end else if (hs_counter != 0)
                hs_counter <= hs_counter + 1;
        end

        // Vertical sync gap measurement
        if (hs_measured && !vs_measured) begin
            if (VS) begin
                if (vs_counter == 0)
                    vs_counter <= 1;
                else
                    vs_measured <= 1;
            end else if (vs_counter != 0)
                vs_counter <= vs_counter + 1;
        end
    end

endmodule