`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2025 02:09:34 PM
// Design Name: 
// Module Name: vec_dot_product
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
module vec_dot_product(
   input wire [7:0] sw, // SW7-SW0 → input data
   input wire sw8, sw9, // index select
   input wire sw12, sw13, // write enables A/B
   input wire sw14, sw15, // show A/B
   input wire clk, BTNC, // clock and reset
   output wire a,b,c,d,e,f,g, // 7-seg segments
   output reg an0,an1,an2,an3, // anodes
   output reg [15:0] led // LEDs for dot product
);

   // Internal signals
   reg [7:0] vecA [3:0];
   reg [7:0] vecB [3:0];
   reg [15:0] dot_product;
   reg [19:0] refresh_counter = 0;
   reg [4:0] digit;
   reg [17:0] sum;

   reg rst_active = 0;
   reg overflow = 0;
   reg [28:0] rst_counter;
   localparam RESET_MAX = 500_000_000;
   initial begin
     dot_product = 16'hFFFF;
     sum = 18'd0;
     led = 16'd0;
     vecA[0] = 8'd0; vecA[1] = 8'd0; vecA[2] = 8'd0; vecA[3] = 8'd0;
     vecB[0] = 8'd0; vecB[1] = 8'd0; vecB[2] = 8'd0; vecB[3] = 8'd0;
   end

   // Main Sequential Block for Registers
   always @(posedge clk) begin
     if (BTNC) begin
       rst_active <= 1;
       rst_counter <= 0;
     end else if (rst_active) begin
       if (rst_counter < RESET_MAX) rst_counter <= rst_counter + 1;
       else rst_active <= 0;
     end

     if (rst_active || BTNC) begin
       vecA[0] <= 8'd0; vecA[1] <= 8'd0; vecA[2] <= 8'd0; vecA[3] <= 8'd0;
       vecB[0] <= 8'd0; vecB[1] <= 8'd0; vecB[2] <= 8'd0; vecB[3] <= 8'd0;
       overflow <= 1'b0;
     end else begin
       if (sw12) vecA[{sw9,sw8}] <= sw;
       if (sw13) vecB[{sw9,sw8}] <= sw;
       if (sum > 16'hFFFF) overflow <= 1'b1;
     end
   end

   // Dot Product Calculation
   always @(posedge clk) begin
     sum <= vecA[0]*vecB[0] + vecA[1]*vecB[1] +
                    vecA[2]*vecB[2] + vecA[3]*vecB[3];
     dot_product <= sum[15:0];
     led <= dot_product;
   end

   // 7-seg refresh counter
   always @(posedge clk)
     refresh_counter <= refresh_counter + 1;

   // 7-seg Combinational Logic
   reg [6:0] seg;
   always @(*) begin
     case (refresh_counter[19:18])
       2'b00: begin an0=0; an1=1; an2=1; an3=1; if (rst_active) digit=20; else if (overflow) digit=0;else if(sw14 & sw15) digit = dot_product[3:0]; else if (sw14 || sw15) digit = sw14 ? vecA[{sw9,sw8}][3:0] : vecB[{sw9,sw8}][3:0];else  digit=17; end
       2'b01: begin an0=1; an1=0; an2=1; an3=1; if (rst_active) digit=5; else if (overflow) digit=18;else if(sw14 & sw15) digit = dot_product[7:4]; else if (sw14 || sw15) digit = sw14 ? vecA[{sw9,sw8}][7:4] : vecB[{sw9,sw8}][7:4]; else digit=17; end
       2'b10: begin an0=1; an1=1; an2=0; an3=1; if (rst_active) digit=19; else if (overflow) digit= 16;else if(sw14 & sw15) digit = dot_product[11:8]; else digit=17; end
       2'b11: begin an0=1; an1=1; an2=1; an3=0; if (rst_active) digit= 21; else if (overflow) digit=0;else if(sw14 & sw15) digit = dot_product[15:12]; else digit=17; end
     endcase

     case(digit)
       4'h0: seg=7'b0000001; 4'h1: seg=7'b1001111; 4'h2: seg=7'b0010010; 4'h3: seg=7'b0000110;
       4'h4: seg=7'b1001100; 4'h5: seg=7'b0100100; 4'h6: seg=7'b0100000; 4'h7: seg=7'b0001111;
       4'h8: seg=7'b0000000; 4'h9: seg=7'b0000100; 4'hA: seg=7'b0001000; 4'hB: seg=7'b1100000;
       4'hC: seg=7'b0110001; 4'hD: seg=7'b1000010; 4'hE: seg=7'b0110000; 4'hF: seg=7'b0111000;
       5'd21: seg=7'b1111110; 5'd16: seg=7'b0111000; 5'd17: seg=7'b1111111; 5'd18: seg=7'b1110001;
       5'd19: seg=7'b1111010; 5'd20: seg=7'b1110000;
       default: seg=7'b1111111;
     endcase
   end

   assign {a,b,c,d,e,f,g} = seg;

endmodule




