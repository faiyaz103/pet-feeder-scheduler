module pet_feeder_top #(
    parameter DIV_1HZ = 99_999_999,
    parameter DIV_1KHZ = 99_999
)(
    input clk,
    input reset,        // Map to btnU in XDC
    input btnC,         // Center button for manual override
    input [3:0] sw,     // Schedule enable switches
    output [6:0] seg,
    output [3:0] an,
    output motor_en,
    output led_status
);

    wire tick_1hz, tick_1khz;
    wire [5:0] seconds, minutes;
    wire [4:0] hours;
    wire match_flag, done_flag;
    wire state;
    wire [4:0] feed_timer;
    wire display_mode;

    // Clock Divider
    clock_divider #(
        .DIV_1HZ(DIV_1HZ),
        .DIV_1KHZ(DIV_1KHZ)
    ) clk_div (
        .clk(clk),
        .reset(reset),
        .tick_1hz(tick_1hz),
        .tick_1khz(tick_1khz)
    );

    // Timekeeping Unit
    timekeeping_unit timekeeper (
        .clk(clk),
        .reset(reset),
        .tick_1hz(tick_1hz),
        .seconds(seconds),
        .minutes(minutes),
        .hours(hours)
    );

    // ALU Datapath
    alu_datapath alu (
        .hours(hours),
        .minutes(minutes),
        .seconds(seconds),
        .sw(sw),
        .btnC(btnC),
        .clk(clk),
        .reset(reset),
        .tick_1hz(tick_1hz),
        .state(state),
        .match_flag(match_flag),
        .done_flag(done_flag),
        .feed_timer(feed_timer)
    );

    // FSM Control Unit
    fsm_control_unit fsm (
        .clk(clk),
        .reset(reset),
        .match_flag(match_flag),
        .done_flag(done_flag),
        .state(state),
        .motor_en(motor_en),
        .led_status(led_status),
        .display_mode(display_mode)
    );

    // Display Controller
    display_controller display (
        .clk(clk),
        .reset(reset),
        .tick_1khz(tick_1khz),
        .hours(hours),
        .minutes(minutes),
        .display_mode(display_mode),
        .seg(seg),
        .an(an)
    );

endmodule
