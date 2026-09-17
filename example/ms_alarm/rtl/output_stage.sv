module output_stage (
    input  logic alarm_enable,
    input  logic vdd,
    input  logic vss,
    output logic driver_out
);
    // Analog subcircuit: transistor-level gate and inverter chain.
    analog_output_driver u_driver (
        .en  (alarm_enable),
        .vout(driver_out),
        .vdd (vdd),
        .vss (vss)
    );
endmodule
