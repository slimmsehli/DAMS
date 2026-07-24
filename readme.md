
# Mixed-Signal Simulation Wrapper

This repository provides a small workflow for running mixed-signal simulations that combine analog SPICE netlists and digital Verilog modules. It is intended as a lightweight wrapper around ngspice for analog transient analysis and Verilator for digital simulation.

## What this repo contains

- [tests/analog](tests/analog) — sample analog SPICE testbench and netlist files.
  - [tests/analog/top.cir](tests/analog/top.cir) contains MOSFET models, inverter/buffer subcircuits, and an RC low-pass filter example.
- [tests/digital](tests/digital) — simple digital Verilog examples.
  - [tests/digital/dlatch.v](tests/digital/dlatch.v) defines a latch module.
  - [tests/digital/top.v](tests/digital/top.v) provides a small testbench that dumps a VCD waveform.
- [tests](tests) — helper scripts and build targets for running simulations and viewing waveforms.
  - [tests/Makefile](tests/Makefile) provides targets for analog and digital runs.
  - [tests/raw2vcd.py](tests/raw2vcd.py) converts ngspice raw output into a VCD file for GTKWave.
- [setup_ngspice.csh](setup_ngspice.csh), [setup_verilator.csh](setup_verilator.csh), and [setup.csh](setup.csh) — setup scripts for installing and configuring the required tools.

## Quick start

1. Install the toolchains:
   ```bash
   csh setup_ngspice.csh
   csh setup_verilator.csh
   ```

2. Load the environment:
   ```bash
   csh setup.csh
   ```

3. Run the analog SPICE simulation:
   ```bash
   make -C tests ng
   ```

4. Convert the generated raw file to VCD and view it:
   ```bash
   make -C tests ng_wave
   ```

5. Run the digital Verilator simulation:
   ```bash
   make -C tests verilator
   ```

6. View the digital waveform:
   ```bash
   make -C tests verilator_wave
   ```

## Notes

- The analog example uses ngspice and writes a raw file named sim.raw.
- The digital example uses Verilator and writes a VCD file named sim.vcd.
- If you want to inspect a converted waveform manually, you can run:
  ```bash
  python3 tests/raw2vcd.py tests/sim.raw tests/sim.vcd
  ```

## Repository layout

```text
simulator/
├── setup.csh
├── setup_ngspice.csh
├── setup_verilator.csh
├── tests/
│   ├── analog/
│   │   └── top.cir
│   ├── digital/
│   │   ├── dlatch.v
│   │   └── top.v
│   ├── Makefile
│   └── raw2vcd.py
└── readme.md
```
