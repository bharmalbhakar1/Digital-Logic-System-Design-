`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2025 01:15:56 PM
// Design Name: 
// Module Name: seg7_display_tb
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


//module seg7_display_tb(

//    );
//endmodule
module seg7_display_tb();

  // Testbench signals
  reg ze, on, tw, th, fo, fi, si, se, ei, ni;
  wire a, b, c, d, e, f, g, an0, an1, an2, an3;

  // Instantiate the DUT (Design Under Test)
  seg7_display UUT (
    .ze(ze), .on(on), .tw(tw), .th(th), .fo(fo),
    .fi(fi), .si(si), .se(se), .ei(ei), .ni(ni),
    .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .an0(an0), .an1(an1), .an2(an2), .an3(an3)
  );

  // Task to set all inputs to 0
  task reset_inputs;
    begin
      ze=0; on=0; tw=0; th=0; fo=0;
      fi=0; si=0; se=0; ei=0; ni=0;
    end
  endtask

  // Stimulus block
  initial begin
//    $display("Starting simulation...");
    reset_inputs;

    // Display 0
    #10 reset_inputs; ze = 1;
    #10;

    // Display 1
    #10 reset_inputs; on = 1;
    #10;

    // Display 2
    #10 reset_inputs; tw = 1;
    #10;

    // Display 3
    #10 reset_inputs; th = 1;
    #10;

    // Display 4
    #10 reset_inputs; fo = 1;
    #10;

    // Display 5
    #10 reset_inputs; fi = 1;
    #10;

    // Display 6
    #10 reset_inputs; si = 1;
    #10;

    // Display 7
    #10 reset_inputs; se = 1;
    #10;

    // Display 8
    #10 reset_inputs; ei = 1;
    #10;

    // Display 9
    #10 reset_inputs; ni = 1;
    #10;

//    $display("Simulation complete.");
//    $finish;
  end

endmodule