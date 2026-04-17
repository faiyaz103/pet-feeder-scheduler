module fsm_control_unit (
    input clk,
    input reset,
    input match_flag,
    input done_flag,
    output reg state, // 0: IDLE, 1: FEEDING
    output motor_en,
    output led_status,
    output display_mode
);

    parameter IDLE = 1'b0;
    parameter FEEDING = 1'b1;

    // FSM State Transition
    // We use a small delay or check to ensure done_flag doesn't trigger 
    // on the very first cycle of FEEDING when timer is still 0.
    reg [3:0] startup_delay; 

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            startup_delay <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (match_flag) begin
                        state <= FEEDING;
                        startup_delay <= 0;
                    end
                end
                FEEDING: begin
                    if (startup_delay < 4'd10) begin
                        startup_delay <= startup_delay + 1;
                    end else if (done_flag) begin
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    // Moore Machine Outputs
    assign motor_en     = (state == FEEDING);
    assign led_status   = (state == FEEDING);
    assign display_mode = (state == FEEDING);

endmodule
