module clock_divider (
    input clk,          // 100 MHz
    input reset,        // Active-high synchronous reset
    output reg tick_1hz,
    output reg tick_1khz
);

    parameter DIV_1HZ = 99_999_999;
    parameter DIV_1KHZ = 99_999;

    reg [26:0] count_1hz;
    reg [16:0] count_1khz;

    always @(posedge clk) begin
        if (reset) begin
            count_1hz <= 0;
            tick_1hz <= 0;
        end else if (count_1hz == DIV_1HZ) begin
            count_1hz <= 0;
            tick_1hz <= 1;
        end else begin
            count_1hz <= count_1hz + 1;
            tick_1hz <= 0;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            count_1khz <= 0;
            tick_1khz <= 0;
        end else if (count_1khz == DIV_1KHZ) begin
            count_1khz <= 0;
            tick_1khz <= 1;
        end else begin
            count_1khz <= count_1khz + 1;
            tick_1khz <= 0;
        end
    end

endmodule
