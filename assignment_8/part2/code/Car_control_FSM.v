`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2025 02:45:43 PM
// Design Name: 
// Module Name: Car_control_FSM
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

module Car_control_FSM (
    input  clk,
    input  btnL,
    input  btnR,
    input  btnC,
    output reg [9:0] current_car_x
);

    localparam START     = 3'b000;
    localparam IDLE      = 3'b001;
    localparam RIGHT_CAR = 3'b010;
    localparam LEFT_CAR  = 3'b011;
    localparam COLLIDE   = 3'b100;

    localparam START_X          = 270;
    localparam COLLISION_LEFT   = 244; 
    localparam CAR_WIDTH        = 14;  
    localparam COLLISION_RIGHT  = 318; 
    localparam MOVE_STEP        = 2;

    localparam CLK_FREQ_HZ  = 100000000;
    localparam MOVE_FREQ_HZ = 10;
    localparam MAX_COUNT    = (CLK_FREQ_HZ / MOVE_FREQ_HZ) - 1;

    reg  [23:0] move_counter = 0;
    wire        move_tick;

    reg  [2:0] current_state, next_state;
    reg  [9:0] car_x_reg;

    always @(posedge clk) begin
        if (move_counter == MAX_COUNT)
            move_counter <= 0;
        else
            move_counter <= move_counter + 1;
    end
    assign move_tick = (move_counter == MAX_COUNT);

   
    wire [9:0] right_edge_now = car_x_reg + CAR_WIDTH;


    wire at_left_now  = (car_x_reg      <= COLLISION_LEFT);
    wire at_right_now = (right_edge_now >= COLLISION_RIGHT);

   
    wire will_hit_left  = (car_x_reg      <= (COLLISION_LEFT + MOVE_STEP));        
    wire will_hit_right = (right_edge_now >= (COLLISION_RIGHT - MOVE_STEP));       

    
    always @(*) begin
        next_state = current_state;

        case (current_state)
            START: begin               
                if (at_left_now || at_right_now)
                    next_state = COLLIDE;
                else if (btnL)
                    next_state = LEFT_CAR;
                else if (btnR)
                    next_state = RIGHT_CAR;
                else
                    next_state = IDLE;
            end

            IDLE: begin          
                if (at_left_now || at_right_now)
                    next_state = COLLIDE;
                else if (btnL)
                    next_state = LEFT_CAR;
                else if (btnR)
                    next_state = RIGHT_CAR;
            end

            RIGHT_CAR: begin
                if (at_right_now || will_hit_right)
                    next_state = COLLIDE;
                else if (!btnR)
                    next_state = IDLE;
            end

            LEFT_CAR: begin
                
                if (at_left_now || will_hit_left)
                    next_state = COLLIDE;
                else if (!btnL)
                    next_state = IDLE;
            end

            COLLIDE: begin
                
                if (btnC)
                    next_state = START;
            end

            default: next_state = START;
        endcase
    end

  
    always @(posedge clk) begin
        if (btnC) begin
            
            current_state <= START;
            car_x_reg     <= START_X;
            current_car_x <= START_X;
        end else begin
            current_state <= next_state;
            current_car_x <= car_x_reg;

            
            if (move_tick) begin
                case (current_state)
                    RIGHT_CAR: begin
                        if (!(at_right_now || will_hit_right))
                            car_x_reg <= car_x_reg + MOVE_STEP;
                       
                    end
                    LEFT_CAR: begin
                        if (!(at_left_now || will_hit_left))
                            car_x_reg <= car_x_reg - MOVE_STEP;
                   
                    end
                    START: begin
                        car_x_reg <= START_X;
                    end
                    default: begin
                        car_x_reg <= car_x_reg; 
                    end
                endcase
            end
        end
    end

endmodule