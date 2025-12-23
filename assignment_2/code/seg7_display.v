`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2025 01:08:47 PM
// Design Name: 
// Module Name: seg7_display
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

module seg7_display(
  input wire ze, on, tw, th, fo, fi, si, se, ei, ni,
  output reg a, b, c, d, e, f, g, an0, an1, an2, an3
);
  always @(*)begin
    a = 1;
    b = 1;
    c = 1;
    d = 1;
    e = 1;
    f =1;
    g = 1;
    an0 = 0;
    an1 = 1;
    an2 = 1;
    an3 = 1;
    if(ni == 1) begin 
      a = 0;
      b = 0;
      c = 0;
      d = 0;
      f = 0;
      g = 0;
    end else if (ei == 1) begin 
      a = 0;
      b = 0;
      c = 0;
      d = 0;
      e = 0;
      f =0;
      g = 0;
    end else  if (se == 1) begin
      a = 0;
      b = 0;
      c = 0;
    end else if (si == 1) begin
      a = 0;
      c = 0;
      d = 0;
      e = 0;
      f =0;
      g = 0;
    end else if (fi == 1) begin
      a = 0;
      c = 0;
      d = 0;
      f =0;
      g = 0;
    end else if (fo == 1) begin
      b = 0;
      c = 0;
      f =0;
      g = 0;
    end else if (th == 1) begin
      a = 0;
      b = 0;
      c = 0;
      d = 0;
      g = 0;
    end else if (tw == 1) begin
      a = 0;
      b = 0;
      d = 0;
      e = 0;
      g = 0;
    end else if (on == 1) begin
      b = 0;
      c = 0;
    end else if (ze ==1) begin
      a = 0;
      b = 0;
      c = 0;
      d = 0;
      e = 0;
      f =0;
    end
  end
endmodule
