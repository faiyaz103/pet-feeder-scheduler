module display_controller (
    input clk,
    input reset,
    input tick_1khz,
    input [4:0] hours,
    input [5:0] minutes,
    input display_mode, // 0: TIME, 1: FEED
    output reg [6:0] seg,
    output reg [3:0] an
);

    reg [1:0] digit_select;
    
    // Multiplexing counter
    always @(posedge clk) begin
        if (reset) begin
            digit_select <= 0;
        end else if (tick_1khz) begin
            digit_select <= digit_select + 1;
        end
    end

    // Anode selection (Active LOW)
    always @(*) begin
        case (digit_select)
            2'b00: an = 4'b1110; // Digit 0 (Rightmost)
            2'b01: an = 4'b1101;
            2'b12: an = 4'b1011;
            2'b11: an = 4'b0111; // Digit 3 (Leftmost)
            default: an = 4'b1111;
        endcase
    end

    // BCD conversion for hours and minutes
    wire [3:0] h_tens, h_units, m_tens, m_units;
    assign h_tens = hours / 10;
    assign h_units = hours % 10;
    assign m_tens = minutes / 10;
    assign m_units = minutes % 10;

    reg [3:0] current_digit_val;
    always @(*) begin
        case (digit_select)
            2'b00: current_digit_val = m_units;
            2'b01: current_digit_val = m_tens;
            2'b10: current_digit_val = h_units;
            2'b11: current_digit_val = h_tens;
            default: current_digit_val = 0;
        endcase
    end

    // 7-segment segment decoder (Active LOW)
    // Bits: gfedcba (seg[6] to seg[0])
    function [6:0] decode_digit(input [3:0] val);
        case (val)
            4'd0: decode_digit = 7'b1000000;
            4'd1: decode_digit = 7'b1111001;
            4'd2: decode_digit = 7'b0100100;
            4'd3: decode_digit = 7'b0110000;
            4'd4: decode_digit = 7'b0011001;
            4'd5: decode_digit = 7'b0010010;
            4'd6: decode_digit = 7'b0000010;
            4'd7: decode_digit = 7'b1111000;
            4'd8: decode_digit = 7'b0000000;
            4'd9: decode_digit = 7'b0010000;
            default: decode_digit = 7'b1111111;
        endcase
    endfunction

    // FEED pattern (Active LOW)
    // 'F': a,e,f,g ON -> abc defg = 011 1000 -> 7'b0111000
    // 'E': a,d,e,f,g ON -> abc defg = 011 0000 -> 7'b0110000
    // 'D': b,c,d,e,g ON -> abc defg = 100 0000 -> 7'b1000000 (roughly d)
    // Actually let's use a clear 'D' shape: b,c,d,e,g = 100 0000
    parameter SEG_F = 7'b0111000;
    parameter SEG_E = 7'b0110000;
    parameter SEG_D = 7'b1000010; // b,c,d,e,g are 0. a, f are 1.

    always @(*) begin
        if (display_mode == 1) begin
            case (digit_select)
                2'b00: seg = SEG_D;
                2'b01: seg = SEG_E;
                2'b10: seg = SEG_E;
                2'b11: seg = SEG_F;
                default: seg = 7'b1111111;
            endcase
        end else begin
            seg = decode_digit(current_digit_val);
        end
    end

endmodule
