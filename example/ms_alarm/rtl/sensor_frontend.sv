module sensor_frontend (
    input  logic sensor_raw,
    input  logic vdd,
    input  logic vss,
    output logic threshold_async
);
    logic sensor_filtered;

    // Analog subcircuit: RC filtering of the sensor input.
    analog_rc_filter u_filter (
        .vin (sensor_raw),
        .vout(sensor_filtered),
        .vss (vss)
    );

    // Analog subcircuit: hysteretic threshold detector.
    analog_schmitt_inv u_threshold (
        .vin (sensor_filtered),
        .vout(threshold_async),
        .vdd (vdd),
        .vss (vss)
    );
endmodule
