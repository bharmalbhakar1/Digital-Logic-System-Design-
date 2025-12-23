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

// this code includes the vec_dot_product
module vec_dot_product(
   input  wire [7:0] sw,
   input  wire sw8, sw9,
   input  wire sw12, sw13,
   input  wire sw14, sw15,
   input  wire clk, BTNC,
   output wire a,b,c,d,e,f,g,
   output reg an0,an1,an2,an3,
   output reg [15:0] led
);

    reg [7:0] vecA [3:0]; // stores the vector
    reg [7:0] vecB [3:0];

    localparam FSM_IDLE=3'd0, FSM_LOAD_A=3'd1, FSM_LOAD_B=3'd2, FSM_ACCUM=3'd3;
    // the keep track of which values to given to the mac for the calculation
    reg [2:0] state = FSM_IDLE; // idle state for FSM
    reg [2:0] index = 3'd0; // keps track of index which is to be multiplied in the mac 

    reg mac_load_b_en, mac_load_c_en, mac_accum_en;    //these are the variables which will used to communcate with the mac and the dot_product
    reg [7:0] mac_data_in;
    // this is the input data which is given to the mac

    wire [15:0] dot_product_result;
    wire mac_overflow; // flag for overflow 
    reg done= 0;       // flag when the vector is calculated once  

    // Instantiate the MAC from the assignment 4
    MAC mac_unit (
        .clk(clk),
        .rst(BTNC),
        .data_in(mac_data_in),
        .load_b_en(mac_load_b_en),
        .load_c_en(mac_load_c_en),
        .accum_en(mac_accum_en),
        .result_out(dot_product_result),
        .overflow(mac_overflow)
    );

    // led is set to the deot_product result which comes after calculation
    always @(posedge clk) begin
        led <= dot_product_result;
    end 
    

    // Vector Write Logic 
    always @(posedge clk) begin
        if (BTNC) {vecA[0],vecA[1],vecA[2],vecA[3],vecB[0],vecB[1],vecB[2],vecB[3]} <= 0;
        else begin
            if (sw12) vecA[{sw9,sw8}] <= sw; done <= 0;
            if (sw13) vecB[{sw9,sw8}] <= sw; done <= 0;
        end
    end

    // FSM State Transition Logic for the MAC to calculate
    always @(posedge clk) begin
        if (BTNC) {state, index} <= {FSM_IDLE, 2'd0};
        else if(~done) begin 
            case (state)
                FSM_IDLE:   state <= FSM_LOAD_A;
                FSM_LOAD_A: state <= FSM_LOAD_B;
                FSM_LOAD_B: state <= FSM_ACCUM;
                FSM_ACCUM:  if (index == 3'd4) begin 
                                 {state, index} <= {FSM_IDLE, 3'd0}; 
                                 done <= 1;       
                            end else {state, index} <= {FSM_LOAD_A, index + 1};
            endcase
        end
    end

    // FSM Output logic
    always @(*) begin
        // Default assignments
        mac_load_b_en = 1'b0;
        mac_load_c_en = 1'b0;
        mac_accum_en  = 1'b0;
        mac_data_in   = 8'd0;

        case(state)
            FSM_LOAD_A: begin
                if (index > 0) begin
                mac_data_in   = vecA[index-1];
                mac_load_b_en = 1'b1;
                end
            end
            FSM_LOAD_B: begin
            if (index > 0) begin
                mac_data_in   = vecB[index-1];
                mac_load_c_en = 1'b1;
                end
            end
            FSM_ACCUM: begin
                mac_accum_en  = 1'b1;
            end
        endcase
    end

    // 7-Segment Display Logic which show the value according to the digit overflow and reset 
    reg [19:0] refresh_counter = 0;
    reg [4:0] digit;
    reg [6:0] seg;

    always @(posedge clk) refresh_counter <= refresh_counter + 1;

    always @(*) begin
        {an3,an2,an1,an0} = 4'b1111; digit = 17;
        case(refresh_counter[19:18])
            2'b00: begin an0=0; if(BTNC) digit=20; else if(mac_overflow) digit=0; else if(sw14&sw15) digit=dot_product_result[3:0]; else if(sw14) digit=vecA[{sw9,sw8}][3:0]; else if(sw15) digit=vecB[{sw9,sw8}][3:0]; end
            2'b01: begin an1=0; if(BTNC) digit=5; else if(mac_overflow) digit=18; else if(sw14&sw15) digit=dot_product_result[7:4]; else if(sw14) digit=vecA[{sw9,sw8}][7:4]; else if(sw15) digit=vecB[{sw9,sw8}][7:4]; end
            2'b10: begin an2=0; if(BTNC) digit=19; else if(mac_overflow) digit=16; else if(sw14&sw15) digit=dot_product_result[11:8]; end
            2'b11: begin an3=0; if(BTNC) digit=15; else if(mac_overflow) digit=0; else if(sw14&sw15) digit=dot_product_result[15:12]; end
        endcase

        case(digit)
           4'h0: seg=7'b0000001; 4'h1: seg=7'b1001111; 4'h2: seg=7'b0010010; 4'h3: seg=7'b0000110;
           4'h4: seg=7'b1001100; 4'h5: seg=7'b0100100; 4'h6: seg=7'b0100000; 4'h7: seg=7'b0001111;
           4'h8: seg=7'b0000000; 4'h9: seg=7'b0000100; 4'hA: seg=7'b0001000; 4'hB: seg=7'b1100000;
           4'hC: seg=7'b0110001; 4'hD: seg=7'b1000010; 4'hE: seg=7'b0110000;
           5'd15: seg=7'b1111110; 5'd16: seg=7'b0111000; 5'd17: seg=7'b1111111; 5'd18: seg=7'b0111001;
           5'd19: seg=7'b0111110; 5'd20: seg=7'b1110000;
           default: seg=7'b1111111;
        endcase
    end
    assign {a,b,c,d,e,f,g} = seg;

endmodule