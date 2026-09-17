module alarm_controller #(
    parameter int DEBOUNCE_COUNT_WIDTH = 3
) (
    input  logic clk,
    input  logic rst_n,
    input  logic threshold_async,
    output logic alarm
);
    logic threshold_sync;
    logic threshold_stable;

    synchronizer u_synchronizer (
        .clk       (clk),
        .rst_n     (rst_n),
        .async_in  (threshold_async),
        .sync_out  (threshold_sync)
    );

    debounce_filter #(.COUNT_WIDTH(DEBOUNCE_COUNT_WIDTH)) u_debounce (
        .clk         (clk),
        .rst_n       (rst_n),
        .noisy_in    (threshold_sync),
        .stable_high (threshold_stable)
    );

    alarm_latch u_alarm_latch (
        .clk   (clk),
        .rst_n (rst_n),
        .set   (threshold_stable),
        .alarm (alarm)
    );
endmodule
