module watchdog_timer (
    input clk, rst_n, enable, kick,
    input [15:0] ini_seed_time,
    output reg         timeout  // Renamed to timeout
);   
    // Internal Counter Register
    reg [15:0] counter;   
    
    // Sequential Watchdog Logic   
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= ini_seed_time;
            timeout <= 1'b0;
        end else if (enable) begin
            if (kick) begin   
                counter <= ini_seed_time; // Software kick: reload counter   
                timeout <= 1'b0;
            end else if (counter == 16'd0) begin
                timeout <= 1'b1;        // Underflow: assert timeout indicator
            end else begin
                counter <= counter - 1'b1; // Normal countdown
            end
        end else begin
            counter <= ini_seed_time;
            timeout <= 1'b0;
        end
    end
endmodule
