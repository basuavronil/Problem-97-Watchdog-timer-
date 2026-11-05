`timescale 1ns / 1ps

module tb_watchdog_timer;

    // Testbench signals
    reg        clk;
    reg        rst_n;
    reg        enable;
    reg        kick;
    reg [15:0] timeout_val;
    wire       timeout;

    // Instantiate the Unit Under Test (UUT)
    watchdog_timer uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .kick(kick),
        .timeout_val(timeout_val),
        .timeout(timeout)
    );

    // Generate Clock: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk         = 1'b0;
        rst_n       = 1'b0;
        enable      = 1'b0;
        kick        = 1'b0;
        timeout_val = 16'd5; // Short timeout for fast simulation

        // Apply Reset
        #20;
        rst_n = 1'b1;
        #10;

        $display("[%0t] Starting Watchdog Testbench...", $time);

        // Test 1: Enable watchdog and let it count down to timeout
        enable = 1'b1;
        
        // Wait long enough for counter (5) to reach 0 and assert timeout
        // 5 cycles * 10ns = 50ns, plus a bit more
        #70;
        
        if (timeout) 
            $display("[%0t] PASSED: Watchdog successfully timed out.", $time);
        else 
            $error("[%0t] FAILED: Watchdog did not time out.", $time);

        // Test 2: Software kick (reload) before timeout occurs
        $display("[%0t] Testing software kick...", $time);
        rst_n = 1'b0; // Reset state
        #10;
        rst_n = 1'b1;
        #10;

        // Kick repeatedly before it hits zero
        repeat (3) begin
            kick = 1'b1;
            #10;
            kick = 1'b0;
            #20; // Wait 2 cycles, less than timeout_val (5)
        end

        // Ensure timeout stayed low during frequent kicks
        if (!timeout) 
            $display("[%0t] PASSED: Watchdog prevented timeout via kicks.", $time);
        else 
            $error("[%0t] FAILED: Watchdog expired despite being kicked.", $time);

        // Test 3: Disable functionality
        $display("[%0t] Testing disable state...", $time);
        enable = 1'b0;
        #50;

        $display("[%0t] Testbench finished.", $time);
        $finish;
    end

endmodule
