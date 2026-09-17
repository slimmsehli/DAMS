# Mixed-Signal Threshold Alarm Example

This is the reference RTL input for the AMS-wrapper elaboration milestone. It describes a sensor alarm that filters and thresholds a sensor signal in analogue circuitry, synchronizes and debounces the resulting alarm request digitally, then drives an analogue output stage.

## Digital hierarchy

```text
ms_alarm_top
├── u_frontend : sensor_frontend
│   ├── u_filter : analog_rc_filter       [analog placeholder]
│   └── u_threshold : analog_schmitt_inv  [analog placeholder]
├── u_controller : alarm_controller
│   ├── u_synchronizer : synchronizer
│   │   ├── u_stage1 : dff
│   │   └── u_stage2 : dff
│   ├── u_debounce : debounce_filter
│   │   ├── u_counter : counter
│   │   └── u_comparator : comparator
│   └── u_alarm_latch : alarm_latch
└── u_output : output_stage
    └── u_driver : analog_output_driver  [analog placeholder]
```

## Boundary candidates

| Instance path | SPICE subcircuit | Expected boundary role |
|---|---|---|
| `ms_alarm_top.u_frontend.u_filter` | `rc_filter` | Analog input and output path |
| `ms_alarm_top.u_frontend.u_threshold` | `schmitt_inv` | `vout` is A2D |
| `ms_alarm_top.u_output.u_driver` | `output_driver` | `en` is D2A |

`rtl/design.f` is the Verilog file list. The analogue placeholder modules are intentionally empty: they let a digital frontend elaborate the hierarchy now, and will later be replaced by generated views driven by the boundary manifest.
