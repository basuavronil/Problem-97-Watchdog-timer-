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

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, watchdog_timer_tb);
  end
    end

    // Clock Generation (10ns Period)
    always #5 clk = ~clk;

    integer errors = 0;

    initial begin
        // 1. Initialize Signals
        clk         = 0;
        rst_n       = 0;
        enable      = 0;
        kick        = 0;
        timeout_val = 16'd5; // Set short timeout (5 clock cycles)

        $display("=================================================");
        $display("   Testing Watchdog Timer (Direct output reg)    ");
        $display("=================================================");

        // 2. Hardware Reset
        #15 rst_n = 1; enable = 1;
        @(posedge clk);

        // Test 1: Periodic Kicking
        repeat (3) begin
            #20;
            kick <= 1'b1;
            @(posedge clk);
            kick <= 1'b0;
        end

        if (wdt_reset !== 1'b0) begin
            $display("[ERROR] Test 1 Failed! wdt_reset triggered during normal software kicking.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 1: Normal kicking operation verified successfully.");
        end

        // Test 2: Software Hang (Stop kicking)
        $display("[INFO]  Simulating Software Hang (kicking stopped)...");
        #70; // Exceed 5-cycle timeout (50ns)

        if (wdt_reset !== 1'b1) begin
            $display("[ERROR] Test 2 Failed! wdt_reset failed to trigger on underflow.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 2: Hardware reset (wdt_reset = 1) asserted on timeout!");
        end

        // Test 3: Clear Reset on Kick
        @(posedge clk);
        kick <= 1'b1;
        @(posedge clk);
        kick <= 1'b0;

        if (wdt_reset !== 1'b0) begin
            $display("[ERROR] Test 3 Failed! wdt_reset did not clear after software kick.");
            errors = errors + 1;
        end else begin
            $display("[PASS]  Test 3: wdt_reset cleared after soft recovery kick.");
        end

        // Final Summary
        if (errors == 0)
            $display("SUCCESS: All Watchdog Timer tests passed!");
        else
            $display("FAILURE: Total Errors = %0d", errors);

        $finish;
    end

endmodule
