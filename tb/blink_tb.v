// blink_tb.v
//
// Self-checking testbench for rtl/blink.v.
// Run with Icarus Verilog (iverilog + vvp), no hardware required.
// Verifies: reset behaviour and that the LED output toggles after
// one full counter period.

`timescale 1ns/1ps

module blink_tb;

    // Use a small counter width in simulation so it finishes in a
    // reasonable number of simulated clock edges instead of 2^24.
    localparam integer SIM_COUNTER_WIDTH = 8;

    reg  clk   = 0;
    reg  btn_n = 1;
    wire led_n;

    blink #(
        .COUNTER_WIDTH(SIM_COUNTER_WIDTH)
    ) dut (
        .clk_i   (clk),
        .btn_n_i (btn_n),
        .led_n_o (led_n)
    );

    // 25 MHz board clock -> 40 ns period.
    always #20 clk = ~clk;

    integer half_periods_seen;

    initial begin
        $dumpfile("blink_tb.vcd");
        $dumpvars(0, blink_tb);

        // Hold reset for a few cycles.
        btn_n = 0;
        repeat (5) @(posedge clk);
        if (led_n !== 1'b1) begin
            $display("TEST FAILED: LED not off (led_n=1) during/after reset, got led_n=%b", led_n);
            $finish;
        end
        btn_n = 1;

        // LED must turn on (led_n=0) once the MSB of the counter sets...
        wait (led_n == 1'b0);
        $display("[%0t] LED ON  (led_n=0)", $time);

        // ...and back off once it wraps again.
        wait (led_n == 1'b1);
        $display("[%0t] LED OFF (led_n=1) - one full blink period observed", $time);

        $display("TEST PASSED");
        $finish;
    end

    // Safety timeout so a stuck design doesn't hang the simulation.
    initial begin
        #200000;
        $display("TEST FAILED: timeout, LED did not toggle as expected");
        $finish;
    end

endmodule
