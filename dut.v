module watchdog_timer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire        kick,
    input  wire [15:0] timeout_val,
    output reg         wdt_reset
);

    // Internal Counter Register
    reg [15:0] counter;

    // Sequential Watchdog Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= timeout_val;
            wdt_reset <= 1'b0;
        end else if (enable) begin
            if (kick) begin
                counter   <= timeout_val; // Software kick: reload counter
                wdt_reset <= 1'b0;
            end else if (counter == 16'd0) begin
                wdt_reset <= 1'b1;        // Underflow: assert hardware reset directly
            end else begin
                counter   <= counter - 1'b1; // Normal countdown
            end
        end else begin
            counter   <= timeout_val;
            wdt_reset <= 1'b0;
        end
    end

endmodule
