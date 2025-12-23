`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2025 01:47:40 PM
// Design Name: 
// Module Name: MAC
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


module MAC(
    input wire clk,
    input wire BTNC,
    input wire sw10, sw11, sw12,
    input wire [7:0] sw,
    output wire a, b, c, d, e, f, g,
    output wire an0, an1, an2, an3,
    output reg [15:0] led
);

   
    reg [7:0] store_B, store_C;
    reg [15:0] store_A;
    reg [1:0] active_anode = 0;
    reg [16:0] counter = 0;
    parameter WIDTH = 20;
    reg [WIDTH-1:0] counter2 = 0;
    reg sw_sync0, sw_sync1;
    reg sw12_delayed;
    wire sw12_rising;
    reg overflow;

    
    wire [15:0] product;
    wire [16:0] sum;

    assign product = store_B * store_C;
    assign sum = {1'b0, store_A} + {1'b0, product};

    
    always @(posedge clk) begin
        if(counter == 17'd99999) begin
            counter <= 0;
            active_anode <= (active_anode == 2'd3) ? 2'd0 : active_anode + 1;
        end else begin
            counter <= counter + 1;
        end
    end

   
    always @(posedge clk) begin
        if (sw10) store_B <= sw;
        else if(sw11) store_C <= sw;
    end

    always @(posedge clk) sw_sync0 <= sw12;
    always @(posedge clk) sw_sync1 <= sw_sync0;

    reg sw12_debounced;
    always @(posedge clk) begin
        if(sw_sync1 == sw12_debounced) counter2 <= 0;
        else begin
            counter2 <= counter2 + 1;
            if(counter2 == {WIDTH{1'b1}}) begin
                sw12_debounced <= sw_sync1;
                counter2 <= 0;
            end
        end
    end

 
    assign sw12_rising = sw12_debounced & ~sw12_delayed;
    always @(posedge clk) sw12_delayed <= sw12_debounced;

    
    reg BTNC_sync0, BTNC_sync1;
    reg rst_debounced;
    reg [WIDTH-1:0] BTNC_counter = 0;

    always @(posedge clk) BTNC_sync0 <= BTNC;
    always @(posedge clk) BTNC_sync1 <= BTNC_sync0;

    always @(posedge clk) begin
        if(BTNC_sync1 == rst_debounced) BTNC_counter <= 0;
        else begin
            BTNC_counter <= BTNC_counter + 1;
            if(BTNC_counter == {WIDTH{1'b1}}) begin
                rst_debounced <= BTNC_sync1;
                BTNC_counter <= 0;
            end
        end
    end

  
    always @(posedge clk) begin
        if(rst_debounced) begin
            store_A <= 16'b0;
            overflow <= 1'b0;
        end
        else if(sw12_rising) begin
            if(sum > 16'hFFFF) begin
                store_A <= 16'b0;
                overflow <= 1'b1;
            end else begin
                store_A <= sum[15:0];
                overflow <= 1'b0;
            end
        end
    end

    
    always @(*) led = store_A;


    assign an0 = ~(active_anode == 2'd0);
    assign an1 = ~(active_anode == 2'd1);
    assign an2 = ~(active_anode == 2'd2);
    assign an3 = ~(active_anode == 2'd3);

   
    
    reg [6:0] seg;
    reg [3:0] current_digit_index; 
    reg [6:0] seg_digits [3:0];
    reg [16:0] seg_counter; 

    always @(*) begin
        if(rst_debounced) begin
            seg_digits[3] = 7'b1111110; // '-'
            seg_digits[2] = 7'b1111010; // r
            seg_digits[1] = 7'b0100100; // S
            seg_digits[0] = 7'b1110000; // t
        end else if(overflow) begin
            seg_digits[3] = 7'b0000001; // O
            seg_digits[2] = 7'b0111000; // F
            seg_digits[1] = 7'b1110001; // L
            seg_digits[0] = 7'b0000001; // O
        end else begin
           
            seg_digits[3] = 7'b1111111; 
            seg_digits[2] = 7'b1111111;
            seg_digits[1] = 7'b1111111;
            seg_digits[0] = 7'b1111111;
        end
    end

    
    always @(*) begin
        case(active_anode)
            2'd0: seg = seg_digits[0];
            2'd1: seg = seg_digits[1];
            2'd2: seg = seg_digits[2];
            2'd3: seg = seg_digits[3];
            default: seg = 7'b1111111; 
        endcase
    end

    
    assign {a,b,c,d,e,f,g} = seg;

endmodule
