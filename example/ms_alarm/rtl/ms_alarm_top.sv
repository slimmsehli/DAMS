module ms_alarm_top (
    input  logic clk,
    input  logic rst_n,
    input  logic sensor_raw,
    output logic alarm,
    output logic driver_out
);
    logic vdd;
    logic vss;
    logic threshold_async;

    // These constants stand in for the eventual analog supply rails.
    assign vdd = 1'b1;
    assign vss = 1'b0;

    sensor_frontend u_frontend (
        .sensor_raw      (sensor_raw),
        .vdd             (vdd),
        .vss             (vss),
        .threshold_async (threshold_async)
    );

    alarm_controller u_controller (
        .clk             (clk),
        .rst_n           (rst_n),
        .threshold_async (threshold_async),
        .alarm           (alarm)
    );

    output_stage u_output (
        .alarm_enable (alarm),
        .vdd          (vdd),
        .vss          (vss),
        .driver_out   (driver_out)
    );
endmodule
