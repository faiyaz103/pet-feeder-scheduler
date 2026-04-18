module pet_feeder_top #(
    parameter DIV_1HZ = 99_999_999,
    parameter DIV_1KHZ = 99_999
)(
    input clk,
    input btnC,         // Center button for manual override
    input [15:0] sw,    // SW[15]=Reset, SW[14]=SelfTest, SW[3:0]=Schedule
    output [6:0] seg,
    output [3:0] an,
    output motor_en,
    output led_status,
    output led_heartbeat // Toggles every second
);

    wire tick_1hz, tick_1khz;
    wire [5:0] seconds, minutes;
    wire [4:0] hours;
    wire match_flag, done_flag;
    wire state;
    wire [4:0] feed_timer;
    wire display_mode;
    
    wire reset_debounced, btnC_debounced;
    reg heartbeat_reg;

    // Button & Switch Debouncers
    // Reset uses SW15 now
    button_debouncer db_reset (
        .clk(clk),
        .btn_in(sw[15]),
        .btn_out(reset_debounced)
    );

    button_debouncer db_btnC (
        .clk(clk),
        .btn_in(btnC),
        .btn_out(btnC_debounced)
    );

    always @(posedge clk) begin
        if (reset_debounced)
            heartbeat_reg <= 0;
        else if (tick_1hz)
            heartbeat_reg <= ~heartbeat_reg;
    end

    assign led_heartbeat = heartbeat_reg;

    // Clock Divider
    clock_divider #(
        .DIV_1HZ(DIV_1HZ),
        .DIV_1KHZ(DIV_1KHZ)
    ) clk_div (
        .clk(clk),
        .reset(reset_debounced),
        .tick_1hz(tick_1hz),
        .tick_1khz(tick_1khz)
    );

    // Timekeeping Unit
    timekeeping_unit timekeeper (
        .clk(clk),
        .reset(reset_debounced),
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
        .sw(sw[3:0]), // Use lower switches for schedule
        .btnC(btnC_debounced),
        .clk(clk),
        .reset(reset_debounced),
        .tick_1hz(tick_1hz),
        .state(state),
        .match_flag(match_flag),
        .done_flag(done_flag),
        .feed_timer(feed_timer)
    );

    // FSM Control Unit
    fsm_control_unit fsm (
        .clk(clk),
        .reset(reset_debounced),
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
        .reset(reset_debounced),
        .tick_1khz(tick_1khz),
        .hours(hours),
        .minutes(minutes),
        .display_mode(display_mode),
        .test_mode(sw[14]), // SW14 for self-test
        .seg(seg),
        .an(an)
    );

endmodule
