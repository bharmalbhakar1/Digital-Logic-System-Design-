module MAC(
    input wire clk,
    input wire rst,
    input wire load_b_en,
    input wire load_c_en,
    input wire accum_en,
    input wire [7:0] data_in,
    output reg [15:0] result_out,
    output reg overflow
);

    reg [7:0] store_B, store_C;
    wire [16:0] sum;

    assign product = store_B * store_C;
    assign sum = {1'b0, result_out} + {1'b0, product};

    always @(posedge clk) begin
        if (rst) begin
            result_out <= 16'd0;
            store_B    <= 8'd0;
            store_C    <= 8'd0;
            overflow   <= 1'b0;
        end else begin
            if (load_b_en) begin
                store_B <= data_in;
            end

            if (load_c_en) begin
                store_C <= data_in;
            end

            if (accum_en) begin
                result_out <= sum[15:0];
                if (sum[16]) begin
                    overflow <= 1'b1;
                end
            end
        end
    end
endmodule