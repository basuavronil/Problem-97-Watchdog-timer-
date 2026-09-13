`timescale 1ns / 1ps

module watchdog_timer_tb;

    reg        clk;
    reg        rst_n;
    reg        enable;
    reg        kick;
    reg [15:0] timeout_val;
    wire       wdt_reset;

    // Instantiate Unit Under Test (UUT)
    watchdog_timer uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .kick(kick),
        .timeout_val(timeout_val),
        .wdt_reset(wdt_reset)
    );

    // Clock Generation (10ns Period)
    always #5 clk = ~clk;

    integer errors = 0;

    initial begin
        // Initialize Signals
        clk         = 0;
        rst_n       = 0;
        enable      = 0;
        kick        = 0;
        timeout_val = 16'd10; // Set timeout to 10 clock cycles

        $display("=================================================");
        $display("   Testing 16-bit Watchdog Timer                 ");
        $display("=================================================");

        #15 rst_n = 1; enable = 1;
        @(posedge clk);

        // Test 1: Periodic Kicking (Normal Operation)
        repeat (3) begin
            #40; // Wait 4 clock cycles
            kick <= 1'b1;
            @(posedge clk);
            kick <= 1'b0;
        end

        if (wdt_reset !== 1'b0) begin
            $display("[ERROR] Test 1 Failed! Reset triggered during normal kicking.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 1: Normal operation verified (Periodic kicks prevent reset).");
        end

        // Test 2: System Hang (Stop kicking and allow timeout)
        $display("[INFO]  Simulating CPU Hang (kicking stopped)...");
        #120; // Exceed timeout limit (100ns)

        if (wdt_reset !== 1'b1) begin
            $display("[ERROR] Test 2 Failed! Watchdog failed to assert reset on timeout.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 2: System reset triggered successfully on timeout!");
        end

        // Final Summary
        if (errors == 0)
            $display("SUCCESS: All Watchdog Timer tests passed!");
        else
            $display("FAILURE: Total Errors = %0d", errors);

        $finish;
    end

endmodule
