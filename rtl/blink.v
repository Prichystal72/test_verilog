// blink.v
//
// Minimal test design for the Colorlight 5A-75B (v8.0) board.
// Divides the 25 MHz board clock down and drives the onboard DATA_LED.
// Purpose: exercise the whole open-source ECP5 toolchain
// (Yosys -> nextpnr-ecp5 -> ecppack) even without physical hardware.
//
// Board pins used (see constraints/colorlight_5a75b_v8.lpf):
//   clk_i    -> P6  (25 MHz oscillator, fixed on-board)
//   btn_n_i  -> R7  (KEY+ push button, active low, has pull-up)
//   led_n_o  -> T6  (DATA_LED, active low / open-drain)

module blink #(
    parameter integer COUNTER_WIDTH = 24 // ~2 Hz blink @ 25 MHz on bit[23]
) (
    input  wire clk_i,
    input  wire btn_n_i,
    output wire led_n_o
);

    reg [COUNTER_WIDTH-1:0] counter = {COUNTER_WIDTH{1'b0}};

    always @(posedge clk_i) begin
        if (btn_n_i)
            counter <= {COUNTER_WIDTH{1'b0}};
        else
            counter <= counter + 1'b1;
    end

    // DATA_LED is active-low, so invert the MSB of the counter.
    assign led_n_o = ~counter[COUNTER_WIDTH-1];

endmodule
