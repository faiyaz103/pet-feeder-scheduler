module button_debouncer (
    input clk,
    input btn_in,
    output reg btn_out
);

    parameter COUNT_MAX = 2_000_000; // 20ms at 100MHz

    reg [20:0] count;
    reg btn_sync_0, btn_sync_1;

    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end

    always @(posedge clk) begin
        if (btn_sync_1 == btn_out) begin
            count <= 0;
        end else begin
            count <= count + 1;
            if (count == COUNT_MAX) begin
                btn_out <= btn_sync_1;
                count <= 0;
            end
        end
    end

endmodule
