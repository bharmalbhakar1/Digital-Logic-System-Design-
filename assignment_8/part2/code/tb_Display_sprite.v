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

  // DUT I/O
  reg  clk;
  reg  btnL, btnR, btnC;
  wire HS, VS;
  wire [11:0] vgaRGB;

  Display_sprite #(
    .pixel_counter_width(10),
    .OFFSET_BG_X(200),
    .OFFSET_BG_Y(150)
  ) dut (
    .clk(clk),
    .btnL(btnL),
    .btnR(btnR),
    .btnC(btnC),
    .HS(HS),
    .VS(VS),
    .vgaRGB(vgaRGB)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("tb_Display_sprite.vcd");
    $dumpvars(0, tb_Display_sprite);
  end

  localparam [2:0] START     = 3'b000;
  localparam [2:0] IDLE      = 3'b001;
  localparam [2:0] RIGHT_CAR = 3'b010;
  localparam [2:0] LEFT_CAR  = 3'b011;
  localparam [2:0] COLLIDE   = 3'b100;

  localparam integer CAR_WIDTH        = 14;
  localparam integer COLLISION_LEFT   = 244;
  localparam integer COLLISION_RIGHT  = 318;
  localparam integer START_X          = 270;
  localparam integer MOVE_STEP        = 2;
  localparam integer FSM_MAX_COUNT    = 10_000_000 - 1; 

  task press_L(input integer cycles); begin btnL=1; btnR=0; btnC=0; repeat(cycles) @(posedge clk); btnL=0; end endtask
  task press_R(input integer cycles); begin btnR=1; btnL=0; btnC=0; repeat(cycles) @(posedge clk); btnR=0; end endtask
  task press_C(input integer cycles); begin btnC=1; btnL=0; btnR=0; repeat(cycles) @(posedge clk); btnC=0; end endtask

  task force_move_tick;
    begin
      force dut.FSM_Inst.move_counter = FSM_MAX_COUNT;
      @(posedge clk);
      release dut.FSM_Inst.move_counter;
      @(posedge clk); 
    end
  endtask

  task step_left(input integer n);
    integer i;
    begin
      btnL = 1; btnR = 0; btnC = 0;
      for (i=0; i<n; i=i+1) begin
        force_move_tick();
        @(posedge clk);
        if (dut.FSM_Inst.current_state == COLLIDE) disable step_left;
      end
      btnL = 0;
    end
  endtask

  task step_right(input integer n);
    integer i;
    begin
      btnR = 1; btnL = 0; btnC = 0;
      for (i=0; i<n; i=i+1) begin
        force_move_tick();
        @(posedge clk);
        if (dut.FSM_Inst.current_state == COLLIDE) disable step_right;
      end
      btnR = 0;
    end
  endtask

  initial begin
    //$display("[%0t] TB start", $time);
    forever begin
      @(posedge clk);
      $strobe("[%0t] x=%0d state=%0b L=%0b R=%0b C=%0b HS=%0b VS=%0b",
              $time,
              dut.FSM_Inst.car_x_reg,
              dut.FSM_Inst.current_state,
              btnL, btnR, btnC, HS, VS);
    end
  end

  initial begin

    btnL=0; btnR=0; btnC=0;
    repeat(5) @(posedge clk);

    press_C(2);
    repeat(5) @(posedge clk);

    step_left(200);
    if (dut.FSM_Inst.current_state != COLLIDE) $error("Expected COLLIDE after moving left");
    
    $display("\n--- Try RIGHT in COLLIDE (ignore) ---");
    press_R(5);
    force_move_tick();
    @(posedge clk);
    if (dut.FSM_Inst.current_state != COLLIDE) $error("Should remain in COLLIDE until btnC");

    $display("\n--- Restart with btnC ---");
    press_C(2);
    @(posedge clk);
    if (dut.FSM_Inst.current_state != START) $error("Expected START after btnC");
    @(posedge clk); // allow START->IDLE

    $display("\n--- Move RIGHT to collision ---");
    step_right(200);
    if (dut.FSM_Inst.current_state != COLLIDE) $error("Expected COLLIDE after moving right");

    $display("\n--- Try LEFT in COLLIDE (ignore) ---");
    press_L(5);
    force_move_tick();
    @(posedge clk);
    if (dut.FSM_Inst.current_state != COLLIDE) $error("Should remain in COLLIDE until btnC");

    $display("\n--- Extreme-left immediate collision ---");
    press_C(2); @(posedge clk);
    force dut.FSM_Inst.car_x_reg = COLLISION_LEFT;
    @(posedge clk);
    btnL = 1; force_move_tick(); btnL = 0;
    release dut.FSM_Inst.car_x_reg;
    @(posedge clk);
    if (dut.FSM_Inst.current_state != COLLIDE) $error("Expected COLLIDE at extreme-left");

    $display("\n--- Extreme-right immediate collision ---");
    press_C(2); @(posedge clk);
    force dut.FSM_Inst.car_x_reg = (COLLISION_RIGHT - CAR_WIDTH);
    @(posedge clk);
    btnR = 1; force_move_tick(); btnR = 0;
    release dut.FSM_Inst.car_x_reg;
    @(posedge clk);
    if (dut.FSM_Inst.current_state != COLLIDE) $error("Expected COLLIDE at extreme-right");

    $display("\n--- Restart and small movement ---");
    press_C(2); @(posedge clk);
    step_right(3);
    step_left(2);

    $display("\n*** TB complete ***");
    repeat(50) @(posedge clk);
    $finish;
  end

endmodule
