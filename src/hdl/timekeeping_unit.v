module timekeeping_unit (
    input clk,
    input reset,
    input tick_1hz,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hours
);

    always @(posedge clk) begin
        if (reset) begin
            seconds <= 0;
            minutes <= 0;
            hours <= 0;
        end else if (tick_1hz) begin
            if (seconds == 59) begin
                seconds <= 0;
                if (minutes == 59) begin
                    minutes <= 0;
                    if (hours == 23) begin
                        hours <= 0;
                    end else begin
                        hours <= hours + 1;
                    end
                end else begin
                    minutes <= minutes + 1;
                end
            end else begin
                seconds <= seconds + 1;
            end
        end
    end

endmodule
