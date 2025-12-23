//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 10/17/2025 01:04:52 PM
//// Design Name: 
//// Module Name: linked_list_fsm
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

module linked_list_fsm #(
    //parameters
    parameter MAX_NODES         = 32,                  //width of the node_data_array
    parameter ADDR_WIDTH        = $clog2(MAX_NODES),   //with of the pointer
    parameter MAX_DISPLAY_COUNT = 25_000_000           // For traversal speed
)(
    input  wire clk,
    input  wire BTNC, 
    input  wire [7:0] SW_data,                        // input switches
    input  wire [2:0] SW_op,                          // operation switches
    output reg  LED0,                                 // Overflow
    output reg  LED1,                                 // Underflow
    output wire [6:0] seg,
    output wire [3:0] an
);

    // Data Structure Memory
    reg [7:0] node_data_mem [0:MAX_NODES-1];
    reg [ADDR_WIDTH:0] next_ptr_mem [0:MAX_NODES-1];
    
    // Pointers
    localparam [ADDR_WIDTH:0] NULL_PTR = MAX_NODES;
    reg [ADDR_WIDTH:0] head_ptr, free_ptr;
    reg [ADDR_WIDTH:0] traverse_ptr, prev_ptr, new_node_addr;

    // Error Timer (for 100MHz clock)
    parameter TWO_SECONDS_COUNT = 28'd200_000_000;
    reg [27:0] error_timer;
    reg        is_overflow_error; // Remembers which error happened

    // FSM States
    localparam [3:0] S_IDLE              = 4'd0,
                     S_INSERT_H          = 4'd1,
                     S_INSERT_T_START    = 4'd2,
                     S_INSERT_T_FIND     = 4'd3,
                     S_INSERT_T_FINISH   = 4'd4,
                     S_DELETE_START      = 4'd5,
                     S_DELETE_FIND       = 4'd6,
                     S_DELETE_FINISH     = 4'd7,
                     S_TRAVERSE_START    = 4'd8,
                     S_TRAVERSE_SHOW     = 4'd9,
                     S_ERROR_DISPLAY     = 4'd10;

    reg [3:0] current_state, next_state;

    // Input Operation Handling
    reg [2:0] prev_op;
    reg op_pending;
    wire op_changed = (SW_op != prev_op);

    always @(posedge clk or posedge BTNC) begin
        if (BTNC) op_pending <= 1'b0;
        else if (op_changed) op_pending <= 1'b1;
        else if (current_state != S_IDLE) op_pending <= 1'b0;
    end

    reg [28:0] traverse_display_counter;

    // Combinational Logic for Next State and Outputs
    always @(*) begin
        next_state = current_state;
        case (current_state)
            S_IDLE: begin
                LED0 = 1'b0;
                LED1 = 1'b0;
                if (op_pending) begin
                    case (SW_op)
                        3'b100: next_state = S_INSERT_H;
                        3'b101: next_state = S_INSERT_T_START;
                        3'b110: next_state = S_DELETE_START;
                        3'b111: next_state = S_TRAVERSE_START;
                        default: next_state = S_IDLE;
                    endcase
                end
            end
            S_INSERT_H:        if (free_ptr == NULL_PTR) next_state = S_ERROR_DISPLAY; else next_state = S_IDLE;
            S_INSERT_T_START:  if (free_ptr == NULL_PTR) next_state = S_ERROR_DISPLAY; else next_state = (head_ptr == NULL_PTR) ? S_INSERT_H : S_INSERT_T_FIND;
            S_INSERT_T_FIND:   if (next_ptr_mem[traverse_ptr] == NULL_PTR) next_state = S_INSERT_T_FINISH; else next_state = S_INSERT_T_FIND;
            S_INSERT_T_FINISH: next_state = S_IDLE;
            S_DELETE_START:    if (head_ptr == NULL_PTR) next_state = S_ERROR_DISPLAY; else next_state = S_DELETE_FIND;
            S_DELETE_FIND:     if (traverse_ptr == NULL_PTR || node_data_mem[traverse_ptr] == SW_data) next_state = S_DELETE_FINISH; else next_state = S_DELETE_FIND;
            S_DELETE_FINISH:   if (traverse_ptr == NULL_PTR && head_ptr != NULL_PTR) next_state = S_ERROR_DISPLAY; else next_state = S_IDLE;
            S_TRAVERSE_START:  next_state = (head_ptr == NULL_PTR) ? S_IDLE : S_TRAVERSE_SHOW;
            S_TRAVERSE_SHOW:   if (traverse_ptr == NULL_PTR) next_state = S_IDLE; else next_state = S_TRAVERSE_SHOW;
            S_ERROR_DISPLAY:   if (error_timer >= TWO_SECONDS_COUNT) next_state = S_IDLE; else next_state = S_ERROR_DISPLAY;
            default:           next_state = S_IDLE;
        endcase

        if (current_state == S_ERROR_DISPLAY) begin
            if (is_overflow_error) LED0 = 1'b1;
            else LED1 = 1'b1;
        end
    end

    always @(posedge clk or posedge BTNC) begin
        if (BTNC) prev_op <= 3'b000;
        else if (op_changed) prev_op <= SW_op;
    end

    // Sequential Logic for State and Data Changes
    integer i;
    always @(posedge clk or posedge BTNC) begin
        if (BTNC) begin
            current_state <= S_IDLE;
            head_ptr <= NULL_PTR;
            free_ptr <= 0;
            traverse_display_counter <= 0;
            traverse_ptr <= NULL_PTR;
            error_timer <= 0;
            is_overflow_error <= 1'b0;
            for (i = 0; i < MAX_NODES; i = i + 1) begin
                next_ptr_mem[i] <= (i == MAX_NODES-1) ? NULL_PTR : i + 1;
                node_data_mem[i] <= 0;
            end
        end else begin
            current_state <= next_state;
            if (next_state == S_ERROR_DISPLAY && current_state != S_ERROR_DISPLAY) begin
                error_timer <= 0;
                if ((current_state == S_INSERT_H || current_state == S_INSERT_T_START) && free_ptr == NULL_PTR)
                    is_overflow_error <= 1'b1;
                else
                    is_overflow_error <= 1'b0;
            end else if (current_state == S_ERROR_DISPLAY) begin
                error_timer <= error_timer + 1;
            end

            // Traversal Display Counter
            if (current_state == S_TRAVERSE_SHOW) begin
                if (traverse_display_counter >= MAX_DISPLAY_COUNT) begin
                    traverse_display_counter <= 0;
                    traverse_ptr <= next_ptr_mem[traverse_ptr];
                end else begin
                    traverse_display_counter <= traverse_display_counter + 1;
                end
            end else begin
                traverse_display_counter <= 0;
            end

            // Main FSM Actions
            case (current_state)
                S_INSERT_H: begin
                    if (free_ptr != NULL_PTR) begin
                        new_node_addr = free_ptr;
                        node_data_mem[new_node_addr] <= SW_data;
                        next_ptr_mem[new_node_addr] <= head_ptr;
                        head_ptr <= new_node_addr;
                        free_ptr <= next_ptr_mem[free_ptr];
                    end
                end
                S_INSERT_T_START: begin
                    if (free_ptr != NULL_PTR) begin
                        new_node_addr = free_ptr;
                        node_data_mem[new_node_addr] <= SW_data;
                        next_ptr_mem[new_node_addr] <= NULL_PTR;
                        free_ptr <= next_ptr_mem[free_ptr];
                        traverse_ptr <= head_ptr;
                    end
                end
                S_INSERT_T_FIND: begin
                    if (next_ptr_mem[traverse_ptr] != NULL_PTR)
                        traverse_ptr <= next_ptr_mem[traverse_ptr];
                end
                S_INSERT_T_FINISH:
                    next_ptr_mem[traverse_ptr] <= new_node_addr;
                S_DELETE_START: begin
                    traverse_ptr <= head_ptr;
                    prev_ptr <= NULL_PTR;
                end
                S_DELETE_FIND: begin
                    if (traverse_ptr != NULL_PTR && node_data_mem[traverse_ptr] != SW_data) begin
                        prev_ptr <= traverse_ptr;
                        traverse_ptr <= next_ptr_mem[traverse_ptr];
                    end
                end
                S_DELETE_FINISH: begin
                    if (traverse_ptr != NULL_PTR && node_data_mem[traverse_ptr] == SW_data) begin
                        if (prev_ptr == NULL_PTR)
                            head_ptr <= next_ptr_mem[traverse_ptr];
                        else
                            next_ptr_mem[prev_ptr] <= next_ptr_mem[traverse_ptr];

                        next_ptr_mem[traverse_ptr] <= free_ptr;
                        free_ptr <= traverse_ptr;
                    end
                end
                S_TRAVERSE_START: begin
                    traverse_ptr <= head_ptr;
                end
            endcase
        end
    end

    // Data to be displayed on the 7-segment
    reg [7:0] ssd_data;
    always @(*) begin
        if (current_state == S_TRAVERSE_SHOW && traverse_ptr != NULL_PTR)
            ssd_data = node_data_mem[traverse_ptr];
        else
            ssd_data = 8'hFF;
    end

    // Instantiation of the display driver
    seven_segment_driver display (
        .clk(clk),
        .reset(BTNC),
        .data_in(ssd_data),
        .seg(seg),
        .an(an)
    );
endmodule
