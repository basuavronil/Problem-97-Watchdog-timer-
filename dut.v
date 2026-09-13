module watchdog_timer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire        kick,
    input  wire [15:0] timeout_val,
    output wire        wdt_reset
);

    // Internal Registers
    reg [15:0] counter;
    reg        reset_reg;

    // Drive output from internal register
    assign wdt_reset = reset_reg;

    // Watchdog Timer Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= timeout_val;
            reset_reg <= 1'b0;
        end else if (enable) begin
            if (kick) begin
                counter   <= timeout_val; // Petting/kicking the watchdog
                reset_reg <= 1'b0;
            end else if (counter == 16'd0) begin
                reset_reg <= 1'b1;        // Trigger system reset on underflow
            end else begin
                counter   <= counter - 1'b1;
            end
        end else begin
            counter   <= timeout_val;
            reset_reg <= 1'b0;
        end
    end

endmodule
