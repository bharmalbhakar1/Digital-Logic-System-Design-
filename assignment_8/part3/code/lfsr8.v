`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 01:22:15 PM
// Design Name: 
// Module Name: lfsr8
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

module lfsr8 #(
    parameter [7:0] SEED = 8'hC5                                                                    
)(
    input  wire clk,
    input  wire reset,   // synchronous active-high
    output reg  [7:0] q
);

    wire newbit = q[7] ^ q[5] ^ q[4] ^ q[3];

    always @(posedge clk) begin
        if (reset) begin
            if (SEED == 8'h00) q <= 8'h01;
            else q <= SEED;
        end else begin
            q <= { q[6:0], newbit };
        end
    end

endmodule