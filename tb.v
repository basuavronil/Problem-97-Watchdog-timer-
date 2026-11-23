`timescale 1ns/1ps

module tb_watchdog_timer;

    // Testbench signals
    reg         clk;
    reg         rst_n;
    reg         enable;
    reg         kick;
    reg  [15:0] ini_seed_time;
    wire        timeout;

    // Instantiate the Device Under Test (DUT)
    watchdog_timer dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .kick(kick),
        .ini_seed_time(ini_seed_time),
        .timeout(timeout)
    );

    // 100 MHz clock -> 10 ns period (toggle every 5 ns)
    always #5 clk = ~clk;

    initial begin
        // Optional waveform dump for GTKWave / simulator viewers
        $dumpfile("watchdog_timer.vcd");
        $dumpvars(0, tb_watchdog_timer);

        // Initialize signals
        clk = 1'b0;
        rst_n = 1'b0;
        enable = 1'b0;
        kick = 1'b0;
        ini_seed_time = 16'd5;

        // 1. Hold reset low, then release
        #12;
        rst_n = 1'b1;

        // 2. Stay disabled for a few cycles (counter stays at ini_seed_time, timeout stays 0)
        @(posedge clk);
        @(posedge clk);

        // 3. Enable timer and let it count down partway, then kick it
        enable = 1'b1;
        repeat (3) @(posedge clk);

        @(negedge clk);
        kick = 1'b1;
        @(negedge clk);
        kick = 1'b0;

        // 4. Let it count all the way down to 0 so timeout goes high
        repeat (7) @(posedge clk);

        // 5. Kick it after timeout to clear timeout and reload ini_seed_time
        @(negedge clk);
        kick = 1'b1;
        @(negedge clk);
        kick = 1'b0;

        // 6. Let it time out again, then disable it to clear timeout
        repeat (7) @(posedge clk);

        @(negedge clk);
        enable = 1'b0;
        repeat (2) @(posedge clk);

        // 7. Test asynchronous reset while enabled
        @(negedge clk);
        enable = 1'b1;
        repeat (2) @(posedge clk);
        #2 rst_n = 1'b0; // Assert mid-cycle to check async behavior
        #6 rst_n = 1'b1;

        repeat (2) @(posedge clk);
        $finish;
    end

    // Print state changes so you can easily trace what happens
    always @(posedge clk or negedge rst_n) begin
        $display("t=%0t | rst_n=%b en=%b kick=%b seed=%0d cnt=%0d -> timeout=%b",
                 $time, rst_n, enable, kick, ini_seed_time, dut.counter, timeout);
    end

endmodule
