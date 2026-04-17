module alu_datapath (
    input [4:0] hours,
    input [5:0] minutes,
    input [5:0] seconds,
    input [3:0] sw,
    input btnC,
    input clk,
    input reset,
    input tick_1hz,
    input state, // 0: IDLE, 1: FEEDING
    output match_flag,
    output done_flag,
    output reg [4:0] feed_timer
);

    wire m0, m1, m2, m3;

    // Time matches for 08:00, 12:00, 17:00, 21:00
    // We add seconds == 0 to ensure it only triggers once at the start of the minute.
    assign m0 = (hours == 5'd8)  && (minutes == 6'd0) && (seconds == 6'd0);
    assign m1 = (hours == 5'd12) && (minutes == 6'd0) && (seconds == 6'd0);
    assign m2 = (hours == 5'd17) && (minutes == 6'd0) && (seconds == 6'd0);
    assign m3 = (hours == 5'd21) && (minutes == 6'd0) && (seconds == 6'd0);

    assign match_flag = (m0 & sw[0]) | (m1 & sw[1]) | (m2 & sw[2]) | (m3 & sw[3]) | btnC;

    assign done_flag = (feed_timer == 5'd0);

    reg prev_state;
    always @(posedge clk) begin
        if (reset) begin
            feed_timer <= 0;
            prev_state <= 0;
        end else begin
            prev_state <= state;
            
            // On entry to FEEDING state, load timer with 10
            if (state == 1 && prev_state == 0) begin
                feed_timer <= 5'd10;
            end 
            // While in FEEDING state, decrement timer every second
            else if (state == 1 && tick_1hz) begin
                if (feed_timer > 0)
                    feed_timer <= feed_timer - 1;
            end
        end
    end

endmodule
